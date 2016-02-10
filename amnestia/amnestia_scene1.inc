struc scene1 {
  .rootsig dq 0
  .pso dq 0 }

if program_section = 'code'
;=============================================================================
FALIGN
scene1_init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 4
  .rootsig_desc D3D12_ROOT_SIGNATURE_DESC
  align 8
  .d3dblob dq ?
  align 32
  .k_stack_size = $+24
end virtual
        sub rsp,.k_stack_size
        ZERO_STACK .k_stack_size
        add rsp,.k_stack_size
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
        xor r8d,r8d
        call [ID3D12GraphicsCommandList.Reset+rdi]
        mov rcx,rsi
        mov edx,1
        lea r8,[viewport]
        call [ID3D12GraphicsCommandList.RSSetViewports+rdi]
        mov rcx,rsi
        mov edx,1
        lea r8,[scissor]
        call [ID3D12GraphicsCommandList.RSSetScissorRects+rdi]
  ; back buffer to D3D12_RESOURCE_STATE_RENDER_TARGET
        mov eax,[back_buffer_index]
        mov rax,[swapchain_buffer+rax*8]
        TRANSITION_BARRIER .barrier+rsp,rax,D3D12_RESOURCE_STATE_PRESENT,D3D12_RESOURCE_STATE_RENDER_TARGET
        mov rcx,rsi
        mov edx,1
        lea r8,[.barrier+rsp]
        call [ID3D12GraphicsCommandList.ResourceBarrier+rdi]
  ; clear back buffer
        mov rcx,rsi
        mov edx,[back_buffer_index]
        imul edx,[rtv_size]
        add rdx,[swapchain_heap_start]
        lea r8,[clear_color]
        xor r9d,r9d
        mov qword[k_funcparam5+rsp],0
        call [ID3D12GraphicsCommandList.ClearRenderTargetView+rdi]
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

scene1 scene1

end if

restruc scene1
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
