format PE64 GUI 4.0
entry start

include '../windows.inc'
include '../highlight_inst.inc'
include '../d3d12.inc'

macro $emit [inst]
{
    forward
        inst
}
macro $barrier cmdlist,vtable,res,sbefore,safter
{
        $mov            [resource_barrier.Transition.pResource],res
        $mov            [resource_barrier.Transition.StateBefore],sbefore
        $mov            [resource_barrier.Transition.StateAfter],safter
        $comcallv       cmdlist,vtable,ID3D12GraphicsCommandList.ResourceBarrier,dword 1,resource_barrier
}
macro $comrelease obj
{
        $mov            rcx,obj
        $test           rcx,rcx
        $jz             @f
        $comcall        rcx,IUnknown.Release
        $mov            obj,0
    @@:
}

section '.text' code readable executable
;========================================================================
align 32
check_cpu:
        $mov            eax,1
        $cpuid
        $and            ecx,$018000000                          ; check OSXSAVE,AVX (018001000 if FMA required)
        $cmp            ecx,$018000000
        $jne            .not_supported
       ;$mov            eax,7
       ;$xor            ecx,ecx
       ;$cpuid
       ;$and            ebx,$20                                 ; check AVX2
       ;$cmp            ebx,$20
       ;$jne            .not_supported
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
        $invoke         QueryPerformanceFrequency,addr .perf_freq
        $invoke         QueryPerformanceCounter,addr .first_perf_counter
    @@: $invoke         QueryPerformanceCounter,addr .perf_counter
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
        $vcvtsd2si      r8,xmm0
        $vcvtsd2si      r9,xmm1
        $invoke         wsprintf,win_title,win_title_fmt,r8,r9
        $invoke         SetWindowText,[win_handle],win_title
    @@: $add            [.frame],1
        $add            rsp,.k_stack_size
        $ret
;========================================================================
align 32
load_binary_file:
    virtual at 0
    rq 7
    .bytes_read dd ?
    dd ?
    .k_stack_size = $
    end virtual
        $push           rdi rsi rbx
        $sub            rsp,.k_stack_size
        $xor            esi,esi                                 ; file handle
        $xor            edi,edi                                 ; memory pointer
        $invoke         CreateFile,rcx,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
        $cmp            rax,INVALID_HANDLE_VALUE
        $je             .error
        $mov            rsi,rax
        $invoke         GetFileSize,rsi,0
        $cmp            eax,INVALID_FILE_SIZE
        $je             .error
        $mov            ebx,eax
        $invoke         HeapAlloc,[def_heap],0,ebx
        $test           rax,rax
        $jz             .error
        $mov            rdi,rax
        $invoke         ReadFile,rsi,rdi,ebx,addr .bytes_read+rsp,0
        $test           eax,eax
        $jz             .error
        $cmp            [.bytes_read+rsp],ebx
        $jne            .error
        $invoke         CloseHandle,rsi
        $mov            rax,rdi
        $mov            edx,ebx
        $jmp            .done
    .error:
        $test           rsi,rsi
        $jz             @f
        $invoke         CloseHandle,rsi
    @@: $test           rdi,rdi
        $jz             @f
        $invoke         HeapFree,[def_heap],0,rdi
    @@: $xor            eax,eax
        $xor            edx,edx
    .done:
        $add            rsp,.k_stack_size
        $pop            rbx rsi rdi
        $ret
;========================================================================
align 32
wait_for_gpu:
    .k_stack_size = 6*8
        $push           rdi
        $sub            rsp,.k_stack_size
        $mov            rdi,[fence_value]
        $comcall        [cmdqueue],ID3D12CommandQueue.Signal,[fence],rdi
        $add            [fence_value],1
        $comcall        [fence],ID3D12Fence.GetCompletedValue
        $cmp            rax,rdi
        $jnb            @f
        $comcall        [fence],ID3D12Fence.SetEventOnCompletion,rdi,[fence_event]
        $invoke         WaitForSingleObject,[fence_event],dword INFINITE
    @@: $add            rsp,.k_stack_size
        $pop            rdi
        $ret
;========================================================================
align 32
generate_gpu_commands:
    virtual at 0
    rq 5
    .rtv_handle dq ?
    .k_stack_size = $+24
    end virtual
        $push           rdi rsi
        $sub            rsp,.k_stack_size
        $mov            rdi,[cmdlist]                           ; rdi = [cmdlist]
        $mov            rsi,[rdi]                               ; rsi = [rdi] ([cmdlist] vtable)
        $comcall        [cmdallocator],ID3D12CommandAllocator.Reset
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.Reset,[cmdallocator],[pso]
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.SetGraphicsRootSignature,[root_signature]
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.RSSetViewports,dword 1,viewport
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.RSSetScissorRects,dword 1,scissor_rect

        $mov            eax,[swap_buffer_index]
        $mov            rax,[swap_buffer+rax*8]
        $barrier        rdi,rsi,rax,D3D12_RESOURCE_STATE_PRESENT,D3D12_RESOURCE_STATE_RENDER_TARGET

        $mov            edx,[rtv_inc_size]
        $imul           edx,[swap_buffer_index]
        $add            rdx,[rtv_heap_start]
        $mov            [.rtv_handle+rsp],rdx
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.ClearRenderTargetView,rdx,clear_color,dword 0,0
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.OMSetRenderTargets,dword 1,addr .rtv_handle+rsp,dword 1,0
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.IASetPrimitiveTopology,dword D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST
        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.DrawInstanced,dword 3,dword 1,dword 0,dword 0

        $mov            eax,[swap_buffer_index]
        $mov            rax,[swap_buffer+rax*8]
        $barrier        rdi,rsi,rax,D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_PRESENT

        $comcallv       rdi,rsi,ID3D12GraphicsCommandList.Close
        $add            rsp,.k_stack_size
        $pop            rsi rdi
        $ret
;========================================================================
align 32
init:
    virtual at 0
    rq 12
    .funcretbuf: rb 32
    .k_stack_size = $
    end virtual
        $push           rdi rsi rbx
        $sub            rsp,.k_stack_size
        $call           check_cpu
        $test           eax,eax
        $jz             .error_cpu
        ; process heap
        $invoke         GetProcessHeap
        $mov            [def_heap],rax
        $test           rax,rax
        $jz             .error
        ; window class
        $invoke         GetModuleHandle,0
        $mov            [win_class.hInstance],rax
        $invoke         LoadIcon,0,IDI_APPLICATION
        $mov            [win_class.hIcon],rax
        $mov            [win_class.hIconSm],rax
        $invoke         LoadCursor,0,IDC_ARROW
        $mov            [win_class.hCursor],rax
        $invoke         RegisterClassEx,win_class
        $test           eax,eax
        $jz             .error
        ; window
        $invoke         AdjustWindowRect,win_rect,k_win_style,0
        $mov            r10d,[win_rect.right]
        $mov            r11d,[win_rect.bottom]
        $sub            r10d,[win_rect.left]
        $sub            r11d,[win_rect.top]
        $invoke         CreateWindowEx,0,win_title,win_title,WS_VISIBLE+k_win_style,CW_USEDEFAULT,CW_USEDEFAULT,r10d,r11d,0,0,[win_class.hInstance],0
        $mov            [win_handle],rax
        $test           rax,rax
        $jz             .error
        ; DXGI factory
        $invoke         CreateDXGIFactory1,IID_IDXGIFactory,dxgifactory
        $test           eax,eax
        $js             .error
        ; debug layer
        $invoke         D3D12GetDebugInterface,IID_ID3D12Debug,dbgi
        $test           eax,eax
        $js             @f
        $comcall        [dbgi],ID3D12Debug.EnableDebugLayer
    @@: ; device
        $invoke         D3D12CreateDevice,0,D3D_FEATURE_LEVEL_11_1,IID_ID3D12Device,device
        $test           eax,eax
        $js             .error
        $mov            rdi,[device]                            ; rdi = [device]
        $mov            rsi,[rdi]                               ; rsi = [rdi] ([device] virtual table)
        ; command queue
        $comcallv       rdi,rsi,ID3D12Device.CreateCommandQueue,cmdqueue_desc,IID_ID3D12CommandQueue,cmdqueue
        $test           eax,eax
        $js             .error
        ; command allocator
        $comcallv       rdi,rsi,ID3D12Device.CreateCommandAllocator,D3D12_COMMAND_LIST_TYPE_DIRECT,IID_ID3D12CommandAllocator,cmdallocator
        $test           eax,eax
        $js             .error
        ; swap chain
        $mov            rax,[win_handle]
        $mov            [swapchain_desc.OutputWindow],rax
        $comcall        [dxgifactory],IDXGIFactory.CreateSwapChain,[cmdqueue],swapchain_desc,swapchain
        $test           eax,eax
        $js             .error
        ; descriptor increment size
        $comcallv       rdi,rsi,ID3D12Device.GetDescriptorHandleIncrementSize,D3D12_DESCRIPTOR_HEAP_TYPE_RTV
        $mov            [rtv_inc_size],eax
        $comcallv       rdi,rsi,ID3D12Device.GetDescriptorHandleIncrementSize,D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV
        $mov            [cbv_srv_uav_inc_size],eax
        ; RTV descriptor heap
        $comcallv       rdi,rsi,ID3D12Device.CreateDescriptorHeap,rtv_heap_desc,IID_ID3D12DescriptorHeap,rtv_heap
        $test           eax,eax
        $js             .error
        $comcall        [rtv_heap],ID3D12DescriptorHeap.GetCPUDescriptorHandleForHeapStart,addr .funcretbuf+rsp
        $mov            rax,[rax]
        $mov            [rtv_heap_start],rax
        ; RTV descriptors
        $xor            ebx,ebx
    .for_each_swap_buffer:
        $comcall        [swapchain],IDXGISwapChain.GetBuffer,ebx,IID_ID3D12Resource,addr swap_buffer+rbx*8
        $test           eax,eax
        $js             .error
        $mov            r9d,ebx
        $imul           r9d,[rtv_inc_size]
        $add            r9,[rtv_heap_start]
        $comcallv       rdi,rsi,ID3D12Device.CreateRenderTargetView,[swap_buffer+rbx*8],0,r9
        $add            ebx,1
        $cmp            ebx,4
        $jb             .for_each_swap_buffer
        ; fence
        $comcallv       rdi,rsi,ID3D12Device.CreateFence,0,D3D12_FENCE_FLAG_NONE,IID_ID3D12Fence,fence
        $test           eax,eax
        $js             .error
        ; fence event
        $invoke         CreateEventEx,0,0,0,EVENT_ALL_ACCESS
        $mov            [fence_event],rax
        $test           rax,rax
        $jz             .error
        ; root signature
        $invoke         D3D12SerializeRootSignature,root_signature_desc,D3D_ROOT_SIGNATURE_VERSION_1,d3dblob,0
        $comcall        [d3dblob],ID3DBlob.GetBufferPointer
        $mov            rbx,rax
        $comcall        [d3dblob],ID3DBlob.GetBufferSize
        $comcallv       rdi,rsi,ID3D12Device.CreateRootSignature,0,rbx,rax,IID_ID3D12RootSignature,root_signature
        $mov            ebx,eax
        $comrelease     [d3dblob]
        $test           ebx,ebx
        $js             .error
        ; create command list
        $comcallv       rdi,rsi,ID3D12Device.CreateCommandList,0,D3D12_COMMAND_LIST_TYPE_DIRECT,[cmdallocator],0,IID_ID3D12GraphicsCommandList,cmdlist
        $test           eax,eax
        $js             .error
        ; PSO
        $mov            rax,[root_signature]
        $mov            [pso_desc.pRootSignature],rax
        $fastcall       load_binary_file,_vs_triangle
        $test           rax,rax
        $jz             .error
        $mov            [pso_desc.VS.pShaderBytecode],rax
        $mov            [pso_desc.VS.BytecodeLength],rdx
        $fastcall       load_binary_file,_ps_triangle
        $test           rax,rax
        $jz             .error
        $mov            [pso_desc.PS.pShaderBytecode],rax
        $mov            [pso_desc.PS.BytecodeLength],rdx
        $comcallv       rdi,rsi,ID3D12Device.CreateGraphicsPipelineState,pso_desc,IID_ID3D12PipelineState,pso
        $mov            ebx,eax
        $invoke         HeapFree,[def_heap],0,[pso_desc.VS.pShaderBytecode]
        $invoke         HeapFree,[def_heap],0,[pso_desc.PS.pShaderBytecode]
        $test           ebx,ebx
        $js             .error
        ; close and execute command list
        $comcall        [cmdlist],ID3D12GraphicsCommandList.Close
        $test           eax,eax
        $js             .error
        $comcall        [cmdqueue],ID3D12CommandQueue.ExecuteCommandLists,1,cmdlist
        $test           eax,eax
        $js             .error
        ; success
        $call           wait_for_gpu
        $mov            eax,1
        $jmp            .return
    .error_cpu:
        $invoke         MessageBox,0,_err_cpu_message,_err_cpu_caption,0
        $xor            eax,eax
        $jmp            .return
    .error:
        $invoke         MessageBox,0,_err_init_message,_err_init_caption,0
        $xor            eax,eax
    .return:
        $add            rsp,.k_stack_size
        $pop            rbx rsi rdi
        $ret
;========================================================================
align 32
deinit:
    .k_stack_size = 6*8
        $push           rbx
        $sub            rsp,.k_stack_size
        $mov            rcx,[cmdlist]
        $test           rcx,rcx
        $jz             @f
        $call           wait_for_gpu
    @@: $comrelease     [cmdlist]
        $comrelease     [fence]
        $comrelease     [rtv_heap]

        $xor            ebx,ebx
    .for_each_swap_buffer:
        $comrelease     [swap_buffer+rbx*8]
        $add            ebx,1
        $cmp            ebx,4
        $jb             .for_each_swap_buffer

        $comrelease     [swapchain]
        $comrelease     [dxgifactory]
        $comrelease     [cmdallocator]
        $comrelease     [cmdqueue]
        $comrelease     [dbgi]
        $comrelease     [pso]
        $comrelease     [root_signature]
        $comrelease     [device]
        $mov            rcx,[fence_event]
        $test           rcx,rcx
        $jz             @f
        $invoke         CloseHandle
    @@: $add            rsp,.k_stack_size
        $pop            rbx
        $ret
;========================================================================
align 32
update:
    .k_stack_size = 7*8
        $sub            rsp,.k_stack_size
        $call           update_frame_stats
        $call           generate_gpu_commands
        $test           eax,eax
        $js             .return
        $comcall        [cmdqueue],ID3D12CommandQueue.ExecuteCommandLists,dword 1,cmdlist
        $comcall        [swapchain],IDXGISwapChain.Present,dword 0,dword DXGI_PRESENT_RESTART
        ; increment swap buffer index
        $mov            eax,[swap_buffer_index]
        $add            eax,1
        $and            eax,$03
        $mov            [swap_buffer_index],eax
        $call           wait_for_gpu
    .return:
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
        $invoke         PeekMessage,win_msg,eax,eax,eax,dword PM_REMOVE
        $test           eax,eax
        $jz             .update
        $invoke         DispatchMessage,win_msg
        $cmp            [win_msg.message],WM_QUIT
        $je             .quit
        $jmp            .main_loop
    .update:
        $call           update
        $test           eax,eax
        $js             .quit
        $jmp            .main_loop
    .quit:
        $call           deinit
        $invoke         ExitProcess,0
;========================================================================
align 32
winproc:
        $sub            rsp,40
        $cmp            edx,WM_KEYDOWN
        $je             .keydown
        $cmp            edx,WM_DESTROY
        $je             .destroy
        $invoke         DefWindowProc,rcx,rdx,r8,r9
        $jmp            .return
    .keydown:
        $cmp            r8d,VK_ESCAPE
        $jne            .return
        $invoke         PostQuitMessage,0
        $xor            eax,eax
        $jmp            .return
    .destroy:
        $invoke         PostQuitMessage,0
        $xor            eax,eax
    .return:
        $add            rsp,40
        $ret
;========================================================================
section '.data' data readable writeable

k_win_width = 1024
k_win_height = 1024
k_win_widthf equ 1024.0
k_win_heightf equ 1024.0
k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

align 8
win_handle dq 0
win_title db 'Direct3D 12 Triangle', 64 dup (0)
win_title_fmt db '[%d fps  %d us] Direct3D 12 Triangle',0
win_msg MSG 0,0,0,0,0,<0,0>
win_class WNDCLASSEX 0,winproc,0,0,0,0,0,0,0,win_title,0
win_rect RECT 0,0,k_win_width,k_win_height

_err_init_caption db 'Initialization failure',0
_err_init_message db 'Program requires hardware Direct3D 12 support (D3D_FEATURE_LEVEL_11_1).',0
_err_cpu_caption db 'Not supported CPU',0
_err_cpu_message db 'Your CPU does not support AVX extension, program will not run.',0

_vs_triangle db 'data/vs_triangle.cso',0
_ps_triangle db 'data/ps_triangle.cso',0

align 8
resource_barrier1 D3D12_RESOURCE_BARRIER D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,D3D12_RESOURCE_BARRIER_FLAG_NONE,\
                 <0,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,0,0>
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
swap_buffer dq 0,0,0,0
fence dq 0
fence_value dq 1
fence_event dq 0
root_signature dq 0
d3dblob dq 0
def_heap dq 0
pso dq 0

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
                                    4,0,1,DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL,0
align 8
rtv_heap_desc D3D12_DESCRIPTOR_HEAP_DESC D3D12_DESCRIPTOR_HEAP_TYPE_RTV,4,D3D12_DESCRIPTOR_HEAP_FLAG_NONE,0

align 8
resource_barrier D3D12_RESOURCE_BARRIER D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,D3D12_RESOURCE_BARRIER_FLAG_NONE,\
                 <0,D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,0,0>
align 8
root_signature_desc D3D12_ROOT_SIGNATURE_DESC 0,0,0,0,D3D12_ROOT_SIGNATURE_FLAG_NONE

align 8
pso_desc D3D12_GRAPHICS_PIPELINE_STATE_DESC

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
IID_ID3D12RootSignature GUID 0xc54a6b66,0x72df,0x4ee8,0x8b,0xe5,0xa9,0x46,0xa1,0x42,0x92,0x14
IID_ID3D12PipelineState GUID 0x765a30f3,0xf624,0x4c6f,0xa8,0x28,0xac,0xe9,0x48,0x62,0x24,0x45
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
GetProcessHeap dq rva _GetProcessHeap
HeapAlloc dq rva _HeapAlloc
HeapFree dq rva _HeapFree
CreateFile dq rva _CreateFile
ReadFile dq rva _ReadFile
GetFileSize dq rva _GetFileSize
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
D3D12SerializeRootSignature dq rva _D3D12SerializeRootSignature
dq 0

_kernel32 db 'kernel32.dll',0
_user32 db 'user32.dll',0
_dxgi db 'dxgi.dll',0
_d3d12 db 'd3d12.dll',0

$emit <_ExitProcess dw 0>,<db 'ExitProcess',0>
$emit <_GetModuleHandle dw 0>,<db 'GetModuleHandleA',0>
$emit <_WaitForSingleObject dw 0>,<db 'WaitForSingleObject',0>
$emit <_QueryPerformanceFrequency dw 0>,<db 'QueryPerformanceFrequency',0>
$emit <_QueryPerformanceCounter dw 0>,<db 'QueryPerformanceCounter',0>
$emit <_CloseHandle dw 0>,<db 'CloseHandle',0>
$emit <_CreateEventEx dw 0>,<db 'CreateEventExA',0>
$emit <_GetProcessHeap dw 0>,<db 'GetProcessHeap',0>
$emit <_HeapAlloc dw 0>,<db 'HeapAlloc',0>
$emit <_HeapFree dw 0>,<db 'HeapFree',0>
$emit <_CreateFile dw 0>,<db 'CreateFileA',0>
$emit <_ReadFile dw 0>,<db 'ReadFile',0>
$emit <_GetFileSize dw 0>,<db 'GetFileSize',0>

$emit <_wsprintf dw 0>,<db 'wsprintfA',0>
$emit <_RegisterClassEx dw 0>,<db 'RegisterClassExA',0>
$emit <_CreateWindowEx dw 0>,<db 'CreateWindowExA',0>
$emit <_DefWindowProc dw 0>,<db 'DefWindowProcA',0>
$emit <_PeekMessage dw 0>,<db 'PeekMessageA',0>
$emit <_DispatchMessage dw 0>,<db 'DispatchMessageA',0>
$emit <_LoadCursor dw 0>,<db 'LoadCursorA',0>
$emit <_LoadIcon dw 0>,<db 'LoadIconA',0>
$emit <_SetWindowText dw 0>,<db 'SetWindowTextA',0>
$emit <_AdjustWindowRect dw 0>,<db 'AdjustWindowRect',0>
$emit <_PostQuitMessage dw 0>,<db 'PostQuitMessage',0>
$emit <_MessageBox dw 0>,<db 'MessageBoxA',0>

$emit <_CreateDXGIFactory1 dw 0>,<db 'CreateDXGIFactory1',0>

$emit <_D3D12CreateDevice dw 0>,<db 'D3D12CreateDevice',0>
$emit <_D3D12GetDebugInterface dw 0>,<db 'D3D12GetDebugInterface',0>
$emit <_D3D12SerializeRootSignature dw 0>,< db 'D3D12SerializeRootSignature',0>
;========================================================================