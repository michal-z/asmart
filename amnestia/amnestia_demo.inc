;=============================================================================
align 32
demo_init:
;-----------------------------------------------------------------------------
virtual at 0
.demo demo_state
end virtual
  .k_stack_size = 4*8
push rsi
sub rsp,.k_stack_size
mov rsi,rcx
; clear color
movss xmm0,[.demo.clear_color+rsi]
movss xmm1,[.demo.clear_color+4+rsi]
movss xmm2,[.demo.clear_color+8+rsi]
movss xmm3,[.demo.clear_color+12+rsi]
call [glClearColor]
; vao
mov ecx,1
lea rdx,[.demo.vao+rsi]
call [glGenVertexArrays]
; vs
mov ecx,GL_VERTEX_SHADER
mov edx,1
lea r8,[vsh_full_triangle_ptr]
call [glCreateShaderProgramv]
mov [.demo.vshp+rsi],eax
; fs
mov ecx,GL_FRAGMENT_SHADER
mov edx,1
lea r8,[fsh_green_ptr]
call [glCreateShaderProgramv]
mov [.demo.fshp+rsi],eax
; pipeline
mov ecx,1
lea rdx,[.demo.pipeline+rsi]
call [glGenProgramPipelines]
mov ecx,[.demo.pipeline+rsi]
mov edx,GL_VERTEX_SHADER_BIT
mov r8d,[.demo.vshp+rsi]
call [glUseProgramStages]
mov ecx,[.demo.pipeline+rsi]
mov edx,GL_FRAGMENT_SHADER_BIT
mov r8d,[.demo.fshp+rsi]
call [glUseProgramStages]
mov eax,1
add rsp,.k_stack_size
pop rsi
ret
;=============================================================================
align 32
demo_deinit:
;-----------------------------------------------------------------------------
virtual at 0
  .demo demo_state
end virtual
  .k_stack_size = 4*8
push rsi
sub rsp,.k_stack_size
mov rsi,rcx
mov ecx,1
lea rdx,[.demo.pipeline+rsi]
call [glDeleteProgramPipelines]
mov ecx,1
lea rdx,[.demo.vao+rsi]
call [glDeleteProgramPipelines]
mov ecx,[.demo.vshp+rsi]
call [glDeleteProgram]
mov ecx,[.demo.fshp+rsi]
call [glDeleteProgram]
add rsp,.k_stack_size
pop rsi
ret
;=============================================================================
align 32
demo_update:
;-----------------------------------------------------------------------------
virtual at 0
  .demo demo_state
end virtual
  .k_stack_size = 4*8
push rsi
sub rsp,.k_stack_size
mov rsi,rcx
mov ecx,GL_COLOR_BUFFER_BIT
call [glClear]
mov ecx,[.demo.vao+rsi]
call [glBindVertexArray]
mov ecx,[.demo.pipeline+rsi]
call [glBindProgramPipeline]
mov ecx,GL_TRIANGLES
xor edx,edx
mov r8d,3
call [glDrawArrays]
add rsp,.k_stack_size
pop rsi
ret
;=============================================================================
; vim: set ft=fasm:
