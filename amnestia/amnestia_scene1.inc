struc scene1 {
  .pso dq 0
  .rootsig dq 0
align 1
  .vs db 'data/vs_triangle.cso',0
  .ps db 'data/ps_triangle.cso',0 }

if program_section = 'code'
;=============================================================================
FALIGN
scene1_init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 6
  .rootsig_desc D3D12_ROOT_SIGNATURE_DESC
  align 8
  .pso_desc D3D12_GRAPHICS_PIPELINE_STATE_DESC
  align 8
  .d3dblob dq ?
  align 32
  .k_stack_size = $+16
end virtual
        push rsi
        sub rsp,.k_stack_size
        ZERO_STACK .k_stack_size
  ; root signature
        lea rcx,[.rootsig_desc+rsp]
        mov edx,D3D_ROOT_SIGNATURE_VERSION_1
        lea r8,[.d3dblob+rsp]
        xor r9d,r9d
        call [D3D12SerializeRootSignature]
        mov rcx,[.d3dblob+rsp]
        mov rax,[rcx]
        call [ID3DBlob.GetBufferPointer+rax]
        mov rsi,rax
        mov rcx,[.d3dblob+rsp]
        mov rax,[rcx]
        call [ID3DBlob.GetBufferSize+rax]
        mov rcx,[device]
        xor edx,edx
        mov r8,rsi
        mov r9,rax
        lea rax,[IID_ID3D12RootSignature]
        mov [k_funcparam5+rsp],rax
        lea rax,[scene1.rootsig]
        mov [k_funcparam6+rsp],rax
        mov rax,[rcx]
        call [ID3D12Device.CreateRootSignature+rax]
        mov esi,eax
        SAFE_RELEASE [.d3dblob+rsp]
        test esi,esi
        js .error
  ; pso
        mov rax,[scene1.rootsig]
        mov [.pso_desc.pRootSignature+rsp],rax
        lea rcx,[scene1.vs]
        call load_file
        mov [.pso_desc.VS.pShaderBytecode+rsp],rax
        mov [.pso_desc.VS.BytecodeLength+rsp],rdx
        lea rcx,[scene1.ps]
        call load_file
        mov [.pso_desc.PS.pShaderBytecode+rsp],rax
        mov [.pso_desc.PS.BytecodeLength+rsp],rdx
        mov [.pso_desc.BlendState.RenderTarget0.RenderTargetWriteMask+rsp],$0f
        mov [.pso_desc.SampleMask+rsp],$ffffffff
        mov [.pso_desc.RasterizerState.CullMode+rsp],D3D12_CULL_MODE_NONE
        mov [.pso_desc.RasterizerState.FillMode+rsp],D3D12_FILL_MODE_SOLID
        mov [.pso_desc.PrimitiveTopologyType+rsp],D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE
        mov [.pso_desc.NumRenderTargets+rsp],1
        mov [.pso_desc.RTVFormats+rsp],DXGI_FORMAT_R8G8B8A8_UNORM
        mov [.pso_desc.SampleDesc.Count+rsp],1
        mov rcx,[device]
        lea rdx,[.pso_desc+rsp]
        lea r8,[IID_ID3D12PipelineState]
        lea r9,[scene1.pso]
        mov rax,[rcx]
        call [ID3D12Device.CreateGraphicsPipelineState+rax]
        test eax,eax
        js .error
  ; success
        mov eax,1
        add rsp,.k_stack_size
        pop rsi
        ret
  .error:
        xor eax,eax
        add rsp,.k_stack_size
        pop rsi
        ret
;=============================================================================
FALIGN
scene1_deinit:
;-----------------------------------------------------------------------------
        ret
;=============================================================================
FALIGN
scene1_update:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .barrier D3D12_RESOURCE_BARRIER
  align 8
  .back_buffer_handle dq ?
  align 32
  .k_stack_size = $+8
end virtual
        push rsi rdi
        sub rsp,.k_stack_size
  ; init transition barrier
        mov [.barrier.Type+rsp],D3D12_RESOURCE_BARRIER_TYPE_TRANSITION
        mov [.barrier.Flags+rsp],0
        mov [.barrier.Transition.Subresource+rsp],D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES
  ; init command list pointers
        mov rsi,[cmdlist]
        mov rdi,[rsi]
  ; reset completed command allocator
        mov eax,[frame_index]
        mov rcx,[cmdallocator+rax*8]
        mov rax,[rcx]
        call [ID3D12CommandAllocator.Reset+rax]
  ; begin commands recording
        mov eax,[frame_index]
        mov rcx,rsi
        mov rdx,[cmdallocator+rax*8]
        mov r8,[scene1.pso]
        call [ID3D12GraphicsCommandList.Reset+rdi]
        mov rcx,rsi
        mov edx,1
        lea r8,[viewport]
        call [ID3D12GraphicsCommandList.RSSetViewports+rdi]
        mov rcx,rsi
        mov edx,1
        lea r8,[scissor]
        call [ID3D12GraphicsCommandList.RSSetScissorRects+rdi]
        mov rcx,rsi
        mov rdx,[scene1.rootsig]
        call [ID3D12GraphicsCommandList.SetGraphicsRootSignature+rdi]
  ; back buffer to D3D12_RESOURCE_STATE_RENDER_TARGET
        mov eax,[back_buffer_index]
        mov rax,[swapchain_buffer+rax*8]
        TRANSITION_BARRIER .barrier+rsp,rax,D3D12_RESOURCE_STATE_PRESENT,D3D12_RESOURCE_STATE_RENDER_TARGET
        mov rcx,rsi
        mov edx,1
        lea r8,[.barrier+rsp]
        call [ID3D12GraphicsCommandList.ResourceBarrier+rdi]
  ; get back buffer handle
        mov eax,[back_buffer_index]
        imul eax,[rtv_size]
        add rax,[swapchain_heap_start]
        mov [.back_buffer_handle+rsp],rax
  ; clear back buffer
        mov rcx,rsi
        mov rdx,[.back_buffer_handle+rsp]
        lea r8,[clear_color]
        xor r9d,r9d
        mov qword[k_funcparam5+rsp],0
        call [ID3D12GraphicsCommandList.ClearRenderTargetView+rdi]
  ; set back buffer as render target
        mov rcx,rsi
        mov edx,1
        lea r8,[.back_buffer_handle+rsp]
        mov r9d,1
        mov qword[k_funcparam5+rsp],0
        call [ID3D12GraphicsCommandList.OMSetRenderTargets+rdi]
  ; draw
        mov rcx,rsi
        mov edx,D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST
        call [ID3D12GraphicsCommandList.IASetPrimitiveTopology+rdi]
        mov rcx,rsi
        mov edx,3
        mov r8d,1
        xor r9d,r9d
        mov dword[k_funcparam5+rsp],0
        call [ID3D12GraphicsCommandList.DrawInstanced+rdi]
  ; back buffer to D3D12_RESOURCE_STATE_PRESENT
        mov eax,[back_buffer_index]
        mov rax,[swapchain_buffer+rax*8]
        TRANSITION_BARRIER .barrier+rsp,rax,D3D12_RESOURCE_STATE_RENDER_TARGET,D3D12_RESOURCE_STATE_PRESENT
        mov rcx,rsi
        mov edx,1
        lea r8,[.barrier+rsp]
        call [ID3D12GraphicsCommandList.ResourceBarrier+rdi]
  ; finish recording and execute commands
        mov rcx,rsi
        call [ID3D12GraphicsCommandList.Close+rdi]
        mov rcx,[cmdqueue]
        mov edx,1
        lea r8,[cmdlist]
        mov rax,[rcx]
        call [ID3D12CommandQueue.ExecuteCommandLists+rax]
        add rsp,.k_stack_size
        pop rdi rsi
        ret
;=============================================================================
else if program_section = 'data'

align 8
  scene1 scene1

end if
;=============================================================================
restruc scene1
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
