if program_section = 'data'

align 8
audio:
  .stream dq 0
  .thread dq 0
  .shutdown_event dq 0
  .buffer_ready_event dq 0
  .render_client dq 0
  .client dq 0
  .device dq 0
  .enumerator dq 0
  .buffer_size_in_frames dd 0,0

else if program_section = 'code'
;=============================================================================
macro get_buffer {
                        mov   rcx,[audio.render_client]
                        mov   edx,[audio.buffer_size_in_frames]
                        lea   r8,[.ptr+rsp]
                    comcall   IAudioRenderClient.GetBuffer
                    checkhr   eax,.error }
macro release_buffer {
                        mov   rcx,[audio.render_client]
                        mov   edx,[audio.buffer_size_in_frames]
                        xor   r8d,r8d
                    comcall   IAudioRenderClient.ReleaseBuffer
                    checkhr   eax,.error }
macro fill_buffer {
                        mov   rcx,[audio.stream]
                        mov   rdx,[.ptr+rsp]
                        mov   r8d,[audio.buffer_size_in_frames]
                        shl   r8d,2
                        lea   r9,[.read_bytes+rsp]
                        mov   qword[rsp+32],0
                      icall   ReadFile }
;=============================================================================
; out: eax - result
falign
audio_play:
;-----------------------------------------------------------------------------
macro activate_device {
                        mov   rcx,[audio.device]
                        lea   rdx,[IID_IAudioClient]
                        mov   r8d,CLSCTX_ALL
                        xor   r9d,r9d
                       lea3   [rsp+32],rax,[audio.client]
                    comcall   IMMDevice.Activate
                    checkhr   eax,.error }
macro init_client {
                        mov   rcx,[audio.client]
                        mov   edx,AUDCLNT_SHAREMODE_EXCLUSIVE
                        mov   r8d,AUDCLNT_STREAMFLAGS_EVENTCALLBACK
                        mov   r9,[.period+rsp]
                        mov   [rsp+32],r9
                       lea3   [rsp+40],rax,[.k_format]
                        mov   qword[rsp+48],0
                    comcall   IAudioClient.Initialize }
macro get_buffer_size {
                        mov   rcx,[audio.client]
                        lea   rdx,[audio.buffer_size_in_frames]
                    comcall   IAudioClient.GetBufferSize
                    checkhr   eax,.error }
macro create_event {
                        xor   ecx,ecx
                        xor   edx,edx
                        xor   r8d,r8d
                        mov   r9d,EVENT_ALL_ACCESS
                      icall   CreateEventEx
                       test   rax,rax
                         jz   .error }
virtual at 0
  rq 7
  .period dq ?
  .ptr dq ?
  .read_bytes dd ?,?
  align 32
  .k_stack_size = $+16
end virtual
                       push   rsi
                        sub   rsp,.k_stack_size
                        xor   ecx,ecx
                      icall   CoInitialize
                    checkhr   eax,.error
                            ; device enumerator
                        lea   rcx,[CLSID_MMDeviceEnumerator]
                        xor   edx,edx
                        mov   r8d,CLSCTX_ALL
                        lea   r9,[IID_IMMDeviceEnumerator]
                       lea3   [rsp+32],rax,[audio.enumerator]
                      icall   CoCreateInstance
                    checkhr   eax,.error
                            ; audio endpoint
                        mov   rcx,[audio.enumerator]
                        mov   edx,eRender
                        mov   r8d,eConsole
                        lea   r9,[audio.device]
                    comcall   IMMDeviceEnumerator.GetDefaultAudioEndpoint
                    checkhr   eax,.error
            activate_device
                            ; check device support
                        mov   rcx,[audio.client]
                        mov   edx,AUDCLNT_SHAREMODE_EXCLUSIVE
                        lea   r8,[.k_format]
                        xor   r9d,r9d
                    comcall   IAudioClient.IsFormatSupported
                    checkhr   eax,.error
                            ; get device period
                        mov   rcx,[audio.client]
                        xor   edx,edx
                        lea   r8,[.period+rsp]
                    comcall   IAudioClient.GetDevicePeriod
                    checkhr   eax,.error
                            ; try to initialize audio client
                init_client
                       test   eax,eax
                         jz   .initialize_ok
                        cmp   eax,AUDCLNT_E_BUFFER_SIZE_NOT_ALIGNED
                        jne   .error
                            ; compute new period and initialize again
            get_buffer_size
                     vxorpd   xmm0,xmm0,xmm0
                  vcvtsi2sd   xmm0,xmm0,[audio.buffer_size_in_frames]
                     vmulsd   xmm0,xmm0,[.k_10000000_0]
                     vdivsd   xmm0,xmm0,[.k_44100_0]
                     vaddsd   xmm0,xmm0,[.k_0_5]
                 vcvttsd2si   rax,xmm0
                        mov   [.period+rsp],rax
                        mov   rcx,[audio.client]
                        mov   rax,[rcx]
                       call   [IAudioClient.Release+rax]
            activate_device
                init_client
                    checkhr   eax,.error
  .initialize_ok:
               create_event
                        mov   [audio.buffer_ready_event],rax
               create_event
                        mov   [audio.shutdown_event],rax
                        mov   rcx,[audio.client]
                        mov   rdx,[audio.buffer_ready_event]
                    comcall   IAudioClient.SetEventHandle
            get_buffer_size
                            ; get audio render client
                        mov   rcx,[audio.client]
                        lea   rdx,[IID_IAudioRenderClient]
                        lea   r8,[audio.render_client]
                    comcall   IAudioClient.GetService
                    checkhr   eax,.error
                            ; open audio file
                        lea   rcx,[.k_audio_file]
                        mov   edx,GENERIC_READ
                        xor   r8d,r8d
                        xor   r9d,r9d
                        mov   dword[rsp+32],OPEN_EXISTING
                        mov   dword[rsp+40],FILE_ATTRIBUTE_NORMAL+FILE_FLAG_SEQUENTIAL_SCAN
                        mov   qword[rsp+48],0
                      icall   CreateFile
                        cmp   rax,INVALID_HANDLE_VALUE
                         je   .error
                        mov   [audio.stream],rax
                            ; create audio thread
                        xor   ecx,ecx
                        xor   edx,edx
                        lea   r8,[audio__thread_func]
                        xor   r9d,r9d
                        mov   dword[rsp+32],0
                        mov   qword[rsp+40],0
                      icall   CreateThread
                        mov   [audio.thread],rax
                       test   rax,rax
                         jz   .error
                            ; load initial audio data
                 get_buffer
                fill_buffer
             release_buffer
                            ; start
                        mov   rcx,[audio.client]
                    comcall   IAudioClient.Start
                    checkhr   eax,.error
                            ; success
                        mov   eax,1
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
  .error:               xor   eax,eax
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
  align 8
  .k_10000000_0 dq 10000000.0
  .k_44100_0 dq 44100.0
  .k_0_5 dq 0.5
  .k_format WAVEFORMATEX WAVE_FORMAT_PCM,2,44100,44100*4,4,16
  .k_audio_file db 'data/flis_amnestia.raw',0

purge activate_device,init_client,get_buffer_size,create_event
;=============================================================================
falign
audio_stop:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+16
                       push   rsi
                        sub   rsp,.k_stack_size
                        mov   rsi,rcx
                        mov   rcx,[audio.shutdown_event]
                       test   rcx,rcx
                         jz   @f
                      icall   SetEvent
  @@:                   mov   rcx,[audio.thread]
                        mov   edx,INFINITE
                       test   rcx,rcx
                         jz   @f
                      icall   WaitForSingleObject
  @@:            safe_close   [audio.thread]
                        mov   rcx,[audio.client]
                       test   rcx,rcx
                         jz   @f
                    comcall   IAudioClient.Stop
  @@:            safe_close   [audio.stream]
                 safe_close   [audio.shutdown_event]
                 safe_close   [audio.buffer_ready_event]
               safe_release   [audio.render_client]
               safe_release   [audio.client]
               safe_release   [audio.device]
               safe_release   [audio.enumerator]
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
;=============================================================================
falign
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
                       push   rsi
                        sub   rsp,.k_stack_size

                        xor   ecx,ecx
                      icall   CoInitialize
                    checkhr   eax,.error

                        mov   [.task_index+rsp],0
                        lea   rcx,[.k_task_name]
                        lea   rdx,[.task_index+rsp]
                      icall   AvSetMmThreadCharacteristics
                       test   rax,rax
                         jz   .error

                       mov3   [.wait_array+rsp],rax,[audio.shutdown_event]
                       mov3   [.wait_array+rsp+8],rax,[audio.buffer_ready_event]
  .play_loop:
                        mov   ecx,2
                        lea   rdx,[.wait_array+rsp]
                        xor   r8d,r8d
                        mov   r9d,INFINITE
                      icall   WaitForMultipleObjects
                       test   eax,eax
                         jz   .error

                 get_buffer
                        xor   eax,eax
                        mov   edx,[audio.buffer_size_in_frames]
                        mov   rcx,[.ptr+rsp]
  @@:                   mov   dword[rcx+rax*4],0
                        add   eax,1
                        cmp   eax,edx
                        jne   @b

                fill_buffer
             release_buffer

                        mov   eax,[audio.buffer_size_in_frames]
                        shl   eax,2
                        cmp   eax,[.read_bytes+rsp]
                        jne   .error
                        jmp   .play_loop
  .error:
                        xor   ecx,ecx
                      icall   ExitThread
                        ret
  align 1
  .k_task_name db 'Playback',0

purge get_buffer,release_buffer,fill_buffer
;=============================================================================
end if ; if program_section = 'data'
