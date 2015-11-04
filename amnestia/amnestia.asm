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

k_funcparam5 = 32
k_funcparam6 = k_funcparam5 + 8
k_funcparam7 = k_funcparam6 + 8
k_funcparam8 = k_funcparam7 + 8
k_funcparam9 = k_funcparam8 + 8
k_funcparam10 = k_funcparam9 + 8
k_funcparam11 = k_funcparam10 + 8
k_funcparam12 = k_funcparam11 + 8

struc POINT p0=0,p1=0 {
.x dd p0
.y dd p1 }

struc MSG p0=0,p1=0,p2=0,p3=0,p4=0,p5=<0,0> {
.hwnd    dq    p0
.message dd    p1,?
.wParam  dq    p2
.lParam  dq    p3
.time    dd    p4
.pt      POINT p5
         dd    ? }

struc WNDCLASSEX p0=0,p1=0,p2=0,p3=0,p4=0,p5=0,p6=0,p7=0,p8=0,p9=0,p10=0 {
.cbSize        dd 80
.style         dd p0
.lpfnWndProc   dq p1
.cbClsExtra    dd p2
.cbWndExtra    dd p3
.hInstance     dq p4
.hIcon         dq p5
.hCursor       dq p6
.hbrBackground dq p7
.lpszMenuName  dq p8
.lpszClassName dq p9
.hIconSm       dq p10 }

struc RECT p0=0,p1=0,p2=0,p3=0 {
.left   dd p0
.top    dd p1
.right  dd p2
.bottom dd p3 }

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
vxorps xmm0,xmm0,xmm0
vcvtsi2sd xmm1,xmm0,rcx
vcvtsi2sd xmm2,xmm0,rdx
vdivsd xmm0,xmm1,xmm2
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
vmovsd [.prev_time],xmm0
vmovsd [.prev_update_time],xmm0
  @@:
call get_time                       ; xmm0 = (0,time)
vmovsd [time],xmm0
vsubsd xmm1,xmm0,[.prev_time]       ; xmm1 = (0,time_delta)
vmovsd [.prev_time],xmm0
vxorps xmm2,xmm2,xmm2
vcvtsd2ss xmm1,xmm2,xmm1            ; xmm1 = (0,0,0,time_delta)
vmovss [time_delta],xmm1
vmovsd xmm1,[.prev_update_time]     ; xmm1 = (0,prev_update_time)
vsubsd xmm2,xmm0,xmm1               ; xmm2 = (0,time-prev_update_time)
vmovsd xmm3,[.k_1_0]                ; xmm3 = (0,1.0)
vcomisd xmm2,xmm3
jb @f
vmovsd [.prev_update_time],xmm0
mov eax,[.frame]
vxorpd xmm1,xmm1,xmm1
vcvtsi2sd xmm1,xmm1,eax             ; xmm1 = (0,frame)
vdivsd xmm0,xmm1,xmm2               ; xmm0 = (0,frame/(time-prev_update_time))
vdivsd xmm1,xmm2,xmm1
vmulsd xmm1,xmm1,[.k_1000000_0]
mov [.frame],0
lea rcx,[win_title]
lea rdx,[win_title_fmt]
vcvtsd2si r8,xmm0
vcvtsd2si r9,xmm1
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
mov edx,IDI_APPLICATION
call [LoadIcon]
mov [win_class.hIcon],rax
mov [win_class.hIconSm],rax
xor ecx,ecx
mov edx,IDC_ARROW
call [LoadCursor]
mov [win_class.hCursor],rax
mov rcx,win_class
call [RegisterClassEx]
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
mov eax,1
add rsp,.k_stack_size
pop rsi
ret
  .error:
xor eax,eax
add rsp,.k_stack_size
pop rsi
ret
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
win_title db 'amnestia', 64 dup 0
win_title_fmt db '[%d fps  %d us] amnestia',0
win_msg MSG
win_class WNDCLASSEX 0,winproc,0,0,0,0,0,0,0,win_title,0
win_rect RECT 0,0,k_win_width,k_win_height

align 8
time dq 0
time_delta dd 0

get_time.perf_counter dq 0
get_time.perf_freq dq 0
get_time.first_perf_counter dq 0

update_frame_stats.prev_time dq 0
update_frame_stats.prev_update_time dq 0
update_frame_stats.frame dd 0,0
update_frame_stats.k_1000000_0 dq 1000000.0
update_frame_stats.k_1_0 dq 1.0
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
dq 0

_user32_table:
wsprintf dq rva _wsprintf
RegisterClassEx dq rva _RegisterClassEx
CreateWindowEx dq rva _CreateWindowEx
DefWindowProc dq rva _DefWindowProc
PeekMessage dq rva _PeekMessage
DispatchMessage dq rva _DispatchMessage
LoadCursor dq rva _LoadCursor
LoadIcon dq rva _LoadIcon
SetWindowText dq rva _SetWindowText
AdjustWindowRect dq rva _AdjustWindowRect
GetDC dq rva _GetDC
ReleaseDC dq rva _ReleaseDC
PostQuitMessage dq rva _PostQuitMessage
MessageBox dq rva _MessageBox
dq 0

_gdi32_table:
DeleteDC dq rva _DeleteDC
dq 0

_kernel32 db 'kernel32.dll',0
_user32 db 'user32.dll',0
_gdi32 db 'gdi32.dll',0

emit <_GetModuleHandle dw 0>,<db 'GetModuleHandleA',0>
emit <_ExitProcess dw 0>,<db 'ExitProcess',0>
emit <_QueryPerformanceFrequency dw 0>,<db 'QueryPerformanceFrequency',0>
emit <_QueryPerformanceCounter dw 0>,<db 'QueryPerformanceCounter',0>
emit <_CloseHandle dw 0>,<db 'CloseHandle',0>

emit <_wsprintf dw 0>,<db 'wsprintfA',0>
emit <_RegisterClassEx dw 0>,<db 'RegisterClassExA',0>
emit <_CreateWindowEx dw 0>,<db 'CreateWindowExA',0>
emit <_DefWindowProc dw 0>,<db 'DefWindowProcA',0>
emit <_PeekMessage dw 0>,<db 'PeekMessageA',0>
emit <_DispatchMessage dw 0>,<db 'DispatchMessageA',0>
emit <_LoadCursor dw 0>,<db 'LoadCursorA',0>
emit <_LoadIcon dw 0>,<db 'LoadIconA',0>
emit <_SetWindowText dw 0>,<db 'SetWindowTextA',0>
emit <_AdjustWindowRect dw 0>,<db 'AdjustWindowRect',0>
emit <_GetDC dw 0>,<db 'GetDC',0>
emit <_ReleaseDC dw 0>,<db 'ReleaseDC',0>
emit <_PostQuitMessage dw 0>,<db 'PostQuitMessage',0>
emit <_MessageBox dw 0>,<db 'MessageBoxA',0>

emit <_DeleteDC dw 0>,<db 'DeleteDC',0>
;========================================================================
