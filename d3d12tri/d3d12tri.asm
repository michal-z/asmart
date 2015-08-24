format PE64 GUI 4.0
entry start

include '../windows.inc'
include '../highlight_inst.inc'
include '../d3d12.inc'

section '.text' code readable executable
;========================================================================
macro iaca_begin
{
        $mov            ebx,111
        db              $64,$67,$90
}
macro iaca_end
{
        $mov            ebx,222
        db              $64,$67,$90
}
;========================================================================
align 32
supports_avx2:
        $mov            eax,1
        $cpuid
        $and            ecx,$018001000                          ; check OSXSAVE,AVX,FMA
        $cmp            ecx,$018001000
        $jne            .not_supported
        $mov            eax,7
        $xor            ecx,ecx
        $cpuid
        $and            ebx,$20                                 ; check AVX2
        $cmp            ebx,$20
        $jne            .not_supported
        $xor            ecx,ecx
        $xgetbv
        $and            eax,$06                                 ; check OS support
        $cmp            eax,$06
        $jne            .not_supported
        $mov            eax,1
        $jmp            .return
    .not_supported:
        $xor            eax,eax
    .return:
        $ret
;========================================================================
align 32
get_time:
    .k_stack_size = 7*8
        $sub            rsp,.k_stack_size
        $mov            rax,[.perf_freq]
        $test           rax,rax
        $jnz            @f
        $mov            rcx,.perf_freq
        $call           [QueryPerformanceFrequency]
        $mov            rcx,.first_perf_counter
        $call           [QueryPerformanceCounter]
    @@: $mov            rcx,.perf_counter
        $call           [QueryPerformanceCounter]
        $mov            rcx,[.perf_counter]
        $sub            rcx,[.first_perf_counter]
        $mov            rdx,[.perf_freq]
        $vxorps         xmm0,xmm0,xmm0
        $vcvtsi2sd      xmm1,xmm0,rcx
        $vcvtsi2sd      xmm2,xmm0,rdx
        $vdivsd         xmm0,xmm1,xmm2
        $add            rsp,.k_stack_size
        $ret
;========================================================================
align 32
update_frame_stats:
    .k_stack_size = 7*8
        $sub            rsp,.k_stack_size
        $mov            rax,[.prev_time]
        $test           rax,rax
        $jnz            @f
        $call           get_time
        $vmovsd         [.prev_time],xmm0
        $vmovsd         [.prev_update_time],xmm0
    @@: $call           get_time                                ; xmm0 = (0, time)
        $vmovsd         [time],xmm0
        $vsubsd         xmm1,xmm0,[.prev_time]                  ; xmm1 = (0, time_delta)
        $vmovsd         [.prev_time],xmm0
        $vxorps         xmm2,xmm2,xmm2
        $vcvtsd2ss      xmm1,xmm2,xmm1                          ; xmm1 = (0, 0, 0, time_delta)
        $vmovss         [time_delta],xmm1
        $vmovsd         xmm1,[.prev_update_time]                ; xmm1 = (0, prev_update_time)
        $vsubsd         xmm2,xmm0,xmm1                          ; xmm2 = (0, time - prev_update_time)
        $vmovsd         xmm3,[.k_1_0]                           ; xmm3 = (0, 1.0)
        $vcomisd        xmm2,xmm3
        $jb             @f
        $vmovsd         [.prev_update_time],xmm0
        $mov            eax,[.frame]
        $vxorpd         xmm1,xmm1,xmm1
        $vcvtsi2sd      xmm1,xmm1,eax                           ; xmm1 = (0, frame)
        $vdivsd         xmm0,xmm1,xmm2                          ; xmm0 = (0, frame / (time - prev_update_time))
        $vdivsd         xmm1,xmm2,xmm1
        $vmulsd         xmm1,xmm1,[.k_1000000_0]
        $mov            [.frame],0
        $mov            rcx,win_title
        $mov            rdx,win_title_fmt
        $vcvtsd2si      r8,xmm0
        $vcvtsd2si      r9,xmm1
        $call           [wsprintf]
        $mov            rcx,[win_handle]
        $mov            edx,win_title
        $call           [SetWindowText]
    @@: $add            [.frame],1
        $add            rsp,.k_stack_size
        $ret
;========================================================================
align 32
wait_for_gpu:
    .k_stack_size = 6*8
        $push           rdi
        $sub            rsp,.k_stack_size
        $mov            rdi,[fence_value]
        $mov            rcx,[cmdqueue]
        $mov            rdx,[fence]
        $mov            r8,rdi
        $mov            rax,[rcx]
        $call           [rax+ID3D12CommandQueue.Signal]
        $add            [fence_value],1
        $mov            rcx,[fence]
        $mov            rax,[rcx]
        $call           [rax+ID3D12Fence.GetCompletedValue]
        $cmp            rax,rdi
        $jnb            @f
        $mov            rcx,[fence]
        $mov            rdx,rdi
        $mov            r8,[fence_event]
        $mov            rax,[rcx]
        $call           [rax+ID3D12Fence.SetEventOnCompletion]
        $mov            rcx,[fence_event]
        $mov            rdx,INFINITE
        $call           [WaitForSingleObject]
    @@: $add            rsp,.k_stack_size
        $pop            rdi
        $ret
;========================================================================
align 32
generate_gpu_commands:
    virtual at 0
    .funcparam1_4: rq 4
    .funcparam5: rq 1
    .k_stack_size = $
    end virtual
        $push           rdi rsi
        $sub            rsp,.k_stack_size
        $mov            rcx,[cmdallocator]
        $mov            rax,[rcx]
        $call           [rax+ID3D12CommandAllocator.Reset]
        $mov            rdi,[cmdlist]                           ; rdi = [cmdlist]
        $mov            rsi,[rdi]                               ; rsi = [rdi] ([cmdlist] vtable)
        $mov            rcx,rdi
        $mov            rdx,[cmdallocator]
        $xor            r8d,r8d
        $call           [rsi+ID3D12GraphicsCommandList.Reset]
        $mov            rcx,rdi
        $mov            edx,1
        $mov            r8,viewport
        $call           [rsi+ID3D12GraphicsCommandList.RSSetViewports]
        $mov            rcx,rdi
        $mov            edx,1
        $mov            r8,scissor_rect
        $call           [rsi+ID3D12GraphicsCommandList.RSSetScissorRects]
        $mov            eax,[swap_buffer_index]
        $mov            rdx,[swap_buffer+rax*8]
        $mov            [resource_barrier.Transition.pResource],rdx
        $mov            [resource_barrier.Transition.StateBefore],D3D12_RESOURCE_STATE_PRESENT
        $mov            [resource_barrier.Transition.StateAfter],D3D12_RESOURCE_STATE_RENDER_TARGET
        $mov            rcx,rdi
        $mov            edx,1
        $mov            r8,resource_barrier
        $call           [rsi+ID3D12GraphicsCommandList.ResourceBarrier]
        $mov            rcx,rdi
        $mov            edx,[rtv_inc_size]
        $imul           edx,[swap_buffer_index]
        $add            rdx,[rtv_heap_start]
        $mov            r8,clear_color
        $xor            r9d,r9d
        $mov            qword [.funcparam5+rsp],0
        $call           [rsi+ID3D12GraphicsCommandList.ClearRenderTargetView]
        $mov            eax,[swap_buffer_index]
        $mov            rdx,[swap_buffer+rax*8]
        $mov            [resource_barrier.Transition.pResource],rdx
        $mov            [resource_barrier.Transition.StateBefore],D3D12_RESOURCE_STATE_RENDER_TARGET
        $mov            [resource_barrier.Transition.StateAfter],D3D12_RESOURCE_STATE_PRESENT
        $mov            rcx,rdi
        $mov            edx,1
        $mov            r8,resource_barrier
        $call           [rsi+ID3D12GraphicsCommandList.ResourceBarrier]
        $mov            rcx,rdi
        $call           [rsi+ID3D12GraphicsCommandList.Close]
        $add            rsp,.k_stack_size
        $pop            rsi rdi
        $ret
;========================================================================
align 32
init:
    virtual at 0
    .funcparam1_4: rq 4
    .funcparam5: rq 1
    .funcparam6: rq 1
    .funcparam7: rq 1
    .funcparam8: rq 1
    .funcparam9: rq 1
    .funcparam10: rq 1
    .funcparam11: rq 1
    .funcparam12: rq 1
    .funcretbuf: rb 32
    .k_stack_size = $
    end virtual
        $push           rdi rsi rbx
        $sub            rsp,.k_stack_size
        $call           supports_avx2
        $test           eax,eax
        $jz             .error_no_avx2
        ; window class
        $xor            ecx,ecx
        $call           [GetModuleHandle]
        $mov            [win_class.hInstance],rax
        $xor            ecx,ecx
        $mov            edx,IDI_APPLICATION
        $call           [LoadIcon]
        $mov            [win_class.hIcon],rax
        $mov            [win_class.hIconSm],rax
        $xor            ecx,ecx
        $mov            edx,IDC_ARROW
        $call           [LoadCursor]
        $mov            [win_class.hCursor],rax
        $mov            rcx,win_class
        $call           [RegisterClassEx]
        $test           eax,eax
        $jz             .error
        ; window
        $mov            rcx,win_rect
        $mov            edx,k_win_style
        $xor            r8d,r8d
        $call           [AdjustWindowRect]
        $mov            r10d,[win_rect.right]
        $mov            r11d,[win_rect.bottom]
        $sub            r10d,[win_rect.left]
        $sub            r11d,[win_rect.top]
        $xor            ecx,ecx
        $mov            rdx,win_title
        $mov            r8,rdx
        $mov            r9d,WS_VISIBLE+k_win_style
        $mov            eax,CW_USEDEFAULT
        $mov            [.funcparam5+rsp],eax
        $mov            [.funcparam6+rsp],eax
        $mov            [.funcparam7+rsp],r10d
        $mov            [.funcparam8+rsp],r11d
        $mov            [.funcparam9+rsp],ecx
        $mov            [.funcparam10+rsp],ecx
        $mov            rax,[win_class.hInstance]
        $mov            [.funcparam11+rsp],rax
        $mov            [.funcparam12+rsp],ecx
        $call           [CreateWindowEx]
        $mov            [win_handle],rax
        $test           rax,rax
        $jz             .error
        ; DXGI factory
        $mov            rcx,IID_IDXGIFactory
        $mov            rdx,dxgifactory
        $call           [CreateDXGIFactory1]
        $test           eax,eax
        $js             .error
        ; debug layer
        $mov            rcx,IID_ID3D12Debug
        $mov            rdx,dbgi
        $call           [D3D12GetDebugInterface]
        $test           eax,eax
        $js             @f
        $mov            rcx,[dbgi]
        $mov            rax,[rcx]
        $call           [rax+ID3D12Debug.EnableDebugLayer]
    @@: ; device
        $xor            ecx,ecx
        $mov            edx,D3D_FEATURE_LEVEL_11_1
        $mov            r8,IID_ID3D12Device
        $mov            r9,device
        $call           [D3D12CreateDevice]
        $test           eax,eax
        $js             .error
        $mov            rdi,[device]                            ; rdi = [device]
        $mov            rsi,[rdi]                               ; rsi = [rdi] ([device] virtual table)
        ; command queue
        $mov            rcx,rdi
        $mov            rdx,cmdqueue_desc
        $mov            r8,IID_ID3D12CommandQueue
        $mov            r9,cmdqueue
        $call           [rsi+ID3D12Device.CreateCommandQueue]
        $test           eax,eax
        $js             .error
        ; command allocator
        $mov            rcx,rdi
        $mov            edx,D3D12_COMMAND_LIST_TYPE_DIRECT
        $mov            r8,IID_ID3D12CommandAllocator
        $mov            r9,cmdallocator
        $call           [rsi+ID3D12Device.CreateCommandAllocator]
        $test           eax,eax
        $js             .error
        ; swap chain
        $mov            rax,[win_handle]
        $mov            [swapchain_desc.OutputWindow],rax
        $mov            rcx,[dxgifactory]
        $mov            rdx,[cmdqueue]
        $mov            r8,swapchain_desc
        $mov            r9,swapchain
        $mov            rax,[rcx]
        $call           [rax+IDXGIFactory.CreateSwapChain]
        $test           eax,eax
        $js             .error
        ; descriptor increment size
        $mov            rcx,rdi
        $mov            edx,D3D12_DESCRIPTOR_HEAP_TYPE_RTV
        $call           [rsi+ID3D12Device.GetDescriptorHandleIncrementSize]
        $mov            [rtv_inc_size],eax
        $mov            rcx,rdi
        $mov            edx,D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV
        $call           [rsi+ID3D12Device.GetDescriptorHandleIncrementSize]
        $mov            [cbv_srv_uav_inc_size],eax
        ; RTV descriptor heap
        $mov            rcx,rdi
        $mov            rdx,rtv_heap_desc
        $mov            r8,IID_ID3D12DescriptorHeap
        $mov            r9,rtv_heap
        $call           [rsi+ID3D12Device.CreateDescriptorHeap]
        $test           eax,eax
        $js             .error
        $mov            rcx,[rtv_heap]
        $lea            rdx,[.funcretbuf+rsp]
        $mov            rax,[rcx]
        $call           [rax+ID3D12DescriptorHeap.GetCPUDescriptorHandleForHeapStart]
        $mov            rax,[rax]
        $mov            [rtv_heap_start],rax
        ; RTV descriptors
        $xor            ebx,ebx
    .for_each_swap_buffer:
        $mov            rcx,[swapchain]
        $mov            edx,ebx
        $mov            r8,IID_ID3D12Resource
        $lea            r9,[swap_buffer+rbx*8]
        $mov            rax,[rcx]
        $call           [rax+IDXGISwapChain.GetBuffer]
        $test           eax,eax
        $js             .error
        $mov            rcx,rdi
        $mov            rdx,[swap_buffer+rbx*8]
        $xor            r8d,r8d
        $mov            r9d,ebx
        $imul           r9d,[rtv_inc_size]
        $add            r9,[rtv_heap_start]
        $call           [rsi+ID3D12Device.CreateRenderTargetView]
        $add            ebx,1
        $cmp            ebx,k_swap_buffer_count
        $jb             .for_each_swap_buffer
        ; fence
        $mov            rcx,rdi
        $xor            edx,edx
        $mov            r8d,D3D12_FENCE_FLAG_NONE
        $mov            r9,IID_ID3D12Fence
        $mov            rax,fence
        $mov            [.funcparam5+rsp],rax
        $call           [rsi+ID3D12Device.CreateFence]
        $test           eax,eax
        $js             .error
        $xor            ecx,ecx
        $xor            edx,edx
        $xor            r8d,r8d
        $mov            r9d,EVENT_ALL_ACCESS
        $call           [CreateEventEx]
        $test           rax,rax
        $jz             .error
        $mov            [fence_event],rax
        ; create command list
        $mov            rcx,rdi
        $xor            edx,edx
        $mov            r8d,D3D12_COMMAND_LIST_TYPE_DIRECT
        $mov            r9,[cmdallocator]
        $mov            qword [.funcparam5+rsp],0
        $mov            rax,IID_ID3D12GraphicsCommandList
        $mov            [.funcparam6+rsp],rax
        $mov            rax,cmdlist
        $mov            [.funcparam7+rsp],rax
        $call           [rsi+ID3D12Device.CreateCommandList]
        $test           eax,eax
        $js             .error
        ; close and execute command list
        $mov            rcx,[cmdlist]
        $mov            rax,[rcx]
        $call           [rax+ID3D12GraphicsCommandList.Close]
        $test           eax,eax
        $js             .error
        $mov            rcx,[cmdqueue]
        $mov            edx,1
        $mov            r8,cmdlist
        $mov            rax,[rcx]
        $call           [rax+ID3D12CommandQueue.ExecuteCommandLists]
        $test           eax,eax
        $js             .error
        $call           wait_for_gpu
        ; success
        $mov            eax,1
        $jmp            .return
    .error_no_avx2:
        $xor            ecx,ecx
        $mov            rdx,no_avx2_message
        $mov            r8,no_avx2_caption
        $xor            r9d,r9d
        $call           [MessageBox]
        $xor            eax,eax
        $jmp            .return
    .error:
        ;$invoke
        $xor            eax,eax
    .return:
        $add            rsp,.k_stack_size
        $pop            rbx rsi rdi
        $ret
;========================================================================
align 32
deinit:
        $ret
;========================================================================
align 32
update:
    .k_stack_size = 7*8
        $sub            rsp,.k_stack_size
        $call           update_frame_stats
        $call           generate_gpu_commands
        $mov            rcx,[cmdqueue]
        $mov            edx,1
        $mov            r8,cmdlist
        $mov            rax,[rcx]
        $call           [rax+ID3D12CommandQueue.ExecuteCommandLists]
        $mov            rcx,[swapchain]
        $xor            edx,edx
        $mov            r8d,DXGI_PRESENT_RESTART
        $mov            rax,[rcx]
        $call           [rax+IDXGISwapChain.Present]
        $mov            eax,[swap_buffer_index]
        $add            eax,1
        $and            eax,$03
        $mov            [swap_buffer_index],eax
        $call           wait_for_gpu
        $add            rsp,.k_stack_size
        $ret
;========================================================================
align 32
start:
    virtual at 0
    .funcparam1_4: rq 4
    .funcparam5: rq 1
    .k_stack_size = $+16
    end virtual
        $sub            rsp,.k_stack_size
        $call           init
        $test           eax,eax
        $jz             .quit
    .main_loop:
        $mov            rcx,win_msg
        $xor            edx,edx
        $xor            r8d,r8d
        $xor            r9d,r9d
        $mov            dword [.funcparam5+rsp],PM_REMOVE
        $call           [PeekMessage]
        $test           eax,eax
        $jz             .update
        $mov            rcx,win_msg
        $call           [DispatchMessage]
        $cmp            [win_msg.message],WM_QUIT
        $je             .quit
        $jmp            .main_loop
    .update:
        $call           update
        $jmp            .main_loop
    .quit:
        $call           deinit
        $xor            ecx,ecx
        $call           [ExitProcess]
;========================================================================
align 32
winproc:
        $sub            rsp,40
        $cmp            edx,WM_KEYDOWN
        $je             .keydown
        $cmp            edx,WM_DESTROY
        $je             .destroy
        $call           [DefWindowProc]
        $jmp            .return
    .keydown:
        $cmp            r8d,VK_ESCAPE
        $jne            .return
        $xor            ecx,ecx
        $call           [PostQuitMessage]
        $xor            eax,eax
        $jmp            .return
    .destroy:
        $xor            ecx,ecx
        $call           [PostQuitMessage]
        $xor            eax,eax
    .return:
        $add            rsp,40
        $ret

struc test x
{
    .x dd ?
    .  rb 32
    virtual at .
    .a_0 dd 1
    end virtual

    virtual at .
    .b_0 dq 2
    end virtual
}
xxx test
mov [xxx.b_0],rax
;========================================================================
section '.data' data readable writeable

k_win_width equ 1024
k_win_height equ 1024
k_win_widthf equ 1024.0
k_win_heightf equ 1024.0
k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

k_swap_buffer_count = 4

align 8
win_handle dq 0
win_title db 'Direct3D 12 Triangle', 64 dup (0)
win_title_fmt db '[%d fps  %d us] Direct3D 12 Triangle',0
win_msg MSG 0,0,0,0,0,<0,0>
win_class WNDCLASSEX 0,winproc,0,0,0,0,0,0,0,win_title,0
win_rect RECT 0,0,k_win_width,k_win_height

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
dxgifactory dq 0
swapchain dq 0
dbgi dq 0
device dq 0
cmdqueue dq 0
cmdallocator dq 0
cmdlist dq 0
rtv_heap dq 0
rtv_heap_start dq 0
swap_buffer dq k_swap_buffer_count dup (0)
fence dq 0
fence_value dq 1
fence_event dq 0

align 4
rtv_inc_size dd 0
cbv_srv_uav_inc_size dd 0
swap_buffer_index dd 0
clear_color dd 0.0,0.2,0.4,1.0

align 8
viewport D3D12_VIEWPORT 0.0,0.0,k_win_widthf,k_win_heightf,0.0,1.0
align 8
scissor_rect D3D12_RECT 0,0,k_win_width,k_win_height

align 8
cmdqueue_desc D3D12_COMMAND_QUEUE_DESC D3D12_COMMAND_LIST_TYPE_DIRECT,0,D3D12_COMMAND_QUEUE_FLAG_NONE,0
align 8
swapchain_desc DXGI_SWAP_CHAIN_DESC <k_win_width,k_win_height,<0,0>,DXGI_FORMAT_R8G8B8A8_UNORM,0,0>,<1,0>,DXGI_USAGE_RENDER_TARGET_OUTPUT,\
                                    k_swap_buffer_count,0,1,DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL,0
align 8
rtv_heap_desc D3D12_DESCRIPTOR_HEAP_DESC D3D12_DESCRIPTOR_HEAP_TYPE_RTV,k_swap_buffer_count,D3D12_DESCRIPTOR_HEAP_FLAG_NONE,0

align 8
resource_barrier D3D12_RESOURCE_BARRIER D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,D3D12_RESOURCE_BARRIER_FLAG_NONE,\
                 <0,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,0,0>

align 8
IID_IDXGIFactory GUID 0x7b7166ec,0x21c7,0x44ae,0xb2,0x1a,0xc9,0xae,0x32,0x1a,0xe3,0x69
IID_IDXGISwapChain GUID 0x310d36a0,0xd2e7,0x4c0a,0xaa,0x04,0x6a,0x9d,0x23,0xb8,0x88,0x6a
IID_ID3D12Device GUID 0x189819f1,0x1db6,0x4b57,0xbe,0x54,0x18,0x21,0x33,0x9b,0x85,0xf7
IID_ID3D12Debug GUID 0x344488b7,0x6846,0x474b,0xb9,0x89,0xf0,0x27,0x44,0x82,0x45,0xe0
IID_ID3D12CommandQueue GUID 0x0ec870a6,0x5d7e,0x4c22,0x8c,0xfc,0x5b,0xaa,0xe0,0x76,0x16,0xed
IID_ID3D12CommandAllocator GUID 0x6102dee4,0xaf59,0x4b09,0xb9,0x99,0xb4,0x4d,0x73,0xf0,0x9b,0x24
IID_ID3D12CommandList GUID 0x7116d91c,0xe7e4,0x47ce,0xb8,0xc6,0xec,0x81,0x68,0xf4,0x37,0xe5
IID_ID3D12GraphicsCommandList GUID 0x5b160d0f,0xac1b,0x4185,0x8b,0xa8,0xb3,0xae,0x42,0xa5,0xa4,0x55
IID_ID3D12DescriptorHeap GUID 0x8efb471d,0x616c,0x4f49,0x90,0xf7,0x12,0x7b,0xb7,0x63,0xfa,0x51
IID_ID3D12Resource GUID 0x696442be,0xa72e,0x4059,0xbc,0x79,0x5b,0x5c,0x98,0x04,0x0f,0xad
IID_ID3D12Fence GUID 0x0a753dcf,0xc4d8,0x4b91,0xad,0xf6,0xbe,0x5a,0x60,0xd9,0x5a,0x76
;========================================================================
section '.idata' import data readable writeable

dd 0,0,0,rva _kernel32,rva _kernel32_table
dd 0,0,0,rva _user32,rva _user32_table
dd 0,0,0,rva _dxgi,rva _dxgi_table
dd 0,0,0,rva _d3d12,rva _d3d12_table
dd 0,0,0,0,0

_kernel32_table:
ExitProcess dq rva _ExitProcess
GetModuleHandle dq rva _GetModuleHandle
WaitForSingleObject dq rva _WaitForSingleObject
QueryPerformanceFrequency dq rva _QueryPerformanceFrequency
QueryPerformanceCounter dq rva _QueryPerformanceCounter
CloseHandle dq rva _CloseHandle
CreateEventEx dq rva _CreateEventEx
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
PostQuitMessage dq rva _PostQuitMessage
MessageBox dq rva _MessageBox
dq 0

_dxgi_table:
CreateDXGIFactory1 dq rva _CreateDXGIFactory1
dq 0

_d3d12_table:
D3D12CreateDevice dq rva _D3D12CreateDevice
D3D12GetDebugInterface dq rva _D3D12GetDebugInterface
dq 0

_kernel32 db 'kernel32.dll',0
_user32 db 'user32.dll',0
_dxgi db 'dxgi.dll',0
_d3d12 db 'd3d12.dll',0

_ExitProcess dw 0
db 'ExitProcess',0
_GetModuleHandle dw 0
db 'GetModuleHandleA',0
_WaitForSingleObject dw 0
db 'WaitForSingleObject',0
_QueryPerformanceFrequency dw 0
db 'QueryPerformanceFrequency',0
_QueryPerformanceCounter dw 0
db 'QueryPerformanceCounter',0
_CloseHandle dw 0
db 'CloseHandle',0
_CreateEventEx dw 0
db 'CreateEventExA',0

_wsprintf dw 0
db 'wsprintfA',0
_RegisterClassEx dw 0
db 'RegisterClassExA',0
_CreateWindowEx dw 0
db 'CreateWindowExA',0
_DefWindowProc dw 0
db 'DefWindowProcA',0
_PeekMessage dw 0
db 'PeekMessageA',0
_DispatchMessage dw 0
db 'DispatchMessageA',0
_LoadCursor dw 0
db 'LoadCursorA',0
_LoadIcon dw 0
db 'LoadIconA',0
_SetWindowText dw 0
db 'SetWindowTextA',0
_AdjustWindowRect dw 0
db 'AdjustWindowRect',0
_PostQuitMessage dw 0
db 'PostQuitMessage',0
_MessageBox dw 0
db 'MessageBoxA',0

_CreateDXGIFactory1 dw 0
db 'CreateDXGIFactory1',0

_D3D12CreateDevice dw 0
db 'D3D12CreateDevice',0
_D3D12GetDebugInterface dw 0
db 'D3D12GetDebugInterface',0
;========================================================================