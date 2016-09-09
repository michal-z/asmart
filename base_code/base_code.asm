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

macro strucOffsetsSize s {
  virtual at 0
    s s
    sizeof.#s = $
  end virtual }

struc POINT {
  .x dd 0
  .y dd 0 }

struc MSG {
  .hwnd dq ?
  .message dd ?, ?
  .wParam dq ?
  .lParam dq ?
  .time dd ?
  .pt POINT
  dd ? }

struc WNDCLASS {
  .style dd ?, ?
  .lpfnWndProc dq ?
  .cbClsExtra dd ?
  .cbWndExtra dd ?
  .hInstance dq ?
  .hIcon dq ?
  .hCursor dq ?
  .hbrBackground dq ?
  .lpszMenuName dq ?
  .lpszClassName dq ? }

struc RECT {
  .left dd ?
  .top dd ?
  .right dd ?
  .bottom dd ? }

struc BITMAPINFOHEADER {
  .biSize dd ?
  .biWidth dd ?
  .biHeight dd ?
  .biPlanes dw ?
  .biBitCount dw ?
  .biCompression dd ?
  .biSizeImage dd ?
  .biXPelsPerMeter dd ?
  .biYPelsPerMeter dd ?
  .biClrUsed dd ?
  .biClrImportant dd ? }

strucOffsetsSize BITMAPINFOHEADER
;========================================================================
macro iaca_begin
  @begin
                        mov  ebx, 111
                         db  $64, $67, $90
  @end

macro iaca_end
  @begin
                        mov  ebx, 222
                         db  $64, $67, $90
  @end

macro debug_break
  @begin
                       int3
                        nop
  @end

macro zero_stack size*
  @begin
                      vpxor  ymm0, ymm0, ymm0
                        xor  eax, eax
                        mov  ecx, size/32
  @@:               vmovdqa  [rsp+rax], ymm0
                        add  eax, 32
                        sub  ecx, 1
                        jnz  @b
  @end

k_win_style equ WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX
;=============================================================================
section '.text' code readable executable
;=============================================================================
align 32
check_cpu_extensions:
;-----------------------------------------------------------------------------
                        mov  eax, 1
                      cpuid
                        and  ecx, $58001000          ; check RDRAND,AVX,OSXSAVE,FMA
                        cmp  ecx, $58001000
                        jne  .not_supported
                        mov  eax, 7
                        xor  ecx, ecx
                      cpuid
                        and  ebx, $20                ; check AVX2
                        cmp  ebx, $20
                        jne  .not_supported
                        xor  ecx, ecx
                     xgetbv
                        and  eax, $6                 ; check OS support
                        cmp  eax, $6
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
                       call  [QueryPerformanceFrequency]
                        lea  rcx, [.first_perf_counter]
                       call  [QueryPerformanceCounter]
  @@:                   lea  rcx, [.perf_counter]
                       call  [QueryPerformanceCounter]
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
virtual at 0
  rq 4
  .text rb 64
  align 32
  .k_stack_size = $+24
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
                        lea  rcx, [.text+rsp]
                        lea  rdx, [_win_text_fmt]
                  vcvtsd2si  r8, xmm0
                  vcvtsd2si  r9, xmm1
                       call  [wsprintf]
                        mov  rcx, [win_handle]
                        lea  rdx, [.text+rsp]
                       call  [SetWindowText]
  @@:                   add  [.frame], 1
                        add  rsp, .k_stack_size
                        ret
;=============================================================================
align 32
init_window:
;-----------------------------------------------------------------------------
virtual at 0
  rq 12
  .wc WNDCLASS
  align 8
  .rect RECT
  align 8
  .bmp_info BITMAPINFOHEADER
  rq 4
  align 32
  .k_stack_size = $+16
end virtual
                       push  rsi

                          ; alloc and clear the stack
                        sub  rsp, .k_stack_size
                 zero_stack  .k_stack_size

                          ; create window class
                        lea  rax, [win_message_handler]
                        mov  [.wc.lpfnWndProc+rsp], rax
                        lea  rax, [_win_class_name]
                        mov  [.wc.lpszClassName+rsp], rax
                        xor  ecx, ecx
                       call  [GetModuleHandle]
                        mov  [.wc.hInstance+rsp], rax
                        xor  ecx, ecx
                        mov  edx, IDC_ARROW
                       call  [LoadCursor]
                        mov  [.wc.hCursor+rsp], rax
                        lea  rcx, [.wc+rsp]
                       call  [RegisterClass]
                       test  eax, eax
                         jz  .error

                          ; compute window size
                        mov  eax, [win_width]
                        mov  [.rect.right+rsp], eax
                        mov  eax, [win_height]
                        mov  [.rect.bottom+rsp], eax
                        lea  rcx, [.rect+rsp]
                        mov  edx, k_win_style
                        xor  r8d, r8d
                       call  [AdjustWindowRect]
                        mov  r10d, [.rect.right+rsp]
                        mov  r11d, [.rect.bottom+rsp]
                        sub  r10d, [.rect.left+rsp]
                        sub  r11d, [.rect.top+rsp]

                          ; create window
                        xor  ecx, ecx
                        lea  rdx, [_win_class_name]
                        mov  r8, rdx
                        mov  r9d, WS_VISIBLE+k_win_style
                        mov  eax, CW_USEDEFAULT
                        mov  [rsp+32], eax
                        mov  [rsp+40], eax
                        mov  [rsp+48], r10d
                        mov  [rsp+56], r11d
                        mov  [rsp+64], ecx
                        mov  [rsp+72], ecx
                        mov  rax, [.wc.hInstance+rsp]
                        mov  [rsp+80], rax
                        mov  [rsp+88], ecx
                       call  [CreateWindowEx]
                        mov  [win_handle], rax
                       test  rax, rax
                         jz  .error

                          ; create bitmap
                        mov  rcx, [win_handle]
                       call  [GetDC]
                        mov  [win_hdc], rax
                       test  rax, rax
                         jz  .error
                        mov  eax, sizeof.BITMAPINFOHEADER
                        mov  [.bmp_info.biSize+rsp], eax
                        mov  eax, [win_width]
                        mov  [.bmp_info.biWidth+rsp], eax
                        mov  eax, [win_height]
                        mov  [.bmp_info.biHeight+rsp], eax
                        mov  [.bmp_info.biPlanes+rsp], 1
                        mov  [.bmp_info.biBitCount+rsp], 32
                        mov  eax, [win_width]
                       imul  eax, [win_height]
                        mov  [.bmp_info.biSizeImage+rsp], eax
                        mov  rcx, [win_hdc]
                        lea  rdx, [.bmp_info+rsp]
                        xor  r8d, r8d
                        lea  r9, [win_pixels]
                        mov  qword[rsp+32], 0
                        mov  qword[rsp+40], 0
                       call  [CreateDIBSection]
                        mov  [win_bmp_handle], rax
                       test  rax, rax
                         jz  .error
                        mov  rcx, [win_hdc]
                       call  [CreateCompatibleDC]
                        mov  [win_bmp_hdc], rax
                       test  rax, rax
                         jz  .error
                        mov  rcx, [win_bmp_hdc]
                        mov  rdx, [win_bmp_handle]
                       call  [SelectObject]
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
macro get_func lib, proc
  @begin
                        mov  rcx, [lib#_dll]
                        lea  rdx, [_#proc]
                       call  [GetProcAddress]
                        mov  [proc], rax
                       test  rax, rax
                         jz  .error
  @end

  .k_stack_size = 32*1+24
                        sub  rsp, .k_stack_size
                          ; load APIs
                        lea  rcx, [_kernel32_dll]
                       call  [LoadLibrary]
                        mov  [kernel32_dll], rax
                       test  rax, rax
                         jz  .error
                        lea  rcx, [_user32_dll]
                       call  [LoadLibrary]
                        mov  [user32_dll], rax
                       test  rax, rax
                         jz  .error
                        lea  rcx, [_gdi32_dll]
                       call  [LoadLibrary]
                        mov  [gdi32_dll], rax
                       test  rax, rax
                         jz  .error

                   get_func  kernel32, ExitProcess
                   get_func  kernel32, GetModuleHandle
                   get_func  kernel32, ExitThread
                   get_func  kernel32, QueryPerformanceFrequency
                   get_func  kernel32, QueryPerformanceCounter
                   get_func  kernel32, CloseHandle
                   get_func  kernel32, Sleep
                   get_func  kernel32, FreeLibrary
                   get_func  kernel32, HeapAlloc
                   get_func  kernel32, HeapReAlloc
                   get_func  kernel32, HeapFree
                   get_func  kernel32, CreateFile
                   get_func  kernel32, ReadFile
                   get_func  kernel32, GetFileSize
                   get_func  kernel32, GetProcessHeap
                   get_func  kernel32, CreateEventEx
                   get_func  kernel32, CreateThread
                   get_func  kernel32, SetEvent
                   get_func  kernel32, WaitForSingleObject
                   get_func  kernel32, WaitForMultipleObjects

                   get_func  user32, wsprintf
                   get_func  user32, RegisterClass
                   get_func  user32, CreateWindowEx
                   get_func  user32, DefWindowProc
                   get_func  user32, PeekMessage
                   get_func  user32, DispatchMessage
                   get_func  user32, LoadCursor
                   get_func  user32, SetWindowText
                   get_func  user32, AdjustWindowRect
                   get_func  user32, GetDC
                   get_func  user32, ReleaseDC
                   get_func  user32, PostQuitMessage
                   get_func  user32, MessageBox

                   get_func  gdi32, CreateDIBSection
                   get_func  gdi32, CreateCompatibleDC
                   get_func  gdi32, SelectObject
                   get_func  gdi32, BitBlt
                   get_func  gdi32, DeleteDC
                   get_func  gdi32, DeleteObject

                          ; check CPU
                       call  check_cpu_extensions
                       test  eax, eax
                         jz  .error

                          ; get process heap
                       call  [GetProcessHeap]
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
purge get_func
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
  .k_stack_size = 32*2+24
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
                        mov  eax, [win_height]
                        mov  dword[rsp+32], eax
                        mov  rax, [win_bmp_hdc]
                        mov  [rsp+40], rax
                        mov  qword[rsp+48], 0
                        mov  qword[rsp+56], 0
                        mov  dword[rsp+64], SRCCOPY
                       call  [BitBlt]

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
                       call  [PeekMessage]
                       test  eax, eax
                         jz  .update

                        lea  rcx, [.msg+rsp]
                       call  [DispatchMessage]
                        cmp  [.msg.message+rsp], WM_QUIT
                         je  .quit
                        jmp  .main_loop
  .update:
                       call  update
                        jmp  .main_loop
  .quit:
                       call  deinit
                        xor  ecx, ecx
                       call  [ExitProcess]
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
