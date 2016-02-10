struc scene1 {
  .pso dq 0 }

if program_section = 'code'
;=============================================================================
FALIGN
scene1_init:
;-----------------------------------------------------------------------------
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
  .k_stack_size = 32*1+8
        push rsi rdi
        sub rsp,.k_stack_size
        mov rsi,[cmdlist]
        mov rdi,[rsi]
        mov eax,[frame_index]
        mov rcx,[cmdallocator+rax*8]
        mov rax,[rcx]
        call [ID3D12CommandAllocator.Reset+rax]
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
