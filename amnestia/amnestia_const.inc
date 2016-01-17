align 4
  k_f32_1 dd 1.0

align 16
  k4_0 dd 4 dup 0
  k4_f32_0p5 dd 4 dup 0.5
  k4_i32_1 dd 4 dup 1
  k4_f32_1 dd 4 dup 1.0
  k4_f32_2 dd 4 dup 2.0
  k4_f32_m1 dd 4 dup -1.0
  k4_i32_2 dd 4 dup 2
  k4_i32_7 dd 4 dup 7
  k4_f32_pi dd 4 dup 3.1415926535897
  k4_f32_2pi dd 4 dup 6.2831853

  k4_i32_min_norm_pos    dd 4 dup 0x00800000
  k4_i32_00800000        dd 4 dup 0x00800000

  k4_i32_not_mant_mask   dd 4 dup not 0x7f800000
  k4_i32_7f800000        dd 4 dup not 0x7f800000

  k4_i32_0000007f        dd 4 dup 0x7f

  k4_i32_sign_mask       dd 4 dup 0x80000000
  k4_i32_80000000        dd 4 dup 0x80000000

  k4_i32_not_sign_mask   dd 4 dup not 0x80000000
  k4_i32_7fffffff        dd 4 dup 0x7fffffff

  k4_f32_2_div_pi        dd 4 dup 0.636619772
  k4_f32_4_div_pi        dd 4 dup 1.2732395
  k4_f32_pi_div_2        dd 4 dup 1.5707963
  k4_f32_pi_div_4        dd 4 dup 0.7853982
  k4_i32_mask_w          dd 0x00000000,0x00000000,0x00000000,0xffffffff
  k4_i32_0_0_0_ffffffff  dd 0x00000000,0x00000000,0x00000000,0xffffffff

  k4_f32_exp_hi          dd 4 dup 88.3762626647949
  k4_f32_exp_lo          dd 4 dup -88.3762626647949
  k4_f32_exp_rln2        dd 4 dup 1.4426950408889634073599
  k4_f32_exp_p0          dd 4 dup 1.26177193074810590878e-4
  k4_f32_exp_p1          dd 4 dup 3.02994407707441961300e-2
  k4_f32_exp_q0          dd 4 dup 3.00198505138664455042e-6
  k4_f32_exp_q1          dd 4 dup 2.52448340349684104192e-3
  k4_f32_exp_q2          dd 4 dup 2.27265548208155028766e-1
  k4_f32_exp_q3          dd 4 dup 2.00000000000000000009e0
  k4_f32_exp_c1          dd 4 dup 6.93145751953125e-1
  k4_f32_exp_c2          dd 4 dup 1.42860682030941723212e-6

  k4_f32_log_p0      dd 4 dup -7.89580278884799154124e-1
  k4_f32_log_p1      dd 4 dup 1.63866645699558079767e1
  k4_f32_log_p2      dd 4 dup -6.41409952958715622951e1
  k4_f32_log_q0      dd 4 dup -3.56722798256324312549e1
  k4_f32_log_q1      dd 4 dup 3.12093766372244180303e2
  k4_f32_log_q2      dd 4 dup -7.69691943550460008604e2
  k4_f32_log_c0      dd 4 dup 0.693147180559945

  k4_f32_exp2_hi     dd 4 dup 127.4999961853
  k4_f32_exp2_lo     dd 4 dup -127.4999961853
  k4_f32_exp2_p0     dd 4 dup 2.30933477057345225087e-2
  k4_f32_exp2_p1     dd 4 dup 2.02020656693165307700e1
  k4_f32_exp2_p2     dd 4 dup 1.51390680115615096133e3
  k4_f32_exp2_q0     dd 4 dup 2.33184211722314911771e2
  k4_f32_exp2_q1     dd 4 dup 4.36821166879210612817e3

  k4_f32_log2_c0     dd 4 dup 1.44269504088896340735992

  k4_f32_sincos_p0   dd 4 dup 0.15707963267948963959e1
  k4_f32_sincos_p1   dd 4 dup -0.64596409750621907082e0
  k4_f32_sincos_p2   dd 4 dup 0.7969262624561800806e-1
  k4_f32_sincos_p3   dd 4 dup -0.468175413106023168e-2

  k4_f32_tan_p0      dd 4 dup -1.79565251976484877988e7
  k4_f32_tan_p1      dd 4 dup 1.15351664838587416140e6
  k4_f32_tan_p2      dd 4 dup -1.30936939181383777646e4
  k4_f32_tan_q0      dd 4 dup -5.38695755929454629881e7
  k4_f32_tan_q1      dd 4 dup 2.50083801823357915839e7
  k4_f32_tan_q2      dd 4 dup -1.32089234440210967447e6
  k4_f32_tan_q3      dd 4 dup 1.36812963470692954678e4
  k4_f32_tan_poleval dd 4 dup 3.68935e19

  k4_f32_atan_t0     dd 4 dup -0.91646118527267623468e-1
  k4_f32_atan_t1     dd 4 dup -0.13956945682312098640e1
  k4_f32_atan_t2     dd 4 dup -0.94393926122725531747e2
  k4_f32_atan_t3     dd 4 dup 0.12888383034157279340e2
  k4_f32_atan_s0     dd 4 dup 0.12797564625607904396e1
  k4_f32_atan_s1     dd 4 dup 0.21972168858277355914e1
  k4_f32_atan_s2     dd 4 dup 0.68193064729268275701e1
  k4_f32_atan_s3     dd 4 dup 0.28205206687035841409e2