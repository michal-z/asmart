format PE64 GUI 4.0
entry start

  TRUE = 1
  FALSE = 0
  INFINITE = 0xffffffff
  IDI_APPLICATION = 32512
  IDC_ARROW = 32512
  WS_VISIBLE = 010000000h
  WS_OVERLAPPED = 000000000h
  WS_CAPTION = 000C00000h
  WS_SYSMENU = 000080000h
  WS_VISIBLE = 010000000h
  WS_MINIMIZEBOX = 000020000h
  CW_USEDEFAULT = 80000000h
  PM_REMOVE = 0001h
  WM_QUIT = 0012h
  WM_KEYDOWN = 0100h
  WM_DESTROY = 0002h
  VK_ESCAPE = 01Bh
  SRCCOPY = 0x00CC0020
  EVENT_ALL_ACCESS = 0x1F0003
  CLSCTX_INPROC_SERVER = 0x1
  CLSCTX_INPROC_HANDLER = 0x2
  CLSCTX_LOCAL_SERVER = 0x4
  CLSCTX_REMOTE_SERVER = 0x10
  CLSCTX_ALL = CLSCTX_INPROC_SERVER+CLSCTX_INPROC_HANDLER+CLSCTX_LOCAL_SERVER+CLSCTX_REMOTE_SERVER
  eRender = 0
  eConsole = 0
  WAVE_FORMAT_PCM = 1
  AUDCLNT_SHAREMODE_EXCLUSIVE = 1
  AUDCLNT_STREAMFLAGS_EVENTCALLBACK = 0x00040000
  AUDCLNT_E_BUFFER_SIZE_NOT_ALIGNED = 0x88890019

  k_funcparam5 = 32
  k_funcparam6 = k_funcparam5 + 8
  k_funcparam7 = k_funcparam6 + 8
  k_funcparam8 = k_funcparam7 + 8
  k_funcparam9 = k_funcparam8 + 8
  k_funcparam10 = k_funcparam9 + 8
  k_funcparam11 = k_funcparam10 + 8
  k_funcparam12 = k_funcparam11 + 8

struc POINT {
  .x dd 0
  .y dd 0 }

struc MSG {
  .hwnd dq 0
  .message dd 0,0
  .wParam dq 0
  .lParam dq 0
  .time dd 0
  .pt POINT
  dd 0 }

struc WNDCLASS proc,name {
  .style dd 0,0
  .lpfnWndProc dq proc
  .cbClsExtra dd 0
  .cbWndExtra dd 0
  .hInstance dq 0
  .hIcon dq 0
  .hCursor dq 0
  .hbrBackground dq 0
  .lpszMenuName dq 0
  .lpszClassName dq name }

struc RECT l,t,r,b {
  .left dd l
  .top dd t
  .right dd r
  .bottom dd b }

struc BITMAPINFOHEADER w,h,b,s {
  .biSize dd 40
  .biWidth dd w
  .biHeight dd h
  .biPlanes dw 1
  .biBitCount dw b
  .biCompression dd 0
  .biSizeImage dd s
  .biXPelsPerMeter dd 0
  .biYPelsPerMeter dd 0
  .biClrUsed dd 0
  .biClrImportant dd 0 }

struc SYSTEM_INFO {
  .dwOemId dd 0
  .dwPageSize dd 0
  .lpMinimumApplicationAddress dq 0
  .lpMaximumApplicationAddress dq 0
  .dwActiveProcessorMask dq 0
  .dwNumberOfProcessors dd 0
  .dwProcessorType dd 0
  .dwAllocationGranularity dd 0
  .wProcessorLevel dw 0
  .wProcessorRevision dw 0 }

struc GUID p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 {
  dd p0
  dw p1
  dw p2
  db p3
  db p4
  db p5
  db p6
  db p7
  db p8
  db p9
  db p10 }

struc WAVEFORMATEX p0,p1,p2,p3,p4,p5 {
  .wFormatTag dw p0
  .nChannels dw p1
  .nSamplesPerSec dd p2
  .nAvgBytesPerSec dd p3
  .nBlockAlign dw p4
  .wBitsPerSample dw p5
  .cbSize dw 0
  dw 0 }

virtual at 0
  IUnknown.QueryInterface rq 1
  IUnknown.AddRef rq 1
  IUnknown.Release rq 1
end virtual

virtual at 0
  IMMDeviceEnumerator.QueryInterface rq 1
  IMMDeviceEnumerator.AddRef rq 1
  IMMDeviceEnumerator.Release rq 1
  IMMDeviceEnumerator.EnumAudioEndpoints rq 1
  IMMDeviceEnumerator.GetDefaultAudioEndpoint rq 1
  IMMDeviceEnumerator.GetDevice rq 1
  IMMDeviceEnumerator.RegisterEndpointNotificationCallback rq 1
  IMMDeviceEnumerator.UnregisterEndpointNotificationCallback rq 1
end virtual

virtual at 0
  IMMDevice.QueryInterface rq 1
  IMMDevice.AddRef rq 1
  IMMDevice.Release rq 1
  IMMDevice.Activate rq 1
  IMMDevice.OpenPropertyStore rq 1
  IMMDevice.GetId rq 1
  IMMDevice.GetState rq 1
end virtual

virtual at 0
  IAudioClient.QueryInterface rq 1
  IAudioClient.AddRef rq 1
  IAudioClient.Release rq 1
  IAudioClient.Initialize rq 1
  IAudioClient.GetBufferSize rq 1
  IAudioClient.GetStreamLatency rq 1
  IAudioClient.GetCurrentPadding rq 1
  IAudioClient.IsFormatSupported rq 1
  IAudioClient.GetMixFormat rq 1
  IAudioClient.GetDevicePeriod rq 1
  IAudioClient.Start rq 1
  IAudioClient.Stop rq 1
  IAudioClient.Reset rq 1
  IAudioClient.SetEventHandle rq 1
  IAudioClient.GetService rq 1
end virtual

virtual at 0
  IAudioRenderClient.QueryInterface rq 1
  IAudioRenderClient.AddRef rq 1
  IAudioRenderClient.Release rq 1
  IAudioRenderClient.GetBuffer rq 1
  IAudioRenderClient.ReleaseBuffer rq 1
end virtual

section '.text' code readable executable
;========================================================================
macro emit [inst] {
forward
        inst }

macro iaca_begin {
      mov           ebx,111
      db            $64,$67,$90 }

macro iaca_end {
      mov           ebx,222
      db            $64,$67,$90 }

macro safe_close handle {
local .end
        mov         rcx,handle
        test        rcx,rcx
        jz          .end
        call        [CloseHandle]
        mov         handle,0
  .end: }

macro safe_release obj {
local .end
        mov         rcx,obj
        test        rcx,rcx
        jz          .end
        mov         rax,[rcx]
        call        [IUnknown.Release+rax]
        mov         obj,0
  .end: }
;=============================================================================
include 'imgsnd_image.inc'
include 'imgsnd_sound.inc'
;=============================================================================
align 32
generate_image_thread:
;-----------------------------------------------------------------------------
        and         rsp,-32
        sub         rsp,32
        mov         esi,ecx                                    ; thread id
  .run: mov         rcx,[image.semaphore]
        mov         edx,INFINITE
        call        [WaitForSingleObject]
        mov         eax,[quit]
        test        eax,eax
        jnz         .ret
  .for_each_tile:
        mov         eax,1
        lock xadd   [image.tile_counter],eax
        cmp         eax,k_tile_count
        jae         .done
        xor         edx,edx
        mov         ecx,k_tile_x_count
        div         ecx
        imul        ecx,edx,k_tile_width
        imul        edx,eax,k_tile_height
        imul        eax,edx,k_win_width
        add         eax,ecx
        shl         eax,2
        mov         r8,[image.ptr]
        add         r8,rax
        call        generate_image_tile
        jmp         .for_each_tile
  .done:
        mov         rcx,[image.thread_done_event+rsi*8]
        call        [SetEvent]
        jmp         .run
  .ret: xor         ecx,ecx
        call        [ExitThread]
;=============================================================================
align 32
supports_avx2:
;-----------------------------------------------------------------------------
        mov         eax,1
        cpuid
        and         ecx,$018001000                             ; check OSXSAVE,AVX,FMA
        cmp         ecx,$018001000
        jne         .not_supported
        mov         eax,7
        xor         ecx,ecx
        cpuid
        and         ebx,$20                                    ; check AVX2
        cmp         ebx,$20
        jne         .not_supported
        xor         ecx,ecx
        xgetbv
        and         eax,$06                                    ; check OS support
        cmp         eax,$06
        jne         .not_supported
        mov         eax,1
        jmp         .ret
  .not_supported:
        xor         eax,eax
  .ret: ret
;=============================================================================
align 32
get_time:
;-----------------------------------------------------------------------------
  .k_stack_size = 7*8
        sub         rsp,.k_stack_size
        mov         rax,[.perf_freq]
        test        rax,rax
        jnz         @f
        lea         rcx,[.perf_freq]
        call        [QueryPerformanceFrequency]
        lea         rcx,[.first_perf_counter]
        call        [QueryPerformanceCounter]
  @@:   lea         rcx,[.perf_counter]
        call        [QueryPerformanceCounter]
        mov         rcx,[.perf_counter]
        sub         rcx,[.first_perf_counter]
        mov         rdx,[.perf_freq]
        vxorps      xmm0,xmm0,xmm0
        vcvtsi2sd   xmm1,xmm0,rcx
        vcvtsi2sd   xmm2,xmm0,rdx
        vdivsd      xmm0,xmm1,xmm2
        add         rsp,.k_stack_size
        ret
;=============================================================================
align 32
update_frame_stats:
;-----------------------------------------------------------------------------
  .k_stack_size = 7*8
        sub         rsp,.k_stack_size
        mov         rax,[.prev_time]
        test        rax,rax
        jnz         @f
        call        get_time
        vmovsd      [.prev_time],xmm0
        vmovsd      [.prev_update_time],xmm0
  @@:   call        get_time                       ; xmm0 = (0,time)
        vmovsd      [time],xmm0
        vsubsd      xmm1,xmm0,[.prev_time]       ; xmm1 = (0,time_delta)
        vmovsd      [.prev_time],xmm0
        vxorps      xmm2,xmm2,xmm2
        vcvtsd2ss   xmm1,xmm2,xmm1            ; xmm1 = (0,0,0,time_delta)
        vmovss      [time_delta],xmm1
        vmovsd      xmm1,[.prev_update_time]     ; xmm1 = (0,prev_update_time)
        vsubsd      xmm2,xmm0,xmm1               ; xmm2 = (0,time-prev_update_time)
        vmovsd      xmm3,[.k_1_0]                ; xmm3 = (0,1.0)
        vcomisd     xmm2,xmm3
        jb          @f
        vmovsd      [.prev_update_time],xmm0
        mov         eax,[.frame]
        vxorpd      xmm1,xmm1,xmm1
        vcvtsi2sd   xmm1,xmm1,eax             ; xmm1 = (0,frame)
        vdivsd      xmm0,xmm1,xmm2               ; xmm0 = (0,frame/(time-prev_update_time))
        vdivsd      xmm1,xmm2,xmm1
        vmulsd      xmm1,xmm1,[.k_1000000_0]
        mov         [.frame],0
        lea         rcx,[win_title]
        lea         rdx,[win_title_fmt]
        vcvtsd2si   r8,xmm0
        vcvtsd2si   r9,xmm1
        call        [wsprintf]
        mov         rcx,[win_handle]
        lea         rdx,[win_title]
        call        [SetWindowText]
  @@:   add         [.frame],1
        add         rsp,.k_stack_size
        ret
;=============================================================================
align 32
init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 12
  .k_stack_size = $+16
end virtual
        push        rsi
        sub         rsp,.k_stack_size
        lea         rcx,[system_info]
        call        [GetSystemInfo]
        mov         eax,[system_info.dwNumberOfProcessors]
        mov         [image.thread_count],eax
        call        supports_avx2
        test        eax,eax
        jz          .no_avx2
        ; window class
        xor         ecx,ecx
        call        [GetModuleHandle]
        mov         [win_class.hInstance],rax
        xor         ecx,ecx
        mov         edx,IDC_ARROW
        call        [LoadCursor]
        mov         [win_class.hCursor],rax
        mov         rcx,win_class
        call        [RegisterClass]
        test        eax,eax
        jz          .error
        ; window
        mov         rcx,win_rect
        mov         edx,k_win_style
        xor         r8d,r8d
        call        [AdjustWindowRect]
        mov         r10d,[win_rect.right]
        mov         r11d,[win_rect.bottom]
        sub         r10d,[win_rect.left]
        sub         r11d,[win_rect.top]
        xor         ecx,ecx
        mov         rdx,win_title
        mov         r8,rdx
        mov         r9d,WS_VISIBLE+k_win_style
        mov         eax,CW_USEDEFAULT
        mov         [k_funcparam5+rsp],eax
        mov         [k_funcparam6+rsp],eax
        mov         [k_funcparam7+rsp],r10d
        mov         [k_funcparam8+rsp],r11d
        mov         [k_funcparam9+rsp],ecx
        mov         [k_funcparam10+rsp],ecx
        mov         rax,[win_class.hInstance]
        mov         [k_funcparam11+rsp],rax
        mov         [k_funcparam12+rsp],ecx
        call        [CreateWindowEx]
        mov         [win_handle],rax
        test        rax,rax
        jz          .error
        ; bitmap
        mov         rcx,[win_handle]
        call        [GetDC]
        mov         [win_hdc],rax
        test        rax,rax
        jz          .error
        mov         rcx,[win_hdc]
        lea         rdx,[bmp_info]
        xor         r8d,r8d
        lea         r9,[image.ptr]
        mov         qword[k_funcparam5+rsp],0
        mov         qword[k_funcparam6+rsp],0
        call        [CreateDIBSection]
        mov         [bmp_handle],rax
        test        rax,rax
        jz          .error
        mov         rcx,[win_hdc]
        call        [CreateCompatibleDC]
        mov         [bmp_hdc],rax
        test        rax,rax
        jz          .error
        mov         rcx,[bmp_hdc]
        mov         rdx,[bmp_handle]
        call        [SelectObject]
        test        eax,eax
        jz          .error
        ; image semaphore
        xor         ecx,ecx
        xor         edx,edx
        mov         r8d,[image.thread_count]
        xor         r9d,r9d
        call        [CreateSemaphore]
        mov         [image.semaphore],rax
        test        rax,rax
        jz          .error
        ; image events
        xor         esi,esi
  @@:   xor         ecx,ecx
        xor         edx,edx
        xor         r8d,r8d
        mov         r9d,EVENT_ALL_ACCESS
        call        [CreateEventEx]
        mov         [image.thread_done_event+rsi*8],rax
        test        rax,rax
        jz          .error
        add         esi,1
        cmp         esi,[image.thread_count]
        jb          @b
        ; image threads
        xor         esi,esi
  @@:   xor         ecx,ecx
        xor         edx,edx
        mov         r8,generate_image_thread
        mov         r9d,esi
        mov         qword[k_funcparam5+rsp],0
        mov         qword[k_funcparam6+rsp],0
        call        [CreateThread]
        mov         [image.thread+rsi*8],rax
        test        rax,rax
        jz          .error
        add         esi,1
        cmp         esi,[image.thread_count]
        jb          @b
        ; sound
        call        audio_play
        test        eax,eax
        jz          .error
        mov         eax,1
        add         rsp,.k_stack_size
        pop         rsi
        ret
  .no_avx2:
        xor         ecx,ecx
        lea         rdx,[no_avx2_message]
        lea         r8,[no_avx2_caption]
        xor         r9d,r9d
        call        [MessageBox]
  .error:
        xor         eax,eax
        add         rsp,.k_stack_size
        pop         rsi
        ret
;=============================================================================
align 32
deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        push        rsi rdi
        sub         rsp,.k_stack_size
        mov         [quit],1
        mov         rcx,[image.semaphore]
        test        rcx,rcx
        jz          @f
        mov         edx,[image.thread_count]
        xor         r8d,r8d
        call        [ReleaseSemaphore]
  @@:
        xor         esi,esi
  .for_each_thrd:
        mov         rdi,[image.thread+rsi*8]
        test        rdi,rdi
        jz          @f
        mov         rcx,rdi
        mov         edx,INFINITE
        call        [WaitForSingleObject]
        mov         rcx,rdi
        call        [CloseHandle]
  @@:   add         esi,1
        cmp         esi,[image.thread_count]
        jb          .for_each_thrd

        xor         esi,esi
  .for_each_sem:
        safe_close  [image.thread_done_event+rsi*8]
        add         esi,1
        cmp         esi,[image.thread_count]
        jb          .for_each_sem

        safe_close  [image.semaphore]
        mov         rcx,[bmp_hdc]
        test        rcx,rcx
        jz          @f
        call        [DeleteDC]
  @@:   mov         rcx,[bmp_handle]
        test        rcx,rcx
        jz          @f
        call        [DeleteObject]
  @@:   mov         rcx,[win_hdc]
        test        rcx,rcx
        jz          @f
        call        [ReleaseDC]
  @@:   add         rsp,.k_stack_size
        pop         rdi rsi
        ret
;=============================================================================
align 32
update:
;-----------------------------------------------------------------------------
virtual at 0
  rq 9
  .k_stack_size = $+16
end virtual
        sub         rsp,.k_stack_size
        call        update_frame_stats
        call        update_state
        mov         [image.tile_counter],0
        mov         rcx,[image.semaphore]
        mov         edx,[image.thread_count]
        xor         r8d,r8d
        call        [ReleaseSemaphore]
        mov         ecx,[image.thread_count]
        lea         rdx,[image.thread_done_event]
        mov         r8d,TRUE
        mov         r9d,INFINITE
        call        [WaitForMultipleObjects]
        mov         rcx,[win_hdc]
        xor         edx,edx
        xor         r8d,r8d
        mov         r9d,k_win_width
        mov         dword[k_funcparam5+rsp],k_win_height
        mov         rax,[bmp_hdc]
        mov         [k_funcparam6+rsp],rax
        mov         qword[k_funcparam7+rsp],0
        mov         qword[k_funcparam8+rsp],0
        mov         dword[k_funcparam9+rsp],SRCCOPY
        call        [BitBlt]
        add         rsp,.k_stack_size
        ret
;=============================================================================
align 32
start:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .k_stack_size = $+16
end virtual
        sub         rsp,.k_stack_size
        call        init
        test        eax,eax
        jz          .quit
  .main_loop:
        lea         rcx,[win_msg]
        xor         edx,edx
        xor         r8d,r8d
        xor         r9d,r9d
        mov         dword[k_funcparam5+rsp],PM_REMOVE
        call        [PeekMessage]
        test        eax,eax
        jz          .update
        lea         rcx,[win_msg]
        call        [DispatchMessage]
        cmp         [win_msg.message],WM_QUIT
        je          .quit
        jmp         .main_loop
  .update:
        call        update
        jmp         .main_loop
  .quit:
        call        deinit
        xor         ecx,ecx
        call        [ExitProcess]
;=============================================================================
align 32
winproc:
;-----------------------------------------------------------------------------
        sub         rsp,40
        cmp         edx,WM_KEYDOWN
        je          .keydown
        cmp         edx,WM_DESTROY
        je          .destroy
        call        [DefWindowProc]
        jmp         .return
  .keydown:
        cmp         r8d,VK_ESCAPE
        jne         .return
        xor         ecx,ecx
        call        [PostQuitMessage]
        xor         eax,eax
        jmp         .return
  .destroy:
        xor         ecx,ecx
        call        [PostQuitMessage]
        xor         eax,eax
  .return:
        add         rsp,40
        ret
;========================================================================
section '.data' data readable

  k_win_width = 1280
  k_win_height = 720
  k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX
  k_tile_width = 80
  k_tile_height = 80
  k_tile_x_count = k_win_width / k_tile_width
  k_tile_y_count = k_win_height / k_tile_height
  k_tile_count = k_tile_x_count * k_tile_y_count
  k_thrd_max_count = 16

align 4
  k_background_color dd 0.0,0.0,0.0

align 8
  CLSID_MMDeviceEnumerator GUID 0xBCDE0395,0xE52F,0x467C,0x8E,0x3D,0xC4,0x57,0x92,0x91,0x69,0x2E
  IID_IMMDeviceEnumerator GUID 0xA95664D2,0x9614,0x4F35,0xA7,0x46,0xDE,0x8D,0xB6,0x36,0x17,0xE6
  IID_IAudioClient GUID 0x1CB9AD4C,0xDBFA,0x4c32,0xB1,0x78,0xC2,0xF5,0x68,0xA7,0x03,0xB2
  IID_IAudioRenderClient GUID 0xF294ACFC,0x3146,0x4483,0xA7,0xBF,0xAD,0xDC,0xA7,0xC2,0x60,0xE2

  update_frame_stats.k_1000000_0 dq 1000000.0
  update_frame_stats.k_1_0 dq 1.0

align 8
  audio_play.k_10000000_0 dq 10000000.0
  audio_play.k_48000_0 dq 48000.0
  audio_play.k_0_5 dq 0.5
  audio_play.k_format WAVEFORMATEX WAVE_FORMAT_PCM,2,48000,48000*4,4,16

  audio_thread.k_task_name db 'Playback',0

align 32
  generate_image_tile.k_x_offset: dd 0.5,1.5,2.5,3.5,0.5,1.5,2.5,3.5
  generate_image_tile.k_y_offset: dd 0.5,0.5,0.5,0.5,1.5,1.5,1.5,1.5
  generate_image_tile.k_win_width_rcp: dd 8 dup 0.0015625      ; 2.0f / k_win_width, k_win_width = 1280
  generate_image_tile.k_win_height_rcp: dd 8 dup 0.0015625     ; 2.0f / k_win_width, k_win_width = 1280
  generate_image_tile.k_rd_z: dd 8 dup -1.732

align 32
  k_1: dd 8 dup 1
  k_2: dd 8 dup 2
  k_1_0: dd 8 dup 1.0
  k_0_5: dd 8 dup 0.5
  k_0_1: dd 8 dup 0.1
  k_camera_radius: dd 8 dup 16.0
  k_sphere_radius: dd 8 dup -4.0
  k_255_0: dd 8 dup 255.0
  k_0_02: dd 8 dup 0.02
  k_hit_distance: dd 8 dup 0.00001
  k_view_distance: dd 8 dup 50.0
  k_normal_eps: dd 8 dup 0.00002
  k_shadow_hardness: dd 8 dup 16.0

  sincos.k_inv_sign_mask: dd 8 dup not 0x80000000
  sincos.k_sign_mask: dd 8 dup 0x80000000
  sincos.k_2_div_pi: dd 8 dup 0.636619772
  sincos.k_p0: dd 8 dup 0.15707963267948963959e1
  sincos.k_p1: dd 8 dup -0.64596409750621907082e0
  sincos.k_p2: dd 8 dup 0.7969262624561800806e-1
  sincos.k_p3: dd 8 dup -0.468175413106023168e-2
;========================================================================
section '.data' data readable writeable

align 8
  audio:
  .enumerator dq 0
  .device dq 0
  .client dq 0
  .render_client dq 0
  .buffer_ready_event dq 0
  .shutdown_event dq 0
  .thread dq 0
  .buffer_size_in_frames dd 0

align 8
  image:
  .ptr dq 0
  .semaphore dq 0
  .thread dq 16 dup 0
  .thread_done_event dq 16 dup 0
  .thread_count dd 0
  .tile_counter dd 0

align 8
  bmp_handle dq 0
  bmp_hdc dq 0
  win_handle dq 0
  win_hdc dq 0
  win_title db 'Image & Sound', 64 dup 0
  win_title_fmt db '[%d fps  %d us] Image & Sound',0
  win_msg MSG
  win_class WNDCLASS winproc,win_title
  win_rect RECT 0,0,k_win_width,k_win_height

  no_avx2_caption db 'Not supported CPU',0
  no_avx2_message db 'Your CPU does not support AVX2, program will not run.',0

align 8
  bmp_info BITMAPINFOHEADER k_win_width,k_win_height,32,k_win_width*k_win_height
  dq 0,0,0,0

align 8
  time dq 0
  time_delta dd 0
  quit dd 0

  get_time.perf_counter dq 0
  get_time.perf_freq dq 0
  get_time.first_perf_counter dq 0

  update_frame_stats.prev_time dq 0
  update_frame_stats.prev_update_time dq 0
  update_frame_stats.frame dd 0,0

align 8
  system_info SYSTEM_INFO

align 4
  eye_position dd 0.0,4.0,400.0
  eye_focus dd 0.0,0.0,0.0

align 32
  eye_xaxis: dd 8 dup 1.0,8 dup 0.0,8 dup 0.0
  eye_yaxis: dd 8 dup 0.0,8 dup 1.0,8 dup 0.0
  eye_zaxis: dd 8 dup 0.0,8 dup 0.0,8 dup 1.0

align 32
  light0_position: dd 8 dup 10.0, 8 dup 10.0, 8 dup 10.0
  light0_power: dd 8 dup 0.9
  light1_position: dd 8 dup 5.0, 8 dup 20.0, 8 dup -15.0
  light1_power: dd 8 dup 0.6
  ambient: dd 8 dup 0.1

align 32
  object:
  .id: dd 8 dup 0,8 dup 8,8 dup 16,8 dup 24
  .param_x: dd 8 dup 0.0,8 dup 0.0,8 dup 3.0,8 dup 0.0
  .param_y: dd 8 dup 0.0,8 dup 1.0,8 dup 0.0,8 dup 1.0
  .param_z: dd 8 dup 0.0,8 dup 3.0,8 dup 0.0,8 dup 0.0
  .param_w: dd 8 dup 2.0,8 dup 0.7,8 dup 1.0,8 dup 2.0
  .red: dd 8 dup 1.0,8 dup 0.0,8 dup 0.0,8 dup 0.5
  .green: dd 8 dup 0.0,8 dup 1.0,8 dup 0.0,8 dup 0.3
  .blue: dd 8 dup 0.0,8 dup 0.0,8 dup 1.0,8 dup 0.2
;========================================================================
section '.idata' import data readable writeable

  dd 0,0,0,rva _kernel32,rva _kernel32_table
  dd 0,0,0,rva _user32,rva _user32_table
  dd 0,0,0,rva _gdi32,rva _gdi32_table
  dd 0,0,0,rva _ole32,rva _ole32_table
  dd 0,0,0,rva _avrt,rva _avrt_table
  dd 0,0,0,0,0

  _kernel32_table:
  GetModuleHandle dq rva _GetModuleHandle
  ExitProcess dq rva _ExitProcess
  WaitForSingleObject dq rva _WaitForSingleObject
  ReleaseSemaphore dq rva _ReleaseSemaphore
  ExitThread dq rva _ExitThread
  QueryPerformanceFrequency dq rva _QueryPerformanceFrequency
  QueryPerformanceCounter dq rva _QueryPerformanceCounter
  CreateSemaphore dq rva _CreateSemaphore
  CreateThread dq rva _CreateThread
  CloseHandle dq rva _CloseHandle
  WaitForMultipleObjects dq rva _WaitForMultipleObjects
  GetSystemInfo dq rva _GetSystemInfo
  CreateEventEx dq rva _CreateEventEx
  SetEvent dq rva _SetEvent
  dq 0

  _user32_table:
  wsprintf dq rva _wsprintf
  RegisterClass dq rva _RegisterClass
  CreateWindowEx dq rva _CreateWindowEx
  DefWindowProc dq rva _DefWindowProc
  PeekMessage dq rva _PeekMessage
  DispatchMessage dq rva _DispatchMessage
  LoadCursor dq rva _LoadCursor
  LoadIcon dq rva _LoadIcon
  SetWindowText dq rva _SetWindowText
  SetRect dq rva _SetRect
  AdjustWindowRect dq rva _AdjustWindowRect
  GetDC dq rva _GetDC
  ReleaseDC dq rva _ReleaseDC
  PostQuitMessage dq rva _PostQuitMessage
  MessageBox dq rva _MessageBox
  dq 0

  _gdi32_table:
  CreateDIBSection dq rva _CreateDIBSection
  CreateCompatibleDC dq rva _CreateCompatibleDC
  SelectObject dq rva _SelectObject
  BitBlt dq rva _BitBlt
  DeleteDC dq rva _DeleteDC
  DeleteObject dq rva _DeleteObject
  dq 0

  _ole32_table:
  CoInitialize dq rva _CoInitialize
  CoCreateInstance dq rva _CoCreateInstance
  dq 0
 
  _avrt_table:
  AvSetMmThreadCharacteristics dq rva _AvSetMmThreadCharacteristics
  dq 0

  _kernel32 db 'kernel32.dll',0
  _user32 db 'user32.dll',0
  _gdi32 db 'gdi32.dll',0
  _ole32 db 'ole32.dll',0
  _avrt db 'avrt.dll',0

emit <_GetModuleHandle dw 0>,<db 'GetModuleHandleA',0>
emit <_ExitProcess dw 0>,<db 'ExitProcess',0>
emit <_WaitForSingleObject dw 0>,<db 'WaitForSingleObject',0>
emit <_ReleaseSemaphore dw 0>,<db 'ReleaseSemaphore',0>
emit <_ExitThread dw 0>,<db 'ExitThread',0>
emit <_QueryPerformanceFrequency dw 0>,<db 'QueryPerformanceFrequency',0>
emit <_QueryPerformanceCounter dw 0>,<db 'QueryPerformanceCounter',0>
emit <_CreateSemaphore dw 0>,<db 'CreateSemaphoreA',0>
emit <_CreateThread dw 0>,<db 'CreateThread',0>
emit <_CloseHandle dw 0>,<db 'CloseHandle',0>
emit <_WaitForMultipleObjects dw 0>,<db 'WaitForMultipleObjects',0>
emit <_GetSystemInfo dw 0>,<db 'GetSystemInfo',0>
emit <_CreateEventEx dw 0>,<db 'CreateEventExA',0>
emit <_SetEvent dw 0>,<db 'SetEvent',0>

emit <_wsprintf dw 0>,<db 'wsprintfA',0>
emit <_RegisterClass dw 0>,<db 'RegisterClassA',0>
emit <_CreateWindowEx dw 0>,<db 'CreateWindowExA',0>
emit <_DefWindowProc dw 0>,<db 'DefWindowProcA',0>
emit <_PeekMessage dw 0>,<db 'PeekMessageA',0>
emit <_DispatchMessage dw 0>,<db 'DispatchMessageA',0>
emit <_LoadCursor dw 0>,<db 'LoadCursorA',0>
emit <_LoadIcon dw 0>,<db 'LoadIconA',0>
emit <_SetWindowText dw 0>,<db 'SetWindowTextA',0>
emit <_SetRect dw 0>,<db 'SetRect',0>
emit <_AdjustWindowRect dw 0>,<db 'AdjustWindowRect',0>
emit <_GetDC dw 0>,<db 'GetDC',0>
emit <_ReleaseDC dw 0>,<db 'ReleaseDC',0>
emit <_PostQuitMessage dw 0>,<db 'PostQuitMessage',0>
emit <_MessageBox dw 0>,<db 'MessageBoxA',0>

emit <_CreateDIBSection dw 0>,<db 'CreateDIBSection',0>
emit <_CreateCompatibleDC dw 0>,<db 'CreateCompatibleDC',0>
emit <_SelectObject dw 0>,<db 'SelectObject',0>
emit <_BitBlt dw 0>,<db 'BitBlt',0>
emit <_DeleteDC dw 0>,<db 'DeleteDC',0>
emit <_DeleteObject dw 0>,<db 'DeleteObject',0>

emit <_CoInitialize dw 0>,<db 'CoInitialize',0>
emit <_CoCreateInstance dw 0>,<db 'CoCreateInstance',0>
 
emit <_AvSetMmThreadCharacteristics dw 0>,<db 'AvSetMmThreadCharacteristicsA',0>
;========================================================================