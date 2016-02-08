if program_section = 'code'
;=============================================================================
macro GET_BUFFER {
        mov rcx,[audio__render_client]
        mov edx,[audio__buffer_size_in_frames]
        lea r8,[.ptr+rsp]
        mov rax,[rcx]
        call [IAudioRenderClient.GetBuffer+rax]
        test eax,eax
        js .error }

macro RELEASE_BUFFER {
        mov rcx,[audio__render_client]
        mov edx,[audio__buffer_size_in_frames]
        xor r8d,r8d
        mov rax,[rcx]
        call [IAudioRenderClient.ReleaseBuffer+rax]
        test eax,eax
        js .error }

macro FILL_BUFFER {
        mov rcx,[audio__stream]
        mov rdx,[.ptr+rsp]
        mov r8d,[audio__buffer_size_in_frames]
        shl r8d,2
        lea r9,[.read_bytes+rsp]
        mov qword[k_funcparam5+rsp],0
        call [ReadFile] }
;=============================================================================
; out: eax - result
FALIGN
audio_play:
;-----------------------------------------------------------------------------
macro ACTIVATE_DEVICE {
        mov rcx,[audio__device]
        lea rdx,[IID_IAudioClient]
        mov r8d,CLSCTX_ALL
        xor r9d,r9d
        lea rax,[audio__client]
        mov [k_funcparam5+rsp],rax
        mov rax,[rcx]
        call [IMMDevice.Activate+rax]
        test eax,eax
        js .error }

macro INIT_CLIENT {
        mov rcx,[audio__client]
        mov edx,AUDCLNT_SHAREMODE_EXCLUSIVE
        mov r8d,AUDCLNT_STREAMFLAGS_EVENTCALLBACK
        mov r9,[.period+rsp]
        mov [k_funcparam5+rsp],r9
        lea rax,[.k_format]
        mov [k_funcparam6+rsp],rax
        mov qword[k_funcparam7+rsp],0
        mov rax,[rcx]
        call [IAudioClient.Initialize+rax] }

macro GET_BUFFER_SIZE {
        mov rcx,[audio__client]
        lea rdx,[audio__buffer_size_in_frames]
        mov rax,[rcx]
        call [IAudioClient.GetBufferSize+rax]
        test eax,eax
        js .error }

macro CREATE_EVENT {
        xor ecx,ecx
        xor edx,edx
        xor r8d,r8d
        mov r9d,EVENT_ALL_ACCESS
        call [CreateEventEx]
        test rax,rax
        jz .error }

virtual at 0
  rq 7
  .period dq ?
  .ptr dq ?
  .read_bytes dd ?,?
  align 32
  .k_stack_size = $+16
end virtual
        push rsi
        sub rsp,.k_stack_size
        vmovaps [rsp],ymm0
        mov rsi,rcx
        xor ecx,ecx
        call [CoInitialize]
        test eax,eax
        js .error
  ; device enumerator
        lea rcx,[CLSID_MMDeviceEnumerator]
        xor edx,edx
        mov r8d,CLSCTX_ALL
        lea r9,[IID_IMMDeviceEnumerator]
        lea rax,[audio__enumerator]
        mov [k_funcparam5+rsp],rax
        call [CoCreateInstance]
        test eax,eax
        js .error
  ; audio endpoint
        mov rcx,[audio__enumerator]
        mov edx,eRender
        mov r8d,eConsole
        lea r9,[audio__device]
        mov rax,[rcx]
        call [IMMDeviceEnumerator.GetDefaultAudioEndpoint+rax]
        test eax,eax
        js .error
        ACTIVATE_DEVICE
  ; check device support
        mov rcx,[audio__client]
        mov edx,AUDCLNT_SHAREMODE_EXCLUSIVE
        lea r8,[.k_format]
        xor r9d,r9d
        mov rax,[rcx]
        call [IAudioClient.IsFormatSupported+rax]
        test eax,eax
        js .error
  ; get device period
        mov rcx,[audio__client]
        xor edx,edx
        lea r8,[.period+rsp]
        mov rax,[rcx]
        call [IAudioClient.GetDevicePeriod+rax]
        test eax,eax
        js .error
  ; try to initialize audio client
        INIT_CLIENT
        test eax,eax
        jz .initialize_ok
        cmp eax,AUDCLNT_E_BUFFER_SIZE_NOT_ALIGNED
        jne .error
  ; compute new period and initialize again
        GET_BUFFER_SIZE
        vxorpd xmm0,xmm0,xmm0
        vcvtsi2sd xmm0,xmm0,[audio__buffer_size_in_frames]
        vmulsd xmm0,xmm0,[.k_10000000_0]
        vdivsd xmm0,xmm0,[.k_44100_0]
        vaddsd xmm0,xmm0,[.k_0_5]
        vcvttsd2si rax,xmm0
        mov [.period+rsp],rax
        mov rcx,[audio__client]
        mov rax,[rcx]
        call [IAudioClient.Release+rax]
        ACTIVATE_DEVICE
        INIT_CLIENT
        test eax,eax
        js .error
  .initialize_ok:
        CREATE_EVENT
        mov [audio__buffer_ready_event],rax
        CREATE_EVENT
        mov [audio__shutdown_event],rax
        mov rcx,[audio__client]
        mov rdx,[audio__buffer_ready_event]
        mov rax,[rcx]
        call [IAudioClient.SetEventHandle+rax]
        GET_BUFFER_SIZE
  ; get audio render client
        mov rcx,[audio__client]
        lea rdx,[IID_IAudioRenderClient]
        lea r8,[audio__render_client]
        mov rax,[rcx]
        call [IAudioClient.GetService+rax]
        test eax,eax
        js .error
  ; open audio file
        lea rcx,[.k_audio_file]
        mov edx,GENERIC_READ
        xor r8d,r8d
        xor r9d,r9d
        mov dword[k_funcparam5+rsp],OPEN_EXISTING
        mov dword[k_funcparam6+rsp],FILE_ATTRIBUTE_NORMAL+FILE_FLAG_SEQUENTIAL_SCAN
        mov qword[k_funcparam7+rsp],0
        call [CreateFile]
        cmp rax,INVALID_HANDLE_VALUE
        je .error
        mov [audio__stream],rax
  ; create audio thread
        xor ecx,ecx
        xor edx,edx
        lea r8,[audio__thread_func]
        xor r9d,r9d
        mov dword[k_funcparam5+rsp],0
        mov qword[k_funcparam6+rsp],0
        call [CreateThread]
        mov [audio__thread],rax
        test rax,rax
        jz .error
  ; load initial audio data
        GET_BUFFER
        FILL_BUFFER
        RELEASE_BUFFER
  ; start
        mov rcx,[audio__client]
        mov rax,[rcx]
        call [IAudioClient.Start+rax]
        test eax,eax
        js .error
  ; success
        mov eax,1
        add rsp,.k_stack_size
        pop rsi
        ret
  .error:
        xor eax,eax
        add rsp,.k_stack_size
        pop rsi
        ret
align 8
  .k_10000000_0 dq 10000000.0
  .k_44100_0 dq 44100.0
  .k_0_5 dq 0.5
  .k_format WAVEFORMATEX WAVE_FORMAT_PCM,2,44100,44100*4,4,16
  .k_audio_file db 'data/flis_amnestia.raw',0
purge ACTIVATE_DEVICE,INIT_CLIENT,GET_BUFFER_SIZE,CREATE_EVENT
;=============================================================================
FALIGN
audio_stop:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+16
        push rsi
        sub rsp,.k_stack_size
        mov rsi,rcx
        mov rcx,[audio__shutdown_event]
        test rcx,rcx
        jz @f
        call [SetEvent]
  @@:   mov rcx,[audio__thread]
        mov edx,INFINITE
        test rcx,rcx
        jz @f
        call [WaitForSingleObject]
  @@:   SAFE_CLOSE [audio__thread]
        mov rcx,[audio__client]
        test rcx,rcx
        jz @f
        mov rax,[rcx]
        call [IAudioClient.Stop+rax]
  @@:   SAFE_CLOSE [audio__stream]
        SAFE_CLOSE [audio__shutdown_event]
        SAFE_CLOSE [audio__buffer_ready_event]
        SAFE_RELEASE [audio__render_client]
        SAFE_RELEASE [audio__client]
        SAFE_RELEASE [audio__device]
        SAFE_RELEASE [audio__enumerator]
        add rsp,.k_stack_size
        pop rsi
        ret
;=============================================================================
FALIGN
audio__thread_func:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .ptr dq ?
  .read_bytes dd ?
  .task_index dd ?
  .wait_array dq ?,?
  align 32
  .k_stack_size = $+16
end virtual
        push rsi
        sub rsp,.k_stack_size
        mov rsi,rcx

        xor ecx,ecx
        call [CoInitialize]
        test eax,eax
        js .error

        lea rcx,[.k_task_name]
        mov [.task_index+rsp],0
        lea rdx,[.task_index+rsp]
        call [AvSetMmThreadCharacteristics]
        test rax,rax
        jz .error

        mov rax,[audio__shutdown_event]
        mov [.wait_array+rsp],rax
        mov rax,[audio__buffer_ready_event]
        mov [.wait_array+rsp+8],rax
  .play_loop:
        mov ecx,2
        lea rdx,[.wait_array+rsp]
        xor r8d,r8d
        mov r9d,INFINITE
        call [WaitForMultipleObjects]
        test eax,eax
        jz .error

        GET_BUFFER
        xor eax,eax
        mov edx,[audio__buffer_size_in_frames]
        mov rcx,[.ptr+rsp]
  @@:   mov dword[rcx+rax*4],0
        add eax,1
        cmp eax,edx
        jne @b

        FILL_BUFFER
        RELEASE_BUFFER

        mov eax,[audio__buffer_size_in_frames]
        shl eax,2
        cmp eax,[.read_bytes+rsp]
        jne .error
        jmp .play_loop
  .error:
        xor ecx,ecx
        call [ExitThread]
        ret
align 1
  .k_task_name db 'Playback',0

purge GET_BUFFER,RELEASE_BUFFER,FILL_BUFFER
;=============================================================================
else if program_section = 'data'

align 8
  audio__stream dq 0
  audio__thread dq 0
  audio__shutdown_event dq 0
  audio__buffer_ready_event dq 0
  audio__render_client dq 0
  audio__client dq 0
  audio__device dq 0
  audio__enumerator dq 0
  audio__buffer_size_in_frames dd 0,0

end if
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
