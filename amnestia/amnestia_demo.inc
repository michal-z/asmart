if program_section = 'code'

;=============================================================================
align 32
demo_init:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
sub rsp,.k_stack_size
movss xmm0,[k_1_0f]
xorps xmm1,xmm1
xorps xmm2,xmm2
movss xmm3,[k_1_0f]
call [glClearColor]
add rsp,.k_stack_size
ret
;=============================================================================
align 32
demo_deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
sub rsp,.k_stack_size
add rsp,.k_stack_size
ret
;=============================================================================
align 32
demo_update:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
sub rsp,.k_stack_size
mov ecx,GL_COLOR_BUFFER_BIT
call [glClear]
add rsp,.k_stack_size
ret
;=============================================================================
else if program_section = 'data'

end if
