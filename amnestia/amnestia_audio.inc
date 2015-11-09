
struc audio_state_t {
.enumerator    dq 0
.device        dq 0
.client        dq 0
.render_client dq 0 }

;=============================================================================
align 32
audio_init:
;-----------------------------------------------------------------------------
virtual at 0
  audio audio_state_t
end virtual
mov rax,[rsi+audio.device]
;=============================================================================

; vim: set ft=fasm:
