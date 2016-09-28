format PE64 GUI 4.0
entry start

include '$instructions.inc'

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
CREATE_EVENT_INITIAL_SET = 2
CREATE_EVENT_MANUAL_RESET = 1

macro strucOffsetsSize s {
  virtual at 0
    s s
    sizeof.#s = $
  end virtual }

macro dalign value* {
  db ((value - 1) - (($-$$) + (value - 1)) mod value) dup 0 }

macro $mov op1*, op2*, op3 {
  if op3 eq
        $mov op1, op2
  else
        $mov op2, op3
        $mov op1, op2
  end if }

macro $lea op1*, op2*, op3 {
  if op3 eq
        $lea op1, op2
  else
        $lea op2, op3
        $mov op1, op2
  end if }

macro $iacaBegin {
        $mov ebx, 111
        db 64h, 67h, 90h }

macro $iacaEnd {
        $mov ebx, 222
        db 64h, 67h, 90h }

macro $debugBreak {
        $int3
        $nop }

macro $zeroStack size* {
        $vpxor ymm0, ymm0, ymm0
        $xor eax, eax
        $mov ecx, size/32
      @@:
        $vmovdqa [rsp+rax], ymm0
        $add eax, 32
        $sub ecx, 1
        $jnz @b }

macro $icall target* {
        $call [target] }

macro falign { align 32 }

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
  .x dda 0
  .y dda 0
  dalign 4 }

struc MSG {
  dalign 8
  .:
  .hwnd dqa 0
  .message dda 0
  .wParam dqa 0
  .lParam dqa 0
  .time dda 0
  .pt POINT
  dalign 8 }

struc WNDCLASS {
  dalign 8
  .:
  .style dda 0
  .lpfnWndProc dqa 0
  .cbClsExtra dda 0
  .cbWndExtra dda 0
  .hInstance dqa 0
  .hIcon dqa 0
  .hCursor dqa 0
  .hbrBackground dqa 0
  .lpszMenuName dqa 0
  .lpszClassName dqa 0
  dalign 8 }

struc RECT {
  dalign 4
  .:
  .left dda 0
  .top dda 0
  .right dda 0
  .bottom dda 0
  dalign 4 }

struc BITMAPINFOHEADER {
  dalign 4
  .:
  .biSize dda 0
  .biWidth dda 0
  .biHeight dda 0
  .biPlanes dwa 0
  .biBitCount dwa 0
  .biCompression dda 0
  .biSizeImage dda 0
  .biXPelsPerMeter dda 0
  .biYPelsPerMeter dda 0
  .biClrUsed dda 0
  .biClrImportant dda 0
  dalign 4 }

struc WorkerThread {
  dalign 8
  .:
  .handle dqa 0
  .begin_event dqa 0
  .end_event dqa 0
  dalign 8 }

strucOffsetsSize BITMAPINFOHEADER
strucOffsetsSize WorkerThread

k_max_num_threads equ 64

k_win_style equ WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX
k_win_resx equ 1024
k_win_resy equ 1024

k_tile_res equ 64
k_tile_numx equ (k_win_resx / k_tile_res)
k_tile_numy equ (k_win_resy / k_tile_res)
k_tile_num equ (k_tile_numx * k_tile_numy)

section '.text' code readable executable

falign
generate_image:
      virtual at rsp
        rq 4
        dalign 32
        .k_stack_size = $-$$+24
      end virtual
        $push rsi rdi rbx rbp r12 r13 r14 r15
        $sub rsp, .k_stack_size
      .for_each_tile:
        $mov eax, 1
        $lock $xadd [tile_index], eax
        $cmp eax, k_tile_num
        $jae .ret
        $xor edx, edx
        $mov ecx, k_tile_numx
        $div ecx
        ; eax = (k_tile_num / k_tile_numx)
        ; edx = (k_tile_num % k_tile_numx)
        $mov r14d, k_tile_res
        $mov r15d, r14d
        $imul edx, r14d
        $imul eax, r15d
        ; eax = (k_tile_num / k_tile_numx) * k_tile_res
        ; edx = (k_tile_num % k_tile_numx) * k_tile_res
        $mov r12d, edx                                  ; r12d = x0
        $mov r13d, eax                                  ; r13d = y0
        $add r14d, r12d                                 ; r14d = x1 = x0 + k_tile_res
        $add r15d, r13d                                 ; r15d = y1 = y0 + k_tile_res
        $imul eax, k_win_resx
        $add eax, edx
        $shl eax, 2
        $mov rbx, [win_pixels]
        $add rbx, rax                                   ; start of the tile
      .for_each_4x2:
        $vmovapd ymm0, [k_1_0]
        $vmovapd ymm1, ymm0
        $vxorpd ymm2, ymm2, ymm2
        $vmovapd ymm3, ymm0
        $vmovapd ymm4, ymm0
        $vxorpd ymm5, ymm5, ymm5
        ; clamp to [0.0 ; 1.0]
        $vxorpd ymm14, ymm14, ymm14
        $vmovapd ymm15, [k_1_0]
        $vmovapd ymm13, [k_255_0]
        rept 6 n:0 {
        $vmaxpd ymm#n, ymm#n, ymm14 }
        rept 6 n:0 {
        $vminpd ymm#n, ymm#n, ymm15 }
        rept 6 n:0 {
        $vmulpd ymm#n, ymm#n, ymm13 }
        rept 6 n:0 {
        $vcvttpd2dq xmm#n, ymm#n }
        $vpslld xmm0, xmm0, 16
        $vpslld xmm1, xmm1, 8
        $vpslld xmm3, xmm3, 16
        $vpslld xmm4, xmm4, 8
        $vpor xmm0, xmm0, xmm1
        $vpor xmm3, xmm3, xmm4
        $vpor xmm0, xmm0, xmm2
        $vpor xmm3, xmm3, xmm5
        $vmovntdq [rbx], xmm0
        $vmovntdq [rbx+4*k_win_resx], xmm3
        $add rbx, 16
        $add r12d, 4
        $cmp r12d, r14d
        $jne .for_each_4x2
        $add rbx, 2*(k_win_resx*4)-k_tile_res*4
        $sub r12d, k_tile_res
        $add r13d, 2
        $cmp r13d, r15d
        $jne .for_each_4x2
        $jmp .for_each_tile
      .ret:
        $mfence
        $add rsp, .k_stack_size
        $pop r15 r14 r13 r12 rbp rbx rdi rsi
        $ret
falign
worker_thread:
; in: rcx - WorkerThread address
      virtual at r12
        .thread WorkerThread
      end virtual
        $and rsp, -32
        $sub rsp, 32
        $mov r12, rcx
      .repeat:
        $mov rcx, [.thread.begin_event]
        $mov edx, INFINITE
        $icall WaitForSingleObject
        $call generate_image
        $mov rcx, [.thread.end_event]
        $icall SetEvent
        $jmp .repeat
falign
create_worker_thread:
; in: rcx - WorkerThread address
      virtual at rsp
        rept 6 n:1 {
        .param#n dq ? }
        dalign 32
        .k_stack_size = $-$$+16
      end virtual
        ; input thread
      virtual at r12
        .thread WorkerThread
      end virtual
        $push r12
        $sub rsp, .k_stack_size
        $mov r12, rcx
        ; begin event
        $mov ecx, 0
        $mov edx, 0
        $mov r8d, 0
        $mov r9d, EVENT_ALL_ACCESS
        $icall CreateEventEx
        $mov [.thread.begin_event], rax
        ; end event
        $mov ecx, 0
        $mov edx, 0
        $mov r8d, 0
        $mov r9d, EVENT_ALL_ACCESS
        $icall CreateEventEx
        $mov [.thread.end_event], rax
        ; thread
        $mov ecx, 0
        $mov edx, 0
        $lea r8, [worker_thread]
        $mov r9, r12
        $mov [.param5], 0
        $mov [.param6], 0
        $icall CreateThread
        $mov [.thread.handle], rax
        $add rsp, .k_stack_size
        $pop r12
        $ret
falign
check_cpu_extensions:
        $mov eax, 1
        $cpuid
        $and ecx, 58001000h          ; check RDRAND, AVX, OSXSAVE, FMA
        $cmp ecx, 58001000h
        $jne .not_supported
        $mov eax, 7
        $xor ecx, ecx
        $cpuid
        $and ebx, 20h                ; check AVX2
        $cmp ebx, 20h
        $jne .not_supported
        $xor ecx, ecx
        $xgetbv
        $and eax, 6h                 ; check OS support
        $cmp eax, 6h
        $jne .not_supported
        $mov eax, 1
        $jmp .ret
      .not_supported:
        $xor eax, eax
      .ret:
        $ret
falign
get_time:
      virtual at rsp
        rq 4
        dalign 32
        .k_stack_size = $-$$+24
      end virtual
        $sub rsp, .k_stack_size
        $mov rax, [.perf_freq]
        $test rax, rax
        $jnz @f
        $lea rcx, [.perf_freq]
        $icall QueryPerformanceFrequency
        $lea rcx, [.first_perf_counter]
        $icall QueryPerformanceCounter
      @@:
        $lea rcx, [.perf_counter]
        $icall QueryPerformanceCounter
        $mov rcx, [.perf_counter]
        $sub rcx, [.first_perf_counter]
        $mov rdx, [.perf_freq]
        $vxorps xmm0, xmm0, xmm0
        $vcvtsi2sd xmm1, xmm0, rcx
        $vcvtsi2sd xmm2, xmm0, rdx
        $vdivsd xmm0, xmm1, xmm2
        $add rsp, .k_stack_size
        $ret
falign
update_frame_stats:
      virtual at rsp
        rq 4
        .text rb 64
        dalign 32
        .k_stack_size = $-$$+24
      end virtual
        $sub rsp, .k_stack_size
        $mov rax, [.prev_time]
        $test rax, rax
        $jnz @f
        $call get_time
        $vmovsd [.prev_time], xmm0
        $vmovsd [.prev_update_time], xmm0
      @@:
        $call get_time                          ; xmm0 = (0, time)
        $vmovsd [time], xmm0
        $vsubsd xmm1, xmm0, [.prev_time]        ; xmm1 = (0, time_delta)
        $vmovsd [.prev_time], xmm0
        $vxorps xmm2, xmm2, xmm2
        $vcvtsd2ss xmm1, xmm2, xmm1             ; xmm1 = (0, 0, 0, time_delta)
        $vmovss [time_delta], xmm1
        $vmovsd xmm1, [.prev_update_time]       ; xmm1 = (0, prev_update_time)
        $vsubsd xmm2, xmm0, xmm1                ; xmm2 = (0, time - prev_update_time)
        $vmovsd xmm3, [.k_1_0]                  ; xmm3 = (0, 1.0)
        $vcomisd xmm2, xmm3
        $jb @f
        $vmovsd [.prev_update_time], xmm0
        $mov eax, [.frame]
        $vxorpd xmm1, xmm1, xmm1
        $vcvtsi2sd xmm1, xmm1, eax              ; xmm1 = (0, frame)
        $vdivsd xmm0, xmm1, xmm2                ; xmm0 = (0, frame / (time - prev_update_time))
        $vdivsd xmm1, xmm2, xmm1
        $vmulsd xmm1, xmm1, [.k_1000000_0]
        $mov [.frame], 0
        $lea rcx, [.text]
        $lea rdx, [s_win_text_fmt]
        $vcvtsd2si r8, xmm0
        $vcvtsd2si r9, xmm1
        $icall wsprintf
        $mov rcx, [win_handle]
        $lea rdx, [.text]
        $icall SetWindowText
      @@:
        $add [.frame], 1
        $add rsp, .k_stack_size
        $ret
falign
init_window:
      virtual at rsp
        rept 12 n:1 {
        .param#n dq ? }
        .wc WNDCLASS
        .rect RECT
        .bmp_info BITMAPINFOHEADER
        dalign 32
        .k_stack_size = $-$$+16
      end virtual
        $push rsi
        ; alloc and clear the stack
        $sub rsp, .k_stack_size
        $zeroStack .k_stack_size
        ; create window class
        $lea [.wc.lpfnWndProc], rax, [win_message_handler]
        $lea [.wc.lpszClassName], rax, [s_win_class_name]
        $xor ecx, ecx
        $icall GetModuleHandle
        $mov [.wc.hInstance], rax
        $xor ecx, ecx
        $mov edx, IDC_ARROW
        $icall LoadCursor
        $mov [.wc.hCursor], rax
        $lea rcx, [.wc]
        $icall RegisterClass
        $test eax, eax
        $jz .error
        ; compute window size
        $mov [.rect.right], eax, [win_width]
        $mov [.rect.bottom], eax, [win_height]
        $lea rcx, [.rect]
        $mov edx, k_win_style
        $xor r8d, r8d
        $icall AdjustWindowRect
        $mov r10d, [.rect.right]
        $mov r11d, [.rect.bottom]
        $sub r10d, [.rect.left]
        $sub r11d, [.rect.top]
        ; create window
        $xor ecx, ecx
        $lea rdx, [s_win_class_name]
        $mov r8, rdx
        $mov r9d, WS_VISIBLE+k_win_style
        $mov dword[.param5], CW_USEDEFAULT
        $mov dword[.param6], CW_USEDEFAULT
        $mov [.param7], r10
        $mov [.param8], r11
        $mov [.param9], 0
        $mov [.param10], 0
        $mov [.param11], rax, [.wc.hInstance]
        $mov [.param12], 0
        $icall CreateWindowEx
        $mov [win_handle], rax
        $test rax, rax
        $jz .error
        ; create bitmap
        $mov rcx, [win_handle]
        $icall GetDC
        $mov [win_hdc], rax
        $test rax, rax
        $jz .error
        $mov [.bmp_info.biSize], eax, sizeof.BITMAPINFOHEADER
        $mov [.bmp_info.biWidth], eax, [win_width]
        $mov [.bmp_info.biHeight], eax, [win_height]
        $mov [.bmp_info.biPlanes], 1
        $mov [.bmp_info.biBitCount], 32
        $mov eax, [win_width]
        $imul eax, [win_height]
        $mov [.bmp_info.biSizeImage], eax
        $mov rcx, [win_hdc]
        $lea rdx, [.bmp_info]
        $xor r8d, r8d
        $lea r9, [win_pixels]
        $mov [.param5], 0
        $mov [.param6], 0
        $icall CreateDIBSection
        $mov [win_bmp_handle], rax
        $test rax, rax
        $jz .error
        $mov rcx, [win_hdc]
        $icall CreateCompatibleDC
        $mov [win_bmp_hdc], rax
        $test rax, rax
        $jz .error
        $mov rcx, [win_bmp_hdc]
        $mov rdx, [win_bmp_handle]
        $icall SelectObject
        $test eax, eax
        $jz .error
        ; finish
        $mov eax, 1
        $add rsp, .k_stack_size
        $pop rsi
        $ret
      .error:
        $xor eax, eax
        $add rsp, .k_stack_size
        $pop rsi
        $ret
; helper macro for loading entry points
macro $getFunc lib, proc {
        $mov rcx, [lib#_dll]
        $lea rdx, [s_#proc]
        $icall GetProcAddress
        $mov [proc], rax
        $test rax, rax
        $jz .error }
falign
init:
      virtual at rsp
        rq 4
        dalign 32
        .k_stack_size = $-$$+8
      end virtual
        $push rsi rdi
        $sub  rsp, .k_stack_size
        ; load APIs
        $lea rcx, [s_kernel32_dll]
        $icall LoadLibrary
        $mov [kernel32_dll], rax
        $test rax, rax
        $jz .error
        $lea rcx, [s_user32_dll]
        $icall LoadLibrary
        $mov [user32_dll], rax
        $test rax, rax
        $jz .error
        $lea rcx, [s_gdi32_dll]
        $icall LoadLibrary
        $mov [gdi32_dll], rax
        $test rax, rax
        $jz .error
        ; kernel32 functions
        $getFunc kernel32, ExitProcess
        $getFunc kernel32, GetModuleHandle
        $getFunc kernel32, ExitThread
        $getFunc kernel32, QueryPerformanceFrequency
        $getFunc kernel32, QueryPerformanceCounter
        $getFunc kernel32, CloseHandle
        $getFunc kernel32, Sleep
        $getFunc kernel32, FreeLibrary
        $getFunc kernel32, HeapAlloc
        $getFunc kernel32, HeapReAlloc
        $getFunc kernel32, HeapFree
        $getFunc kernel32, CreateFile
        $getFunc kernel32, ReadFile
        $getFunc kernel32, GetFileSize
        $getFunc kernel32, GetProcessHeap
        $getFunc kernel32, CreateEventEx
        $getFunc kernel32, CreateThread
        $getFunc kernel32, SetEvent
        $getFunc kernel32, WaitForSingleObject
        $getFunc kernel32, WaitForMultipleObjects
        $getFunc kernel32, GetActiveProcessorCount
        $getFunc kernel32, OutputDebugString
        ; user32 functions
        $getFunc user32, wsprintf
        $getFunc user32, RegisterClass
        $getFunc user32, CreateWindowEx
        $getFunc user32, DefWindowProc
        $getFunc user32, PeekMessage
        $getFunc user32, DispatchMessage
        $getFunc user32, LoadCursor
        $getFunc user32, SetWindowText
        $getFunc user32, AdjustWindowRect
        $getFunc user32, GetDC
        $getFunc user32, ReleaseDC
        $getFunc user32, MessageBox
        ; gdi32 functions
        $getFunc gdi32, CreateDIBSection
        $getFunc gdi32, CreateCompatibleDC
        $getFunc gdi32, SelectObject
        $getFunc gdi32, BitBlt
        $getFunc gdi32, DeleteDC
        $getFunc gdi32, DeleteObject
        purge $getFunc
        ; check CPU
        $call check_cpu_extensions
        $test eax, eax
        $jz .error
        ; get number of logical cores
        $mov ecx, 0
        $icall GetActiveProcessorCount
        $dec eax
        $mov [num_worker_threads], eax
        ; create worker threads
        $lea rdi, [worker_threads]
        $mov esi, [num_worker_threads]
      .threads_loop:
        $mov rcx, rdi
        $call create_worker_thread
        $add rdi, sizeof.WorkerThread
        $dec esi
        $jnz .threads_loop
        ; get process heap
        $icall GetProcessHeap
        $mov [process_heap], rax
        $test rax, rax
        $jz .error
        ; create window
        $call init_window
        $test eax, eax
        $jz .error
        ; finish
        $mov eax, 1
        $jmp .ret
      .error:
        $xor eax, eax
      .ret:
        $add rsp, .k_stack_size
        $pop rdi rsi
        $ret
falign
deinit:
        $ret
falign
update:
      virtual at rsp
        rept 9 n:1 {
        .param#n dq ? }
        .thread_end_events rq k_max_num_threads
        dalign 32
        .k_stack_size = $-$$+8
      end virtual
        $push rsi rdi
        $sub rsp, .k_stack_size
        $call update_frame_stats
        $mov [tile_index], 0
        ; dispatch all worker threads
        $lea rdi, [worker_threads]
        $xor esi, esi
      @@:
        $mov [rsi*8+.thread_end_events], rax, [rdi+WorkerThread.end_event]
        $mov rcx, [rdi+WorkerThread.begin_event]
        $icall SetEvent
        $add rdi, sizeof.WorkerThread
        $inc esi
        $cmp esi, [num_worker_threads]
        $jne @b
        $call generate_image
        ; wait for all threads
        $mov ecx, [num_worker_threads]
        $lea rdx, [.thread_end_events]
        $mov r8d, 1
        $mov r9d, INFINITE
        $icall WaitForMultipleObjects
        ; transfer image data
        $mov rcx, [win_hdc]
        $xor edx, edx
        $xor r8d, r8d
        $mov r9d, [win_width]
        $mov dword[.param5], eax, [win_height]
        $mov [.param6], rax, [win_bmp_hdc]
        $mov [.param7], 0
        $mov [.param8], 0
        $mov dword[.param9], SRCCOPY
        $icall BitBlt
        ; finish
        $add rsp, .k_stack_size
        $pop rdi rsi
        $ret
falign
start:
      virtual at rsp
        rept 5 n:1 {
        .param#n dq ? }
        .msg MSG
        dalign 32
        .k_stack_size = $-$$
      end virtual
        $and rsp, -32
        $sub rsp, .k_stack_size
        $call init
        $test eax, eax
        $jz .quit
      .main_loop:
        $lea rcx, [.msg]
        $xor edx, edx
        $xor r8d, r8d
        $xor r9d, r9d
        $mov dword[.param5], PM_REMOVE
        $icall PeekMessage
        $test eax, eax
        $jz .update
        $lea rcx, [.msg]
        $icall DispatchMessage
        $cmp [quit], 1
        $je .quit
        $jmp .main_loop
      .update:
        $call update
        $jmp .main_loop
      .quit:
        $call deinit
        $xor ecx, ecx
        $icall ExitProcess
falign
win_message_handler:
      virtual at rsp
        rq 4
        dalign 32
        .k_stack_size = $-$$+24
      end virtual
        $sub rsp, .k_stack_size
        $cmp edx, WM_KEYDOWN
        $je .keydown
        $cmp edx, WM_DESTROY
        $je .destroy
      .default:
        $icall DefWindowProc
        $jmp .return
      .keydown:
        $cmp r8d, VK_ESCAPE
        $jne .default
        $mov [quit], 1
        $xor eax, eax
        $jmp .return
      .destroy:
        $mov [quit], 1
        $xor eax, eax
        $jmp .return
      .return:
        $add rsp, .k_stack_size
        $ret

section '.data' data readable writeable

dalign 32
k_1_0: dq 4 dup 1.0
k_255_0: dq 4 dup 255.0

dalign 8
worker_threads rb k_max_num_threads * sizeof.WorkerThread

num_worker_threads dda 0
tile_index dda 0
quit dda 0

dalign 8
win_handle dq 0
win_hdc dq 0
win_bmp_handle dq 0
win_bmp_hdc dq 0
win_pixels dq 0
win_width dd k_win_resx
win_height dd k_win_resy

dalign 8
process_heap dq 0
time dq 0
time_delta dd 0, 0

dalign 8
get_time.perf_counter dq 0
get_time.perf_freq dq 0
get_time.first_perf_counter dq 0

update_frame_stats.prev_time dq 0
update_frame_stats.prev_update_time dq 0
update_frame_stats.frame dd 0,0
update_frame_stats.k_1000000_0 dq 1000000.0
update_frame_stats.k_1_0 dq 1.0

dalign 8
kernel32_dll dq 0
user32_dll dq 0
gdi32_dll dq 0

dalign 8
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
GetActiveProcessorCount dq 0
OutputDebugString dq 0

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
MessageBox dq 0

DeleteDC dq 0
CreateDIBSection dq 0
CreateCompatibleDC dq 0
SelectObject dq 0
BitBlt dq 0
DeleteObject dq 0

s_win_text_fmt db '[%d fps  %d us] Base Code', 0
s_win_class_name db 'Base Code', 0

s_kernel32_dll db 'kernel32.dll', 0
s_user32_dll db 'user32.dll', 0
s_gdi32_dll db 'gdi32.dll', 0

s_GetModuleHandle db 'GetModuleHandleA', 0
s_ExitProcess db 'ExitProcess', 0
s_ExitThread db 'ExitThread', 0
s_QueryPerformanceFrequency db 'QueryPerformanceFrequency', 0
s_QueryPerformanceCounter db 'QueryPerformanceCounter', 0
s_CloseHandle db 'CloseHandle', 0
s_Sleep db 'Sleep', 0
s_FreeLibrary db 'FreeLibrary', 0
s_HeapAlloc db 'HeapAlloc', 0
s_HeapReAlloc db 'HeapReAlloc', 0
s_HeapFree db 'HeapFree', 0
s_CreateFile db 'CreateFileA', 0
s_ReadFile db 'ReadFile', 0
s_GetFileSize db 'GetFileSize', 0
s_GetProcessHeap db 'GetProcessHeap', 0
s_CreateEventEx db 'CreateEventExA', 0
s_CreateThread db 'CreateThread', 0
s_SetEvent db 'SetEvent', 0
s_WaitForSingleObject db 'WaitForSingleObject', 0
s_WaitForMultipleObjects db 'WaitForMultipleObjects', 0
s_GetActiveProcessorCount db 'GetActiveProcessorCount', 0
s_OutputDebugString db 'OutputDebugStringA', 0

s_wsprintf db 'wsprintfA', 0
s_RegisterClass db 'RegisterClassA', 0
s_CreateWindowEx db 'CreateWindowExA', 0
s_DefWindowProc db 'DefWindowProcA', 0
s_PeekMessage db 'PeekMessageA', 0
s_DispatchMessage db 'DispatchMessageA', 0
s_LoadCursor db 'LoadCursorA', 0
s_SetWindowText db 'SetWindowTextA', 0
s_AdjustWindowRect db 'AdjustWindowRect', 0
s_GetDC db 'GetDC', 0
s_ReleaseDC db 'ReleaseDC', 0
s_MessageBox db 'MessageBoxA', 0

s_DeleteDC db 'DeleteDC', 0
s_CreateDIBSection db 'CreateDIBSection', 0
s_CreateCompatibleDC db 'CreateCompatibleDC', 0
s_SelectObject db 'SelectObject', 0
s_BitBlt db 'BitBlt', 0
s_DeleteObject db 'DeleteObject', 0

section '.idata' import data readable writeable

dd 0, 0, 0, rva s_kernel32_dll, rva _kernel32_table
dd 0, 0, 0, 0, 0

dalign 8
_kernel32_table:
  LoadLibrary dq rva _LoadLibrary
  GetProcAddress dq rva _GetProcAddress
  dq 0

_LoadLibrary dw 0
db 'LoadLibraryA', 0
_GetProcAddress dw 0
db 'GetProcAddress', 0
