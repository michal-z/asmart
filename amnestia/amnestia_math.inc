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
macro VECTOR3_DOT {
        vmulps xmm1,xmm0,xmm1
        vshufps xmm0,xmm1,xmm1,$00
        vshufps xmm2,xmm1,xmm1,$55
        vaddps xmm0,xmm0,xmm2
        vshufps xmm2,xmm1,xmm1,$aa
        vaddps xmm0,xmm0,xmm2 }
;=============================================================================
; in: xmm0.x offsetx, xmm1.x offsety, xmm2.x offsetz
; out: ymm0 = 0 0 1 0  0 0 0 1
;      ymm1 = 1 offsetz offsety offsetx  0 1 0 0
macro MATRIX_TRANSLATION {
        vmovaps xmm3,[k_f32_identity_r3]
        vinsertps xmm3,xmm3,xmm0,00000000b
        vinsertps xmm3,xmm3,xmm1,00010000b
        vinsertps xmm3,xmm3,xmm2,00100000b
        vmovaps xmm2,[k_f32_identity_r2]
        vmovaps ymm0,[k_f32_identity_r0]
        vinsertf128 ymm1,ymm2,xmm3,1 }
;=============================================================================
; in: xmm0.x angle
; out: ymm0 = 0 sin cos 0  0 0 0 1
;      ymm1 = 1 0 0 0  0 cos -sin 0
macro MATRIX_ROTATION_X {
        call sincosf
        vxorps xmm2,xmm2,xmm2
        vmovss xmm0,xmm2,xmm0
        vmovss xmm1,xmm2,xmm1
        VSHUFPS_MM_SHUFFLE xmm2,xmm1,xmm0,3,0,0,3
        vmovaps xmm3,[k_f32_identity_r0]
        vinsertf128 ymm0,ymm3,xmm2,1
        VSHUFPS_MM_SHUFFLE xmm2,xmm2,xmm2,3,1,2,0
        vxorps xmm2,xmm2,[k_i32_negative_zero_y0]
        vmovaps ymm3,[k_f32_identity_r2]
        vinsertf128 ymm1,ymm3,xmm2,0 }
;=============================================================================
; in: xmm0.x angle
; out: ymm0 = 0 0 1 0  0 -sin 0 cos
;      ymm1 = 1 0 0 0  0 cos 0 sin
macro MATRIX_ROTATION_Y {
        call sincosf
        vxorps xmm2,xmm2,xmm2
        vmovss xmm0,xmm2,xmm0
        vmovss xmm1,xmm2,xmm1
        VSHUFPS_MM_SHUFFLE xmm2,xmm0,xmm1,3,0,3,0
        vmovaps ymm3,[k_f32_identity_r2]
        vinsertf128 ymm1,ymm3,xmm2,0
        VSHUFPS_MM_SHUFFLE xmm2,xmm2,xmm2,3,0,1,2
        vxorps xmm2,xmm2,[k_i32_negative_zero_z0]
        vmovaps ymm3,[k_f32_identity_r0]
        vinsertf128 ymm0,ymm3,xmm2,0 }
;=============================================================================
; in: xmm0.x angle
; out: ymm0 = 0 0 cos -sin  0 0 sin cos
;      ymm1 = 1 0 0 0  0 1 0 0
macro MATRIX_ROTATION_Z {
        call sincosf
        vxorps xmm2,xmm2,xmm2
        vmovss xmm0,xmm2,xmm0
        vmovss xmm1,xmm2,xmm1
        vunpcklps xmm2,xmm1,xmm0
        VSHUFPS_MM_SHUFFLE xmm3,xmm2,xmm2,3,2,0,1
        vxorps xmm3,xmm3,[k_i32_negative_zero_x0]
        vinsertf128 ymm0,ymm2,xmm3,1
        vmovaps ymm1,[k_f32_identity_r2] }
;=============================================================================
; in: xmm0.x fovy, xmm1.x aspect, xmm2.x near z, xmm3.x far z
; out: ymm0,ymm1 perspective matrix
macro MATRIX_PERSPECTIVE_FOV {
        sub rsp,32
        vmovss [rsp],xmm1
        vmovss [rsp+4],xmm2
        vmovss [rsp+8],xmm3
        vmulss xmm0,xmm0,[k_f32_half]
        call sincosf
        vxorps xmm2,xmm2,xmm2
        vmovss xmm0,xmm2,xmm0
        vmovss xmm1,xmm2,xmm1
        vdivss xmm1,xmm1,xmm0 ; row 1 [0 0 0 h]
        vmovss xmm2,[rsp]
        vmovaps xmm7,[k_f32_identity_r3] ; xmm7 = [1 0 0 0]
        vdivss xmm0,xmm1,xmm2 ; row 0 [0 0 0 w]
        vinsertps xmm1,xmm7,xmm1,00011101b ; row 1 [0 0 h 0]
        vmovss xmm4,[rsp+4]
        vmovss xmm5,[rsp+8]
        add rsp,32
        vsubss xmm2,xmm5,xmm4
        vdivss xmm2,xmm5,xmm2 ; row 2 [0 0 0 range]
        vmovaps xmm3,xmm2
        vmulss xmm3,xmm3,xmm4 ; row 3 [0 0 0 range*near_z]
        vinsertps xmm2,xmm7,xmm2,00100011b ; row 2 [1 range 0 0]
        vinsertps xmm3,xmm7,xmm3,00101011b
        vxorps xmm3,xmm3,[k_i32_negative_zero_z0] ; row 3 [0 0 -range*near_z 0]
        vinsertf128 ymm0,ymm0,xmm1,1
        vinsertf128 ymm1,ymm2,xmm3,1 }
;=============================================================================
; in: ymm0,ymm1 = m0; ymm2,ymm3 = m1
; out: ymm0,ymm1 = m0*m1
FALIGN
matrix_mul:
;-----------------------------------------------------------------------------
        vperm2f128 ymm4,ymm2,ymm2,1
        vperm2f128 ymm5,ymm3,ymm3,1
        vmovaps ymm12,[k_i32_perm_x0_y1]
        vmovaps ymm13,[k_i32_perm_z0_w1]
        vmovaps ymm14,[k_i32_perm_y0_x1]
        vmovaps ymm15,[k_i32_perm_w0_z1]
  ; row 0,1
        vpermps ymm6,ymm12,ymm0
        vpermps ymm7,ymm13,ymm0
        vpermps ymm8,ymm14,ymm0
        vpermps ymm9,ymm15,ymm0
        vmulps ymm6,ymm6,ymm2
        vmulps ymm7,ymm7,ymm3
        vmulps ymm8,ymm8,ymm4
        vmulps ymm9,ymm9,ymm5
        vaddps ymm6,ymm6,ymm7
        vaddps ymm8,ymm8,ymm9
        vaddps ymm0,ymm6,ymm8
  ; row 2,3
        vpermps ymm6,ymm12,ymm1
        vpermps ymm7,ymm13,ymm1
        vpermps ymm8,ymm14,ymm1
        vpermps ymm9,ymm15,ymm1
        vmulps ymm6,ymm6,ymm2
        vmulps ymm7,ymm7,ymm3
        vmulps ymm8,ymm8,ymm4
        vmulps ymm9,ymm9,ymm5
        vaddps ymm6,ymm6,ymm7
        vaddps ymm8,ymm8,ymm9
        vaddps ymm1,ymm6,ymm8
        ret
;=============================================================================
; in: ymm0,ymm1 = m0; ymm2,ymm3 = m1
; out: ymm0,ymm1 = transpose(m0*m1)
FALIGN
matrix_mul_transpose:
;-----------------------------------------------------------------------------
        vperm2f128 ymm4,ymm2,ymm2,1
        vperm2f128 ymm5,ymm3,ymm3,1
        vmovaps ymm12,[k_i32_perm_x0_y1]
        vmovaps ymm13,[k_i32_perm_z0_w1]
        vmovaps ymm14,[k_i32_perm_y0_x1]
        vmovaps ymm15,[k_i32_perm_w0_z1]
  ; row 0,1
        vpermps ymm6,ymm12,ymm0
        vpermps ymm7,ymm13,ymm0
        vpermps ymm8,ymm14,ymm0
        vpermps ymm9,ymm15,ymm0
        vmulps ymm6,ymm6,ymm2
        vmulps ymm7,ymm7,ymm3
        vmulps ymm8,ymm8,ymm4
        vmulps ymm9,ymm9,ymm5
        vaddps ymm6,ymm6,ymm7
        vaddps ymm8,ymm8,ymm9
        vaddps ymm10,ymm6,ymm8
  ; row 2,3
        vpermps ymm6,ymm12,ymm1
        vpermps ymm7,ymm13,ymm1
        vpermps ymm8,ymm14,ymm1
        vpermps ymm9,ymm15,ymm1
        vmulps ymm6,ymm6,ymm2
        vmulps ymm7,ymm7,ymm3
        vmulps ymm8,ymm8,ymm4
        vmulps ymm9,ymm9,ymm5
        vaddps ymm6,ymm6,ymm7
        vaddps ymm8,ymm8,ymm9
        vaddps ymm11,ymm6,ymm8
  ; transpose and store the result
        vunpcklps ymm4,ymm10,ymm11
        vunpckhps ymm5,ymm10,ymm11
        vperm2f128 ymm10,ymm4,ymm5,$20
        vperm2f128 ymm11,ymm4,ymm5,$31
        vunpcklps ymm4,ymm10,ymm11
        vunpckhps ymm5,ymm10,ymm11
        vperm2f128 ymm0,ymm4,ymm5,$20
        vperm2f128 ymm1,ymm4,ymm5,$31
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
  k_f32_half: dd 8 dup 0.5
  k_f32_sin_coefficients: dd -0.16666667,0.0083333310,-0.00019840874,2.7525562e-06,-2.3889859e-08,-0.16665852,0.0083139502,-0.00018524670
  k_f32_cos_coefficients: dd -0.5,0.041666638,-0.0013888378,2.4760495e-05,-2.6051615e-07,-0.49992746,0.041493919,-0.0012712436
  k_i32_negative_zero: dd 8 dup 0x80000000
  k_i32_negative_zero_x0: dd 0x80000000,0,0,0,0,0,0,0
  k_i32_negative_zero_y0: dd 0,0x80000000,0,0,0,0,0,0
  k_i32_negative_zero_z0: dd 0,0,0x80000000,0,0,0,0,0
  k_f32_one: dd 8 dup 1.0
  k_f32_negative_one: dd 8 dup -1.0
  k_i32_perm_x0_y1: dd 0,0,0,0,5,5,5,5
  k_i32_perm_z0_w1: dd 2,2,2,2,7,7,7,7
  k_i32_perm_y0_x1: dd 1,1,1,1,4,4,4,4
  k_i32_perm_w0_z1: dd 3,3,3,3,6,6,6,6

end if
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
