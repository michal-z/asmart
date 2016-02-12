;=============================================================================
FALIGN
am_sinf:
;-----------------------------------------------------------------------------
macro AM_SINF {
        movaps xmm7,xmm0
        movss xmm1,[k4_i32_7fffffff]
        movss xmm2,[k4_i32_80000000]
        movss xmm3,[k4_f32_2_div_pi]
        andps xmm0,xmm1
        andps xmm7,xmm2
        mulss xmm0,xmm3
        pxor xmm3,xmm3
        movd xmm5,[k4_i32_1]
        movss xmm4,[k4_f32_1]
        cvttps2dq xmm2,xmm0
        pand xmm5,xmm2
        movd xmm1,[k4_i32_2]
        pcmpeqd xmm5,xmm3
        cvtdq2ps xmm6,xmm2
        pand xmm2,xmm1
        pslld xmm2,30
        subss xmm0,xmm6
        movss xmm3,[k4_f32_sincos_p3]
        minss xmm0,xmm4
        subss xmm4,xmm0
        andps xmm0,xmm5
        andnps xmm5,xmm4
        orps xmm0,xmm5
        movaps xmm1,xmm0
        movss xmm4,[k4_f32_sincos_p2]
        mulss xmm0,xmm0
        xorps xmm2,xmm7
        movss xmm5,[k4_f32_sincos_p1]
        orps xmm1,xmm2
        movaps xmm7,xmm0
        mulss xmm0,xmm3
        movss xmm6,[k4_f32_sincos_p0]
        addss xmm0,xmm4
        mulss xmm0,xmm7
        addss xmm0,xmm5
        mulss xmm0,xmm7
        addss xmm0,xmm6
        mulss xmm0,xmm1 }

        AM_SINF
        ret
;=============================================================================
FALIGN
am_cosf:
;-----------------------------------------------------------------------------
macro AM_COSF {
        movss xmm1,[k4_i32_7fffffff]
        movss xmm2,[k4_f32_pi_div_2]
        movss xmm3,[k4_f32_2_div_pi]
        andps xmm0,xmm1
        addss xmm0,xmm2
        mulss xmm0,xmm3
        pxor xmm3,xmm3
        movd xmm5,[k4_i32_1]
        movss xmm4,[k4_f32_1]
        cvttps2dq xmm2,xmm0
        pand xmm5,xmm2
        movd xmm1,[k4_i32_2]
        pcmpeqd xmm5,xmm3
        cvtdq2ps xmm6,xmm2
        pand xmm2,xmm1
        pslld xmm2,30
        subss xmm0,xmm6
        movss xmm3,[k4_f32_sincos_p3]
        minss xmm0,xmm4
        subss xmm4,xmm0
        andps xmm0,xmm5
        andnps xmm5,xmm4
        orps xmm0,xmm5
        movaps xmm1,xmm0
        movss xmm4,[k4_f32_sincos_p2]
        mulss xmm0,xmm0
        movss xmm5,[k4_f32_sincos_p1]
        orps xmm1,xmm2
        movaps xmm7,xmm0
        mulss xmm0,xmm3
        movss xmm6,[k4_f32_sincos_p0]
        addss xmm0,xmm4
        mulss xmm0,xmm7
        addss xmm0,xmm5
        mulss xmm0,xmm7
        addss xmm0,xmm6
        mulss xmm0,xmm1 }

        AM_COSF
        ret
;=============================================================================
macro VSHUFPS_MM_SHUFFLE d*,s0*,s1*,fp3*,fp2*,fp1*,fp0* {
        vshufps d,s0,s1,(fp3 shl 6) or (fp2 shl 4) or (fp1 shl 2) or fp0 }
;=============================================================================
FALIGN
matrix_mul:
;-----------------------------------------------------------------------------
macro MATRIX_MUL dst*,m0*,m1* {
        vmovaps xmm8,[m0]
        vmovaps xmm9,[m0+16]
        vmovaps xmm10,[m0+32]
        vmovaps xmm11,[m0+48]
        vmovaps xmm4,[m1]
        vmovaps xmm5,[m1+16]
        vmovaps xmm6,[m1+32]
        vmovaps xmm7,[m1+48]
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
        vmovaps [dst],xmm0
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
        vmovaps [dst+16],xmm0
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
        vmovaps [dst+32],xmm0
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
        vmovaps [dst+48],xmm0 }

        MATRIX_MUL rcx,rdx,r8
        ret
;=============================================================================
FALIGN
matrix_mul_transpose:
;-----------------------------------------------------------------------------
macro MATRIX_MUL_TRANSPOSE dst*,m0*,m1* {
        vmovaps xmm8,[m0]
        vmovaps xmm9,[m0+16]
        vmovaps xmm10,[m0+32]
        vmovaps xmm11,[m0+48]
        vmovaps xmm4,[m1]
        vmovaps xmm5,[m1+16]
        vmovaps xmm6,[m1+32]
        vmovaps xmm7,[m1+48]
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
        vmovaps [dst],xmm0
        vmovaps [dst+16],xmm1
        vmovaps [dst+32],xmm2
        vmovaps [dst+48],xmm3 }

        MATRIX_MUL_TRANSPOSE rcx,rdx,r8
        ret
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
