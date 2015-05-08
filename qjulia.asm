format PE64 GUI 4.0
entry start
include 'win64a.inc'

DIB_RGB_COLORS = 0
INFINITE = -1

section '.text' code readable executable
;========================================================================
macro iaca_begin {
        mov             ebx,111
        db              0x64,0x67,0x90
}
macro iaca_end {
        mov             ebx,222
        db              0x64,0x67,0x90
}
;========================================================================
program_section = 'code'
include 'qjulia_render.asm'
;========================================================================
align 16
generate_fractal_thread:
        and             rsp,-32
        mov             esi,ecx                                 ; thread id
    .run:
        invoke          WaitForSingleObject,[main_thrd_semaphore],INFINITE
        mov             eax,[quit]
        test            eax,eax
        jnz             .return
        call            generate_image
        invoke          ReleaseSemaphore,[thrd_semaphore+rsi*8],1,NULL
        jmp             .run
    .return:
        invoke          ExitThread,0
;========================================================================
align 16
get_time:
        sub             rsp,24
        mov             rax,[.perf_freq]
        test            rax,rax
        jnz             @f
        invoke          QueryPerformanceFrequency,.perf_freq
        invoke          QueryPerformanceCounter,.first_perf_counter
    @@: invoke          QueryPerformanceCounter,.perf_counter
        mov             rcx,[.perf_counter]
        sub             rcx,[.first_perf_counter]
        mov             rdx,[.perf_freq]
        vxorps          xmm0,xmm0,xmm0
        vcvtsi2sd       xmm1,xmm0,rcx
        vcvtsi2sd       xmm2,xmm0,rdx
        vdivsd          xmm0,xmm1,xmm2
        add             rsp,24
        ret
;========================================================================
align 16
update_frame_stats:
        sub             rsp,24
        mov             rax,[.prev_time]
        test            rax,rax
        jnz             @f
        call            get_time
        vmovsd          [.prev_time],xmm0
        vmovsd          [.prev_update_time],xmm0
    @@: call            get_time                                ; xmm0 = (0, time)
        vmovsd          [time],xmm0
        vsubsd          xmm1,xmm0,[.prev_time]                  ; xmm1 = (0, time_delta)
        vmovsd          [.prev_time],xmm0
        vxorps          xmm2,xmm2,xmm2
        vcvtsd2ss       xmm1,xmm2,xmm1                          ; xmm1 = (0, 0, 0, time_delta)
        vmovss          [time_delta],xmm1
        vmovsd          xmm1,[.prev_update_time]                ; xmm1 = (0, prev_update_time)
        vsubsd          xmm2,xmm0,xmm1                          ; xmm2 = (0, time - prev_update_time)
        vmovsd          xmm3,[.k_1_0]                           ; xmm3 = (0, 1.0)
        vcomisd         xmm2,xmm3
        jb              @f
        vmovsd          [.prev_update_time],xmm0
        mov             eax,[.frame]
        vxorpd          xmm1,xmm1,xmm1
        vcvtsi2sd       xmm1,xmm1,eax                           ; xmm1 = (0, frame)
        vdivsd          xmm0,xmm1,xmm2                          ; xmm0 = (0, frame / (time - prev_update_time))
        vdivsd          xmm1,xmm2,xmm1
        vmulsd          xmm1,xmm1,[.k_1000000_0]
        vcvtsd2si       r10,xmm0
        vcvtsd2si       r11,xmm1
        mov             [.frame],0
        cinvoke         wsprintf,win_title,win_title_fmt,r10,r11
        invoke          SetWindowText,[win_handle],win_title
    @@: add             [.frame],1
        add             rsp,24
        ret
;========================================================================
align 16
init:
        push            rsi
        sub             rsp,16
        invoke          GetModuleHandle,0
        mov             [win_class.hInstance],rax
        invoke          LoadIcon,0,IDI_APPLICATION
        mov             [win_class.hIcon],rax
        mov             [win_class.hIconSm],rax
        invoke          LoadCursor,0,IDC_ARROW
        mov             [win_class.hCursor],rax
        invoke          GetStockObject,BLACK_BRUSH
        mov             [win_class.hbrBackground],rax
        invoke          RegisterClassEx,win_class
        test            eax,eax
        jz              .error
        invoke          SetRect,win_rect,0,0,k_win_width,k_win_height
        test            eax,eax
        jz              .error
        invoke          AdjustWindowRect,win_rect,k_win_style,FALSE
        test            eax,eax
        jz              .error
        mov             esi,[win_rect.right]
        mov             edi,[win_rect.bottom]
        sub             esi,[win_rect.left]
        sub             edi,[win_rect.top]
        invoke          CreateWindowEx,0,win_title,win_title,WS_VISIBLE+k_win_style,CW_USEDEFAULT,CW_USEDEFAULT,esi,edi,NULL,NULL,[win_class.hInstance],NULL
        mov             [win_handle],rax
        test            rax,rax
        jz              .error
        invoke          GetDC,rax
        mov             [win_hdc],rax
        test            rax,rax
        jz              .error
        invoke          CreateDIBSection,[win_hdc],bmp_info,DIB_RGB_COLORS,displayptr,NULL,0
        mov             [bmp_handle],rax
        test            rax,rax
        jz              .error
        invoke          CreateCompatibleDC,[win_hdc]
        mov             [bmp_hdc],rax
        test            rax,rax
        jz              .error
        invoke          SelectObject,[bmp_hdc],[bmp_handle]
        test            eax,eax
        jz              .error
        invoke          CreateSemaphore,NULL,0,k_thrd_count,NULL
        mov             [main_thrd_semaphore],rax
        test            rax,rax
        jz              .error
        xor             esi,esi
    @@: invoke          CreateSemaphore,NULL,0,1,NULL
        mov             [thrd_semaphore+rsi*8],rax
        test            rax,rax
        jz              .error
        add             esi,1
        cmp             esi,k_thrd_count
        jb              @b
        xor             esi,esi
    @@: invoke          CreateThread,NULL,0,generate_fractal_thread,esi,0,NULL
        mov             [thrd_handle+rsi*8],rax
        test            rax,rax
        jz              .error
        add             esi,1
        cmp             esi,k_thrd_count
        jb              @b
        mov             eax,1
        add             rsp,24
        ret
    .error:
        xor             eax,eax
        add             rsp,16
        pop             rsi
        ret
;========================================================================
align 16
deinit:
        push            rsi rdi
        sub             rsp,8
        mov             [quit],1
        invoke          ReleaseSemaphore,[main_thrd_semaphore],k_thrd_count,NULL
        xor             esi,esi
    .for_each_thrd:
        mov             rdi,[thrd_handle+rsi*8]
        test            rdi,rdi
        jz              @f
        invoke          WaitForSingleObject,rdi,INFINITE
        invoke          CloseHandle,rdi
    @@: add             esi,1
        cmp             esi,k_thrd_count
        jb              .for_each_thrd
        mov             rcx,[main_thrd_semaphore]
        test            rcx,rcx
        jz              @f
        invoke          CloseHandle,rcx
    @@: xor             esi,esi
    .for_each_sem:
        mov             rcx,[thrd_semaphore+rsi*8]
        test            rcx,rcx
        jz              @f
        invoke          CloseHandle,rcx
    @@: add             esi,1
        cmp             esi,k_thrd_count
        jb              .for_each_sem
        mov             rcx,[bmp_hdc]
        test            rcx,rcx
        jz              @f
        invoke          DeleteDC,rcx
    @@: mov             rcx,[bmp_handle]
        test            rcx,rcx
        jz              @f
        invoke          DeleteObject,rcx
    @@: mov             rcx,[win_hdc]
        test            rcx,rcx
        jz              @f
        invoke          ReleaseDC,rcx
    @@: add             rsp,8
        pop             rdi rsi
        ret
;========================================================================
align 16
update:
        sub             rsp,24
        call            update_frame_stats
        call            update_state
        mov             [tileidx],0
        invoke          ReleaseSemaphore,[main_thrd_semaphore],k_thrd_count,NULL
        invoke          WaitForMultipleObjects,k_thrd_count,thrd_semaphore,TRUE,INFINITE
        invoke          BitBlt,[win_hdc],0,0,k_win_width,k_win_height,[bmp_hdc],0,0,SRCCOPY
        add             rsp,24
        ret
;========================================================================
align 16
start:
        and             rsp,-32
        call            init
        test            eax,eax
        jz              .quit
    .main_loop:
        invoke          PeekMessage,win_msg,NULL,0,0,PM_REMOVE
        test            eax,eax
        jz              .update
        invoke          DispatchMessage,win_msg
        cmp             [win_msg.message],WM_QUIT
        je              .quit
        jmp             .main_loop
    .update:
        call            update
        jmp             .main_loop
    .quit:
        call            deinit
        invoke          ExitProcess,0
;========================================================================
align 16
proc winproc hwnd,msg,wparam,lparam
        mov             [hwnd],rcx
        mov             [msg],rdx
        mov             [wparam],r8
        mov             [lparam],r9
        cmp             edx,WM_KEYDOWN
        je              .keydown
        cmp             edx,WM_DESTROY
        je              .destroy
        invoke          DefWindowProc,rcx,rdx,r8,r9
        jmp             .return
    .keydown:
        cmp             [wparam],VK_ESCAPE
        jne             .return
        invoke          PostQuitMessage,0
        xor             eax,eax
        jmp             .return
    .destroy:
        invoke          PostQuitMessage,0
        xor             eax,eax
    .return:
        ret
endp
;========================================================================
section '.data' data readable writeable

k_win_width = 1280
k_win_height = 720
k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

k_tile_width = 80
k_tile_height = 80
k_tile_x_count = k_win_width / k_tile_width
k_tile_y_count = k_win_height / k_tile_height
k_tile_count = k_tile_x_count * k_tile_y_count

k_thrd_count = 8

align 8
bmp_handle dq 0
bmp_hdc dq 0
win_handle dq 0
win_hdc dq 0
win_title db 'Quaternion Julia Sets', 64 dup 0
win_title_fmt db '[%d fps  %d us] Quaternion Julia Sets',0
win_msg MSG
win_class WNDCLASSEX sizeof.WNDCLASSEX,0,winproc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,win_title,NULL
win_rect RECT

align 8
bmp_info BITMAPINFOHEADER sizeof.BITMAPINFOHEADER,k_win_width,k_win_height,1,32,BI_RGB,k_win_width*k_win_height,0,0,0,0
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
update_frame_stats.k_1000000_0 dq 1000000.0
update_frame_stats.k_1_0 dq 1.0

displayptr dq 0
tileidx dd 0,0

align 8
main_thrd_semaphore dq 0
thrd_handle dq k_thrd_count dup 0
thrd_semaphore dq k_thrd_count dup 0

program_section = 'data'
include 'qjulia_render.asm'
;========================================================================
section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'

import kernel32,\
       GetModuleHandle,'GetModuleHandleA',ExitProcess,'ExitProcess',\
       WaitForSingleObject,'WaitForSingleObject',ReleaseSemaphore,'ReleaseSemaphore',\
       ExitThread,'ExitThread',QueryPerformanceFrequency,'QueryPerformanceFrequency',\
       QueryPerformanceCounter,'QueryPerformanceCounter',CreateSemaphore,'CreateSemaphoreA',\
       CreateThread,'CreateThread',CloseHandle,'CloseHandle',\
       WaitForMultipleObjects,'WaitForMultipleObjects'

import user32,\
       wsprintf,'wsprintfA',\
       RegisterClassEx,'RegisterClassExA',\
       CreateWindowEx,'CreateWindowExA',\
       DefWindowProc,'DefWindowProcA',\
       PeekMessage,'PeekMessageA',\
       DispatchMessage,'DispatchMessageA',\
       LoadCursor,'LoadCursorA',\
       LoadIcon,'LoadIconA',\
       SetWindowText,'SetWindowTextA',SetRect,'SetRect',AdjustWindowRect,'AdjustWindowRect',\
       GetDC,'GetDC',ReleaseDC,'ReleaseDC',PostQuitMessage,'PostQuitMessage'

import gdi32,\
       GetStockObject,'GetStockObject',CreateDIBSection,'CreateDIBSection',\
       CreateCompatibleDC,'CreateCompatibleDC',SelectObject,'SelectObject',\
       BitBlt,'BitBlt',DeleteDC,'DeleteDC',DeleteObject,'DeleteObject'
;========================================================================
