;=============================================================================
macro get_buffer {
        mov         rcx,[.audio.render_client+rsi]
        mov         edx,[.audio.buffer_size_in_frames+rsi]
        lea         r8,[.ptr+rsp]
        mov         rax,[rcx]
        call        [IAudioRenderClient.GetBuffer+rax]
        test        eax,eax
        js          .error }

macro release_buffer {
        mov         rcx,[.audio.render_client+rsi]
        mov         edx,[.audio.buffer_size_in_frames+rsi]
        xor         r8d,r8d
        mov         rax,[rcx]
        call        [IAudioRenderClient.ReleaseBuffer+rax]
        test        eax,eax
        js          .error }
;=============================================================================
; in: rcx - pointer to an audio_state structure
; out: eax - 1/0 succes/error
align 32
audio_play:
;-----------------------------------------------------------------------------
macro activate {
        mov         rcx,[.audio.device+rsi]
        lea         rdx,[IID_IAudioClient]
        mov         r8d,CLSCTX_ALL
        xor         r9d,r9d
        lea         rax,[.audio.client+rsi]
        mov         [k_funcparam5+rsp],rax
        mov         rax,[rcx]
        call        [IMMDevice.Activate+rax]
        test        eax,eax
        js          .error }

macro initialize {
        mov         rcx,[.audio.client+rsi]
        mov         edx,AUDCLNT_SHAREMODE_EXCLUSIVE
        mov         r8d,AUDCLNT_STREAMFLAGS_EVENTCALLBACK
        mov         r9,[.period+rsp]
        mov         [k_funcparam5+rsp],r9
        lea         rax,[.k_format]
        mov         [k_funcparam6+rsp],rax
        mov         qword[k_funcparam7+rsp],0
        mov         rax,[rcx]
        call        [IAudioClient.Initialize+rax] }

macro get_buf_size {
        mov         rcx,[.audio.client+rsi]
        lea         rdx,[.audio.buffer_size_in_frames+rsi]
        mov         rax,[rcx]
        call        [IAudioClient.GetBufferSize+rax]
        test        eax,eax
        js          .error }

macro create_event {
        xor         ecx,ecx
        xor         edx,edx
        xor         r8d,r8d
        mov         r9d,EVENT_ALL_ACCESS
        call        [CreateEventEx]
        test        rax,rax
        jz          .error }

virtual at 0
  .audio audio_state
end virtual
virtual at 0
  rq 7
  .period dq ?
  .ptr dq ?
  .read_bytes dd ?,?
  .k_stack_size = $
end virtual
        push        rsi
        sub         rsp,.k_stack_size
        mov         rsi,rcx
        xor         ecx,ecx
        call        [CoInitialize]
        test        eax,eax
        js          .error
        ; device enumerator
        lea         rcx,[CLSID_MMDeviceEnumerator]
        xor         edx,edx
        mov         r8d,CLSCTX_ALL
        lea         r9,[IID_IMMDeviceEnumerator]
        lea         rax,[.audio.enumerator+rsi]
        mov         [k_funcparam5+rsp],rax
        call        [CoCreateInstance]
        test        eax,eax
        js          .error
        ; audio endpoint
        mov         rcx,[.audio.enumerator+rsi]
        mov         edx,eRender
        mov         r8d,eConsole
        lea         r9,[.audio.device+rsi]
        mov         rax,[rcx]
        call        [IMMDeviceEnumerator.GetDefaultAudioEndpoint+rax]
        test        eax,eax
        js          .error
        activate
        ; check device support
        mov         rcx,[.audio.client+rsi]
        mov         edx,AUDCLNT_SHAREMODE_EXCLUSIVE
        lea         r8,[.k_format]
        xor         r9d,r9d
        mov         rax,[rcx]
        call        [IAudioClient.IsFormatSupported+rax]
        test        eax,eax
        js          .error
        ; get device period
        mov         rcx,[.audio.client+rsi]
        xor         edx,edx
        lea         r8,[.period+rsp]
        mov         rax,[rcx]
        call        [IAudioClient.GetDevicePeriod+rax]
        test        eax,eax
        js          .error
        ; try to initialize audio client
        initialize
        test        eax,eax
        jz          .initialize_ok
        cmp         eax,AUDCLNT_E_BUFFER_SIZE_NOT_ALIGNED
        jne         .error
        ; compute new period and initialize again
        get_buf_size
        xorpd       xmm0,xmm0
        cvtsi2sd    xmm0,[.audio.buffer_size_in_frames+rsi]
        mulsd       xmm0,[.k_10000000_0]
        divsd       xmm0,[.k_48000_0]
        addsd       xmm0,[.k_0_5]
        cvttsd2si   rax,xmm0
        mov         [.period+rsp],rax
        mov         rcx,[.audio.client+rsi]
        mov         rax,[rcx]
        call        [IAudioClient.Release+rax]
        activate
        initialize
        test        eax,eax
        js          .error
  .initialize_ok:
        create_event
        mov         [.audio.buffer_ready_event+rsi],rax
        create_event
        mov         [.audio.shutdown_event+rsi],rax
        mov         rcx,[.audio.client+rsi]
        mov         rdx,[.audio.buffer_ready_event+rsi]
        mov         rax,[rcx]
        call        [IAudioClient.SetEventHandle+rax]
        get_buf_size
        ; get audio render client
        mov         rcx,[.audio.client+rsi]
        lea         rdx,[IID_IAudioRenderClient]
        lea         r8,[.audio.render_client+rsi]
        mov         rax,[rcx]
        call        [IAudioClient.GetService+rax]
        test        eax,eax
        js          .error
        ; create audio thread
        xor         ecx,ecx
        xor         edx,edx
        lea         r8,[audio_thread]
        lea         r9,[.audio+rsi]
        mov         dword[k_funcparam5+rsp],0
        mov         qword[k_funcparam6+rsp],0
        call        [CreateThread]
        mov         [.audio.thread+rsi],rax
        test        rax,rax
        jz          .error
        ; load initial audio data
        get_buffer
        release_buffer
        ; start
        mov         rcx,[.audio.client+rsi]
        mov         rax,[rcx]
        call        [IAudioClient.Start+rax]
        test        eax,eax
        js          .error
        ; success
        mov         eax,1
        add         rsp,.k_stack_size
        pop         rsi
        ret
  .error:
        xor         eax,eax
        add         rsp,.k_stack_size
        pop         rsi
        ret
align 8
.k_10000000_0 dq 10000000.0
.k_48000_0 dq 48000.0
.k_0_5 dq 0.5
.k_format WAVEFORMATEX WAVE_FORMAT_PCM,2,48000,48000*4,4,16
purge activate,initialize,get_buf_size,create_event
;=============================================================================
align 32
audio_stop:
;-----------------------------------------------------------------------------
virtual at 0
  .audio audio_state
end virtual
  .k_stack_size = 4*8
        push        rsi
        sub         rsp,.k_stack_size
        mov         rsi,rcx
        mov         rcx,[.audio.shutdown_event+rsi]
        test        rcx,rcx
        jz          @f
        call        [SetEvent]
  @@:   mov         rcx,[.audio.thread+rsi]
        mov         edx,INFINITE
        test        rcx,rcx
        jz          @f
        call        [WaitForSingleObject]
  @@:   safe_close  [.audio.thread+rsi]
        mov         rcx,[.audio.client+rsi]
        test        rcx,rcx
        jz          @f
        mov         rax,[rcx]
        call        [IAudioClient.Stop+rax]
  @@:   safe_close  [.audio.shutdown_event+rsi]
        safe_close  [.audio.buffer_ready_event+rsi]
        safe_release [.audio.render_client+rsi]
        safe_release [.audio.client+rsi]
        safe_release [.audio.device+rsi]
        safe_release [.audio.enumerator+rsi]
        add         rsp,.k_stack_size
        pop         rsi
        ret
;=============================================================================
align 32
audio_thread:
;-----------------------------------------------------------------------------
virtual at 0
  .audio audio_state
end virtual
virtual at 0
  rq 5
  .ptr dq ?
  .read_bytes dd ?
  .task_index dd ?
  .wait_array dq ?,?
  .k_stack_size = $+8
end virtual
        push        rsi
        sub         rsp,.k_stack_size
        mov         rsi,rcx
        xor         ecx,ecx
        call        [CoInitialize]
        test        eax,eax
        js          .error
        lea         rcx,[.k_task_name]
        mov         [.task_index+rsp],0
        lea         rdx,[.task_index+rsp]
        call        [AvSetMmThreadCharacteristics]
        test        rax,rax
        jz          .error
        mov         rax,[.audio.shutdown_event+rsi]
        mov         [.wait_array+rsp],rax
        mov         rax,[.audio.buffer_ready_event+rsi]
        mov         [.wait_array+rsp+8],rax
  .play_loop:
        mov         ecx,2
        lea         rdx,[.wait_array+rsp]
        xor         r8d,r8d
        mov         r9d,INFINITE
        call        [WaitForMultipleObjects]
        test        eax,eax
        jz          .error
        get_buffer
        release_buffer
        jmp .play_loop
  .error:
        xor         ecx,ecx
        call        [ExitThread]
        ret
.k_task_name db 'Playback',0
;=============================================================================
purge get_buffer,release_buffer
;=============================================================================