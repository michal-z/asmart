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
SRCCOPY = 0x00CC0020
OPEN_EXISTING = 3
GENERIC_READ = 0x80000000
INVALID_HANDLE_VALUE = 0xffffffffffffffff
INVALID_FILE_SIZE = 0xffffffff
FILE_ATTRIBUTE_NORMAL = 128
FILE_FLAG_SEQUENTIAL_SCAN = 0x08000000
EVENT_ALL_ACCESS = 0x1F0003
;=============================================================================
macro strucOffsetsSize s {
  virtual at 0
    s s
    sizeof.#s = $
  end virtual }

macro dalign value* {
  db ((value - 1) - (($-$$) + (value - 1)) mod value) dup 0 }

macro mov op1*, op2*, op3 {
  if op3 eq
                        mov  op1, op2
  else
                        mov  op2, op3
                        mov  op1, op2
  end if }
 
macro lea op1*, op2*, op3 {
  if op3 eq
                        lea  op1, op2
  else
                        lea  op2, op3
                        mov  op1, op2
  end if }
 
macro iacaBegin {
                        mov  ebx, 111
                         db  64h, 67h, 90h }

macro iacaEnd {
                        mov  ebx, 222
                         db  64h, 67h, 90h }

macro debugBreak {
                       int3
                        nop }

macro zeroStack size* {
                      vpxor  ymm0, ymm0, ymm0
                        xor  eax, eax
                        mov  ecx, size/32
  @@:               vmovdqa  [rsp+rax], ymm0
                        add  eax, 32
                        sub  ecx, 1
                        jnz  @b }

macro icall target* {
                       call  [target] }
;=============================================================================
struc dwa [data] {
  common
  dalign 2
  . dw data }

struc dda [data] {
  common
  dalign 4
  . dd data }

struc dqa [data] {
  common
  dalign 8
  . dq data }

struc POINT {
  dalign 4
  .:
  .x    dda 0
  .y    dda 0
  dalign 4 }

struc MSG {
  dalign 8
  .:
  .hwnd         dqa 0
  .message      dda 0
  .wParam       dqa 0
  .lParam       dqa 0
  .time         dda 0
  .pt           POINT
  dalign 8 }

struc WNDCLASS {
  dalign 8
  .:
  .style                dda 0
  .lpfnWndProc          dqa 0
  .cbClsExtra           dda 0
  .cbWndExtra           dda 0
  .hInstance            dqa 0
  .hIcon                dqa 0
  .hCursor              dqa 0
  .hbrBackground        dqa 0
  .lpszMenuName         dqa 0
  .lpszClassName        dqa 0
  dalign 8 }

struc RECT {
  dalign 4
  .:
  .left         dda 0
  .top          dda 0
  .right        dda 0
  .bottom       dda 0
  dalign 4 }

struc BITMAPINFOHEADER {
  dalign 4
  .:
  .biSize               dda 0
  .biWidth              dda 0
  .biHeight             dda 0
  .biPlanes             dwa 0
  .biBitCount           dwa 0
  .biCompression        dda 0
  .biSizeImage          dda 0
  .biXPelsPerMeter      dda 0
  .biYPelsPerMeter      dda 0
  .biClrUsed            dda 0
  .biClrImportant       dda 0
  dalign 4 }

strucOffsetsSize BITMAPINFOHEADER
;=============================================================================
k_win_style equ WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX
;=============================================================================
section '.text' code readable executable
;=============================================================================
align 32
check_cpu_extensions:
;-----------------------------------------------------------------------------
                        mov  eax, 1
                      cpuid
                        and  ecx, 58001000h          ; check RDRAND,AVX,OSXSAVE,FMA
                        cmp  ecx, 58001000h
                        jne  .not_supported
                        mov  eax, 7
                        xor  ecx, ecx
                      cpuid
                        and  ebx, 20h                ; check AVX2
                        cmp  ebx, 20h
                        jne  .not_supported
                        xor  ecx, ecx
                     xgetbv
                        and  eax, 6h                 ; check OS support
                        cmp  eax, 6h
                        jne  .not_supported
                        mov  eax, 1
                        jmp  .ret
  .not_supported:       xor  eax, eax
  .ret:                 ret
;=============================================================================
align 32
get_time:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub  rsp, .k_stack_size
                        mov  rax, [.perf_freq]
                       test  rax, rax
                        jnz  @f
                        lea  rcx, [.perf_freq]
                      icall  QueryPerformanceFrequency
                        lea  rcx, [.first_perf_counter]
                      icall  QueryPerformanceCounter
  @@:                   lea  rcx, [.perf_counter]
                      icall  QueryPerformanceCounter
                        mov  rcx, [.perf_counter]
                        sub  rcx, [.first_perf_counter]
                        mov  rdx, [.perf_freq]
                     vxorps  xmm0, xmm0, xmm0
                  vcvtsi2sd  xmm1, xmm0, rcx
                  vcvtsi2sd  xmm2, xmm0, rdx
                     vdivsd  xmm0, xmm1, xmm2
                        add  rsp, .k_stack_size
                        ret
;=============================================================================
align 32
update_frame_stats:
;-----------------------------------------------------------------------------
  virtual at rsp
  rq 4
  .text rb 64
  dalign 32
  .k_stack_size = $-$$+24
  end virtual
                        sub  rsp, .k_stack_size
                        mov  rax, [.prev_time]
                       test  rax, rax
                        jnz  @f
                       call  get_time
                     vmovsd  [.prev_time], xmm0
                     vmovsd  [.prev_update_time], xmm0
  @@:                  call  get_time                       ; xmm0 = (0,time)
                     vmovsd  [time], xmm0
                     vsubsd  xmm1, xmm0, [.prev_time]       ; xmm1 = (0,time_delta)
                     vmovsd  [.prev_time], xmm0
                     vxorps  xmm2, xmm2, xmm2
                  vcvtsd2ss  xmm1, xmm2, xmm1            ; xmm1 = (0,0,0,time_delta)
                     vmovss  [time_delta], xmm1
                     vmovsd  xmm1, [.prev_update_time]     ; xmm1 = (0,prev_update_time)
                     vsubsd  xmm2, xmm0, xmm1               ; xmm2 = (0,time-prev_update_time)
                     vmovsd  xmm3, [.k_1_0]                ; xmm3 = (0,1.0)
                    vcomisd  xmm2, xmm3
                         jb  @f
                     vmovsd  [.prev_update_time], xmm0
                        mov  eax, [.frame]
                     vxorpd  xmm1, xmm1, xmm1
                  vcvtsi2sd  xmm1, xmm1, eax             ; xmm1 = (0,frame)
                     vdivsd  xmm0, xmm1, xmm2               ; xmm0 = (0,frame/(time-prev_update_time))
                     vdivsd  xmm1, xmm2, xmm1
                     vmulsd  xmm1, xmm1, [.k_1000000_0]
                        mov  [.frame], 0
                        lea  rcx, [.text]
                        lea  rdx, [_win_text_fmt]
                  vcvtsd2si  r8, xmm0
                  vcvtsd2si  r9, xmm1
                      icall  wsprintf
                        mov  rcx, [win_handle]
                        lea  rdx, [.text]
                      icall  SetWindowText
  @@:                   add  [.frame], 1
                        add  rsp, .k_stack_size
                        ret
;=============================================================================
align 32
init_window:
;-----------------------------------------------------------------------------
  virtual at rsp
  rept 12 n:1 { .param#n dq ? }
  .wc           WNDCLASS
  .rect         RECT
  .bmp_info     BITMAPINFOHEADER
  dalign 32
  .k_stack_size = $-$$+16
  end virtual
                       push  rsi

                          ; alloc and clear the stack
                        sub  rsp, .k_stack_size
                  zeroStack  .k_stack_size

                          ; create window class
                        lea  [.wc.lpfnWndProc], rax, [win_message_handler]
                        lea  [.wc.lpszClassName], rax, [_win_class_name]
                        xor  ecx, ecx
                      icall  GetModuleHandle
                        mov  [.wc.hInstance], rax
                        xor  ecx, ecx
                        mov  edx, IDC_ARROW
                      icall  LoadCursor
                        mov  [.wc.hCursor], rax
                        lea  rcx, [.wc]
                       call  [RegisterClass]
                       test  eax, eax
                         jz  .error

                          ; compute window size
                        mov  [.rect.right], eax, [win_width]
                        mov  [.rect.bottom], eax, [win_height]
                        lea  rcx, [.rect]
                        mov  edx, k_win_style
                        xor  r8d, r8d
                      icall  AdjustWindowRect
                        mov  r10d, [.rect.right]
                        mov  r11d, [.rect.bottom]
                        sub  r10d, [.rect.left]
                        sub  r11d, [.rect.top]

                          ; create window
                        xor  ecx, ecx
                        lea  rdx, [_win_class_name]
                        mov  r8, rdx
                        mov  r9d, WS_VISIBLE+k_win_style
                        mov  dword[.param5], CW_USEDEFAULT
                        mov  dword[.param6], CW_USEDEFAULT
                        mov  [.param7], r10
                        mov  [.param8], r11
                        mov  [.param9], 0
                        mov  [.param10], 0
                        mov  [.param11], rax, [.wc.hInstance]
                        mov  [.param12], 0
                      icall  CreateWindowEx
                        mov  [win_handle], rax
                       test  rax, rax
                         jz  .error

                          ; create bitmap
                        mov  rcx, [win_handle]
                      icall  GetDC
                        mov  [win_hdc], rax
                       test  rax, rax
                         jz  .error
                        mov  [.bmp_info.biSize], eax, sizeof.BITMAPINFOHEADER
                        mov  [.bmp_info.biWidth], eax, [win_width]
                        mov  [.bmp_info.biHeight], eax, [win_height]
                        mov  [.bmp_info.biPlanes], 1
                        mov  [.bmp_info.biBitCount], 32
                        mov  eax, [win_width]
                       imul  eax, [win_height]
                        mov  [.bmp_info.biSizeImage], eax
                        mov  rcx, [win_hdc]
                        lea  rdx, [.bmp_info]
                        xor  r8d, r8d
                        lea  r9, [win_pixels]
                        mov  [.param5], 0
                        mov  [.param6], 0
                      icall  CreateDIBSection
                        mov  [win_bmp_handle], rax
                       test  rax, rax
                         jz  .error
                        mov  rcx, [win_hdc]
                      icall  CreateCompatibleDC
                        mov  [win_bmp_hdc], rax
                       test  rax, rax
                         jz  .error
                        mov  rcx, [win_bmp_hdc]
                        mov  rdx, [win_bmp_handle]
                      icall  SelectObject
                       test  eax, eax
                         jz  .error

                        mov  eax, 1
                        add  rsp, .k_stack_size
                        pop  rsi
                        ret
  .error:               xor  eax, eax
                        add  rsp, .k_stack_size
                        pop  rsi
                        ret
;=============================================================================
align 32
init:
;-----------------------------------------------------------------------------
macro getFunc lib, proc {
                        mov  rcx, [lib#_dll]
                        lea  rdx, [_#proc]
                      icall  GetProcAddress
                        mov  [proc], rax
                       test  rax, rax
                         jz  .error }

  .k_stack_size = 32*1+24
                        sub  rsp, .k_stack_size
                          ; load APIs
                        lea  rcx, [_kernel32_dll]
                      icall  LoadLibrary
                        mov  [kernel32_dll], rax
                       test  rax, rax
                         jz  .error
                        lea  rcx, [_user32_dll]
                      icall  LoadLibrary
                        mov  [user32_dll], rax
                       test  rax, rax
                         jz  .error
                        lea  rcx, [_gdi32_dll]
                      icall  LoadLibrary
                        mov  [gdi32_dll], rax
                       test  rax, rax
                         jz  .error

                    getFunc  kernel32, ExitProcess
                    getFunc  kernel32, GetModuleHandle
                    getFunc  kernel32, ExitThread
                    getFunc  kernel32, QueryPerformanceFrequency
                    getFunc  kernel32, QueryPerformanceCounter
                    getFunc  kernel32, CloseHandle
                    getFunc  kernel32, Sleep
                    getFunc  kernel32, FreeLibrary
                    getFunc  kernel32, HeapAlloc
                    getFunc  kernel32, HeapReAlloc
                    getFunc  kernel32, HeapFree
                    getFunc  kernel32, CreateFile
                    getFunc  kernel32, ReadFile
                    getFunc  kernel32, GetFileSize
                    getFunc  kernel32, GetProcessHeap
                    getFunc  kernel32, CreateEventEx
                    getFunc  kernel32, CreateThread
                    getFunc  kernel32, SetEvent
                    getFunc  kernel32, WaitForSingleObject
                    getFunc  kernel32, WaitForMultipleObjects

                    getFunc  user32, wsprintf
                    getFunc  user32, RegisterClass
                    getFunc  user32, CreateWindowEx
                    getFunc  user32, DefWindowProc
                    getFunc  user32, PeekMessage
                    getFunc  user32, DispatchMessage
                    getFunc  user32, LoadCursor
                    getFunc  user32, SetWindowText
                    getFunc  user32, AdjustWindowRect
                    getFunc  user32, GetDC
                    getFunc  user32, ReleaseDC
                    getFunc  user32, PostQuitMessage
                    getFunc  user32, MessageBox

                    getFunc  gdi32, CreateDIBSection
                    getFunc  gdi32, CreateCompatibleDC
                    getFunc  gdi32, SelectObject
                    getFunc  gdi32, BitBlt
                    getFunc  gdi32, DeleteDC
                    getFunc  gdi32, DeleteObject

                          ; check CPU
                       call  check_cpu_extensions
                       test  eax, eax
                         jz  .error

                          ; get process heap
                      icall  GetProcessHeap
                        mov  [process_heap], rax
                       test  rax, rax
                         jz  .error

                          ; create window
                       call  init_window
                       test  eax, eax
                         jz  .error

                        mov  eax, 1
                        add  rsp, .k_stack_size
                        ret
  .error:               xor  eax, eax
                        add  rsp, .k_stack_size
                        ret
purge getFunc
;=============================================================================
align 32
deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub  rsp, .k_stack_size
                        add  rsp, .k_stack_size
                        ret
;=============================================================================
align 32
update:
;-----------------------------------------------------------------------------
  virtual at rsp
  rept 9 n:1 { .param#n dq ? }
  dalign 32
  .k_stack_size = $-$$+24
  end virtual
                        sub  rsp, .k_stack_size
                       call  update_frame_stats

                   vpcmpeqd  ymm0, ymm0, ymm0
                        mov  rax, [win_pixels]

                        mov  ecx, 100000
  @@:              vmovntdq  [rax], ymm0
                        add  rax, 32
                        sub  ecx, 1
                        jnz  @b
                     mfence

                        mov  rcx, [win_hdc]
                        xor  edx, edx
                        xor  r8d, r8d
                        mov  r9d, [win_width]
                        mov  dword[.param5], eax, [win_height]
                        mov  [.param6], rax, [win_bmp_hdc]
                        mov  [.param7], 0
                        mov  [.param8], 0
                        mov  dword[.param9], SRCCOPY
                      icall  BitBlt

                        add  rsp, .k_stack_size
                        ret
;=============================================================================
align 32
start:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .msg MSG
  align 32
  .k_stack_size = $
end virtual
                        and  rsp, -32
                        sub  rsp, .k_stack_size
                       call  init
                       test  eax, eax
                         jz  .quit
  .main_loop:
                        lea  rcx, [.msg+rsp]
                        xor  edx, edx
                        xor  r8d, r8d
                        xor  r9d, r9d
                        mov  dword[rsp+32], PM_REMOVE
                      icall  PeekMessage
                       test  eax, eax
                         jz  .update

                        lea  rcx, [.msg+rsp]
                      icall  DispatchMessage
                        cmp  [.msg.message+rsp], WM_QUIT
                         je  .quit
                        jmp  .main_loop
  .update:
                       call  update
                        jmp  .main_loop
  .quit:
                       call  deinit
                        xor  ecx, ecx
                      icall  ExitProcess
;=============================================================================
align 32
win_message_handler:
;-----------------------------------------------------------------------------
  .k_stack_size = 16*2+8
                        sub  rsp, .k_stack_size
                        cmp  edx, WM_KEYDOWN
                         je  .keydown
                        cmp  edx, WM_DESTROY
                         je  .destroy
                       call  [DefWindowProc]
                        jmp  .return
  .keydown:
                        cmp  r8d, VK_ESCAPE
                        jne  .return
                        xor  ecx, ecx
                      icall  PostQuitMessage
                        xor  eax, eax
                        jmp  .return
  .destroy:
                        xor  ecx, ecx
                       call  [PostQuitMessage]
                        xor  eax, eax
  .return:
                        add  rsp, .k_stack_size
                        ret
;========================================================================
section '.data' data readable writeable

align 8
win_handle dq 0
win_hdc dq 0
win_bmp_handle dq 0
win_bmp_hdc dq 0
win_pixels dq 0
win_width dd 1280
win_height dd 720

align 8
process_heap dq 0
time dq 0
time_delta dd 0,0

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
kernel32_dll dq 0
user32_dll dq 0
gdi32_dll dq 0

align 8
GetModuleHandle dq 0
ExitProcess dq 0
ExitThread dq 0
QueryPerformanceFrequency dq 0
QueryPerformanceCounter dq 0
CloseHandle dq 0
Sleep dq 0
FreeLibrary dq 0
HeapAlloc dq 0
HeapReAlloc dq 0
HeapFree dq 0
CreateFile dq 0
ReadFile dq 0
GetFileSize dq 0
GetProcessHeap dq 0
CreateEventEx dq 0
CreateThread dq 0
SetEvent dq 0
WaitForSingleObject dq 0
WaitForMultipleObjects dq 0

wsprintf dq 0
RegisterClass dq 0
CreateWindowEx dq 0
DefWindowProc dq 0
PeekMessage dq 0
DispatchMessage dq 0
LoadCursor dq 0
SetWindowText dq 0
AdjustWindowRect dq 0
GetDC dq 0
ReleaseDC dq 0
PostQuitMessage dq 0
MessageBox dq 0

DeleteDC dq 0
CreateDIBSection dq 0
CreateCompatibleDC dq 0
SelectObject dq 0
BitBlt dq 0
DeleteObject dq 0

align 1
_win_text_fmt db '[%d fps  %d us] Base Code',0
_win_class_name db 'Base Code',0

_kernel32_dll db 'kernel32.dll',0
_user32_dll db 'user32.dll',0
_gdi32_dll db 'gdi32.dll',0

_GetModuleHandle db 'GetModuleHandleA',0
_ExitProcess db 'ExitProcess',0
_ExitThread db 'ExitThread',0
_QueryPerformanceFrequency db 'QueryPerformanceFrequency',0
_QueryPerformanceCounter db 'QueryPerformanceCounter',0
_CloseHandle db 'CloseHandle',0
_Sleep db 'Sleep',0
_FreeLibrary db 'FreeLibrary',0
_HeapAlloc db 'HeapAlloc',0
_HeapReAlloc db 'HeapReAlloc',0
_HeapFree db 'HeapFree',0
_CreateFile db 'CreateFileA',0
_ReadFile db 'ReadFile',0
_GetFileSize db 'GetFileSize',0
_GetProcessHeap db 'GetProcessHeap',0
_CreateEventEx db 'CreateEventExA',0
_CreateThread db 'CreateThread',0
_SetEvent db 'SetEvent',0
_WaitForSingleObject db 'WaitForSingleObject',0
_WaitForMultipleObjects db 'WaitForMultipleObjects',0

_wsprintf db 'wsprintfA',0
_RegisterClass db 'RegisterClassA',0
_CreateWindowEx db 'CreateWindowExA',0
_DefWindowProc db 'DefWindowProcA',0
_PeekMessage db 'PeekMessageA',0
_DispatchMessage db 'DispatchMessageA',0
_LoadCursor db 'LoadCursorA',0
_SetWindowText db 'SetWindowTextA',0
_AdjustWindowRect db 'AdjustWindowRect',0
_GetDC db 'GetDC',0
_ReleaseDC db 'ReleaseDC',0
_PostQuitMessage db 'PostQuitMessage',0
_MessageBox db 'MessageBoxA',0

_DeleteDC db 'DeleteDC',0
_CreateDIBSection db 'CreateDIBSection',0
_CreateCompatibleDC db 'CreateCompatibleDC',0
_SelectObject db 'SelectObject',0
_BitBlt db 'BitBlt',0
_DeleteObject db 'DeleteObject',0
;========================================================================
section '.idata' import data readable writeable

dd 0, 0, 0, rva _kernel32_dll, rva _kernel32_table
dd 0, 0, 0, 0, 0

_kernel32_table:
  LoadLibrary dq rva _LoadLibrary
  GetProcAddress dq rva _GetProcAddress
  dq 0

_LoadLibrary dw 0
db 'LoadLibraryA',0
_GetProcAddress dw 0
db 'GetProcAddress',0
;========================================================================
; vim: ft=fasm autoindent ts=8 sts=0 sw=8 :
