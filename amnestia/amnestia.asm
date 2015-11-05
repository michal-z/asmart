format PE64 GUI 4.0
entry start

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
.hwnd    dq    0
.message dd    0,0
.wParam  dq    0
.lParam  dq    0
.time    dd    0
.pt      POINT
         dd    0 }

struc WNDCLASS proc,name {
.style         dd 0,0
.lpfnWndProc   dq proc
.cbClsExtra    dd 0
.cbWndExtra    dd 0
.hInstance     dq 0
.hIcon         dq 0
.hCursor       dq 0
.hbrBackground dq 0
.lpszMenuName  dq 0
.lpszClassName dq name }

struc RECT l,t,r,b {
.left   dd l
.top    dd t
.right  dd r
.bottom dd b }

struc PIXELFORMATDESCRIPTOR {
.nSize           dw 40
.nVersion        dw 1
.dwFlags         dd PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER
.iPixelType      db PFD_TYPE_RGBA
.cColorBits      db 32
.cRedBits        db 0
.cRedShift       db 0
.cGreenBits      db 0
.cGreenShift     db 0
.cBlueBits       db 0
.cBlueShift      db 0
.cAlphaBits      db 0
.cAlphaShift     db 0
.cAccumBits      db 0
.cAccumRedBits   db 0
.cAccumGreenBits db 0
.cAccumBlueBits  db 0
.cAccumAlphaBits db 0
.cDepthBits      db 24
.cStencilBits    db 8
.cAuxBuffers     db 0
.iLayerType      db 0
.bReserved       db 0
.dwLayerMask     dd 0
.dwVisibleMask   dd 0
.dwDamageMask    dd 0 }

section '.text' code readable executable
;========================================================================
macro emit [inst] {
forward
inst }

macro iaca_begin {
mov ebx,111
db $64,$67,$90 }

macro iaca_end {
mov ebx,222
db $64,$67,$90 }
;=============================================================================
align 32
get_time:
;-----------------------------------------------------------------------------
  .k_stack_size = 7*8
sub rsp,.k_stack_size
mov rax,[.perf_freq]
test rax,rax
jnz @f
lea rcx,[.perf_freq]
call [QueryPerformanceFrequency]
lea rcx,[.first_perf_counter]
call [QueryPerformanceCounter]
  @@:
lea rcx,[.perf_counter]
call [QueryPerformanceCounter]
mov rcx,[.perf_counter]
sub rcx,[.first_perf_counter]
mov rdx,[.perf_freq]
xorps xmm0,xmm0
cvtsi2sd xmm0,rcx
xorps xmm1,xmm1
cvtsi2sd xmm1,rdx
divsd xmm0,xmm1
add rsp,.k_stack_size
ret
;=============================================================================
align 32
update_frame_stats:
;-----------------------------------------------------------------------------
  .k_stack_size = 7*8
sub rsp,.k_stack_size
mov rax,[.prev_time]
test rax,rax
jnz @f
call get_time
movsd [.prev_time],xmm0
movsd [.prev_update_time],xmm0
  @@:
call get_time                       ; xmm0 = (0,time)
movsd [time],xmm0
movapd xmm1,xmm0
subsd xmm1,[.prev_time]             ; xmm1 = (0,time_delta)
movsd [.prev_time],xmm0
xorpd xmm2,xmm2
cvtsd2ss xmm1,xmm1                  ; xmm1 = (0,0,0,time_delta)
movss [time_delta],xmm1
movsd xmm1,[.prev_update_time]      ; xmm1 = (0,prev_update_time)
movapd xmm2,xmm0
subsd xmm2,xmm1                     ; xmm2 = (0,time-prev_update_time)
movsd xmm3,[.k_1_0]                 ; xmm3 = (0,1.0)
comisd xmm2,xmm3
jb @f
movsd [.prev_update_time],xmm0
mov eax,[.frame]
xorpd xmm1,xmm1
cvtsi2sd xmm1,eax                   ; xmm1 = (0,frame)
movapd xmm3,xmm1
divsd xmm1,xmm2                     ; xmm1 = (0,frame/(time-prev_update_time))
divsd xmm2,xmm3                     ; xmm2 = (0,(time-prev_update_time)/frame)
mulsd xmm2,[.k_1000000_0]
mov [.frame],0
lea rcx,[win_title]
lea rdx,[win_title_fmt]
cvtsd2si r8,xmm1
cvtsd2si r9,xmm2
call [wsprintf]
mov rcx,[win_handle]
lea rdx,[win_title]
call [SetWindowText]
  @@:
add [.frame],1
add rsp,.k_stack_size
ret
;=============================================================================
align 32
init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 12
  .k_stack_size = $+16
end virtual
push rsi
sub rsp,.k_stack_size
; window class
xor ecx,ecx
call [GetModuleHandle]
mov [win_class.hInstance],rax
xor ecx,ecx
mov edx,IDC_ARROW
call [LoadCursor]
mov [win_class.hCursor],rax
mov rcx,win_class
call [RegisterClass]
test eax,eax
jz .error
; window
mov rcx,win_rect
mov edx,k_win_style
xor r8d,r8d
call [AdjustWindowRect]
mov r10d,[win_rect.right]
mov r11d,[win_rect.bottom]
sub r10d,[win_rect.left]
sub r11d,[win_rect.top]
xor ecx,ecx
mov rdx,win_title
mov r8,rdx
mov r9d,WS_VISIBLE+k_win_style
mov eax,CW_USEDEFAULT
mov [k_funcparam5+rsp],eax
mov [k_funcparam6+rsp],eax
mov [k_funcparam7+rsp],r10d
mov [k_funcparam8+rsp],r11d
mov [k_funcparam9+rsp],ecx
mov [k_funcparam10+rsp],ecx
mov rax,[win_class.hInstance]
mov [k_funcparam11+rsp],rax
mov [k_funcparam12+rsp],ecx
call [CreateWindowEx]
mov [win_handle],rax
test rax,rax
jz .error
mov rcx,[win_handle]
call [GetDC]
mov [win_hdc],rax
test rax,rax
jz .error
mov rcx,[win_hdc]
lea rdx,[pfd]
call [ChoosePixelFormat]
mov rcx,[win_hdc]
mov edx,eax
lea r8,[pfd]
call [SetPixelFormat]
test eax,eax
jz .error
mov eax,1
add rsp,.k_stack_size
pop rsi
ret
  .error:
xor eax,eax
add rsp,.k_stack_size
pop rsi
ret
;  HGLRC hrc = state->wglCreateContext_(state->hdc);
;  if (!hrc) return 0;
;  if (!state->wglMakeCurrent_(state->hdc, hrc)) {
;    state->wglDeleteContext_(hrc);
;    return 0;
;  }
;
;  if (!(state->wglCreateContextAttribsARB_ = (wglCreateContextAttribsARB_fn)os_load_gl_func("wglCreateContextAttribsARB"))) return 0;
;
;  int ctx_attribs[] = {
;    WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
;    WGL_CONTEXT_MINOR_VERSION_ARB, 3,
;    WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB,
;    WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
;    0
;  };
;  state->hrc = state->wglCreateContextAttribsARB_(state->hdc, NULL, ctx_attribs);
;
;  if (!state->hrc) {
;    state->wglDeleteContext_(hrc);
;    return 0;
;  }
;  if (!state->wglMakeCurrent_(state->hdc, state->hrc)) {
;    state->wglDeleteContext_(hrc);
;    return 0;
;  }
;  state->wglDeleteContext_(hrc);
;
;  if (!(state->wglSwapIntervalEXT_ = (wglSwapIntervalEXT_fn)os_load_gl_func("wglSwapIntervalEXT"))) return 0;


;  if (state->wglMakeCurrent_) {
;    state->wglMakeCurrent_(NULL, NULL);
;  }
;  if (state->hrc) {
;    state->wglDeleteContext_(state->hrc);
;    state->hrc = NULL;
;  }
;  if (state->hdc) {
;    ReleaseDC(state->hwnd, state->hdc);
;    state->hdc = NULL;
;  }
;  if (state->opengl_dll) {
;    FreeLibrary(state->opengl_dll);
;    state->opengl_dll = NULL;
;  }
;=============================================================================
align 32
deinit:
;-----------------------------------------------------------------------------
ret
;=============================================================================
align 32
update:
;-----------------------------------------------------------------------------
  .k_stack_size = 7*8
sub rsp,.k_stack_size
call update_frame_stats
mov ecx,1
call [Sleep]
add rsp,.k_stack_size
ret
;=============================================================================
align 32
start:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .k_stack_size = $+16
end virtual
sub rsp,.k_stack_size
call init
test eax,eax
jz .quit
  .main_loop:
lea rcx,[win_msg]
xor edx,edx
xor r8d,r8d
xor r9d,r9d
mov dword [k_funcparam5+rsp],PM_REMOVE
call [PeekMessage]
test eax,eax
jz .update
lea rcx,[win_msg]
call [DispatchMessage]
cmp [win_msg.message],WM_QUIT
je .quit
jmp .main_loop
  .update:
call update
jmp .main_loop
  .quit:
call deinit
xor ecx,ecx
call [ExitProcess]
;=============================================================================
align 32
winproc:
;-----------------------------------------------------------------------------
  .k_stack_size = 7*8
sub rsp,.k_stack_size
cmp edx,WM_KEYDOWN
je .keydown
cmp edx,WM_DESTROY
je .destroy
call [DefWindowProc]
jmp .return
  .keydown:
cmp r8d,VK_ESCAPE
jne .return
xor ecx,ecx
call [PostQuitMessage]
xor eax,eax
jmp .return
  .destroy:
xor ecx,ecx
call [PostQuitMessage]
xor eax,eax
  .return:
add rsp,.k_stack_size
ret
;========================================================================
section '.data' data readable writeable

k_win_width = 1280
k_win_height = 720
k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

align 8
win_handle dq 0
win_hdc dq 0
win_title db 'amnestia', 64 dup 0
win_title_fmt db '[%d fps  %d us] amnestia',0
win_msg MSG
win_class WNDCLASS winproc,win_title
win_rect RECT 0,0,k_win_width,k_win_height

align 8
time dq 0
time_delta dd 0,0
pfd PIXELFORMATDESCRIPTOR

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
;========================================================================
section '.idata' import data readable writeable

dd 0,0,0,rva _kernel32,rva _kernel32_table
dd 0,0,0,rva _user32,rva _user32_table
dd 0,0,0,rva _gdi32,rva _gdi32_table
dd 0,0,0,0,0

_kernel32_table:
GetModuleHandle dq rva _GetModuleHandle
ExitProcess dq rva _ExitProcess
QueryPerformanceFrequency dq rva _QueryPerformanceFrequency
QueryPerformanceCounter dq rva _QueryPerformanceCounter
CloseHandle dq rva _CloseHandle
Sleep dq rva _Sleep
LoadLibrary dq rva _LoadLibrary
GetProcAddress dq rva _GetProcAddress
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
dq 0

_kernel32 db 'kernel32.dll',0
_user32 db 'user32.dll',0
_gdi32 db 'gdi32.dll',0

emit <_GetModuleHandle dw 0>,<db 'GetModuleHandleA',0>
emit <_ExitProcess dw 0>,<db 'ExitProcess',0>
emit <_QueryPerformanceFrequency dw 0>,<db 'QueryPerformanceFrequency',0>
emit <_QueryPerformanceCounter dw 0>,<db 'QueryPerformanceCounter',0>
emit <_CloseHandle dw 0>,<db 'CloseHandle',0>
emit <_Sleep dw 0>,<db 'Sleep',0>
emit <_LoadLibrary dw 0>,<db 'LoadLibraryA',0>
emit <_GetProcAddress dw 0>,<db 'GetProcAddress',0>

emit <_wsprintf dw 0>,<db 'wsprintfA',0>
emit <_RegisterClass dw 0>,<db 'RegisterClassA',0>
emit <_CreateWindowEx dw 0>,<db 'CreateWindowExA',0>
emit <_DefWindowProc dw 0>,<db 'DefWindowProcA',0>
emit <_PeekMessage dw 0>,<db 'PeekMessageA',0>
emit <_DispatchMessage dw 0>,<db 'DispatchMessageA',0>
emit <_LoadCursor dw 0>,<db 'LoadCursorA',0>
emit <_SetWindowText dw 0>,<db 'SetWindowTextA',0>
emit <_AdjustWindowRect dw 0>,<db 'AdjustWindowRect',0>
emit <_GetDC dw 0>,<db 'GetDC',0>
emit <_ReleaseDC dw 0>,<db 'ReleaseDC',0>
emit <_PostQuitMessage dw 0>,<db 'PostQuitMessage',0>
emit <_MessageBox dw 0>,<db 'MessageBoxA',0>

emit <_DeleteDC dw 0>,<db 'DeleteDC',0>
emit <_SetPixelFormat dw 0>,<db 'SetPixelFormat',0>
emit <_ChoosePixelFormat dw 0>,<db 'ChoosePixelFormat',0>
;========================================================================
