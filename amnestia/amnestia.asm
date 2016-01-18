format PE64 GUI 4.0
entry start

include '../fasm/inst_prefix.inc'

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
  OPEN_EXISTING = 3
  GENERIC_READ = 0x80000000
  INVALID_HANDLE_VALUE = 0xffffffffffffffff
  INVALID_FILE_SIZE = 0xffffffff
  FILE_ATTRIBUTE_NORMAL = 128
  FILE_FLAG_SEQUENTIAL_SCAN = 0x08000000
  EVENT_ALL_ACCESS = 0x1F0003
  PFD_TYPE_RGBA = 0
  PFD_DOUBLEBUFFER = 0x00000001
  PFD_DRAW_TO_WINDOW = 0x00000004
  PFD_SUPPORT_OPENGL = 0x00000020

  WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091
  WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092
  WGL_CONTEXT_FLAGS_ARB = 0x2094
  WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126
  WGL_CONTEXT_ES_PROFILE_BIT_EXT = 0x0004
  WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB = 0x0002
  WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001
  GL_COLOR_BUFFER_BIT = 0x00004000
  GL_FRAGMENT_SHADER = 0x8B30
  GL_VERTEX_SHADER = 0x8B31
  GL_VERTEX_SHADER_BIT = 0x00000001
  GL_FRAGMENT_SHADER_BIT = 0x00000002
  GL_TRIANGLES = 0x0004

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

struc PIXELFORMATDESCRIPTOR {
  .nSize dw 40
  .nVersion dw 1
  .dwFlags dd PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER
  .iPixelType db PFD_TYPE_RGBA
  .cColorBits db 32
  .cRedBits db 0
  .cRedShift db 0
  .cGreenBits db 0
  .cGreenShift db 0
  .cBlueBits db 0
  .cBlueShift db 0
  .cAlphaBits db 0
  .cAlphaShift db 0
  .cAccumBits db 0
  .cAccumRedBits db 0
  .cAccumGreenBits db 0
  .cAccumBlueBits db 0
  .cAccumAlphaBits db 0
  .cDepthBits db 24
  .cStencilBits db 8
  .cAuxBuffers db 0
  .iLayerType db 0
  .bReserved db 0
  .dwLayerMask dd 0
  .dwVisibleMask dd 0
  .dwDamageMask dd 0 }

struc WAVEFORMATEX p0,p1,p2,p3,p4,p5 {
  .wFormatTag dw p0
  .nChannels dw p1
  .nSamplesPerSec dd p2
  .nAvgBytesPerSec dd p3
  .nBlockAlign dw p4
  .wBitsPerSample dw p5
  .cbSize dw 0
  dw 0 }

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
macro EMIT [inst] {
  forward
        inst }

macro IACA_BEGIN {
        $mov ebx,111
        db $64,$67,$90 }

macro IACA_END {
        $mov ebx,222
        db $64,$67,$90 }

macro MALLOC size {
        $mov rcx,[process_heap]
        $xor edx,edx
        $mov r8d,size
        $call [HeapAlloc] }

macro FREE ptr {
        $mov rcx,[process_heap]
        $xor edx,edx
        $mov r8,ptr
        $call [HeapFree] }

macro LN txt {
        db txt,13,10 }

macro SAFE_CLOSE handle {
  local .end
        $mov rcx,handle
        $test rcx,rcx
        $jz .end
        $call [CloseHandle]
        $mov handle,0
  .end: }

macro SAFE_RELEASE iface {
  local .end
        $mov rcx,iface
        $test rcx,rcx
        $jz .end
        $mov rax,[rcx]
        $call [IUnknown.Release+rax]
        $mov iface,0
  .end: }

macro FALIGN {
        align 16 }

macro DEBUG_BREAK {
        $int3
        $nop }
;=============================================================================
include 'amnestia_demo.inc'
include 'amnestia_audio.inc'
include 'amnestia_math.inc'
;=============================================================================
FALIGN
get_time:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $mov rax,[.perf_freq]
        $test rax,rax
        $jnz @f
        $lea rcx,[.perf_freq]
        $call [QueryPerformanceFrequency]
        $lea rcx,[.first_perf_counter]
        $call [QueryPerformanceCounter]

  @@:   $lea rcx,[.perf_counter]
        $call [QueryPerformanceCounter]
        $mov rcx,[.perf_counter]
        $sub rcx,[.first_perf_counter]
        $mov rdx,[.perf_freq]
        $xorps xmm0,xmm0
        $cvtsi2sd xmm0,rcx
        $xorps xmm1,xmm1
        $cvtsi2sd xmm1,rdx
        $divsd xmm0,xmm1
        $add rsp,.k_stack_size
        $ret
;=============================================================================
FALIGN
update_frame_stats:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $mov rax,[.prev_time]
        $test rax,rax
        $jnz @f
        $call get_time
        $movsd [.prev_time],xmm0
        $movsd [.prev_update_time],xmm0
  @@:   $call get_time                        ; xmm0 = (0,time)
        $movsd [time],xmm0
        $movapd xmm1,xmm0
        $subsd xmm1,[.prev_time]               ; xmm1 = (0,time_delta)
        $movsd [.prev_time],xmm0
        $xorpd xmm2,xmm2
        $cvtsd2ss xmm1,xmm1                      ; xmm1 = (0,0,0,time_delta)
        $movss [time_delta],xmm1
        $movsd xmm1,[.prev_update_time]        ; xmm1 = (0,prev_update_time)
        $movapd xmm2,xmm0
        $subsd xmm2,xmm1                       ; xmm2 = (0,time-prev_update_time)
        $movsd xmm3,[.k_1_0]                   ; xmm3 = (0,1.0)
        $comisd xmm2,xmm3
        $jb @f
        $movsd [.prev_update_time],xmm0
        $mov eax,[.frame]
        $xorpd xmm1,xmm1
        $cvtsi2sd xmm1,eax                       ; xmm1 = (0,frame)
        $movapd xmm3,xmm1
        $divsd xmm1,xmm2                       ; xmm1 = (0,frame/(time-prev_update_time))
        $divsd xmm2,xmm3                       ; xmm2 = (0,(time-prev_update_time)/frame)
        $mulsd xmm2,[.k_1000000_0]
        $mov [.frame],0
        $lea rcx,[win_title]
        $lea rdx,[win_title_fmt]
        $cvtsd2si r8,xmm1
        $cvtsd2si r9,xmm2
        $call [wsprintf]
        $mov rcx,[win_handle]
        $lea rdx,[win_title]
        $call [SetWindowText]
  @@:   $add [.frame],1
        $add rsp,.k_stack_size
        $ret
;=============================================================================
FALIGN
init:
;-----------------------------------------------------------------------------
macro GET_WGL_FUNC func {
        $mov rcx,[opengl_dll]
        $lea rdx,[s_#func]
        $call [GetProcAddress]
        $mov [func],rax
        $test rax,rax
        $jz .error }

macro GET_GL_FUNC func {
        $lea rcx,[s_#func]
        $call [wglGetProcAddress]
        $test rax,rax
        $jnz @f
        $mov rcx,[opengl_dll]
        $lea rdx,[s_#func]
        $call [GetProcAddress]
        $test rax,rax
        $jz .error
  @@:   $mov [func],rax }

virtual at 0
  rq 12
  .k_stack_size = $+16
end virtual
        $push rsi
        $sub rsp,.k_stack_size
  ; process heap
        $call [GetProcessHeap]
        $mov [process_heap],rax
        $test rax,rax
        $jz .error
  ; opengl32.dll
        $lea rcx,[s_opengl_dll]
        $call [LoadLibrary]
        $mov [opengl_dll],rax
        $test rax,rax
        $jz .error
        GET_WGL_FUNC wglCreateContext
        GET_WGL_FUNC wglDeleteContext
        GET_WGL_FUNC wglGetProcAddress
        GET_WGL_FUNC wglMakeCurrent
  ; window class
        $xor ecx,ecx
        $call [GetModuleHandle]
        $mov [win_class.hInstance],rax

        $xor ecx,ecx
        $mov edx,IDC_ARROW
        $call [LoadCursor]
        $mov [win_class.hCursor],rax

        $lea rcx,[win_class]
        $call [RegisterClass]
        $test eax,eax
        $jz .error
  ; window
        $lea rcx,[win_rect]
        $mov edx,k_win_style
        $xor r8d,r8d
        $call [AdjustWindowRect]

        $mov r10d,[win_rect.right]
        $mov r11d,[win_rect.bottom]
        $sub r10d,[win_rect.left]
        $sub r11d,[win_rect.top]

        $xor ecx,ecx
        $lea rdx,[win_title]
        $mov r8,rdx
        $mov r9d,WS_VISIBLE+k_win_style
        $mov eax,CW_USEDEFAULT
        $mov [k_funcparam5+rsp],eax
        $mov [k_funcparam6+rsp],eax
        $mov [k_funcparam7+rsp],r10d
        $mov [k_funcparam8+rsp],r11d
        $mov [k_funcparam9+rsp],ecx
        $mov [k_funcparam10+rsp],ecx
        $mov rax,[win_class.hInstance]
        $mov [k_funcparam11+rsp],rax
        $mov [k_funcparam12+rsp],ecx
        $call [CreateWindowEx]
        $mov [win_handle],rax
        $test rax,rax
        $jz .error

        $mov rcx,[win_handle]
        $call [GetDC]
        $mov [win_hdc],rax
        $test rax,rax
        $jz .error
  ; pixel format
        $mov rcx,[win_hdc]
        $lea rdx,[pfd]
        $call [ChoosePixelFormat]

        $mov rcx,[win_hdc]
        $mov edx,eax
        $lea r8,[pfd]
        $call [SetPixelFormat]
        $test eax,eax
        $jz .error
  ; opengl context
        $mov rcx,[win_hdc]
        $call [wglCreateContext]
        $test rax,rax
        $jz .error

        $mov rsi,rax                         ; rsi = temp gl context
        $mov rcx,[win_hdc]
        $mov rdx,rsi
        $call [wglMakeCurrent]
        $test eax,eax
        $jz .error_del_ctx

        GET_GL_FUNC wglCreateContextAttribsARB
        $mov rcx,[win_hdc]
        $xor edx,edx
        $lea r8,[ogl_ctx_attribs]
        $call [wglCreateContextAttribsARB]
        $mov [hglrc],rax
        $test rax,rax
        $jz .error_del_ctx

        $mov rcx,[win_hdc]
        $mov rdx,[hglrc]
        $call [wglMakeCurrent]
        $test eax,eax
        $jz .error_del_ctx

        $mov rcx,rsi
        $call [wglDeleteContext]

        GET_GL_FUNC wglSwapIntervalEXT
        $xor ecx,ecx
        $call [wglSwapIntervalEXT]
  ; opengl commands
        GET_GL_FUNC glClear
        GET_GL_FUNC glClearColor
        GET_GL_FUNC glCreateShaderProgramv
        GET_GL_FUNC glDeleteProgram
        GET_GL_FUNC glUseProgramStages
        GET_GL_FUNC glBindProgramPipeline
        GET_GL_FUNC glDeleteProgramPipelines
        GET_GL_FUNC glGenProgramPipelines
        GET_GL_FUNC glDrawArrays
        GET_GL_FUNC glBindVertexArray
        GET_GL_FUNC glDeleteVertexArrays
        GET_GL_FUNC glGenVertexArrays
        $mov eax,1                           ; success
        $add rsp,.k_stack_size
        $pop rsi
        $ret
  .error_del_ctx:
        $mov rcx,rsi
        $call [wglDeleteContext]
  .error:
        $xor eax,eax
        $add rsp,.k_stack_size
        $pop rsi
        $ret
purge GET_WGL_FUNC,GET_GL_FUNC
;=============================================================================
FALIGN
deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $mov rax,[wglMakeCurrent]
        $test rax,rax
        $jz @f

        $xor ecx,ecx
        $xor edx,edx
        $call [wglMakeCurrent]

  @@:   $mov rcx,[hglrc]
        $test rcx,rcx
        $jz @f
        $call [wglDeleteContext]

  @@:   $mov rcx,[win_hdc]
        $test rcx,rcx
        $jz @f
        $mov rcx,[win_handle]
        $mov rdx,[win_hdc]
        $call [ReleaseDC]

  @@:   $mov rcx,[opengl_dll]
        $test rcx,rcx
        $jz @f
        $call [FreeLibrary]

  @@:   $add rsp,.k_stack_size
        $ret
;=============================================================================
FALIGN
update:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $call update_frame_stats
        $call demo_update
        $mov rcx,[win_hdc]
        $call [SwapBuffers]
        $add rsp,.k_stack_size
        $ret
;=============================================================================
FALIGN
start:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $mov eax,1234567.0
        $movd xmm0,eax
        $call sinf
        ;DEBUG_BREAK
        $call init
        $test eax,eax
        $jz .quit_deinit

        $call demo_init
        $test eax,eax
        $jz .quit
  .main_loop:
        $lea rcx,[win_msg]
        $xor edx,edx
        $xor r8d,r8d
        $xor r9d,r9d
        $mov dword[k_funcparam5+rsp],PM_REMOVE
        $call [PeekMessage]

        $test eax,eax
        $jz .update

        $lea rcx,[win_msg]
        $call [DispatchMessage]
        $cmp [win_msg.message],WM_QUIT
        $je .quit

        $jmp .main_loop
  .update:
        $call update
        $jmp .main_loop
  .quit:
        $call demo_deinit
  .quit_deinit:
        $call deinit
        $xor ecx,ecx
        $call [ExitProcess]
;=============================================================================
FALIGN
winproc:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $cmp edx,WM_KEYDOWN
        $je .keydown
        $cmp edx,WM_DESTROY
        $je .destroy
        $call [DefWindowProc]
        $jmp .return
  .keydown:
        $cmp r8d,VK_ESCAPE
        $jne .return
        $xor ecx,ecx
        $call [PostQuitMessage]
        $xor eax,eax
        $jmp .return
  .destroy:
        $xor ecx,ecx
        $call [PostQuitMessage]
        $xor eax,eax
  .return:
        $add rsp,.k_stack_size
        $ret
;========================================================================
section '.data' data readable

  k_win_width = 800
  k_win_height = 800
  k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

align 4
  clear_color dd 0.0,0.2,0.4,1.0
  ogl_ctx_attribs dd WGL_CONTEXT_MAJOR_VERSION_ARB,4,\
                     WGL_CONTEXT_MINOR_VERSION_ARB,4,\
                     WGL_CONTEXT_FLAGS_ARB,WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB,\
                     WGL_CONTEXT_PROFILE_MASK_ARB,WGL_CONTEXT_CORE_PROFILE_BIT_ARB,0

align 8
  CLSID_MMDeviceEnumerator GUID 0xBCDE0395,0xE52F,0x467C,0x8E,0x3D,0xC4,0x57,0x92,0x91,0x69,0x2E
  IID_IMMDeviceEnumerator GUID 0xA95664D2,0x9614,0x4F35,0xA7,0x46,0xDE,0x8D,0xB6,0x36,0x17,0xE6
  IID_IAudioClient GUID 0x1CB9AD4C,0xDBFA,0x4c32,0xB1,0x78,0xC2,0xF5,0x68,0xA7,0x03,0xB2
  IID_IAudioRenderClient GUID 0xF294ACFC,0x3146,0x4483,0xA7,0xBF,0xAD,0xDC,0xA7,0xC2,0x60,0xE2

include 'amnestia_const.inc'
include 'amnestia_glsl.inc'
;========================================================================
section '.data' data readable writeable

align 4
  vshp dd 0
  fshp dd 0
  pipeline dd 0
  vao dd 0

align 8
  audio_stream dq 0
  audio_thread dq 0
  audio_shutdown_event dq 0
  audio_buffer_ready_event dq 0
  audio_render_client dq 0
  audio_client dq 0
  audio_device dq 0
  audio_enumerator dq 0
  audio_buffer_size_in_frames dd 0,0

align 8
  hglrc dq 0
  win_handle dq 0
  win_hdc dq 0
  win_title db 'amnestia', 64 dup 0
  win_title_fmt db '[%d fps  %d us] amnestia',0
  win_msg MSG
  win_class WNDCLASS winproc,win_title
  win_rect RECT 0,0,k_win_width,k_win_height

align 8
  process_heap dq 0
  time dq 0
  time_delta dd 0,0
  pfd PIXELFORMATDESCRIPTOR

align 8
  get_time.perf_counter dq 0
  get_time.perf_freq dq 0
  get_time.first_perf_counter dq 0

  update_frame_stats.prev_time dq 0
  update_frame_stats.prev_update_time dq 0
  update_frame_stats.frame dd 0,0
  update_frame_stats.k_1000000_0 dq 1000000.0
  update_frame_stats.k_1_0 dq 1.0

align 8
  opengl_dll dq 0
  wglCreateContext dq 0
  wglDeleteContext dq 0
  wglGetProcAddress dq 0
  wglMakeCurrent dq 0
  wglCreateContextAttribsARB dq 0
  wglSwapIntervalEXT dq 0
  glClear dq 0
  glClearColor dq 0
  glCreateShaderProgramv dq 0
  glDeleteProgram dq 0
  glUseProgramStages dq 0
  glBindProgramPipeline dq 0
  glDeleteProgramPipelines dq 0
  glGenProgramPipelines dq 0
  glDrawArrays dq 0
  glBindVertexArray dq 0
  glDeleteVertexArrays dq 0
  glGenVertexArrays dq 0

  s_opengl_dll db 'opengl32.dll',0
  s_wglCreateContext db 'wglCreateContext',0
  s_wglDeleteContext db 'wglDeleteContext',0
  s_wglGetProcAddress db 'wglGetProcAddress',0
  s_wglMakeCurrent db 'wglMakeCurrent',0
  s_wglCreateContextAttribsARB db 'wglCreateContextAttribsARB',0
  s_wglSwapIntervalEXT db 'wglSwapIntervalEXT',0
  s_glClear db 'glClear',0
  s_glClearColor db 'glClearColor',0
  s_glCreateShaderProgramv db 'glCreateShaderProgramv',0
  s_glDeleteProgram db 'glDeleteProgram',0
  s_glUseProgramStages db 'glUseProgramStages',0
  s_glBindProgramPipeline db 'glBindProgramPipeline',0
  s_glDeleteProgramPipelines db 'glDeleteProgramPipelines',0
  s_glGenProgramPipelines db 'glGenProgramPipelines',0
  s_glDrawArrays db 'glDrawArrays',0
  s_glBindVertexArray db 'glBindVertexArray',0
  s_glDeleteVertexArrays db 'glDeleteVertexArrays',0
  s_glGenVertexArrays db 'glGenVertexArrays',0
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
  ExitThread dq rva _ExitThread
  QueryPerformanceFrequency dq rva _QueryPerformanceFrequency
  QueryPerformanceCounter dq rva _QueryPerformanceCounter
  CloseHandle dq rva _CloseHandle
  Sleep dq rva _Sleep
  LoadLibrary dq rva _LoadLibrary
  FreeLibrary dq rva _FreeLibrary
  GetProcAddress dq rva _GetProcAddress
  HeapAlloc dq rva _HeapAlloc
  HeapReAlloc dq rva _HeapReAlloc
  HeapFree dq rva _HeapFree
  CreateFile dq rva _CreateFile
  ReadFile dq rva _ReadFile
  GetFileSize dq rva _GetFileSize
  GetProcessHeap dq rva _GetProcessHeap
  CreateEventEx dq rva _CreateEventEx
  CreateThread dq rva _CreateThread
  SetEvent dq rva _SetEvent
  WaitForSingleObject dq rva _WaitForSingleObject
  WaitForMultipleObjects dq rva _WaitForMultipleObjects
  dq 0

  _user32_table:
  wsprintf dq rva _wsprintf
  RegisterClass dq rva _RegisterClass
  CreateWindowEx dq rva _CreateWindowEx
  DefWindowProc dq rva _DefWindowProc
  PeekMessage dq rva _PeekMessage
  DispatchMessage dq rva _DispatchMessage
  LoadCursor dq rva _LoadCursor
  SetWindowText dq rva _SetWindowText
  AdjustWindowRect dq rva _AdjustWindowRect
  GetDC dq rva _GetDC
  ReleaseDC dq rva _ReleaseDC
  PostQuitMessage dq rva _PostQuitMessage
  MessageBox dq rva _MessageBox
  dq 0

  _gdi32_table:
  DeleteDC dq rva _DeleteDC
  SetPixelFormat dq rva _SetPixelFormat
  ChoosePixelFormat dq rva _ChoosePixelFormat
  SwapBuffers dq rva _SwapBuffers
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

EMIT <_GetModuleHandle dw 0>,<db 'GetModuleHandleA',0>
EMIT <_ExitProcess dw 0>,<db 'ExitProcess',0>
EMIT <_ExitThread dw 0>,<db 'ExitThread',0>
EMIT <_QueryPerformanceFrequency dw 0>,<db 'QueryPerformanceFrequency',0>
EMIT <_QueryPerformanceCounter dw 0>,<db 'QueryPerformanceCounter',0>
EMIT <_CloseHandle dw 0>,<db 'CloseHandle',0>
EMIT <_Sleep dw 0>,<db 'Sleep',0>
EMIT <_LoadLibrary dw 0>,<db 'LoadLibraryA',0>
EMIT <_FreeLibrary dw 0>,<db 'FreeLibrary',0>
EMIT <_GetProcAddress dw 0>,<db 'GetProcAddress',0>
EMIT <_HeapAlloc dw 0>,<db 'HeapAlloc',0>
EMIT <_HeapReAlloc dw 0>,<db 'HeapReAlloc',0>
EMIT <_HeapFree dw 0>,<db 'HeapFree',0>
EMIT <_CreateFile dw 0>,<db 'CreateFileA',0>
EMIT <_ReadFile dw 0>,<db 'ReadFile',0>
EMIT <_GetFileSize dw 0>,<db 'GetFileSize',0>
EMIT <_GetProcessHeap dw 0>,<db 'GetProcessHeap',0>
EMIT <_CreateEventEx dw 0>,<db 'CreateEventExA',0>
EMIT <_CreateThread dw 0>,<db 'CreateThread',0>
EMIT <_SetEvent dw 0>,<db 'SetEvent',0>
EMIT <_WaitForSingleObject dw 0>,<db 'WaitForSingleObject',0>
EMIT <_WaitForMultipleObjects dw 0>,<db 'WaitForMultipleObjects',0>

EMIT <_wsprintf dw 0>,<db 'wsprintfA',0>
EMIT <_RegisterClass dw 0>,<db 'RegisterClassA',0>
EMIT <_CreateWindowEx dw 0>,<db 'CreateWindowExA',0>
EMIT <_DefWindowProc dw 0>,<db 'DefWindowProcA',0>
EMIT <_PeekMessage dw 0>,<db 'PeekMessageA',0>
EMIT <_DispatchMessage dw 0>,<db 'DispatchMessageA',0>
EMIT <_LoadCursor dw 0>,<db 'LoadCursorA',0>
EMIT <_SetWindowText dw 0>,<db 'SetWindowTextA',0>
EMIT <_AdjustWindowRect dw 0>,<db 'AdjustWindowRect',0>
EMIT <_GetDC dw 0>,<db 'GetDC',0>
EMIT <_ReleaseDC dw 0>,<db 'ReleaseDC',0>
EMIT <_PostQuitMessage dw 0>,<db 'PostQuitMessage',0>
EMIT <_MessageBox dw 0>,<db 'MessageBoxA',0>

EMIT <_DeleteDC dw 0>,<db 'DeleteDC',0>
EMIT <_SetPixelFormat dw 0>,<db 'SetPixelFormat',0>
EMIT <_ChoosePixelFormat dw 0>,<db 'ChoosePixelFormat',0>
EMIT <_SwapBuffers dw 0>,<db 'SwapBuffers',0>

EMIT <_CoInitialize dw 0>,<db 'CoInitialize',0>
EMIT <_CoCreateInstance dw 0>,<db 'CoCreateInstance',0>

EMIT <_AvSetMmThreadCharacteristics dw 0>,<db 'AvSetMmThreadCharacteristicsA',0>
;========================================================================