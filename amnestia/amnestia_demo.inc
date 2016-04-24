if program_section = 'code'
;=============================================================================
FALIGN
demo_init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 7
  .dbgi dq ?
  align 8
  .cmdqueue_desc D3D12_COMMAND_QUEUE_DESC
  align 8
  .swapchain_desc DXGI_SWAP_CHAIN_DESC
  align 8
  .swapchain_heap_desc D3D12_DESCRIPTOR_HEAP_DESC
  align 32
  .k_stack_size = $+16
end virtual
                       push   rsi
                        sub   rsp,.k_stack_size
                 ZERO_STACK   .k_stack_size
  ; debug layer
                        lea   rcx,[IID_ID3D12Debug]
                        lea   rdx,[.dbgi+rsp]
                       call   [D3D12GetDebugInterface]
                       test   eax,eax
                         js   @f
                        mov   rcx,[.dbgi+rsp]
                        mov   rax,[rcx]
                       call   [ID3D12Debug.EnableDebugLayer+rax]
               SAFE_RELEASE   [.dbgi+rsp]
  ; DXGI factory
  @@:                   lea   rcx,[IID_IDXGIFactory4]
                        lea   rdx,[dxgifactory]
                       call   [CreateDXGIFactory1]
                       test   eax,eax
                         js   .error
  ; device
                        xor   ecx,ecx
                        mov   edx,D3D_FEATURE_LEVEL_11_0
                        lea   r8,[IID_ID3D12Device]
                        lea   r9,[device]
                       call   [D3D12CreateDevice]
                       test   eax,eax
                         js   .error
  ; command queue
                        mov   [.cmdqueue_desc.Type+rsp],D3D12_COMMAND_LIST_TYPE_DIRECT
                        mov   rcx,[device]
                        lea   rdx,[.cmdqueue_desc+rsp]
                        lea   r8,[IID_ID3D12CommandQueue]
                        lea   r9,[cmdqueue]
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateCommandQueue+rax]
                       test   eax,eax
                         js   .error
  ; command allocators
                        xor   esi,esi
  @@:                   mov   rcx,[device]
                        mov   edx,D3D12_COMMAND_LIST_TYPE_DIRECT
                        lea   r8,[IID_ID3D12CommandAllocator]
                        lea   r9,[cmdallocator+rsi*8]
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateCommandAllocator+rax]
                       test   eax,eax
                         js   .error
                        add   esi,1
                        cmp   esi,k_frame_count
                         jb   @b
  ; swapchain
                        mov   eax,[win_width]
                        mov   [.swapchain_desc.BufferDesc.Width+rsp],eax
                        mov   eax,[win_height]
                        mov   [.swapchain_desc.BufferDesc.Height+rsp],eax
                        mov   [.swapchain_desc.BufferDesc.Format+rsp],DXGI_FORMAT_R8G8B8A8_UNORM
                        mov   [.swapchain_desc.SampleDesc.Count+rsp],1
                        mov   [.swapchain_desc.BufferCount+rsp],k_swapchain_buffer_count
                        mov   rax,[win_handle]
                        mov   [.swapchain_desc.OutputWindow+rsp],rax
                        mov   [.swapchain_desc.Windowed+rsp],1
                        mov   [.swapchain_desc.SwapEffect+rsp],DXGI_SWAP_EFFECT_FLIP_DISCARD
                        mov   rcx,[dxgifactory]
                        mov   rdx,[cmdqueue]
                        lea   r8,[.swapchain_desc+rsp]
                        lea   r9,[swapchain]
                        mov   rax,[rcx]
                       call   [IDXGIFactory4.CreateSwapChain+rax]
                       test   eax,eax
                         js   .error
  ; viewport & scissor
                        mov   [viewport.TopLeftX],dword 0.0
                        mov   [viewport.TopLeftY],dword 0.0
                     vxorps   xmm2,xmm2,xmm2
                  vcvtsi2ss   xmm0,xmm2,[win_width]
                  vcvtsi2ss   xmm1,xmm2,[win_height]
                      vmovd   [viewport.Width],xmm0
                      vmovd   [viewport.Height],xmm1
                        mov   [viewport.MinDepth],dword 0.0
                        mov   [viewport.MaxDepth],dword 1.0
                        mov   [scissor.left],0
                        mov   [scissor.top],0
                        mov   eax,[win_width]
                        mov   [scissor.right],eax
                        mov   eax,[win_height]
                        mov   [scissor.bottom],eax
  ; get descriptor sizes
                        mov   rcx,[device]
                        mov   edx,D3D12_DESCRIPTOR_HEAP_TYPE_RTV
                        mov   rax,[rcx]
                       call   [ID3D12Device.GetDescriptorHandleIncrementSize+rax]
                        mov   [rtv_size],eax
                        mov   rcx,[device]
                        mov   edx,D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV
                        mov   rax,[rcx]
                       call   [ID3D12Device.GetDescriptorHandleIncrementSize+rax]
                        mov   [cbv_srv_uav_size],eax
  ; swapchain descriptor heap
                        mov   [.swapchain_heap_desc.Type+rsp],D3D12_DESCRIPTOR_HEAP_TYPE_RTV
                        mov   [.swapchain_heap_desc.NumDescriptors+rsp],k_swapchain_buffer_count
                        mov   rcx,[device]
                        lea   rdx,[.swapchain_heap_desc+rsp]
                        lea   r8,[IID_ID3D12DescriptorHeap]
                        lea   r9,[swapchain_heap]
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateDescriptorHeap+rax]
                       test   eax,eax
                         js   .error
                        mov   rcx,[swapchain_heap]
                        lea   rdx,[swapchain_heap_start]
                        mov   rax,[rcx]
                       call   [ID3D12DescriptorHeap.GetCPUDescriptorHandleForHeapStart+rax]
                        mov   rax,[rax]
                        mov   [swapchain_heap_start],rax
  ; swapchain buffer descriptors
                        xor   esi,esi
  .for_each_swap_buffer:
                        mov   rcx,[swapchain]
                        mov   edx,esi
                        lea   r8,[IID_ID3D12Resource]
                        lea   r9,[swapchain_buffer+rsi*8]
                        mov   rax,[rcx]
                       call   [IDXGISwapChain3.GetBuffer+rax]
                       test   eax,eax
                         js   .error
                        mov   rcx,[device]
                        mov   rdx,[swapchain_buffer+rsi*8]
                        xor   r8d,r8d
                        mov   r9d,esi
                       imul   r9d,[rtv_size]
                        add   r9,[swapchain_heap_start]
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateRenderTargetView+rax]
                        add   esi,1
                        cmp   esi,k_swapchain_buffer_count
                         jb   .for_each_swap_buffer
  ; frame fence
                        mov   rcx,[device]
                        mov   edx,1
                        mov   r8d,D3D12_FENCE_FLAG_NONE
                        lea   r9,[IID_ID3D12Fence]
                        lea   rax,[frame_fence]
                        mov   [k_funcparam5+rsp],rax
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateFence+rax]
                       test   eax,eax
                         js   .error
  ; frame fence event
                        xor   ecx,ecx
                        xor   edx,edx
                        xor   r8d,r8d
                        mov   r9d,EVENT_ALL_ACCESS
                       call   [CreateEventEx]
                        mov   [frame_fence_event],rax
                       test   rax,rax
                         jz   .error
  ; create command list
                        mov   rcx,[device]
                        xor   edx,edx
                        mov   r8d,D3D12_COMMAND_LIST_TYPE_DIRECT
                        mov   r9,[cmdallocator]
                        mov   qword[k_funcparam5+rsp],0
                        lea   rax,[IID_ID3D12GraphicsCommandList]
                        mov   [k_funcparam6+rsp],rax
                        lea   rax,[cmdlist]
                        mov   [k_funcparam7+rsp],rax
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateCommandList+rax]
                       test   eax,eax
                         js   .error
  ; init scene
                        lea   rax,[scene1_init]
                        mov   [scene_init],rax
                        lea   rax,[scene1_deinit]
                        mov   [scene_deinit],rax
                        lea   rax,[scene1_update]
                        mov   [scene_update],rax
                       call   [scene_init]
                       test   eax,eax
                         jz   .error
  ; close command list
                        mov   rcx,[cmdlist]
                        mov   rax,[rcx]
                       call   [ID3D12GraphicsCommandList.Close+rax]
                       test   eax,eax
                         js   .error
  ; execute command list
                        mov   rcx,[cmdqueue]
                        mov   edx,1
                        lea   r8,[cmdlist]
                        mov   rax,[rcx]
                       call   [ID3D12CommandQueue.ExecuteCommandLists+rax]
                       test   eax,eax
                         js   .error
  ; wait for the GPU
                        mov   rcx,[cmdqueue]
                        mov   rdx,[frame_fence]
                        xor   r8d,r8d
                        mov   rax,[rcx]
                       call   [ID3D12CommandQueue.Signal+rax]
                        mov   rcx,[frame_fence]
                        xor   edx,edx
                        mov   r8,[frame_fence_event]
                        mov   rax,[rcx]
                       call   [ID3D12Fence.SetEventOnCompletion+rax]
                        mov   rcx,[frame_fence_event]
                        mov   edx,INFINITE
                       call   [WaitForSingleObject]
  ; audio
                       call   audio_play
                       test   eax,eax
                         jz   .error
  ; success
                        mov   eax,1
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
  .error:
                        xor   eax,eax
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
;=============================================================================
FALIGN
demo_deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub   rsp,.k_stack_size
                        mov   rcx,[scene_deinit]
                       test   rcx,rcx
                         jz   @f
                       call   rcx
  @@:                  call   audio_stop
                        add   rsp,.k_stack_size
                        ret
;=============================================================================
FALIGN
demo_update:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+16
                       push   rsi
                        sub   rsp,.k_stack_size
                       call   [scene_update]
  ; present
                        mov   rcx,[swapchain]
                        xor   edx,edx
                        xor   r8d,r8d
                        mov   rax,[rcx]
                       call   [IDXGISwapChain3.Present+rax]
                        add   [cpu_completed_frames],1
                        mov   rcx,[cmdqueue]
                        mov   rdx,[frame_fence]
                        mov   r8,[cpu_completed_frames]
                        mov   rax,[rcx]
                       call   [ID3D12CommandQueue.Signal+rax]
                        mov   rcx,[frame_fence]
                        mov   rax,[rcx]
                       call   [ID3D12Fence.GetCompletedValue+rax]
                        mov   rsi,rax
                        mov   rax,[cpu_completed_frames]
                        sub   rax,rsi
                        cmp   eax,k_frame_count
                         jb   @f
  ; wait for the GPU to finish one frame
                        mov   rcx,[frame_fence]
                        mov   rdx,rsi
                        add   rdx,1
                        mov   r8,[frame_fence_event]
                        mov   rax,[rcx]
                       call   [ID3D12Fence.SetEventOnCompletion+rax]
                        mov   rcx,[frame_fence_event]
                        mov   edx,INFINITE
                       call   [WaitForSingleObject]
  ; update back_buffer_index and frame_index
  @@:                   mov   rcx,[swapchain]
                        mov   rax,[rcx]
                       call   [IDXGISwapChain3.GetCurrentBackBufferIndex+rax]
                        mov   [back_buffer_index],eax
                        xor   edx,edx
                        mov   rax,[cpu_completed_frames]
                        mov   ecx,k_frame_count
                        div   rcx
                        mov   [frame_index],edx
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
;=============================================================================
else if program_section = 'data'

align 8
  dxgifactory dq 0
  device dq 0
  cmdqueue dq 0
  cmdallocator dq k_frame_count dup 0
  cmdlist dq 0
  swapchain dq 0
  swapchain_heap dq 0
  swapchain_heap_start dq 0
  swapchain_buffer dq k_swapchain_buffer_count dup 0
  frame_fence dq 0
  frame_fence_event dq 0
  cpu_completed_frames dq 0

  scene_init dq 0
  scene_deinit dq 0
  scene_update dq 0

align 8
  viewport D3D12_VIEWPORT
align 8
  scissor D3D12_RECT

align 4
  rtv_size dd 0
  cbv_srv_uav_size dd 0
  back_buffer_index dd 0
  frame_index dd 0
  clear_color dd 0.0,0.2,0.4,1.0

end if
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
