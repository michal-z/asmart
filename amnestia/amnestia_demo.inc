if program_section = 'data'

align 8
demo:
  .dxgifactory dq 0
  .device dq 0
  .cmdqueue dq 0
  .cmdalloc dq k_frame_count dup 0
  .cmdlist dq 0
  .swapchain dq 0
  .swapchain_heap dq 0
  .swapchain_heap_start dq 0
  .swapchain_buffer dq k_swapchain_buffer_count dup 0
  .frame_fence dq 0
  .frame_fence_event dq 0
  .cpu_completed_frames dq 0

  .scene_init dq 0
  .scene_deinit dq 0
  .scene_update dq 0

  align 8
  .viewport D3D12_VIEWPORT
  align 8
  .scissor D3D12_RECT

  align 4
  .rtv_size dd 0
  .cbv_srv_uav_size dd 0
  .back_buffer_index dd 0
  .frame_index dd 0
  .clear_color dd 0.0,0.2,0.4,1.0

else if program_section = 'code'
;=============================================================================
falign
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
                 zero_stack   .k_stack_size

                            ; debug layer
                        lea   rcx,[IID_ID3D12Debug]
                        lea   rdx,[.dbgi+rsp]
                      icall   D3D12GetDebugInterface
                    checkhr   eax,@f
                        mov   rcx,[.dbgi+rsp]
                    comcall   ID3D12Debug.EnableDebugLayer
               safe_release   [.dbgi+rsp]

                            ; DXGI factory
  @@:                   lea   rcx,[IID_IDXGIFactory4]
                        lea   rdx,[demo.dxgifactory]
                      icall   CreateDXGIFactory1
                    checkhr   eax,.error

                            ; device
                        xor   ecx,ecx
                        mov   edx,D3D_FEATURE_LEVEL_11_1
                        lea   r8,[IID_ID3D12Device]
                        lea   r9,[demo.device]
                      icall   D3D12CreateDevice
                    checkhr   eax,.error

                            ; command queue
                        mov   [.cmdqueue_desc.Type+rsp],D3D12_COMMAND_LIST_TYPE_DIRECT
                        mov   rcx,[demo.device]
                        lea   rdx,[.cmdqueue_desc+rsp]
                        lea   r8,[IID_ID3D12CommandQueue]
                        lea   r9,[demo.cmdqueue]
                    comcall   ID3D12Device.CreateCommandQueue
                    checkhr   eax,.error

                            ; command allocators
                        xor   esi,esi
  @@:                   mov   rcx,[demo.device]
                        mov   edx,D3D12_COMMAND_LIST_TYPE_DIRECT
                        lea   r8,[IID_ID3D12CommandAllocator]
                        lea   r9,[demo.cmdalloc+rsi*8]
                    comcall   ID3D12Device.CreateCommandAllocator
                    checkhr   eax,.error
                        add   esi,1
                        cmp   esi,k_frame_count
                         jb   @b

                            ; swapchain
                       mov3   [.swapchain_desc.BufferDesc.Width+rsp],eax,[win_width]
                       mov3   [.swapchain_desc.BufferDesc.Height+rsp],eax,[win_height]
                        mov   [.swapchain_desc.BufferDesc.Format+rsp],DXGI_FORMAT_R8G8B8A8_UNORM
                        mov   [.swapchain_desc.SampleDesc.Count+rsp],1
                        mov   [.swapchain_desc.BufferCount+rsp],k_swapchain_buffer_count
                       mov3   [.swapchain_desc.OutputWindow+rsp],rax,[win_handle]
                        mov   [.swapchain_desc.Windowed+rsp],1
                        mov   [.swapchain_desc.SwapEffect+rsp],DXGI_SWAP_EFFECT_FLIP_DISCARD
                        mov   rcx,[demo.dxgifactory]
                        mov   rdx,[demo.cmdqueue]
                        lea   r8,[.swapchain_desc+rsp]
                        lea   r9,[demo.swapchain]
                    comcall   IDXGIFactory4.CreateSwapChain

                            ; viewport & scissor
                     vxorps   xmm2,xmm2,xmm2
                  vcvtsi2ss   xmm0,xmm2,[win_width]
                  vcvtsi2ss   xmm1,xmm2,[win_height]
                        mov   [demo.viewport.TopLeftX],dword 0.0
                        mov   [demo.viewport.TopLeftY],dword 0.0
                      vmovd   [demo.viewport.Width],xmm0
                      vmovd   [demo.viewport.Height],xmm1
                        mov   [demo.viewport.MinDepth],dword 0.0
                        mov   [demo.viewport.MaxDepth],dword 1.0
                        mov   [demo.scissor.left],0
                        mov   [demo.scissor.top],0
                       mov3   [demo.scissor.right],eax,[win_width]
                       mov3   [demo.scissor.bottom],eax,[win_height]

                            ; get descriptor sizes
                        mov   rcx,[demo.device]
                        mov   edx,D3D12_DESCRIPTOR_HEAP_TYPE_RTV
                    comcall   ID3D12Device.GetDescriptorHandleIncrementSize
                        mov   [demo.rtv_size],eax

                        mov   rcx,[demo.device]
                        mov   edx,D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV
                    comcall   ID3D12Device.GetDescriptorHandleIncrementSize
                        mov   [demo.cbv_srv_uav_size],eax

                            ; swapchain descriptor heap
                        mov   [.swapchain_heap_desc.Type+rsp],D3D12_DESCRIPTOR_HEAP_TYPE_RTV
                        mov   [.swapchain_heap_desc.NumDescriptors+rsp],k_swapchain_buffer_count
                        mov   rcx,[demo.device]
                        lea   rdx,[.swapchain_heap_desc+rsp]
                        lea   r8,[IID_ID3D12DescriptorHeap]
                        lea   r9,[demo.swapchain_heap]
                    comcall   ID3D12Device.CreateDescriptorHeap
                    checkhr   eax,.error

                        mov   rcx,[demo.swapchain_heap]
                        lea   rdx,[demo.swapchain_heap_start]
                    comcall   ID3D12DescriptorHeap.GetCPUDescriptorHandleForHeapStart
                        mov   rax,[rax]
                        mov   [demo.swapchain_heap_start],rax

                            ; swapchain buffer descriptors
                        xor   esi,esi
  .for_each_swap_buffer:
                        mov   rcx,[demo.swapchain]
                        mov   edx,esi
                        lea   r8,[IID_ID3D12Resource]
                        lea   r9,[demo.swapchain_buffer+rsi*8]
                    comcall   IDXGISwapChain3.GetBuffer
                    checkhr   eax,.error

                        mov   rcx,[demo.device]
                        mov   rdx,[demo.swapchain_buffer+rsi*8]
                        xor   r8d,r8d
                        mov   r9d,esi
                       imul   r9d,[demo.rtv_size]
                        add   r9,[demo.swapchain_heap_start]
                    comcall   ID3D12Device.CreateRenderTargetView

                        add   esi,1
                        cmp   esi,k_swapchain_buffer_count
                         jb   .for_each_swap_buffer

                            ; frame fence
                        mov   rcx,[demo.device]
                        mov   edx,1
                        mov   r8d,D3D12_FENCE_FLAG_NONE
                        lea   r9,[IID_ID3D12Fence]
                       lea3   [rsp+32],rax,[demo.frame_fence]
                    comcall   ID3D12Device.CreateFence
                    checkhr   eax,.error

                            ; frame fence event
                        xor   ecx,ecx
                        xor   edx,edx
                        xor   r8d,r8d
                        mov   r9d,EVENT_ALL_ACCESS
                      icall   CreateEventEx
                        mov   [demo.frame_fence_event],rax
                       test   rax,rax
                         jz   .error

                            ; create command list
                        mov   rcx,[demo.device]
                        xor   edx,edx
                        mov   r8d,D3D12_COMMAND_LIST_TYPE_DIRECT
                        mov   r9,[demo.cmdalloc]
                        mov   qword[rsp+32],0
                       lea3   [rsp+40],rax,[IID_ID3D12GraphicsCommandList]
                       lea3   [rsp+48],rax,[demo.cmdlist]
                    comcall   ID3D12Device.CreateCommandList
                    checkhr   eax,.error

                            ; init scene
                       lea3   [demo.scene_init],rax,[scene1_init]
                       lea3   [demo.scene_deinit],rax,[scene1_deinit]
                       lea3   [demo.scene_update],rax,[scene1_update]
                      icall   demo.scene_init
                       test   eax,eax
                         jz   .error

                            ;  close & execute command list
                        mov   rcx,[demo.cmdlist]
                    comcall   ID3D12GraphicsCommandList.Close
                    checkhr   eax,.error
                        mov   rcx,[demo.cmdqueue]
                        mov   edx,1
                        lea   r8,[demo.cmdlist]
                    comcall   ID3D12CommandQueue.ExecuteCommandLists

                            ; wait for the GPU
                        mov   rcx,[demo.cmdqueue]
                        mov   rdx,[demo.frame_fence]
                        xor   r8d,r8d
                    comcall   ID3D12CommandQueue.Signal
                    checkhr   eax,.error

                        mov   rcx,[demo.frame_fence]
                        xor   edx,edx
                        mov   r8,[demo.frame_fence_event]
                    comcall   ID3D12Fence.SetEventOnCompletion
                    checkhr   eax,.error

                        mov   rcx,[demo.frame_fence_event]
                        mov   edx,INFINITE
                      icall   WaitForSingleObject

                            ; audio
                       call   audio_play
                       test   eax,eax
                         jz   .error
                        mov   eax,1
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
  .error:               xor   eax,eax
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
;=============================================================================
falign
demo_deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub   rsp,.k_stack_size
                        mov   rcx,[demo.scene_deinit]
                       test   rcx,rcx
                         jz   @f
                       call   rcx
  @@:                  call   audio_stop
                        add   rsp,.k_stack_size
                        ret
;=============================================================================
falign
demo_update:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+16
                       push   rsi
                        sub   rsp,.k_stack_size
                      icall   demo.scene_update
                       test   eax,eax
                         jz   .error

                            ; present
                        mov   rcx,[demo.swapchain]
                        xor   edx,edx
                        xor   r8d,r8d
                    comcall   IDXGISwapChain3.Present

                        add   [demo.cpu_completed_frames],1
                        mov   rcx,[demo.cmdqueue]
                        mov   rdx,[demo.frame_fence]
                        mov   r8,[demo.cpu_completed_frames]
                    comcall   ID3D12CommandQueue.Signal

                        mov   rcx,[demo.frame_fence]
                    comcall   ID3D12Fence.GetCompletedValue
                        mov   rsi,rax
                        mov   rax,[demo.cpu_completed_frames]
                        sub   rax,rsi
                        cmp   eax,k_frame_count
                         jb   @f

                            ; wait for the GPU to finish one frame
                        mov   rcx,[demo.frame_fence]
                        mov   rdx,rsi
                        add   rdx,1
                        mov   r8,[demo.frame_fence_event]
                    comcall   ID3D12Fence.SetEventOnCompletion
                        mov   rcx,[demo.frame_fence_event]
                        mov   edx,INFINITE
                      icall   WaitForSingleObject

                            ; update back_buffer_index and frame_index
  @@:                   mov   rcx,[demo.swapchain]
                    comcall   IDXGISwapChain3.GetCurrentBackBufferIndex
                        mov   [demo.back_buffer_index],eax

                        xor   edx,edx
                        mov   rax,[demo.cpu_completed_frames]
                        mov   ecx,k_frame_count
                        div   rcx
                        mov   [demo.frame_index],edx
                            ; success
                        mov   eax,1
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
  .error:               xor   eax,eax
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
;=============================================================================
end if ; if program_section = 'data'
