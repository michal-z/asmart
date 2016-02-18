if program_section = 'code'
;=============================================================================
macro VSHUFPS_MM_SHUFFLE d*,s0*,s1*,fp3*,fp2*,fp1*,fp0* {
        vshufps d,s0,s1,(fp3 shl 6) or (fp2 shl 4) or (fp1 shl 2) or fp0 }
;=============================================================================
FALIGN
sinf:
;-----------------------------------------------------------------------------
        vmovaps xmm1,xmm0
        vmulss xmm0,xmm0,[k_f32_reciprocal_two_pi]
        vroundss xmm0,xmm0,xmm0,0
        vmulss xmm0,xmm0,[k_f32_two_pi]
        vsubss xmm0,xmm1,xmm0
        vandps xmm1,xmm0,[k_i32_negative_zero]
        vorps xmm2,xmm1,[k_f32_pi]
        vandnps xmm3,xmm1,xmm0
        vsubss xmm4,xmm2,xmm0
        vcmpless xmm5,xmm3,[k_f32_half_pi]
        vblendvps xmm0,xmm4,xmm0,xmm5
        vmulss xmm1,xmm0,xmm0
        vmovss xmm2,[k_f32_sin_coefficients+16]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients+12]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients+8]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients+4]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients]
        vfmadd213ss xmm2,xmm1,[k_f32_one]
        vmulss xmm0,xmm2,xmm0
        ret
;=============================================================================
FALIGN
sin8f:
;-----------------------------------------------------------------------------
        vmovaps ymm1,ymm0
        vmulps ymm0,ymm0,[k_f32_reciprocal_two_pi]
        vroundps ymm0,ymm0,0
        vmulps ymm0,ymm0,[k_f32_two_pi]
        vsubps ymm0,ymm1,ymm0
        vandps ymm1,ymm0,[k_i32_negative_zero]
        vorps ymm2,ymm1,[k_f32_pi]
        vandnps ymm3,ymm1,ymm0
        vsubps ymm4,ymm2,ymm0
        vcmpleps ymm5,ymm3,[k_f32_half_pi]
        vblendvps ymm0,ymm4,ymm0,ymm5
        vmulps ymm1,ymm0,ymm0
        vbroadcastss ymm2,[k_f32_sin_coefficients+16]
        vbroadcastss ymm3,[k_f32_sin_coefficients+12]
        vbroadcastss ymm4,[k_f32_sin_coefficients+8]
        vbroadcastss ymm5,[k_f32_sin_coefficients+4]
        vbroadcastss ymm6,[k_f32_sin_coefficients]
        vfmadd213ps ymm2,ymm1,ymm3
        vfmadd213ps ymm2,ymm1,ymm4
        vfmadd213ps ymm2,ymm1,ymm5
        vfmadd213ps ymm2,ymm1,ymm6
        vfmadd213ps ymm2,ymm1,[k_f32_one]
        vmulps ymm0,ymm2,ymm0
        ret
;=============================================================================
FALIGN
cosf:
;-----------------------------------------------------------------------------
        vmovaps xmm1,xmm0
        vmulss xmm0,xmm0,[k_f32_reciprocal_two_pi]
        vroundss xmm0,xmm0,xmm0,0
        vmulss xmm0,xmm0,[k_f32_two_pi]
        vsubss xmm0,xmm1,xmm0
        vandps xmm1,xmm0,[k_i32_negative_zero]
        vorps xmm2,xmm1,[k_f32_pi]
        vandnps xmm3,xmm1,xmm0
        vsubss xmm4,xmm2,xmm0
        vcmpless xmm5,xmm3,[k_f32_half_pi]
        vblendvps xmm0,xmm4,xmm0,xmm5
        vmovaps xmm6,[k_f32_one]
        vandnps xmm2,xmm5,[k_f32_negative_one]
        vandps xmm1,xmm5,xmm6
        vorps xmm7,xmm1,xmm2
        vmulss xmm1,xmm0,xmm0
        vmovss xmm2,[k_f32_cos_coefficients+16]
        vfmadd213ss xmm2,xmm1,[k_f32_cos_coefficients+12]
        vfmadd213ss xmm2,xmm1,[k_f32_cos_coefficients+8]
        vfmadd213ss xmm2,xmm1,[k_f32_cos_coefficients+4]
        vfmadd213ss xmm2,xmm1,[k_f32_cos_coefficients]
        vfmadd213ss xmm2,xmm1,xmm6
        vmulss xmm0,xmm2,xmm7
        ret
;=============================================================================
FALIGN
cos8f:
;-----------------------------------------------------------------------------
        vmovaps ymm1,ymm0
        vmulps ymm0,ymm0,[k_f32_reciprocal_two_pi]
        vroundps ymm0,ymm0,0
        vmulps ymm0,ymm0,[k_f32_two_pi]
        vsubps ymm0,ymm1,ymm0
        vandps ymm1,ymm0,[k_i32_negative_zero]
        vorps ymm2,ymm1,[k_f32_pi]
        vandnps ymm3,ymm1,ymm0
        vsubps ymm4,ymm2,ymm0
        vcmpleps ymm5,ymm3,[k_f32_half_pi]
        vblendvps ymm0,ymm4,ymm0,ymm5
        vmovaps ymm8,[k_f32_one]
        vandnps ymm2,ymm5,[k_f32_negative_one]
        vandps ymm1,ymm5,ymm8
        vorps ymm7,ymm1,ymm2
        vmulps ymm1,ymm0,ymm0
        vbroadcastss ymm2,[k_f32_cos_coefficients+16]
        vbroadcastss ymm3,[k_f32_cos_coefficients+12]
        vbroadcastss ymm4,[k_f32_cos_coefficients+8]
        vbroadcastss ymm5,[k_f32_cos_coefficients+4]
        vbroadcastss ymm6,[k_f32_cos_coefficients]
        vfmadd213ps ymm2,ymm1,ymm3
        vfmadd213ps ymm2,ymm1,ymm4
        vfmadd213ps ymm2,ymm1,ymm5
        vfmadd213ps ymm2,ymm1,ymm6
        vfmadd213ps ymm2,ymm1,ymm8
        vmulps ymm0,ymm2,ymm7
        ret
;=============================================================================
FALIGN
sincosf:
;-----------------------------------------------------------------------------
        vmovaps xmm1,xmm0
        vmulss xmm0,xmm0,[k_f32_reciprocal_two_pi]
        vroundss xmm0,xmm0,xmm0,0
        vmulss xmm0,xmm0,[k_f32_two_pi]
        vsubss xmm0,xmm1,xmm0
        vandps xmm1,xmm0,[k_i32_negative_zero]
        vorps xmm2,xmm1,[k_f32_pi]
        vandnps xmm3,xmm1,xmm0
        vsubss xmm4,xmm2,xmm0
        vcmpless xmm5,xmm3,[k_f32_half_pi]
        vblendvps xmm0,xmm4,xmm0,xmm5
        vmovaps xmm6,[k_f32_one]
        vandnps xmm2,xmm5,[k_f32_negative_one]
        vandps xmm1,xmm5,xmm6
        vorps xmm7,xmm1,xmm2
        vmulss xmm1,xmm0,xmm0
        vmovss xmm2,[k_f32_sin_coefficients+16]
        vmovss xmm3,[k_f32_cos_coefficients+16]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients+12]
        vfmadd213ss xmm3,xmm1,[k_f32_cos_coefficients+12]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients+8]
        vfmadd213ss xmm3,xmm1,[k_f32_cos_coefficients+8]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients+4]
        vfmadd213ss xmm3,xmm1,[k_f32_cos_coefficients+4]
        vfmadd213ss xmm2,xmm1,[k_f32_sin_coefficients]
        vfmadd213ss xmm3,xmm1,[k_f32_cos_coefficients]
        vfmadd213ss xmm2,xmm1,xmm6
        vfmadd213ss xmm3,xmm1,xmm6
        vmulss xmm0,xmm2,xmm0
        vmulss xmm1,xmm3,xmm7
        ret
;=============================================================================
FALIGN
sincos8f:
;-----------------------------------------------------------------------------
        vmovaps ymm1,ymm0
        vmulps ymm0,ymm0,[k_f32_reciprocal_two_pi]
        vroundps ymm0,ymm0,0
        vmulps ymm0,ymm0,[k_f32_two_pi]
        vsubps ymm0,ymm1,ymm0
        vandps ymm1,ymm0,[k_i32_negative_zero]
        vorps ymm2,ymm1,[k_f32_pi]
        vandnps ymm3,ymm1,ymm0
        vsubps ymm4,ymm2,ymm0
        vcmpleps ymm5,ymm3,[k_f32_half_pi]
        vblendvps ymm0,ymm4,ymm0,ymm5
        vmovaps ymm14,[k_f32_one]
        vandnps ymm2,ymm5,[k_f32_negative_one]
        vandps ymm1,ymm5,ymm14
        vorps ymm15,ymm1,ymm2
        vmulps ymm1,ymm0,ymm0
        vbroadcastss ymm2,[k_f32_sin_coefficients+16]
        vbroadcastss ymm3,[k_f32_cos_coefficients+16]
        vbroadcastss ymm4,[k_f32_sin_coefficients+12]
        vbroadcastss ymm5,[k_f32_cos_coefficients+12]
        vbroadcastss ymm6,[k_f32_sin_coefficients+8]
        vbroadcastss ymm7,[k_f32_cos_coefficients+8]
        vbroadcastss ymm8,[k_f32_sin_coefficients+4]
        vbroadcastss ymm9,[k_f32_cos_coefficients+4]
        vbroadcastss ymm10,[k_f32_sin_coefficients]
        vbroadcastss ymm11,[k_f32_cos_coefficients]
        vfmadd213ps ymm2,ymm1,ymm4
        vfmadd213ps ymm3,ymm1,ymm5
        vfmadd213ps ymm2,ymm1,ymm6
        vfmadd213ps ymm3,ymm1,ymm7
        vfmadd213ps ymm2,ymm1,ymm8
        vfmadd213ps ymm3,ymm1,ymm9
        vfmadd213ps ymm2,ymm1,ymm10
        vfmadd213ps ymm3,ymm1,ymm11
        vfmadd213ps ymm2,ymm1,ymm14
        vfmadd213ps ymm3,ymm1,ymm14
        vmulps ymm0,ymm2,ymm0
        vmulps ymm1,ymm3,ymm15
        ret
;=============================================================================
macro MATRIX_ROTATION_X dst* {
        call sincosf
        vmovaps ymm2,[k_f32_identity_r0]
        vmovaps ymm3,[k_f32_identity_r2]
        vmovaps [dst],ymm2
        vmovaps [dst+32],ymm3
        vxorps ymm2,ymm2,ymm2
        vsubps ymm2,ymm2,ymm0
        vmovss [dst+16+4],xmm1
        vmovss [dst+16+8],xmm0
        vmovss [dst+32+4],xmm2
        vmovss [dst+32+8],xmm1 }
;=============================================================================
macro MATRIX_ROTATION_Y dst* {
        call sincosf
        vmovaps ymm2,[k_f32_identity_r0]
        vmovaps ymm3,[k_f32_identity_r2]
        vmovaps [dst],ymm2
        vmovaps [dst+32],ymm3
        vxorps ymm2,ymm2,ymm2
        vsubps ymm2,ymm2,ymm0
        vmovss [dst],xmm1
        vmovss [dst+8],xmm2
        vmovss [dst+32],xmm0
        vmovss [dst+32+8],xmm1 }
;=============================================================================
macro MATRIX_ROTATION_Z dst* {
        call sincosf
        vmovaps ymm2,[k_f32_identity_r0]
        vmovaps ymm3,[k_f32_identity_r2]
        vmovaps [dst],ymm2
        vmovaps [dst+32],ymm3
        vxorps ymm2,ymm2,ymm2
        vsubps ymm2,ymm2,ymm0
        vmovss [dst],xmm1
        vmovss [dst+4],xmm0
        vmovss [dst+16],xmm2
        vmovss [dst+16+4],xmm1 }
;=============================================================================
macro MATRIX_PERSPECTIVE_FOV dst* {
        vmovaps xmm11,xmm1
        vmovaps xmm12,xmm2
        vmovaps xmm13,xmm3
        vmulss xmm0,xmm0,[k_f32_half]
        call sincosf
        vdivss xmm0,xmm1,xmm0
        vdivss xmm1,xmm0,xmm11
        vsubss xmm2,xmm13,xmm12
        vdivss xmm2,xmm13,xmm2
        vmulss xmm3,xmm2,xmm12
        vxorps ymm4,ymm4,ymm4
        vsubss xmm3,xmm4,xmm3
        vmovaps [dst],ymm4
        vmovaps [dst+32],ymm4
        vmovss [dst],xmm1
        vmovss [dst+16+4],xmm0
        vmovss [dst+32+8],xmm2
        vmovss [dst+48+8],xmm3 }
;=============================================================================
FALIGN
matrix_mul:
;-----------------------------------------------------------------------------
        vmovaps ymm8,[rdx]
        vmovaps ymm9,[rdx+32]
        vmovaps ymm4,[r8]
        vmovaps ymm5,[r8+32]
        vperm2f128 ymm6,ymm4,ymm4,1
        vperm2f128 ymm7,ymm5,ymm5,1
  ; row 0,1
        vshufps ymm0,ymm8,ymm8,$55
        vshufps xmm0,xmm8,xmm8,$00
        vshufps ymm1,ymm8,ymm8,$ff
        vshufps xmm1,xmm8,xmm8,$aa
        vshufps ymm2,ymm8,ymm8,$00
        vshufps xmm2,xmm8,xmm8,$55
        vshufps ymm3,ymm8,ymm8,$aa
        vshufps xmm3,xmm8,xmm8,$ff
        vmulps ymm0,ymm0,ymm4
        vmulps ymm1,ymm1,ymm5
        vmulps ymm2,ymm2,ymm6
        vmulps ymm3,ymm3,ymm7
        vaddps ymm0,ymm0,ymm1
        vaddps ymm2,ymm2,ymm3
        vaddps ymm0,ymm0,ymm2
        vmovaps [rcx],ymm0
  ; row 2,3
        vshufps ymm0,ymm9,ymm9,$55
        vshufps xmm0,xmm9,xmm9,$00
        vshufps ymm1,ymm9,ymm9,$ff
        vshufps xmm1,xmm9,xmm9,$aa
        vshufps ymm2,ymm9,ymm9,$00
        vshufps xmm2,xmm9,xmm9,$55
        vshufps ymm3,ymm9,ymm9,$aa
        vshufps xmm3,xmm9,xmm9,$ff
        vmulps ymm0,ymm0,ymm4
        vmulps ymm1,ymm1,ymm5
        vmulps ymm2,ymm2,ymm6
        vmulps ymm3,ymm3,ymm7
        vaddps ymm0,ymm0,ymm1
        vaddps ymm2,ymm2,ymm3
        vaddps ymm0,ymm0,ymm2
        vmovaps [rcx+32],ymm0
        ret
;=============================================================================
FALIGN
matrix_mul_transpose:
;-----------------------------------------------------------------------------
        vmovaps ymm8,[rdx]
        vmovaps ymm9,[rdx+32]
        vmovaps ymm4,[r8]
        vmovaps ymm5,[r8+32]
        vperm2f128 ymm6,ymm4,ymm4,1
        vperm2f128 ymm7,ymm5,ymm5,1
        vmovaps ymm12,[k_i32_perm_x0_y1]
        vmovaps ymm13,[k_i32_perm_z0_w1]
        vmovaps ymm14,[k_i32_perm_y0_x1]
        vmovaps ymm15,[k_i32_perm_w0_z1]
  ; row 0,1
        vpermps ymm0,ymm12,ymm8
        vpermps ymm1,ymm13,ymm8
        vpermps ymm2,ymm14,ymm8
        vpermps ymm3,ymm15,ymm8
        vmulps ymm0,ymm0,ymm4
        vmulps ymm1,ymm1,ymm5
        vmulps ymm2,ymm2,ymm6
        vmulps ymm3,ymm3,ymm7
        vaddps ymm0,ymm0,ymm1
        vaddps ymm2,ymm2,ymm3
        vaddps ymm0,ymm0,ymm2
        vmovaps ymm10,ymm0
  ; row 2,3
        vpermps ymm0,ymm12,ymm9
        vpermps ymm1,ymm13,ymm9
        vpermps ymm2,ymm14,ymm9
        vpermps ymm3,ymm15,ymm9
        vmulps ymm0,ymm0,ymm4
        vmulps ymm1,ymm1,ymm5
        vmulps ymm2,ymm2,ymm6
        vmulps ymm3,ymm3,ymm7
        vaddps ymm0,ymm0,ymm1
        vaddps ymm2,ymm2,ymm3
        vaddps ymm0,ymm0,ymm2
        vmovaps ymm11,ymm0
  ; transpose and store the result
        vmovaps xmm12,xmm10
        vextractf128 xmm13,ymm10,1
        vmovaps xmm14,xmm11
        vextractf128 xmm15,ymm11,1
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

align 64
  k_f32_identity_r0: dd 1.0,0.0,0.0,0.0
  k_f32_identity_r1: dd 0.0,1.0,0.0,0.0
  k_f32_identity_r2: dd 0.0,0.0,1.0,0.0
  k_f32_identity_r3: dd 0.0,0.0,0.0,1.0

  k_f32_pi: dd 8 dup 3.141592654
  k_f32_two_pi: dd 8 dup 6.283185307
  k_f32_reciprocal_two_pi: dd 8 dup 0.159154943
  k_f32_half_pi: dd 8 dup 1.570796327
  k_f32_sin_coefficients: dd -0.16666667,0.0083333310,-0.00019840874,2.7525562e-06,-2.3889859e-08,-0.16665852,0.0083139502,-0.00018524670
  k_f32_cos_coefficients: dd -0.5,0.041666638,-0.0013888378,2.4760495e-05,-2.6051615e-07,-0.49992746,0.041493919,-0.0012712436
  k_i32_negative_zero: dd 8 dup 0x80000000
  k_f32_one: dd 8 dup 1.0
  k_f32_negative_one: dd 8 dup -1.0
  k_i32_perm_x0_y1: dd 0,0,0,0,5,5,5,5
  k_i32_perm_z0_w1: dd 2,2,2,2,7,7,7,7
  k_i32_perm_y0_x1: dd 1,1,1,1,4,4,4,4
  k_i32_perm_w0_z1: dd 3,3,3,3,6,6,6,6

end if
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
