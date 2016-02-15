if program_section = 'code'
;=============================================================================
macro VSHUFPS_MM_SHUFFLE d*,s0*,s1*,fp3*,fp2*,fp1*,fp0* {
        vshufps d,s0,s1,(fp3 shl 6) or (fp2 shl 4) or (fp1 shl 2) or fp0 }
;=============================================================================
FALIGN
sinf:
;-----------------------------------------------------------------------------
        vmovaps xmm1,xmm0
        vmulss xmm0,xmm0,[k4_f32_reciprocal_two_pi]
        vroundss xmm0,xmm0,xmm0,0
        vmulss xmm0,xmm0,[k4_f32_two_pi]
        vsubss xmm0,xmm1,xmm0
        vandps xmm1,xmm0,[k4_i32_negative_zero]
        vorps xmm2,xmm1,[k4_f32_pi]
        vandnps xmm3,xmm1,xmm0
        vsubss xmm4,xmm2,xmm0
        vcmpless xmm5,xmm3,[k4_f32_half_pi]
        vblendvps xmm0,xmm4,xmm0,xmm5
        vmulss xmm1,xmm0,xmm0
        vmovss xmm2,[k4_f32_sin_coefficients1]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0+12]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0+8]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0+4]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0]
        vfmadd213ss xmm2,xmm1,[k4_f32_one]
        vmulss xmm0,xmm2,xmm0
        ret
;=============================================================================
FALIGN
cosf:
;-----------------------------------------------------------------------------
        vmovaps xmm1,xmm0
        vmulss xmm0,xmm0,[k4_f32_reciprocal_two_pi]
        vroundss xmm0,xmm0,xmm0,0
        vmulss xmm0,xmm0,[k4_f32_two_pi]
        vsubss xmm0,xmm1,xmm0
        vandps xmm1,xmm0,[k4_i32_negative_zero]
        vorps xmm2,xmm1,[k4_f32_pi]
        vandnps xmm3,xmm1,xmm0
        vsubss xmm4,xmm2,xmm0
        vcmpless xmm5,xmm3,[k4_f32_half_pi]
        vblendvps xmm0,xmm4,xmm0,xmm5
        vmovaps xmm6,[k4_f32_one]
        vandnps xmm2,xmm5,[k4_f32_negative_one]
        vandps xmm1,xmm5,xmm6
        vorps xmm7,xmm1,xmm2
        vmulss xmm1,xmm0,xmm0
        vmovss xmm2,[k4_f32_cos_coefficients1]
        vfmadd213ss xmm2,xmm1,[k4_f32_cos_coefficients0+12]
        vfmadd213ss xmm2,xmm1,[k4_f32_cos_coefficients0+8]
        vfmadd213ss xmm2,xmm1,[k4_f32_cos_coefficients0+4]
        vfmadd213ss xmm2,xmm1,[k4_f32_cos_coefficients0]
        vfmadd213ss xmm2,xmm1,xmm6
        vmulss xmm0,xmm2,xmm7
        ret
;=============================================================================
FALIGN
sincosf:
;-----------------------------------------------------------------------------
        vmovaps xmm1,xmm0
        vmulss xmm0,xmm0,[k4_f32_reciprocal_two_pi]
        vroundss xmm0,xmm0,xmm0,0
        vmulss xmm0,xmm0,[k4_f32_two_pi]
        vsubss xmm0,xmm1,xmm0
        vandps xmm1,xmm0,[k4_i32_negative_zero]
        vorps xmm2,xmm1,[k4_f32_pi]
        vandnps xmm3,xmm1,xmm0
        vsubss xmm4,xmm2,xmm0
        vcmpless xmm5,xmm3,[k4_f32_half_pi]
        vblendvps xmm0,xmm4,xmm0,xmm5
        vmovaps xmm6,[k4_f32_one]
        vandnps xmm2,xmm5,[k4_f32_negative_one]
        vandps xmm1,xmm5,xmm6
        vorps xmm7,xmm1,xmm2
        vmulss xmm1,xmm0,xmm0
        vmovss xmm2,[k4_f32_sin_coefficients1]
        vmovss xmm3,[k4_f32_cos_coefficients1]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0+12]
        vfmadd213ss xmm3,xmm1,[k4_f32_cos_coefficients0+12]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0+8]
        vfmadd213ss xmm3,xmm1,[k4_f32_cos_coefficients0+8]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0+4]
        vfmadd213ss xmm3,xmm1,[k4_f32_cos_coefficients0+4]
        vfmadd213ss xmm2,xmm1,[k4_f32_sin_coefficients0]
        vfmadd213ss xmm3,xmm1,[k4_f32_cos_coefficients0]
        vfmadd213ss xmm2,xmm1,xmm6
        vfmadd213ss xmm3,xmm1,xmm6
        vmulss xmm0,xmm2,xmm0
        vmulss xmm1,xmm3,xmm7
        ret
;=============================================================================
FALIGN
matrix_rotation_y:
;-----------------------------------------------------------------------------
        call sincosf
        vxorps xmm2,xmm2,xmm2
        vmovss xmm0,xmm2,xmm0
        vmovss xmm1,xmm2,xmm1
        ret
;=============================================================================
FALIGN
matrix_mul:
;-----------------------------------------------------------------------------
        vmovaps xmm8,[rdx]
        vmovaps xmm9,[rdx+16]
        vmovaps xmm10,[rdx+32]
        vmovaps xmm11,[rdx+48]
        vmovaps xmm4,[r8]
        vmovaps xmm5,[r8+16]
        vmovaps xmm6,[r8+32]
        vmovaps xmm7,[r8+48]
  ; row 0
        vshufps xmm0,xmm8,xmm8,$00
        vshufps xmm1,xmm8,xmm8,$55
        vshufps xmm2,xmm8,xmm8,$aa
        vshufps xmm3,xmm8,xmm8,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps [rcx],xmm0
  ; row 1
        vshufps xmm0,xmm9,xmm9,$00
        vshufps xmm1,xmm9,xmm9,$55
        vshufps xmm2,xmm9,xmm9,$aa
        vshufps xmm3,xmm9,xmm9,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps [rcx+16],xmm0
  ; row 2
        vshufps xmm0,xmm10,xmm10,$00
        vshufps xmm1,xmm10,xmm10,$55
        vshufps xmm2,xmm10,xmm10,$aa
        vshufps xmm3,xmm10,xmm10,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps [rcx+32],xmm0
  ; row 3
        vshufps xmm0,xmm11,xmm11,$00
        vshufps xmm1,xmm11,xmm11,$55
        vshufps xmm2,xmm11,xmm11,$aa
        vshufps xmm3,xmm11,xmm11,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps [rcx+48],xmm0
        ret
;=============================================================================
FALIGN
matrix_mul_transpose:
;-----------------------------------------------------------------------------
        vmovaps xmm8,[rdx]
        vmovaps xmm9,[rdx+16]
        vmovaps xmm10,[rdx+32]
        vmovaps xmm11,[rdx+48]
        vmovaps xmm4,[r8]
        vmovaps xmm5,[r8+16]
        vmovaps xmm6,[r8+32]
        vmovaps xmm7,[r8+48]
  ; row 0
        vshufps xmm0,xmm8,xmm8,$00
        vshufps xmm1,xmm8,xmm8,$55
        vshufps xmm2,xmm8,xmm8,$aa
        vshufps xmm3,xmm8,xmm8,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps xmm12,xmm0
  ; row 1
        vshufps xmm0,xmm9,xmm9,$00
        vshufps xmm1,xmm9,xmm9,$55
        vshufps xmm2,xmm9,xmm9,$aa
        vshufps xmm3,xmm9,xmm9,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps xmm13,xmm0
  ; row 2
        vshufps xmm0,xmm10,xmm10,$00
        vshufps xmm1,xmm10,xmm10,$55
        vshufps xmm2,xmm10,xmm10,$aa
        vshufps xmm3,xmm10,xmm10,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps xmm14,xmm0
  ; row 3
        vshufps xmm0,xmm11,xmm11,$00
        vshufps xmm1,xmm11,xmm11,$55
        vshufps xmm2,xmm11,xmm11,$aa
        vshufps xmm3,xmm11,xmm11,$ff
        vmulps xmm0,xmm0,xmm4
        vmulps xmm1,xmm1,xmm5
        vmulps xmm2,xmm2,xmm6
        vmulps xmm3,xmm3,xmm7
        vaddps xmm0,xmm0,xmm1
        vaddps xmm2,xmm2,xmm3
        vaddps xmm0,xmm0,xmm2
        vmovaps xmm15,xmm0
  ; transpose and store the result
        VSHUFPS_MM_SHUFFLE xmm4,xmm12,xmm13,1,0,1,0
        VSHUFPS_MM_SHUFFLE xmm6,xmm12,xmm13,3,2,3,2
        VSHUFPS_MM_SHUFFLE xmm5,xmm14,xmm15,1,0,1,0
        VSHUFPS_MM_SHUFFLE xmm7,xmm14,xmm15,3,2,3,2
        VSHUFPS_MM_SHUFFLE xmm0,xmm4,xmm5,2,0,2,0
        VSHUFPS_MM_SHUFFLE xmm1,xmm4,xmm5,3,1,3,1
        VSHUFPS_MM_SHUFFLE xmm2,xmm6,xmm7,2,0,2,0
        VSHUFPS_MM_SHUFFLE xmm3,xmm6,xmm7,3,1,3,1
        vmovaps [rcx],xmm0
        vmovaps [rcx+16],xmm1
        vmovaps [rcx+32],xmm2
        vmovaps [rcx+48],xmm3
        ret
;=============================================================================
else if program_section = 'cdata'

align 16
  k4_f32_identity_r0: dd 1.0,0.0,0.0,0.0
  k4_f32_identity_r1: dd 0.0,1.0,0.0,0.0
  k4_f32_identity_r2: dd 0.0,0.0,1.0,0.0
  k4_f32_identity_r3: dd 0.0,0.0,0.0,1.0

  k4_f32_pi: dd 3.141592654,3.141592654,3.141592654,3.141592654
  k4_f32_two_pi: dd 6.283185307,6.283185307,6.283185307,6.283185307
  k4_f32_reciprocal_two_pi: dd 0.159154943,0.159154943,0.159154943,0.159154943
  k4_f32_half_pi: dd 1.570796327,1.570796327,1.570796327,1.570796327
  k4_f32_sin_coefficients0: dd -0.16666667,0.0083333310,-0.00019840874,2.7525562e-06
  k4_f32_sin_coefficients1: dd -2.3889859e-08,-0.16665852,0.0083139502,-0.00018524670
  k4_f32_cos_coefficients0: dd -0.5,0.041666638,-0.0013888378,2.4760495e-05
  k4_f32_cos_coefficients1: dd -2.6051615e-07,-0.49992746,0.041493919,-0.0012712436
  k4_i32_negative_zero: dd 0x80000000,0x80000000,0x80000000,0x80000000
  k4_f32_one: dd 1.0,1.0,1.0,1.0
  k4_f32_negative_one: dd -1.0,-1.0,-1.0,-1.0

end if
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
