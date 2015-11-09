;=============================================================================
align 32
audio_init:
;-----------------------------------------------------------------------------
virtual at 0
  .audio audio_state
end virtual
  .k_stack_size = 4*8
push rsi
sub rsp,.k_stack_size
mov rsi,rcx
mov [.audio.enumerator+rsi],rax
add rsp,.k_stack_size
pop rsi
ret
;=============================================================================
; vim: set ft=fasm:
