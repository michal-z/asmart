if program_section = 'data'

struc frame_resources {
  .constant_buffer dq 0
  .constant_buffer_ptr dq 0
  .constant_buffer_gpu_ptr dq 0
  .vertex_buffer dq 0
  .vertex_buffer_ptr dq 0
  .vertex_buffer_view D3D12_VERTEX_BUFFER_VIEW }
struc_offsets_size frame_resources

struc scene {
  .pso dq 0
  .rootsig dq 0

  align 8
  rept k_frame_count n:0 \{ .frame_resources\#n frame_resources \}

  align 4
  .eye_half_fovy dd 0.52359876 ; pi / 6
  .eye_nearz dd 1.0
  .eye_farz dd 100.0

  align 16
  .eye_position: dd 1.7,1.7,-1.7,1.0
  .eye_focus: dd 0.0,0.0,0.0,1.0
  .eye_up: dd 0.0,1.0,0.0,0.0
  .tri_v0: dd -0.7,-0.7,0.0,1.0
  .tri_v1: dd 0.0,0.7,0.0,1.0
  .tri_v2: dd 0.7,-0.7,0.0,1.0

  align 1
  .s_position db 'POSITION',0
  .s_vs db 'data/vs_transform.cso',0
  .s_ps db 'data/ps_shade.cso',0 }

  align 8
  scene1 scene

restruc scene,frame_resources

else if program_section = 'code'
;=============================================================================
falign
scene1_init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 8
  .rootsig_desc D3D12_ROOT_SIGNATURE_DESC
  align 8
  .pso_desc D3D12_GRAPHICS_PIPELINE_STATE_DESC
  align 8
  .root_descriptor D3D12_ROOT_PARAMETER
  align 8
  .upload_heap_props D3D12_HEAP_PROPERTIES
  align 8
  .buffer_res_desc D3D12_RESOURCE_DESC
  align 8
  .empty_range D3D12_RANGE
  align 8
  .input_element_desc D3D12_INPUT_ELEMENT_DESC
  align 8
  .d3dblob dq ?
  align 32
  .k_stack_size = $+8
end virtual
                       push   rsi rbx
                        sub   rsp,.k_stack_size
                 zero_stack   .k_stack_size

                        mov   [.upload_heap_props.Type+rsp],D3D12_HEAP_TYPE_UPLOAD
                        mov   [.buffer_res_desc.Dimension+rsp],D3D12_RESOURCE_DIMENSION_BUFFER
                        mov   [.buffer_res_desc.Width+rsp],1024
                        mov   [.buffer_res_desc.Height+rsp],1
                        mov   [.buffer_res_desc.DepthOrArraySize+rsp],1
                        mov   [.buffer_res_desc.MipLevels+rsp],1
                        mov   [.buffer_res_desc.SampleDesc.Count+rsp],1
                        mov   [.buffer_res_desc.Layout+rsp],D3D12_TEXTURE_LAYOUT_ROW_MAJOR


                        mov   esi,k_frame_count
                        lea   rbx,[scene1.frame_resources0]
  .frame_resources_loop:
                            ; constant buffer: create
                        mov   rcx,[demo.device]
                        lea   rdx,[.upload_heap_props+rsp]
                        mov   r8d,D3D12_HEAP_FLAG_NONE
                        lea   r9,[.buffer_res_desc+rsp]
                        mov   dword[rsp+32],D3D12_RESOURCE_STATE_GENERIC_READ
                        mov   qword[rsp+40],0
                        lrm   [rsp+48],[IID_ID3D12Resource]
                        lrm   [rsp+56],[rbx+frame_resources.constant_buffer]
                     hrcall   [ID3D12Device.CreateCommittedResource+rax]
                            ; vertex buffer: create
                        mov   rcx,[demo.device]
                        lea   rdx,[.upload_heap_props+rsp]
                        mov   r8d,D3D12_HEAP_FLAG_NONE
                        lea   r9,[.buffer_res_desc+rsp]
                        mov   dword[rsp+32],D3D12_RESOURCE_STATE_GENERIC_READ
                        mov   qword[rsp+40],0
                        lrm   [rsp+48],[IID_ID3D12Resource]
                        lrm   [rsp+56],[rbx+frame_resources.vertex_buffer]
                     hrcall   [ID3D12Device.CreateCommittedResource+rax]
                            ; constant buffer: map (get CPU address)
                        mov   rcx,[rbx+frame_resources.constant_buffer]
                        xor   edx,edx
                        lea   r8,[.empty_range+rsp]
                        lea   r9,[rbx+frame_resources.constant_buffer_ptr]
                     hrcall   [ID3D12Resource.Map+rax]
                            ; vertex buffer: map (get CPU address)
                        mov   rcx,[rbx+frame_resources.vertex_buffer]
                        xor   edx,edx
                        lea   r8,[.empty_range+rsp]
                        lea   r9,[rbx+frame_resources.vertex_buffer_ptr]
                     hrcall   [ID3D12Resource.Map+rax]
                            ; get constant
                        mov   rcx,[rbx+frame_resources.constant_buffer]
                        mov   rax,[rcx]
                       call   [ID3D12Resource.GetGPUVirtualAddress+rax]
                        mov   [rbx+frame_resources.constant_buffer_gpu_ptr],rax

                        mov   rcx,[rbx+frame_resources.vertex_buffer]
                        mov   rax,[rcx]
                       call   [ID3D12Resource.GetGPUVirtualAddress+rax]
                        mov   [rbx+frame_resources.vertex_buffer_view.BufferLocation],rax
                        mov   [rbx+frame_resources.vertex_buffer_view.SizeInBytes],1024
                        mov   [rbx+frame_resources.vertex_buffer_view.StrideInBytes],16

                        add   rbx,sizeof.frame_resources
                        sub   esi,1
                        jnz   .frame_resources_loop

                            ; create root signature
                        mov   [.root_descriptor.ParameterType+rsp],D3D12_ROOT_PARAMETER_TYPE_CBV
                        mov   [.root_descriptor.Descriptor.ShaderRegister+rsp],0

                        mov   [.rootsig_desc.NumParameters+rsp],1
                        lrm   [.rootsig_desc.pParameters+rsp],[.root_descriptor+rsp]
                        mov   [.rootsig_desc.Flags+rsp],D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT

                        lea   rcx,[.rootsig_desc+rsp]
                        mov   edx,D3D_ROOT_SIGNATURE_VERSION_1
                        lea   r8,[.d3dblob+rsp]
                        xor   r9d,r9d
                       call   [D3D12SerializeRootSignature]

                        mov   rcx,[.d3dblob+rsp]
                        mov   rax,[rcx]
                       call   [ID3DBlob.GetBufferPointer+rax]
                        mov   rsi,rax
                        mov   rcx,[.d3dblob+rsp]
                        mov   rax,[rcx]
                       call   [ID3DBlob.GetBufferSize+rax]

                        mov   rcx,[demo.device]
                        xor   edx,edx
                        mov   r8,rsi
                        mov   r9,rax
                        lrm   [rsp+32],[IID_ID3D12RootSignature]
                        lrm   [rsp+40],[scene1.rootsig]
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateRootSignature+rax]
                        mov   esi,eax
               safe_release   [.d3dblob+rsp]
                       test   esi,esi
                         js   .error


                        lrm   [.input_element_desc.SemanticName+rsp],[scene1.s_position]
                        mov   [.input_element_desc.SemanticIndex+rsp],0
                        mov   [.input_element_desc.Format+rsp],DXGI_FORMAT_R32G32B32A32_FLOAT
                        mov   [.input_element_desc.InputSlot+rsp],0
                        mov   [.input_element_desc.AlignedByteOffset+rsp],0
                            ; load VS
                        lea   rcx,[scene1.s_vs]
                       call   load_file
                        mov   [.pso_desc.VS.pShaderBytecode+rsp],rax
                        mov   [.pso_desc.VS.BytecodeLength+rsp],rdx
                            ; load PS
                        lea   rcx,[scene1.s_ps]
                       call   load_file
                        mov   [.pso_desc.PS.pShaderBytecode+rsp],rax
                        mov   [.pso_desc.PS.BytecodeLength+rsp],rdx
                            ; PSO
                        mrm   [.pso_desc.pRootSignature+rsp],[scene1.rootsig]
                        lrm   [.pso_desc.InputLayout.pInputElementDescs+rsp],[.input_element_desc+rsp]
                        mov   [.pso_desc.InputLayout.NumElements+rsp],1
                        mov   [.pso_desc.BlendState.RenderTarget0.RenderTargetWriteMask+rsp],$0f
                        mov   [.pso_desc.SampleMask+rsp],$ffffffff
                        mov   [.pso_desc.RasterizerState.CullMode+rsp],D3D12_CULL_MODE_NONE
                        mov   [.pso_desc.RasterizerState.FillMode+rsp],D3D12_FILL_MODE_SOLID
                        mov   [.pso_desc.PrimitiveTopologyType+rsp],D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE
                        mov   [.pso_desc.NumRenderTargets+rsp],1
                        mov   [.pso_desc.RTVFormats+rsp],DXGI_FORMAT_R8G8B8A8_UNORM
                        mov   [.pso_desc.SampleDesc.Count+rsp],1

                        mov   rcx,[demo.device]
                        lea   rdx,[.pso_desc+rsp]
                        lea   r8,[IID_ID3D12PipelineState]
                        lea   r9,[scene1.pso]
                        mov   rax,[rcx]
                       call   [ID3D12Device.CreateGraphicsPipelineState+rax]    ; create pso
                        mov   esi,eax
                       free   [.pso_desc.VS.pShaderBytecode+rsp]
                       free   [.pso_desc.PS.pShaderBytecode+rsp]
                       test   esi,esi
                         js   .error

                        mov   eax,1
                        add   rsp,.k_stack_size
                        pop   rbx rsi
                        ret
  .error:               xor   eax,eax
                        add   rsp,.k_stack_size
                        pop   rbx rsi
                        ret
;=============================================================================
falign
scene1_deinit:
;-----------------------------------------------------------------------------
                        ret
;=============================================================================
falign
scene1_update:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .barrier D3D12_RESOURCE_BARRIER
  align 8
  .back_buffer_handle dq ?
  align 32
  .mat: rd 16
  align 32
  .k_stack_size = $
end virtual
                       push   rsi rdi r12
                        sub   rsp,.k_stack_size
                        mov   r12d,[demo.frame_index]
                       imul   r12d,sizeof.frame_resources
                        lea   r12,[r12+scene1.frame_resources0]

                            ; update rotation matrix
                     vmovss   xmm0,[scene1.eye_half_fovy]
                       call   sincosf
                     vmovss   xmm2,[demo.viewport.Width]
                     vdivss   xmm2,xmm2,[demo.viewport.Height]
                     vmovss   xmm3,[scene1.eye_nearz]
                     vmovss   xmm4,[scene1.eye_farz]
        mat_perspective_fov
                    vmovaps   [.mat+rsp],ymm0
                    vmovaps   [.mat+rsp+32],ymm1

                    vmovaps   xmm0,[scene1.eye_position]
                    vmovaps   xmm1,[scene1.eye_focus]
                    vmovaps   xmm2,[scene1.eye_up]
                       call   mat_look_at

                    vmovaps   ymm2,[.mat+rsp]
                    vmovaps   ymm3,[.mat+32+rsp]
                       call   mat_mul           ; lookat*perspective
                    vmovaps   [.mat+rsp],ymm0
                    vmovaps   [.mat+32+rsp],ymm1

                  vcvtsd2ss   xmm0,xmm0,[time]
                       call   sincosf
             mat_rotation_x
                    vmovaps   ymm2,[.mat+rsp]
                    vmovaps   ymm3,[.mat+32+rsp]
                       call   mat_mul_transpose ; transpose(rotation*lookat*perspective)

                        mov   rcx,[r12+frame_resources.constant_buffer_ptr]
                    vmovaps   [rcx],ymm0
                    vmovaps   [rcx+32],ymm1

                            ; update vertex buffer
                        mov   rcx,[r12+frame_resources.vertex_buffer_ptr]
                    vmovaps   xmm0,[scene1.tri_v0]
                    vmovaps   [rcx],xmm0
                    vmovaps   xmm0,[scene1.tri_v1]
                    vmovaps   [rcx+16],xmm0
                    vmovaps   xmm0,[scene1.tri_v2]
                    vmovaps   [rcx+32],xmm0
                            ; init transition barrier
                        mov   [.barrier.Type+rsp],D3D12_RESOURCE_BARRIER_TYPE_TRANSITION
                        mov   [.barrier.Flags+rsp],0
                        mov   [.barrier.Transition.Subresource+rsp],D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES
                            ; init command list pointers
                        mov   rsi,[demo.cmdlist]
                        mov   rdi,[rsi]
                            ; reset completed command allocator
                        mov   eax,[demo.frame_index]
                        mov   rcx,[demo.cmdalloc+rax*8]
                        mov   rax,[rcx]
                       call   [ID3D12CommandAllocator.Reset+rax]
                            ; begin commands recording
                        mov   eax,[demo.frame_index]
                        mov   rcx,rsi
                        mov   rdx,[demo.cmdalloc+rax*8]
                        mov   r8,[scene1.pso]
                       call   [ID3D12GraphicsCommandList.Reset+rdi]
                        mov   rcx,rsi
                        mov   edx,1
                        lea   r8,[demo.viewport]
                       call   [ID3D12GraphicsCommandList.RSSetViewports+rdi]
                        mov   rcx,rsi
                        mov   edx,1
                        lea   r8,[demo.scissor]
                       call   [ID3D12GraphicsCommandList.RSSetScissorRects+rdi]
                            ; set root signature and resources
                        mov   rcx,rsi
                        mov   rdx,[scene1.rootsig]
                       call   [ID3D12GraphicsCommandList.SetGraphicsRootSignature+rdi]

                        mov   rcx,rsi
                        xor   edx,edx
                        mov   r8,[r12+frame_resources.constant_buffer_gpu_ptr]
                       call   [ID3D12GraphicsCommandList.SetGraphicsRootConstantBufferView+rdi]
                            ; vertex buffer view
                        mov   rcx,rsi
                        xor   edx,edx
                        mov   r8d,1
                        lea   r9,[r12+frame_resources.vertex_buffer_view]
                       call   [ID3D12GraphicsCommandList.IASetVertexBuffers+rdi]
                            ; back buffer to D3D12_RESOURCE_STATE_RENDER_TARGET
                        mov   eax,[demo.back_buffer_index]
                        mov   rax,[demo.swapchain_buffer+rax*8]
         transition_barrier   .barrier+rsp,rax,D3D12_RESOURCE_STATE_PRESENT,D3D12_RESOURCE_STATE_RENDER_TARGET
                        mov   rcx,rsi
                        mov   edx,1
                        lea   r8,[.barrier+rsp]
                       call   [ID3D12GraphicsCommandList.ResourceBarrier+rdi]
                            ; get back buffer handle
                        mov   eax,[demo.back_buffer_index]
                       imul   eax,[demo.rtv_size]
                        add   rax,[demo.swapchain_heap_start]
                        mov   [.back_buffer_handle+rsp],rax
                            ; clear back buffer
                        mov   rcx,rsi
                        mov   rdx,[.back_buffer_handle+rsp]
                        lea   r8,[demo.clear_color]
                        xor   r9d,r9d
                        mov   qword[rsp+32],0
                       call   [ID3D12GraphicsCommandList.ClearRenderTargetView+rdi]
                            ; set back buffer as render target
                        mov   rcx,rsi
                        mov   edx,1
                        lea   r8,[.back_buffer_handle+rsp]
                        mov   r9d,1
                        mov   qword[rsp+32],0
                       call   [ID3D12GraphicsCommandList.OMSetRenderTargets+rdi]
                            ; draw
                        mov   rcx,rsi
                        mov   edx,D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST
                       call   [ID3D12GraphicsCommandList.IASetPrimitiveTopology+rdi]
                        mov   rcx,rsi
                        mov   edx,3
                        mov   r8d,1
                        xor   r9d,r9d
                        mov   dword[rsp+32],0
                       call   [ID3D12GraphicsCommandList.DrawInstanced+rdi]
                            ; back buffer to D3D12_RESOURCE_STATE_PRESENT
                        mov   eax,[demo.back_buffer_index]
                        mov   rax,[demo.swapchain_buffer+rax*8]
         transition_barrier   .barrier+rsp,rax,D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_PRESENT
                        mov   rcx,rsi
                        mov   edx,1
                        lea   r8,[.barrier+rsp]
                       call   [ID3D12GraphicsCommandList.ResourceBarrier+rdi]
                            ; finish recording and execute commands
                        mov   rcx,rsi
                       call   [ID3D12GraphicsCommandList.Close+rdi]
                        mov   rcx,[demo.cmdqueue]
                        mov   edx,1
                        lea   r8,[demo.cmdlist]
                        mov   rax,[rcx]
                       call   [ID3D12CommandQueue.ExecuteCommandLists+rax]
                        add   rsp,.k_stack_size
                        pop   r12 rdi rsi
                        ret
;=============================================================================
end if ; if program_section = 'data'
