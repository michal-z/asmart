;=============================================================================
FALIGN
demo_init:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
        sub rsp,.k_stack_size
  ; audio
        call audio_play
        test eax,eax
        jz .error

        mov eax,1
        add rsp,.k_stack_size
        ret
  .error:
        xor eax,eax
        add rsp,.k_stack_size
        ret
;=============================================================================
FALIGN
demo_deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
        sub rsp,.k_stack_size
        call audio_stop
        add rsp,.k_stack_size
        ret
;=============================================================================
FALIGN
demo_update:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
        sub rsp,.k_stack_size

        add rsp,.k_stack_size
        ret
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
