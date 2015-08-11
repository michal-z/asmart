if program_section = 'code'
;========================================================================
; in: <ymm0> angle in radians
; out: <ymm0> sin(ymm0), <ymm1> cos(ymm0)
;------------------------------------------------------------------------
align 32
sincos:
        $vandps ymm0,ymm0,[.k_inv_sign_mask]
        $vandps ymm7,ymm0,[.k_sign_mask]
        $vmulps ymm0,ymm0,[.k_2_div_pi]
        $vpxor ymm3,ymm3,ymm3
        $vmovdqa ymm8,[k_1]
        $vmovaps ymm4,[k_1_0]
        $vcvttps2dq ymm2,ymm0
        $vpand ymm5,ymm8,ymm2
        $vpcmpeqd ymm5,ymm5,ymm3
        $vmovdqa ymm1,[k_2]
        $vcvtdq2ps ymm6,ymm2
        $vpaddd ymm3,ymm8,ymm2
        $vpand ymm2,ymm2,ymm1
        $vpand ymm3,ymm3,ymm1
        $vsubps ymm0,ymm0,ymm6
        $vpslld ymm2,ymm2,30
        $vminps ymm0,ymm0,ymm4
        $vsubps ymm4,ymm4,ymm0
        $vpslld ymm3,ymm3,30
        $vxorps ymm2,ymm2,ymm7
        $vandps ymm6,ymm4,ymm5
        $vandnps ymm7,ymm5,ymm0
        $vandps ymm0,ymm0,ymm5
        $vandnps ymm5,ymm5,ymm4
        $vmovaps ymm8,[.k_p3]
        $vmovaps ymm9,[.k_p2]
        $vmovaps ymm10,[.k_p1]
        $vmovaps ymm11,[.k_p0]
        $vorps ymm6,ymm6,ymm7
        $vorps ymm0,ymm0,ymm5
        $vorps ymm1,ymm0,ymm2
        $vorps ymm7,ymm6,ymm3
        $vmulps ymm2,ymm0,ymm0
        $vmulps ymm3,ymm6,ymm6
        $vfmadd132ps ymm0,ymm9,ymm8
        $vfmadd132ps ymm6,ymm9,ymm8
        $vfmadd132ps ymm0,ymm10,ymm2
        $vfmadd132ps ymm6,ymm10,ymm3
        $vfmadd132ps ymm0,ymm11,ymm2
        $vfmadd132ps ymm6,ymm11,ymm3
        $vmulps ymm0,ymm0,ymm1
        $vmulps ymm1,ymm6,ymm7
        $ret
;========================================================================
; in: <ymm0,ymm1,ymm2> position
; out: <ymm0> distance to the nearest object
;------------------------------------------------------------------------
align 32
nearest_distance:
        $vsubps ymm3,ymm0,[object.param_x+$000]
        $vsubps ymm6,ymm0,[object.param_x+$020]
        $vsubps ymm9,ymm0,[object.param_x+$040]
        $vsubps ymm4,ymm1,[object.param_y+$000]
        $vsubps ymm7,ymm1,[object.param_y+$020]
        $vsubps ymm10,ymm1,[object.param_y+$040]
        $vsubps ymm5,ymm2,[object.param_z+$000]
        $vsubps ymm8,ymm2,[object.param_z+$020]
        $vsubps ymm11,ymm2,[object.param_z+$040]
        $vmulps ymm3,ymm3,ymm3
        $vmulps ymm6,ymm6,ymm6
        $vmulps ymm9,ymm9,ymm9
        $vfmadd231ps ymm3,ymm4,ymm4
        $vfmadd231ps ymm6,ymm7,ymm7
        $vfmadd231ps ymm9,ymm10,ymm10
        $vfmadd231ps ymm3,ymm5,ymm5
        $vfmadd231ps ymm6,ymm8,ymm8
        $vfmadd231ps ymm9,ymm11,ymm11
        $vaddps ymm5,ymm1,[object.param_w+$060]
        $vsqrtps ymm3,ymm3
        $vsqrtps ymm6,ymm6
        $vsqrtps ymm9,ymm9
        $vmovaps ymm10,[object.param_w+$000]
        $vmovaps ymm11,[object.param_w+$020]
        $vmovaps ymm12,[object.param_w+$040]
        $vsubps ymm3,ymm3,ymm10
        $vsubps ymm6,ymm6,ymm11
        $vsubps ymm9,ymm9,ymm12
        $vminps ymm0,ymm5,ymm3
        $vminps ymm0,ymm0,ymm6
        $vminps ymm0,ymm0,ymm9
        $ret
;========================================================================
; in: <ymm0,ymm1,ymm2> position
; out: <ymm0> id of the nearest object
;------------------------------------------------------------------------
align 32
nearest_object:
        $vsubps ymm3,ymm0,[object.param_x+$000]
        $vsubps ymm6,ymm0,[object.param_x+$020]
        $vsubps ymm9,ymm0,[object.param_x+$040]
        $vsubps ymm4,ymm1,[object.param_y+$000]
        $vsubps ymm7,ymm1,[object.param_y+$020]
        $vsubps ymm10,ymm1,[object.param_y+$040]
        $vsubps ymm5,ymm2,[object.param_z+$000]
        $vsubps ymm8,ymm2,[object.param_z+$020]
        $vsubps ymm11,ymm2,[object.param_z+$040]
        $vmulps ymm3,ymm3,ymm3
        $vmulps ymm6,ymm6,ymm6
        $vmulps ymm9,ymm9,ymm9
        $vfmadd231ps ymm3,ymm4,ymm4
        $vfmadd231ps ymm6,ymm7,ymm7
        $vfmadd231ps ymm9,ymm10,ymm10
        $vfmadd231ps ymm3,ymm5,ymm5
        $vfmadd231ps ymm6,ymm8,ymm8
        $vfmadd231ps ymm9,ymm11,ymm11
        $vaddps ymm5,ymm1,[object.param_w+$060]         ; ymm5 = object3_distance
        $vsqrtps ymm2,ymm3
        $vsqrtps ymm3,ymm6
        $vsqrtps ymm4,ymm9
        $vmovaps ymm10,[object.param_w+$000]
        $vmovaps ymm11,[object.param_w+$020]
        $vmovaps ymm12,[object.param_w+$040]
        $vmovaps ymm6,[object.id+$000]
        $vmovaps ymm7,[object.id+$020]
        $vmovaps ymm8,[object.id+$040]
        $vmovaps ymm9,[object.id+$060]
        $vsubps ymm2,ymm2,ymm10                         ; ymm2 = object0_distance
        $vsubps ymm3,ymm3,ymm11                         ; ymm3 = object1_distance
        $vsubps ymm4,ymm4,ymm12                         ; ymm4 = object2_distance
        $vcmpltps ymm10,ymm5,ymm2
        $vminps ymm0,ymm5,ymm2
        $vblendvps ymm1,ymm6,ymm9,ymm10
        $vcmpltps ymm10,ymm0,ymm3
        $vminps ymm0,ymm0,ymm3
        $vblendvps ymm1,ymm7,ymm1,ymm10
        $vcmpltps ymm10,ymm0,ymm4
        $vblendvps ymm0,ymm8,ymm1,ymm10
        $ret
;========================================================================
; in: <ymm0,ymm1,ymm2> ray origin, <ymm3,ymm4,ymm5> ray direction
; out: <ymm0> distance to the nearest object,
;      <ymm1> id of the nearest object, <ymm2,ymm3,ymm4> ray hit position
;------------------------------------------------------------------------
align 32
cast_ray:
    .k_stack_size = 10*32+16
        $push rsi
        $sub rsp,.k_stack_size
        $vmovaps ymm6,[k_1_0]
        $vmovaps [rsp+$000],ymm0                        ; [rsp+$000] = ray_org_x
        $vmovaps [rsp+$020],ymm1                        ; [rsp+$020] = ray_org_y
        $vmovaps [rsp+$040],ymm2                        ; [rsp+$040] = ray_org_z
        $vmovaps [rsp+$0c0],ymm6                        ; [rsp+$0c0] = distance
        $vmovaps [rsp+$060],ymm3                        ; [rsp+$060] = ray_dir_x
        $vmovaps [rsp+$080],ymm4                        ; [rsp+$080] = ray_dir_y
        $vmovaps [rsp+$0a0],ymm5                        ; [rsp+$0a0] = ray_dir_z
        $mov esi,128
    align 32
    .march:
        $vfmadd231ps ymm0,ymm6,ymm3
        $vfmadd231ps ymm1,ymm6,ymm4
        $vfmadd231ps ymm2,ymm6,ymm5
        $vmovaps [rsp+$0e0],ymm0                        ; [rsp+$0e0] = pos_x
        $vmovaps [rsp+$100],ymm1                        ; [rsp+$100] = pos_y
        $vmovaps [rsp+$120],ymm2                        ; [rsp+$120] = pos_z
        $call nearest_distance
        $vmovaps ymm6,[rsp+$0c0]                        ; ymm6 = distance
        $vcmpltps ymm7,ymm0,[k_hit_distance]            ; ymm7 = nearest_distance() < k_hit_distance
        $vcmpgtps ymm8,ymm6,[k_view_distance]           ; ymm8 = distance > k_view_distance
        $vorps ymm7,ymm7,ymm8
        $vmovmskps eax,ymm7
        $cmp eax,$ff
        $je .march_end
        $vandnps ymm0,ymm7,ymm0
        $vaddps ymm6,ymm6,ymm0
        $vmovaps ymm0,[rsp+$000]                        ; ymm0 = ray_org_x
        $vmovaps ymm1,[rsp+$020]                        ; ymm1 = ray_org_y
        $vmovaps ymm2,[rsp+$040]                        ; ymm2 = ray_org_z
        $vmovaps ymm3,[rsp+$060]                        ; ymm3 = ray_dir_x
        $vmovaps ymm4,[rsp+$080]                        ; ymm4 = ray_dir_y
        $vmovaps ymm5,[rsp+$0a0]                        ; ymm5 = ray_dir_z
        $vmovaps [rsp+$0c0],ymm6                        ; distance = ymm6
        $sub esi,1
        $jnz .march
    .march_end:
        $vmovaps ymm0,[rsp+$0e0]                        ; ymm0 = pos_x
        $vmovaps ymm1,[rsp+$100]                        ; ymm1 = pos_y
        $vmovaps ymm2,[rsp+$120]                        ; ymm2 = pos_z
        $call nearest_object
        $vmovaps ymm2,[rsp+$0e0]                        ; ymm2 = pos_x
        $vmovaps ymm3,[rsp+$100]                        ; ymm3 = pos_y
        $vmovaps ymm4,[rsp+$120]                        ; ymm4 = pos_z
        $vmovaps ymm1,ymm0                              ; ymm1 = object_id
        $vmovaps ymm0,[rsp+$0c0]                        ; ymm0 = distance
        $add rsp,.k_stack_size
        $pop rsi
        $ret
;========================================================================
; in: <ymm0,ymm1,ymm2> ray origin, <ymm3,ymm4,ymm5> ray direction
; out: <ymm0> shadow factor
;------------------------------------------------------------------------
align 32
cast_shadow_ray:
    .k_stack_size = 8*32+16
        $push rsi
        $sub rsp,.k_stack_size
        $vmovaps ymm6,[k_1_0]
        $vmovaps [rsp+$0e0],ymm6                        ; [rsp+$0e0] = shadow_factor = 1.0
        $vmovaps ymm6,[k_0_02]
        $vmovaps [rsp+$000],ymm0                        ; [rsp+$000] = ray_org_x
        $vmovaps [rsp+$020],ymm1                        ; [rsp+$020] = ray_org_y
        $vmovaps [rsp+$040],ymm2                        ; [rsp+$040] = ray_org_z
        $vmovaps [rsp+$0c0],ymm6                        ; [rsp+$0c0] = distance
        $vmovaps [rsp+$060],ymm3                        ; [rsp+$060] = ray_dir_x
        $vmovaps [rsp+$080],ymm4                        ; [rsp+$080] = ray_dir_y
        $vmovaps [rsp+$0a0],ymm5                        ; [rsp+$0a0] = ray_dir_z
        $mov esi,128
    align 32
    .march:
        $vfmadd231ps ymm0,ymm6,ymm3
        $vfmadd231ps ymm1,ymm6,ymm4
        $vfmadd231ps ymm2,ymm6,ymm5
        $call nearest_distance
        $vmovaps ymm6,[rsp+$0c0]                        ; ymm6 = distance
        $vcmpltps ymm7,ymm0,[k_hit_distance]            ; ymm7 = nearest_distance() < k_hit_distance
        $vcmpgtps ymm8,ymm6,[k_view_distance]           ; ymm8 = distance > k_view_distance
        $vorps ymm7,ymm7,ymm8
        $vmovmskps eax,ymm7
        $cmp eax,$ff
        $je .march_end
        $vrcpps ymm10,ymm6
        $vmulps ymm10,ymm0,ymm10
        $vmulps ymm10,ymm10,[k_shadow_hardness]
        $vminps ymm10,ymm10,[rsp+$0e0]                  ; ymm10 = min(ymm10, shadow_factor)
        $vmovaps [rsp+$0e0],ymm10                       ; shadow_factor = ymm10
        $vandnps ymm0,ymm7,ymm0
        $vaddps ymm6,ymm6,ymm0
        $vmovaps ymm0,[rsp+$000]                        ; ymm0 = ray_org_x
        $vmovaps ymm1,[rsp+$020]                        ; ymm1 = ray_org_y
        $vmovaps ymm2,[rsp+$040]                        ; ymm2 = ray_org_z
        $vmovaps ymm3,[rsp+$060]                        ; ymm3 = ray_dir_x
        $vmovaps ymm4,[rsp+$080]                        ; ymm4 = ray_dir_y
        $vmovaps ymm5,[rsp+$0a0]                        ; ymm5 = ray_dir_z
        $vmovaps [rsp+$0c0],ymm6                        ; distance = ymm6
        $sub esi,1
        $jnz .march
    .march_end:
        $vmovaps ymm0,[rsp+$0e0]                        ; ymm0 = shadow_factor
        $add rsp,.k_stack_size
        $pop rsi
        $ret
;========================================================================
; in: <ymm2,ymm3,ymm4> position, <ymm5> k_normal_eps
; out: <ymm0,ymm1,ymm2> normal $vector at input position
;------------------------------------------------------------------------
macro calculate_normal_vector
{
        $vsubps ymm0,ymm2,ymm5                          ; ymm0 = hit_pos_x-k_normal_pos
        $vaddps ymm6,ymm2,ymm5                          ; ymm6 = hit_pos_x+k_normal_eps
        $vsubps ymm7,ymm3,ymm5                          ; ymm7 = hit_pos_y-k_normal_eps
        $vaddps ymm8,ymm3,ymm5                          ; ymm8 = hit_pos_y+k_normal_eps
        $vsubps ymm9,ymm4,ymm5                          ; ymm9 = hit_pos_z-k_normal_eps
        $vaddps ymm10,ymm4,ymm5                         ; ymm10 = hit_pos_z+k_normal_eps
        $vmovaps ymm1,ymm3                              ; ymm1 = hit_pos_y
        $vmovaps ymm2,ymm4                              ; ymm2 = hit_pos_z
        $vmovaps [rsp+$0a0],ymm6                        ; [rsp+$0a0] = hit_pos_x+k_normal_eps
        $vmovaps [rsp+$0c0],ymm7                        ; [rsp+$0c0] = hit_pos_y-k_normal_eps
        $vmovaps [rsp+$0e0],ymm8                        ; [rsp+$0e0] = hit_pos_y+k_normal_eps
        $vmovaps [rsp+$100],ymm9                        ; [rsp+$100] = hit_pos_z-k_normal_eps
        $vmovaps [rsp+$120],ymm10                       ; [rsp+$120] = hit_pos_z+k_normal_eps
        $call nearest_distance                          ; ymm0 = nearest_distance(x-eps,y,z)
        $vmovaps ymm1,[rsp+$060]                        ; ymm1 = hit_pos_y
        $vmovaps ymm2,[rsp+$080]                        ; ymm2 = hit_pos_z
        $vmovaps [rsp+$140],ymm0                        ; [rsp+$140] = nearest_distance(x-eps,y,z)
        $vmovaps ymm0,[rsp+$0a0]                        ; ymm0 = hit_pos_x+k_normal_eps
        $call nearest_distance                          ; ymm0 = nearest_distance(x+eps,y,z)
        $vmovaps ymm1,[rsp+$0c0]                        ; ymm1 = hit_pos_y-k_normal_eps
        $vmovaps ymm2,[rsp+$080]                        ; ymm2 = hit_pos_z
        $vmovaps [rsp+$160],ymm0                        ; [rsp+$160] = nearest_distance(x+eps,y,z)
        $vmovaps ymm0,[rsp+$040]                        ; ymm0 = hit_pos_x
        $call nearest_distance                          ; ymm0 = nearest_distance(x,y-eps,z)
        $vmovaps ymm1,[rsp+$0e0]                        ; ymm1 = hit_pos_y+k_normal_eps
        $vmovaps ymm2,[rsp+$080]                        ; ymm2 = hit_pos_z
        $vmovaps [rsp+$180],ymm0                        ; [rsp+$180] = nearest_distance(x,y-eps,z)
        $vmovaps ymm0,[rsp+$040]                        ; ymm0 = hit_pos_x
        $call nearest_distance                          ; ymm0 = nearest_distance(x,y+eps,z)
        $vmovaps ymm1,[rsp+$060]                        ; ymm1 = hit_pos_y
        $vmovaps ymm2,[rsp+$100]                        ; ymm2 = hit_pos_z-k_normal_eps
        $vmovaps [rsp+$1a0],ymm0                        ; [rsp+$1a0] = nearest_distance(x,y+eps,z)
        $vmovaps ymm0,[rsp+$040]                        ; ymm0 = hit_pos_x
        $call nearest_distance                          ; ymm0 = nearest_distance(x,y,z-eps)
        $vmovaps ymm1,[rsp+$060]                        ; ymm1 = hit_pos_y
        $vmovaps ymm2,[rsp+$120]                        ; ymm2 = hit_pos_z+k_normal_eps
        $vmovaps [rsp+$1c0],ymm0                        ; [rsp+$1c0] = nearest_distance(x,y,z-eps)
        $vmovaps ymm0,[rsp+$040]                        ; ymm0 = hit_pos_x
        $call nearest_distance                          ; ymm0 = nearest_distance(x,y,z+eps)
        $vsubps ymm2,ymm0,[rsp+$1c0]
        $vmovaps ymm0,[rsp+$160]
        $vmovaps ymm1,[rsp+$1a0]
        $vsubps ymm0,ymm0,[rsp+$140]
        $vsubps ymm1,ymm1,[rsp+$180]                    ; (ymm0,ymm1,ymm2) = normal_vector
}
;========================================================================
; in: <ymm0,ymm1,ymm2> ray origin, <ymm3,ymm4,ymm5> ray direction
; out: <ymm0,ymm1,ymm2> rgb color
;------------------------------------------------------------------------
align 32
compute_color:
    .k_stack_size = 16*32+24
        $sub rsp,.k_stack_size
        $call cast_ray
        $vmovaps ymm5,[k_view_distance]
        $vcmpltps ymm11,ymm0,ymm5                       ; ymm11 = hit_mask
        $vmovmskps eax,ymm11
        $test eax,eax
        $jz .no_hit
        $vmovaps ymm7,[k_1_0]
        $vrcpps ymm5,ymm5
        $vmulps ymm5,ymm0,ymm5
        $vsubps ymm5,ymm7,ymm5
        $vmovaps [rsp+$1e0],ymm5                        ; [rsp+$1e0] = fog_factor
        $vmovaps ymm5,[k_normal_eps]
        $vmovaps [rsp+$020],ymm1                        ; [rsp+$020] = hit_id
        $vmovaps [rsp+$040],ymm2                        ; [rsp+$040] = pos_x
        $vmovaps [rsp+$060],ymm3                        ; [rsp+$060] = pos_y
        $vmovaps [rsp+$080],ymm4                        ; [rsp+$080] = pos_z
        $vmovaps [rsp+$000],ymm11                       ; [rsp+$000] = hit_mask
        calculate_normal_vector                         ; (ymm0,ymm1,ymm2) = normal_vector
        $vmovaps ymm9,[rsp+$040]                        ; ymm9 = hit_pos_x
        $vmovaps ymm10,[rsp+$060]                       ; ymm10 = hit_pos_y
        $vmovaps ymm11,[rsp+$080]                       ; ymm11 = hit_pos_z
        $vmovaps ymm3,[light0_position+$000]
        $vmovaps ymm4,[light0_position+$020]
        $vmovaps ymm5,[light0_position+$040]
        $vmovaps ymm6,[light1_position+$000]
        $vmovaps ymm7,[light1_position+$020]
        $vmovaps ymm8,[light1_position+$040]
        $vsubps ymm3,ymm3,ymm9
        $vsubps ymm4,ymm4,ymm10
        $vsubps ymm5,ymm5,ymm11                         ; (ymm3,ymm4,ymm5) = light0_vector
        $vsubps ymm6,ymm6,ymm9
        $vsubps ymm7,ymm7,ymm10
        $vsubps ymm8,ymm8,ymm11                         ; (ymm6,ymm7,ymm8) = light1_vector
        $vmulps ymm12,ymm0,ymm0
        $vmulps ymm13,ymm3,ymm3
        $vmulps ymm14,ymm6,ymm6
        $vfmadd231ps ymm12,ymm1,ymm1
        $vfmadd231ps ymm13,ymm4,ymm4
        $vfmadd231ps ymm14,ymm7,ymm7
        $vfmadd231ps ymm12,ymm2,ymm2
        $vfmadd231ps ymm13,ymm5,ymm5
        $vfmadd231ps ymm14,ymm8,ymm8
        $vrsqrtps ymm12,ymm12
        $vrsqrtps ymm13,ymm13
        $vrsqrtps ymm14,ymm14
        $vmulps ymm0,ymm0,ymm12
        $vmulps ymm1,ymm1,ymm12
        $vmulps ymm2,ymm2,ymm12                         ; (ymm0,ymm1,ymm2) = normalize(normal_vector)
        $vmulps ymm3,ymm3,ymm13
        $vmulps ymm4,ymm4,ymm13
        $vmulps ymm5,ymm5,ymm13                         ; (ymm3,ymm4,ymm5) = normalize(light0_vector)
        $vmulps ymm6,ymm6,ymm14
        $vmulps ymm7,ymm7,ymm14
        $vmulps ymm8,ymm8,ymm14                         ; (ymm6,ymm7,ymm8) = normalize(light1_vector)
        $vxorps ymm14,ymm14,ymm14
        $vmulps ymm12,ymm0,ymm3
        $vmulps ymm13,ymm0,ymm6
        $vfmadd231ps ymm12,ymm1,ymm4
        $vfmadd231ps ymm13,ymm1,ymm7
        $vfmadd231ps ymm12,ymm2,ymm5
        $vfmadd231ps ymm13,ymm2,ymm8
        $vmaxps ymm12,ymm12,ymm14                       ; ymm12 = n_dot_l0
        $vmaxps ymm13,ymm13,ymm14                       ; ymm13 = n_dot_l1
        $vmovaps [rsp+$0a0],ymm12                       ; [rsp+$0a0] = n_dot_l0
        $vmovaps [rsp+$0c0],ymm13                       ; [rsp+$0c0] = n_dot_l1
        $vmovaps ymm0,ymm9
        $vmovaps ymm1,ymm10
        $vmovaps ymm2,ymm11
        $vmovaps [rsp+$0e0],ymm6                        ; [rsp+$0e0] = light1_vec_x
        $vmovaps [rsp+$100],ymm7                        ; [rsp+$100] = light1_vec_y
        $vmovaps [rsp+$120],ymm8                        ; [rsp+$120] = light1_vec_z
        $call cast_shadow_ray
        $vmovaps [rsp+$140],ymm0                        ; [rsp+$140] = light0_shadow
        $vmovaps ymm0,[rsp+$040]                        ; ymm0 = hit_pos_x
        $vmovaps ymm1,[rsp+$060]                        ; ymm1 = hit_pos_y
        $vmovaps ymm2,[rsp+$080]                        ; ymm2 = hit_pos_z
        $vmovaps ymm3,[rsp+$0e0]                        ; ymm3 = light1_vec_x
        $vmovaps ymm4,[rsp+$100]                        ; ymm4 = light1_vec_y
        $vmovaps ymm5,[rsp+$120]                        ; ymm5 = light1_vec_z
        $call cast_shadow_ray
        $vmulps ymm7,ymm0,[rsp+$0c0]                    ; ymm7 = ymm0 * n_dot_l1
        $vmovaps ymm6,[rsp+$0a0]                        ; ymm6 = n_dot_l0
        $vmulps ymm6,ymm6,[rsp+$140]                    ; ymm6 = ymm6 * light0_shadow
        $vmulps ymm7,ymm7,[light1_power]
        $vmulps ymm6,ymm6,[light0_power]
        $vaddps ymm6,ymm6,ymm7
        $vmovaps ymm7,[rsp+$1e0]                        ; ymm7 = fog_factor
        $vmovaps ymm8,[ambient]
        $vmovaps ymm11,[rsp+$000]                       ; ymm11 = hit_mask
        $lea rax,[object]
        $vmovdqa ymm1,[rsp+$020]                        ; ymm1 = hit_id
        $vpcmpeqd ymm2,ymm2,ymm2
        $vgatherdps ymm3,[rax+ymm1*4+(object.red-object)],ymm2
        $vpcmpeqd ymm2,ymm2,ymm2
        $vgatherdps ymm4,[rax+ymm1*4+(object.green-object)],ymm2
        $vpcmpeqd ymm2,ymm2,ymm2
        $vgatherdps ymm5,[rax+ymm1*4+(object.blue-object)],ymm2
        $vfmadd132ps ymm3,ymm8,ymm6
        $vfmadd132ps ymm4,ymm8,ymm6
        $vfmadd132ps ymm5,ymm8,ymm6
        $vmulps ymm3,ymm3,ymm7
        $vmulps ymm4,ymm4,ymm7
        $vmulps ymm5,ymm5,ymm7
        $vbroadcastss ymm7,[k_background_color]
        $vbroadcastss ymm8,[k_background_color+4]
        $vbroadcastss ymm9,[k_background_color+8]
        $vblendvps ymm0,ymm7,ymm3,ymm11
        $vblendvps ymm1,ymm8,ymm4,ymm11
        $vblendvps ymm2,ymm9,ymm5,ymm11
        $add rsp,.k_stack_size
        $ret
    align 32
    .no_hit:
        $vbroadcastss ymm0,[k_background_color]
        $vbroadcastss ymm1,[k_background_color+4]
        $vbroadcastss ymm2,[k_background_color+8]
        $add rsp,.k_stack_size
        $ret
;========================================================================
; Generate image tile by tile. Take one tile from the pool, compute
; it's color and then take next tile, and so on. Finish when all tiles
; are computed. This function is dispatched from all worker threads in
; parallel.
;------------------------------------------------------------------------
align 32
generate_image:
        $push rsi rdi rbx rbp r12 r13 r14 r15
        $sub rsp,24
    .for_each_tile:
        $mov eax,1
        $lock $xadd [tileidx],eax
        $cmp eax,k_tile_count
        $jae .return
        $xor edx,edx
        $mov ecx,k_tile_x_count
        $div ecx                                        ; eax = (k_tile_count / k_tile_x_count), edx = (k_tile_count % k_tile_x_count)
        $mov r14d,k_tile_width
        $mov r15d,k_tile_height
        $imul edx,r14d                                  ; edx = (k_tile_count % k_tile_x_count) * k_tile_width
        $imul eax,r15d                                  ; eax = (k_tile_count / k_tile_x_count) * k_tile_height
        $mov r12d,edx                                   ; r12d = x0
        $mov r13d,eax                                   ; r13d = y0
        $add r14d,r12d                                  ; r14d = x1 = x0 + k_tile_width
        $add r15d,r13d                                  ; r15d = y1 = y0 + k_tile_height
        $imul eax,k_win_width
        $add eax,edx
        $shl eax,2
        $mov rbx,[displayptr]
        $add rbx,rax
    align 32
    .for_each_4x2:
        $vxorps xmm0,xmm0,xmm0
        $vxorps xmm1,xmm1,xmm1
        $mov eax,r12d
        $mov edx,r13d
        $sub eax,k_win_width/2
        $sub edx,k_win_height/2
        $vcvtsi2ss xmm0,xmm0,eax                        ; (0, 0, 0, xf = (float)(x - k_win_width / 2))
        $vcvtsi2ss xmm1,xmm1,edx                        ; (0, 0, 0, yf = (float)(y - k_win_height / 2))
        $vbroadcastss ymm0,xmm0                         ; ymm0 = (xf ... xf)
        $vbroadcastss ymm1,xmm1                         ; ymm1 = (yf ... yf)
        $vaddps ymm0,ymm0,[.k_x_offset]
        $vaddps ymm1,ymm1,[.k_y_offset]
        $vmovaps ymm2,[.k_rd_z]
        $vmulps ymm0,ymm0,[.k_win_width_rcp]
        $vmulps ymm1,ymm1,[.k_win_height_rcp]
        $vmulps ymm3,ymm0,[eye_xaxis+$000]
        $vmulps ymm6,ymm0,[eye_xaxis+$020]
        $vmulps ymm9,ymm0,[eye_xaxis+$040]
        $vfmadd231ps ymm3,ymm1,[eye_yaxis+$000]
        $vfmadd231ps ymm6,ymm1,[eye_yaxis+$020]
        $vfmadd231ps ymm9,ymm1,[eye_yaxis+$040]
        $vfmadd231ps ymm3,ymm2,[eye_zaxis+$000]
        $vfmadd231ps ymm6,ymm2,[eye_zaxis+$020]
        $vfmadd231ps ymm9,ymm2,[eye_zaxis+$040]
        $vbroadcastss ymm0,[eye_position+0]
        $vbroadcastss ymm1,[eye_position+4]
        $vbroadcastss ymm2,[eye_position+8]
        $vmulps ymm10,ymm3,ymm3
        $vmulps ymm11,ymm6,ymm6
        $vmulps ymm12,ymm9,ymm9
        $vaddps ymm10,ymm10,ymm11
        $vaddps ymm10,ymm10,ymm12
        $vrsqrtps ymm10,ymm10
        $vmulps ymm3,ymm3,ymm10
        $vmulps ymm4,ymm6,ymm10
        $vmulps ymm5,ymm9,ymm10
        $call compute_color
        $vxorps ymm7,ymm7,ymm7                          ; ymm7 = (0 ... 0)
        $vmovaps ymm8,[k_1_0]                           ; ymm8 = (1.0 ... 1.0)
        $vmovaps ymm9,[k_255_0]                         ; ymm9 = (255.0 ... 255.0)
        $vmaxps ymm0,ymm0,ymm7
        $vmaxps ymm1,ymm1,ymm7
        $vmaxps ymm2,ymm2,ymm7
        $vminps ymm0,ymm0,ymm8
        $vminps ymm1,ymm1,ymm8
        $vminps ymm2,ymm2,ymm8
        $vmulps ymm0,ymm0,ymm9
        $vmulps ymm1,ymm1,ymm9
        $vmulps ymm2,ymm2,ymm9
        $vcvttps2dq ymm0,ymm0
        $vcvttps2dq ymm1,ymm1
        $vcvttps2dq ymm2,ymm2
        $vpslld ymm0,ymm0,16
        $vpslld ymm1,ymm1,8
        $vpor ymm0,ymm0,ymm1
        $vpor ymm0,ymm0,ymm2
        $vmovdqa [rbx],xmm0
        $vextracti128 [rbx+k_win_width*4],ymm0,1
        $add rbx,16
        $add r12d,4
        $cmp r12d,r14d
        $jb .for_each_4x2
        $add rbx,2*(k_win_width*4)-k_tile_width*4
        $sub r12d,k_tile_width
        $add r13d,2
        $cmp r13d,r15d
        $jb .for_each_4x2
        $jmp .for_each_tile
    .return:
        $add rsp,24
        $pop r15 r14 r13 r12 rbp rbx rdi rsi
        $ret
;========================================================================
; Update global state. Runs in the main thread.
;------------------------------------------------------------------------
align 32
update_state:
        $sub rsp,24
        $vxorps xmm0,xmm0,xmm0
        ;$vcvtsd2ss xmm0,xmm0,[time]
        $vbroadcastss ymm0,xmm0
        $vmulps ymm0,ymm0,[k_0_5]
        $call sincos
        $vmovaps ymm2,[k_camera_radius]
        $vmulps ymm0,ymm0,ymm2
        $vmulps ymm1,ymm1,ymm2
        $vmovss [eye_position+0],xmm0
        $vmovss [eye_position+8],xmm1
        $vxorps xmm0,xmm0,xmm0
        $vcvtsd2ss xmm0,xmm0,[time]
        $vbroadcastss ymm0,xmm0
        $vmulps ymm0,ymm0,[k_0_5]
        $call sincos
        $vmovaps ymm2,[k_sphere_radius]
        $vmulps ymm0,ymm0,ymm2
        $vmulps ymm1,ymm1,ymm2
        $vmovaps [object.param_x+$020],ymm1
        $vmovaps [object.param_z+$020],ymm0
        $vxorps ymm2,ymm2,ymm2
        $vsubps ymm0,ymm2,ymm0
        $vsubps ymm1,ymm2,ymm1
        $vmovaps [object.param_x+$040],ymm1
        $vmovaps [object.param_z+$040],ymm0
        $vbroadcastss ymm0,[eye_position+0]             ; ymm0 = eye x pos
        $vbroadcastss ymm3,[eye_focus+0]
        $vbroadcastss ymm1,[eye_position+4]             ; ymm1 = eye y pos
        $vbroadcastss ymm4,[eye_focus+4]
        $vbroadcastss ymm2,[eye_position+8]             ; ymm2 = eye z pos
        $vbroadcastss ymm5,[eye_focus+8]
        $vsubps ymm3,ymm0,ymm3
        $vsubps ymm4,ymm1,ymm4
        $vsubps ymm5,ymm2,ymm5
        $vmulps ymm6,ymm3,ymm3
        $vmulps ymm7,ymm4,ymm4
        $vmulps ymm8,ymm5,ymm5
        $vaddps ymm6,ymm6,ymm7
        $vaddps ymm6,ymm6,ymm8
        $vrsqrtps ymm6,ymm6
        $vmulps ymm3,ymm3,ymm6
        $vmulps ymm4,ymm4,ymm6
        $vmulps ymm5,ymm5,ymm6                          ; (ymm3,ymm4,ymm5) = normalized(iz)
        $vmovaps [eye_zaxis+$000],ymm3
        $vmovaps [eye_zaxis+$020],ymm4
        $vmovaps [eye_zaxis+$040],ymm5
        $vxorps ymm8,ymm8,ymm8
        $vsubps ymm8,ymm8,ymm3
        $vxorps ymm7,ymm7,ymm7
        $vmovaps ymm6,ymm5                              ; (ymm6,ymm7,ymm8) = ix
        $vmulps ymm9,ymm8,ymm8
        $vmulps ymm10,ymm6,ymm6
        $vaddps ymm9,ymm9,ymm10
        $vrsqrtps ymm9,ymm9
        $vmulps ymm6,ymm6,ymm9
        $vmulps ymm8,ymm8,ymm9                          ; (ymm6,ymm7,ymm8) = normalized(ix)
        $vmovaps [eye_xaxis+$000],ymm6
        $vmovaps [eye_xaxis+$020],ymm7
        $vmovaps [eye_xaxis+$040],ymm8
        $vmulps ymm9,ymm5,ymm7
        $vmulps ymm10,ymm3,ymm8
        $vmulps ymm11,ymm4,ymm6
        $vfmsub231ps ymm9,ymm4,ymm8
        $vfmsub231ps ymm10,ymm5,ymm6
        $vfmsub231ps ymm11,ymm3,ymm7                    ; (ymm9,ymm10,ymm11) = iy
        $vmulps ymm12,ymm9,ymm9
        $vmulps ymm13,ymm10,ymm10
        $vmulps ymm14,ymm11,ymm11
        $vaddps ymm12,ymm12,ymm13
        $vaddps ymm12,ymm12,ymm14
        $vrsqrtps ymm12,ymm12
        $vmulps ymm9,ymm9,ymm12
        $vmulps ymm10,ymm10,ymm12
        $vmulps ymm11,ymm11,ymm12                       ; (ymm9,ymm10,ymm11) = normalized(iy)
        $vmovaps [eye_yaxis+$000],ymm9
        $vmovaps [eye_yaxis+$020],ymm10
        $vmovaps [eye_yaxis+$040],ymm11
        $add rsp,24
        $ret
;========================================================================
else if program_section = 'data'

align 4
eye_position dd 0.0,4.0,400.0
eye_focus dd 0.0,0.0,0.0
k_background_color dd 0.0,0.0,0.0

align 32
eye_xaxis: dd 8 dup 1.0,8 dup 0.0,8 dup 0.0
eye_yaxis: dd 8 dup 0.0,8 dup 1.0,8 dup 0.0
eye_zaxis: dd 8 dup 0.0,8 dup 0.0,8 dup 1.0

align 32
generate_image.k_x_offset: dd 0.5,1.5,2.5,3.5,0.5,1.5,2.5,3.5
generate_image.k_y_offset: dd 0.5,0.5,0.5,0.5,1.5,1.5,1.5,1.5
generate_image.k_win_width_rcp: dd 8 dup 0.0015625      ; 2.0f / k_win_width, k_win_width = 1280
generate_image.k_win_height_rcp: dd 8 dup 0.0015625     ; 2.0f / k_win_width, k_win_width = 1280
generate_image.k_rd_z: dd 8 dup -1.732

align 32
k_1: dd 8 dup 1
k_2: dd 8 dup 2
k_1_0: dd 8 dup 1.0
k_0_5: dd 8 dup 0.5
k_0_1: dd 8 dup 0.1
k_camera_radius: dd 8 dup 16.0
k_sphere_radius: dd 8 dup -4.0
k_255_0: dd 8 dup 255.0
k_0_02: dd 8 dup 0.02
k_hit_distance: dd 8 dup 0.00001
k_view_distance: dd 8 dup 50.0
k_normal_eps: dd 8 dup 0.00002
k_shadow_hardness: dd 8 dup 16.0

align 32
light0_position: dd 8 dup 10.0, 8 dup 10.0, 8 dup 10.0
light0_power: dd 8 dup 0.9
light1_position: dd 8 dup 5.0, 8 dup 20.0, 8 dup -15.0
light1_power: dd 8 dup 0.6
ambient: dd 8 dup 0.1

align 32
object:
.id:      dd 8 dup 0,8 dup 8,8 dup 16,8 dup 24
.param_x: dd 8 dup 0.0,8 dup 0.0,8 dup 3.0,8 dup 0.0
.param_y: dd 8 dup 0.0,8 dup 1.0,8 dup 0.0,8 dup 1.0
.param_z: dd 8 dup 0.0,8 dup 3.0,8 dup 0.0,8 dup 0.0
.param_w: dd 8 dup 2.0,8 dup 0.7,8 dup 1.0,8 dup 2.0
.red:     dd 8 dup 1.0,8 dup 0.0,8 dup 0.0,8 dup 0.5
.green:   dd 8 dup 0.0,8 dup 1.0,8 dup 0.0,8 dup 0.3
.blue:    dd 8 dup 0.0,8 dup 0.0,8 dup 1.0,8 dup 0.2

align 32
sincos.k_inv_sign_mask: dd 8 dup not 0x80000000
sincos.k_sign_mask: dd 8 dup 0x80000000
sincos.k_2_div_pi: dd 8 dup 0.636619772
sincos.k_p0: dd 8 dup 0.15707963267948963959e1
sincos.k_p1: dd 8 dup -0.64596409750621907082e0
sincos.k_p2: dd 8 dup 0.7969262624561800806e-1
sincos.k_p3: dd 8 dup -0.468175413106023168e-2

end if ; program_section = 'data'
;========================================================================