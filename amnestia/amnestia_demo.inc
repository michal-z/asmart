;=============================================================================
FALIGN
demo_init:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
  ; clear color
        $movss xmm0,[clear_color]
        $movss xmm1,[clear_color+4]
        $movss xmm2,[clear_color+8]
        $movss xmm3,[clear_color+12]
        $call [glClearColor]
  ; vao
        $mov ecx,1
        $lea rdx,[vao]
        $call [glGenVertexArrays]
  ; vs
        $mov ecx,GL_VERTEX_SHADER
        $mov edx,1
        $lea r8,[vsh_full_triangle_ptr]
        $call [glCreateShaderProgramv]
        $mov [vshp],eax
  ; fs
        $mov ecx,GL_FRAGMENT_SHADER
        $mov edx,1
        $lea r8,[fsh_green_ptr]
        $call [glCreateShaderProgramv]
        $mov [fshp],eax
  ; pipeline
        $mov ecx,1
        $lea rdx,[pipeline]
        $call [glGenProgramPipelines]

        $mov ecx,[pipeline]
        $mov edx,GL_VERTEX_SHADER_BIT
        $mov r8d,[vshp]
        $call [glUseProgramStages]

        $mov ecx,[pipeline]
        $mov edx,GL_FRAGMENT_SHADER_BIT
        $mov r8d,[fshp]
        $call [glUseProgramStages]
  ; audio
        $call audio_play
        $test eax,eax
        $jz .error

        $mov eax,1
        $add rsp,.k_stack_size
        $ret
  .error:
        $xor eax,eax
        $add rsp,.k_stack_size
        $ret
;=============================================================================
FALIGN
demo_deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size
        $call audio_stop

        $mov ecx,1
        $lea rdx,[pipeline]
        $call [glDeleteProgramPipelines]

        $mov ecx,1
        $lea rdx,[vao]
        $call [glDeleteProgramPipelines]

        $mov ecx,[vshp]
        $call [glDeleteProgram]

        $mov ecx,[fshp]
        $call [glDeleteProgram]
        $add rsp,.k_stack_size
        $ret
;=============================================================================
FALIGN
demo_update:
;-----------------------------------------------------------------------------
  .k_stack_size = 5*8
        $sub rsp,.k_stack_size

        $mov ecx,GL_COLOR_BUFFER_BIT
        $call [glClear]

        $mov ecx,[vao]
        $call [glBindVertexArray]

        $mov ecx,[pipeline]
        $call [glBindProgramPipeline]

        $mov ecx,GL_TRIANGLES
        $xor edx,edx
        $mov r8d,3
        $call [glDrawArrays]

        $add rsp,.k_stack_size
        $ret
;=============================================================================