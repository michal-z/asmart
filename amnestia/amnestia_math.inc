macro isinf {
        movaps  xmm7,xmm0
        movss   xmm1,[k4_i32_7fffffff]
        movss   xmm2,[k4_i32_80000000]
        movss   xmm3,[k4_f32_2_div_pi]
        andps   xmm0,xmm1
        andps   xmm7,xmm2
        mulss   xmm0,xmm3
        pxor    xmm3,xmm3
        movd    xmm5,[k4_i32_1]
        movss   xmm4,[k4_f32_1]
        cvttps2dq xmm2,xmm0
        pand    xmm5,xmm2
        movd    xmm1,[k4_i32_2]
        pcmpeqd xmm5,xmm3
        cvtdq2ps xmm6,xmm2
        pand    xmm2,xmm1
        pslld   xmm2,30
        subss   xmm0,xmm6
        movss   xmm3,[k4_f32_sincos_p3]
        minss   xmm0,xmm4
        subss   xmm4,xmm0
        andps   xmm0,xmm5
        andnps  xmm5,xmm4
        orps    xmm0,xmm5
        movaps  xmm1,xmm0
        movss   xmm4,[k4_f32_sincos_p2]
        mulss   xmm0,xmm0
        xorps   xmm2,xmm7
        movss   xmm5,[k4_f32_sincos_p1]
        orps    xmm1,xmm2
        movaps  xmm7,xmm0
        mulss   xmm0,xmm3
        movss   xmm6,[k4_f32_sincos_p0]
        addss   xmm0,xmm4
        mulss   xmm0,xmm7
        addss   xmm0,xmm5
        mulss   xmm0,xmm7
        addss   xmm0,xmm6
        mulss   xmm0,xmm1 }
falign
sinf:
        isinf
        ret