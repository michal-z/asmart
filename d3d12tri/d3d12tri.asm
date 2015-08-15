format PE64 GUI 4.0
entry start
include 'win64a.inc'
include '../highlight_inst.inc'
include '../d3d12.inc'

struct GUID
  dd ?
  dw ?
  dw ?
  db ?
  db ?
  db ?
  db ?
  db ?
  db ?
  db ?
  db ?
ends

section '.text' code readable executable
program_section = 'code'
;========================================================================
macro iaca_begin
{
        $mov ebx,111
        db $64,$67,$90
}
macro iaca_end
{
        $mov ebx,222
        db $64,$67,$90
}
;========================================================================
align 32
supports_avx2:
        $mov eax,1
        $cpuid
        $and ecx,$018001000                             ; check OSXSAVE,AVX,FMA
        $cmp ecx,$018001000
        $jne .not_supported
        $mov eax,7
        $xor ecx,ecx
        $cpuid
        $and ebx,$20                                    ; check AVX2
        $cmp ebx,$20
        $jne .not_supported
        $xor ecx,ecx
        $xgetbv
        $and eax,$06                                    ; check OS support
        $cmp eax,$06
        $jne .not_supported
        $mov eax,1
        $jmp .return
    .not_supported:
        $xor eax,eax
    .return:
        $ret
;========================================================================
align 32
get_time:
        $sub rsp,24
        $mov rax,[.perf_freq]
        $test rax,rax
        $jnz @f
        $invoke QueryPerformanceFrequency,addr .perf_freq
        $invoke QueryPerformanceCounter,addr .first_perf_counter
    @@: $invoke QueryPerformanceCounter,addr .perf_counter
        $mov rcx,[.perf_counter]
        $sub rcx,[.first_perf_counter]
        $mov rdx,[.perf_freq]
        $vxorps xmm0,xmm0,xmm0
        $vcvtsi2sd xmm1,xmm0,rcx
        $vcvtsi2sd xmm2,xmm0,rdx
        $vdivsd xmm0,xmm1,xmm2
        $add rsp,24
        $ret
;========================================================================
align 32
update_frame_stats:
        $sub rsp,24
        $mov rax,[.prev_time]
        $test rax,rax
        $jnz @f
        $call get_time
        $vmovsd [.prev_time],xmm0
        $vmovsd [.prev_update_time],xmm0
    @@: $call get_time                                  ; xmm0 = (0, time)
        $vmovsd [time],xmm0
        $vsubsd xmm1,xmm0,[.prev_time]                  ; xmm1 = (0, time_delta)
        $vmovsd [.prev_time],xmm0
        $vxorps xmm2,xmm2,xmm2
        $vcvtsd2ss xmm1,xmm2,xmm1                       ; xmm1 = (0, 0, 0, time_delta)
        $vmovss [time_delta],xmm1
        $vmovsd xmm1,[.prev_update_time]                ; xmm1 = (0, prev_update_time)
        $vsubsd xmm2,xmm0,xmm1                          ; xmm2 = (0, time - prev_update_time)
        $vmovsd xmm3,[.k_1_0]                           ; xmm3 = (0, 1.0)
        $vcomisd xmm2,xmm3
        $jb @f
        $vmovsd [.prev_update_time],xmm0
        $mov eax,[.frame]
        $vxorpd xmm1,xmm1,xmm1
        $vcvtsi2sd xmm1,xmm1,eax                        ; xmm1 = (0, frame)
        $vdivsd xmm0,xmm1,xmm2                          ; xmm0 = (0, frame / (time - prev_update_time))
        $vdivsd xmm1,xmm2,xmm1
        $vmulsd xmm1,xmm1,[.k_1000000_0]
        $vcvtsd2si r10,xmm0
        $vcvtsd2si r11,xmm1
        $mov [.frame],0
        $cinvoke wsprintf,addr win_title,addr win_title_fmt,r10,r11
        $invoke SetWindowText,[win_handle],win_title
    @@: $add [.frame],1
        $add rsp,24
        $ret
;========================================================================
align 32
init:
        $push rsi
        $sub rsp,16
        $call supports_avx2
        $test eax,eax
        $jz .no_avx2
        $invoke GetModuleHandle,0
        $mov [win_class.hInstance],rax
        $invoke LoadIcon,0,IDI_APPLICATION
        $mov [win_class.hIcon],rax
        $mov [win_class.hIconSm],rax
        $invoke LoadCursor,0,IDC_ARROW
        $mov [win_class.hCursor],rax
        $invoke RegisterClassEx,win_class
        $test eax,eax
        $jz .error
        $invoke SetRect,win_rect,0,0,k_win_width,k_win_height
        $test eax,eax
        $jz .error
        $invoke AdjustWindowRect,win_rect,k_win_style,FALSE
        $test eax,eax
        $jz .error
        $mov esi,[win_rect.right]
        $mov edi,[win_rect.bottom]
        $sub esi,[win_rect.left]
        $sub edi,[win_rect.top]
        $invoke CreateWindowEx,0,win_title,win_title,WS_VISIBLE+k_win_style,CW_USEDEFAULT,CW_USEDEFAULT,esi,edi,NULL,NULL,[win_class.hInstance],NULL
        $mov [win_handle],rax
        $test rax,rax
        $jz .error
        $invoke CreateDXGIFactory1,IID_IDXGIFactory,dxgifactory
        $test eax,eax
        $js .error
        $mov rax,[dxgifactory]
        $test rax,rax
        $jz .error
        $invoke D3D12GetDebugInterface,IID_ID3D12Debug,dbgi
        $cominvk dbgi,EnableDebugLayer

        $invoke D3D12CreateDevice,NULL,D3D_FEATURE_LEVEL_11_1,IID_ID3D12Device,device
        $test eax,eax
        $js .error

        $mov eax,1
        $add rsp,16
        $pop rsi
        $ret
    .no_avx2:
        $invoke MessageBox,NULL,addr no_avx2_message,addr no_avx2_caption,0
        $jmp .return0
    .error:
        ;$invoke
    .return0:
        $xor eax,eax
        $add rsp,16
        $pop rsi
        $ret
;========================================================================
align 32
deinit:
        $ret
;========================================================================
align 32
update:
        $sub rsp,24
        $call update_frame_stats
        $add rsp,24
        $ret
;========================================================================
align 32
start:
        $and rsp,-32
        $call init
        $test eax,eax
        $jz .quit
    .main_loop:
        $invoke PeekMessage,win_msg,NULL,0,0,PM_REMOVE
        $test eax,eax
        $jz .update
        $invoke DispatchMessage,win_msg
        $cmp [win_msg.message],WM_QUIT
        $je .quit
        $jmp .main_loop
    .update:
        $call update
        $jmp .main_loop
    .quit:
        $call deinit
        $invoke ExitProcess,0
;========================================================================
align 32
proc winproc hwnd,msg,wparam,lparam
        $mov [hwnd],rcx
        $mov [msg],rdx
        $mov [wparam],r8
        $mov [lparam],r9
        $cmp edx,WM_KEYDOWN
        $je .keydown
        $cmp edx,WM_DESTROY
        $je .destroy
        $invoke DefWindowProc,rcx,rdx,r8,r9
        $jmp .return
    .keydown:
        $cmp [wparam],VK_ESCAPE
        $jne .return
        $invoke PostQuitMessage,0
        $xor eax,eax
        $jmp .return
    .destroy:
        $invoke PostQuitMessage,0
        $xor eax,eax
    .return:
        $ret
endp
;========================================================================
section '.data' data readable writeable
program_section = 'data'

k_win_width = 1024
k_win_height = 1024
k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

align 8
win_handle dq 0
win_title db 'Direct3D 12 Triangle', 64 dup 0
win_title_fmt db '[%d fps  %d us] Direct3D 12 Triangle',0
win_msg MSG
win_class WNDCLASSEX sizeof.WNDCLASSEX,0,winproc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,win_title,NULL
win_rect RECT

no_avx2_caption db 'Not supported CPU',0
no_avx2_message db 'Your CPU does not support AVX2, program will not run.',0

align 8
time dq 0
time_delta dd 0,0

get_time.perf_counter dq 0
get_time.perf_freq dq 0
get_time.first_perf_counter dq 0

update_frame_stats.prev_time dq 0
update_frame_stats.prev_update_time dq 0
update_frame_stats.frame dd 0,0
update_frame_stats.k_1000000_0 dq 1000000.0
update_frame_stats.k_1_0 dq 1.0

align 8
dxgifactory IDXGIFactory
dbgi ID3D12Debug
device ID3D12Device

align 8
IID_IDXGIFactory GUID 0x7b7166ec,0x21c7,0x44ae,0xb2,0x1a,0xc9,0xae,0x32,0x1a,0xe3,0x69
IID_ID3D12Device GUID 0x189819f1,0x1db6,0x4b57,0xbe,0x54,0x18,0x21,0x33,0x9b,0x85,0xf7
IID_ID3D12Debug GUID 0x344488b7,0x6846,0x474b,0xb9,0x89,0xf0,0x27,0x44,0x82,0x45,0xe0
;========================================================================
section '.idata' import data readable writeable

library kernel32,'kernel32.dll',user32,'user32.dll',d3d12,'d3d12.dll',dxgi,'dxgi.dll'

import kernel32,\
    GetModuleHandle,'GetModuleHandleA',ExitProcess,'ExitProcess',\
    WaitForSingleObject,'WaitForSingleObject',ReleaseSemaphore,'ReleaseSemaphore',\
    ExitThread,'ExitThread',QueryPerformanceFrequency,'QueryPerformanceFrequency',\
    QueryPerformanceCounter,'QueryPerformanceCounter',CreateSemaphore,'CreateSemaphoreA',\
    CreateThread,'CreateThread',CloseHandle,'CloseHandle',\
    WaitForMultipleObjects,'WaitForMultipleObjects',GetSystemInfo,'GetSystemInfo'

import user32,\
    wsprintf,'wsprintfA',RegisterClassEx,'RegisterClassExA',\
    CreateWindowEx,'CreateWindowExA',DefWindowProc,'DefWindowProcA',\
    PeekMessage,'PeekMessageA',DispatchMessage,'DispatchMessageA',\
    LoadCursor,'LoadCursorA',LoadIcon,'LoadIconA',\
    SetWindowText,'SetWindowTextA',SetRect,'SetRect',AdjustWindowRect,'AdjustWindowRect',\
    GetDC,'GetDC',ReleaseDC,'ReleaseDC',PostQuitMessage,'PostQuitMessage',MessageBox,'MessageBoxA'

import dxgi,\
    CreateDXGIFactory1,'CreateDXGIFactory1'

import d3d12,\
    D3D12CreateDevice,'D3D12CreateDevice',D3D12GetDebugInterface,'D3D12GetDebugInterface'
;========================================================================