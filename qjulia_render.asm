if qjulia_section = 'code'
;========================================================================
align 16
sincos:
                  vandps  ymm0,ymm0,[@sincos.k_inv_sign_mask]
                  vandps  ymm7,ymm0,[@sincos.k_sign_mask]
                  vmulps  ymm0,ymm0,[@sincos.k_2_div_pi]
                   vpxor  ymm3,ymm3,ymm3
                 vmovdqa  ymm8,[k_1]
                 vmovaps  ymm4,[k_1_0]
              vcvttps2dq  ymm2,ymm0
                   vpand  ymm5,ymm8,ymm2
                vpcmpeqd  ymm5,ymm5,ymm3
                 vmovdqa  ymm1,[k_2]
               vcvtdq2ps  ymm6,ymm2
                  vpaddd  ymm3,ymm8,ymm2
                   vpand  ymm2,ymm2,ymm1
                   vpand  ymm3,ymm3,ymm1
                  vsubps  ymm0,ymm0,ymm6
                  vpslld  ymm2,ymm2,30
                  vminps  ymm0,ymm0,ymm4
                  vsubps  ymm4,ymm4,ymm0
                  vpslld  ymm3,ymm3,30
                  vxorps  ymm2,ymm2,ymm7
                  vandps  ymm6,ymm4,ymm5
                 vandnps  ymm7,ymm5,ymm0
                  vandps  ymm0,ymm0,ymm5
                 vandnps  ymm5,ymm5,ymm4
                 vmovaps  ymm8,[@sincos.k_p3]
                 vmovaps  ymm9,[@sincos.k_p2]
                 vmovaps  ymm10,[@sincos.k_p1]
                 vmovaps  ymm11,[@sincos.k_p0]
                   vorps  ymm6,ymm6,ymm7
                   vorps  ymm0,ymm0,ymm5
                   vorps  ymm1,ymm0,ymm2
                   vorps  ymm7,ymm6,ymm3
                  vmulps  ymm2,ymm0,ymm0
                  vmulps  ymm3,ymm6,ymm6
             vfmadd132ps  ymm0,ymm9,ymm8
             vfmadd132ps  ymm6,ymm9,ymm8
             vfmadd132ps  ymm0,ymm10,ymm2
             vfmadd132ps  ymm6,ymm10,ymm3
             vfmadd132ps  ymm0,ymm11,ymm2
             vfmadd132ps  ymm6,ymm11,ymm3
                  vmulps  ymm0,ymm0,ymm1
                  vmulps  ymm1,ymm6,ymm7
                     ret
;========================================================================
align 16
nearest_distance: ; (ymm0,ymm1,ymm2) position
                  vsubps  ymm3,ymm0,[scene.param_x]
                  vsubps  ymm4,ymm1,[scene.param_y]
                  vsubps  ymm5,ymm2,[scene.param_z]
                  vsubps  ymm7,ymm0,[scene.param_x+32]
                  vsubps  ymm8,ymm1,[scene.param_y+32]
                  vsubps  ymm9,ymm2,[scene.param_z+32]
                  vsubps  ymm11,ymm0,[scene.param_x+64]
                  vmulps  ymm3,ymm3,ymm3
                  vmulps  ymm7,ymm7,ymm7
                  vsubps  ymm12,ymm1,[scene.param_y+64]
                  vsubps  ymm13,ymm2,[scene.param_z+64]
                 vmovaps  ymm6,[scene.param_w]
                 vmovaps  ymm10,[scene.param_w+32]
                  vmulps  ymm11,ymm11,ymm11
             vfmadd231ps  ymm3,ymm4,ymm4
                 vmovaps  ymm4,[scene.param_w+64]
             vfmadd231ps  ymm7,ymm8,ymm8
             vfmadd231ps  ymm11,ymm12,ymm12
             vfmadd231ps  ymm3,ymm5,ymm5
                 vmovaps  ymm5,[scene.param_w+96]
             vfmadd231ps  ymm7,ymm9,ymm9
             vfmadd231ps  ymm11,ymm13,ymm13
                vrsqrtps  ymm3,ymm3
                vrsqrtps  ymm7,ymm7
                vrsqrtps  ymm11,ymm11
                  vaddps  ymm0,ymm1,ymm5
                  vrcpps  ymm3,ymm3
                  vrcpps  ymm7,ymm7
                  vrcpps  ymm11,ymm11
                  vsubps  ymm3,ymm3,ymm6
                  vsubps  ymm7,ymm7,ymm10
                  vsubps  ymm11,ymm11,ymm4
                  vminps  ymm0,ymm0,ymm3
                  vminps  ymm0,ymm0,ymm7
                  vminps  ymm0,ymm0,ymm11
                     ret
;========================================================================
align 16
raymarch_distance: ; (ymm0,ymm1,ymm2) ray origin, (ymm3,ymm4,ymm5) ray direction
  virtual at rsp
  .rayo: rd 3*8
  .rayd: rd 3*8
  .distance: rd 8
  .k_stack_size = $-$$
  end virtual
                    push  rsi
                     sub  rsp,.k_stack_size+16
                 vmovaps  ymm6,[k_1_0]
                 vmovaps  [.rayo],ymm0
                 vmovaps  [.rayo+32],ymm1
                 vmovaps  [.rayo+64],ymm2
                 vmovaps  [.distance],ymm6
                 vmovaps  [.rayd],ymm3
                 vmovaps  [.rayd+32],ymm4
                 vmovaps  [.rayd+64],ymm5
                     mov  esi,128
  align 32
  .march:
             vfmadd231ps  ymm0,ymm6,ymm3
             vfmadd231ps  ymm1,ymm6,ymm4
             vfmadd231ps  ymm2,ymm6,ymm5
                    call  nearest_distance
                 vmovaps  ymm6,[.distance]
                vcmpltps  ymm7,ymm0,[k_hit_distance]                    ; nearest_distance() < k_hit_distance
                vcmpgtps  ymm8,ymm6,[k_view_distance]                   ; .distance > k_view_distance
                   vorps  ymm7,ymm7,ymm8
               vmovmskps  eax,ymm7
                     cmp  eax,0xff
                      je  .march_end
                 vandnps  ymm0,ymm7,ymm0
                  vaddps  ymm6,ymm6,ymm0
                 vmovaps  ymm0,[.rayo]
                 vmovaps  ymm1,[.rayo+32]
                 vmovaps  ymm2,[.rayo+64]
                 vmovaps  ymm3,[.rayd]
                 vmovaps  ymm4,[.rayd+32]
                 vmovaps  ymm5,[.rayd+64]
                 vmovaps  [.distance],ymm6
                     sub  esi,1
                     jnz  .march
  .march_end:
                 vmovaps  ymm0,ymm6
                     add  rsp,.k_stack_size+16
                     pop  rsi
                     ret
;========================================================================
align 16
generate_fractal:
                    push  rsi rdi rbx rbp r12 r13 r14 r15
                     sub  rsp,24
  .for_each_tile:
                     mov  eax,1
               lock xadd  [tileidx],eax
                     cmp  eax,k_tile_count
                     jae  .return
                     xor  edx,edx
                     mov  ecx,k_tile_x_count
                     div  ecx                                     ; eax = (k_tile_count / k_tile_x_count), edx = (k_tile_count % k_tile_x_count)
                     mov  r14d,k_tile_width
                     mov  r15d,k_tile_height
                    imul  edx,r14d                                ; edx = (k_tile_count % k_tile_x_count) * k_tile_width
                    imul  eax,r15d                                ; eax = (k_tile_count / k_tile_x_count) * k_tile_height
                     mov  r12d,edx                                ; r12d = x0
                     mov  r13d,eax                                ; r13d = y0
                     add  r14d,r12d                               ; r14d = x1 = x0 + k_tile_width
                     add  r15d,r13d                               ; r15d = y1 = y0 + k_tile_height
                    imul  eax,k_win_width
                     add  eax,edx
                     shl  eax,2
                     mov  rbx,[displayptr]
                     add  rbx,rax
  align 32
  .for_each_4x2:
                  vxorps  xmm0,xmm0,xmm0
                  vxorps  xmm1,xmm1,xmm1
                     mov  eax,r12d
                     mov  edx,r13d
                     sub  eax,k_win_width/2
                     sub  edx,k_win_height/2
               vcvtsi2ss  xmm0,xmm0,eax                           ; (0, 0, 0, xf = (float)(x - k_win_width / 2))
               vcvtsi2ss  xmm1,xmm1,edx                           ; (0, 0, 0, yf = (float)(y - k_win_height / 2))
            vbroadcastss  ymm0,xmm0                               ; ymm0 = (xf ... xf)
            vbroadcastss  ymm1,xmm1                               ; ymm1 = (yf ... yf)
                  vaddps  ymm0,ymm0,[@generate_fractal.k_x_offset]
                  vaddps  ymm1,ymm1,[@generate_fractal.k_y_offset]
                 vmovaps  ymm2,[@generate_fractal.k_rd_z]
                  vmulps  ymm0,ymm0,[@generate_fractal.k_win_width_rcp]
                  vmulps  ymm1,ymm1,[@generate_fractal.k_win_height_rcp]
                  vmulps  ymm3,ymm0,[eye_xaxis]
                  vmulps  ymm6,ymm0,[eye_xaxis+32]
                  vmulps  ymm9,ymm0,[eye_xaxis+64]
             vfmadd231ps  ymm3,ymm1,[eye_yaxis]
             vfmadd231ps  ymm6,ymm1,[eye_yaxis+32]
             vfmadd231ps  ymm9,ymm1,[eye_yaxis+64]
             vfmadd231ps  ymm3,ymm2,[eye_zaxis]
             vfmadd231ps  ymm6,ymm2,[eye_zaxis+32]
             vfmadd231ps  ymm9,ymm2,[eye_zaxis+64]
            vbroadcastss  ymm0,[eye_position]
            vbroadcastss  ymm1,[eye_position+4]
            vbroadcastss  ymm2,[eye_position+8]
                  vmulps  ymm10,ymm3,ymm3
                  vmulps  ymm11,ymm6,ymm6
                  vmulps  ymm12,ymm9,ymm9
                  vaddps  ymm10,ymm10,ymm11
                  vaddps  ymm10,ymm10,ymm12
                vrsqrtps  ymm10,ymm10
                  vmulps  ymm3,ymm3,ymm10
                  vmulps  ymm4,ymm6,ymm10
                  vmulps  ymm5,ymm9,ymm10
                    call  raymarch_distance
                 vmovaps  ymm3,[k_view_distance]
            vbroadcastss  ymm4,[k_background_color]
            vbroadcastss  ymm5,[k_background_color+4]
            vbroadcastss  ymm6,[k_background_color+8]
                  vxorps  ymm7,ymm7,ymm7                          ; ymm7 = (0 ... 0)
                 vmovaps  ymm8,[k_1_0]                            ; ymm8 = (1.0 ... 1.0)
                 vmovaps  ymm9,[k_255_0]                          ; ymm9 = (255.0 ... 255.0)
                  vrcpps  ymm10,ymm3
                  vmulps  ymm10,ymm0,ymm10
                  vsubps  ymm10,ymm8,ymm10
                vcmpltps  ymm11,ymm0,ymm3                         ; ymm11 = hit mask
               vblendvps  ymm0,ymm4,ymm10,ymm11
               vblendvps  ymm1,ymm5,ymm10,ymm11
               vblendvps  ymm2,ymm6,ymm10,ymm11
                  vmaxps  ymm0,ymm0,ymm7
                  vmaxps  ymm1,ymm1,ymm7
                  vmaxps  ymm2,ymm2,ymm7
                  vminps  ymm0,ymm0,ymm8
                  vminps  ymm1,ymm1,ymm8
                  vminps  ymm2,ymm2,ymm8
                  vmulps  ymm0,ymm0,ymm9
                  vmulps  ymm1,ymm1,ymm9
                  vmulps  ymm2,ymm2,ymm9
              vcvttps2dq  ymm0,ymm0
              vcvttps2dq  ymm1,ymm1
              vcvttps2dq  ymm2,ymm2
                  vpslld  ymm0,ymm0,16
                  vpslld  ymm1,ymm1,8
                    vpor  ymm0,ymm0,ymm1
                    vpor  ymm0,ymm0,ymm2
                 vmovdqa  [rbx],xmm0
            vextracti128  [rbx+k_win_width*4],ymm0,1
                     add  rbx,16
                     add  r12d,4
                     cmp  r12d,r14d
                      jb  .for_each_4x2
                     add  rbx,2*(k_win_width*4)-k_tile_width*4
                     sub  r12d,k_tile_width
                     add  r13d,2
                     cmp  r13d,r15d
                      jb  .for_each_4x2
                     jmp  .for_each_tile
  .return:
                     add  rsp,24
                     pop  r15 r14 r13 r12 rbp rbx rdi rsi
                     ret
;========================================================================
align 16
update:
                     sub  rsp,24
                  vxorps  xmm0,xmm0,xmm0
               vcvtsd2ss  xmm0,xmm0,[time]
            vbroadcastss  ymm0,xmm0
                    call  sincos
                 vmovaps  ymm2,[k_7_0]
                  vmulps  ymm0,ymm0,ymm2
                  vmulps  ymm1,ymm1,ymm2
                  vmovss  [eye_position],xmm0
                  vmovss  [eye_position+8],xmm1
            vbroadcastss  ymm0,[eye_position]           ; ymm0 = eye x pos
            vbroadcastss  ymm3,[eye_focus]
            vbroadcastss  ymm1,[eye_position+4]         ; ymm1 = eye y pos
            vbroadcastss  ymm4,[eye_focus+4]
            vbroadcastss  ymm2,[eye_position+8]         ; ymm2 = eye z pos
            vbroadcastss  ymm5,[eye_focus+8]
                  vsubps  ymm3,ymm0,ymm3
                  vsubps  ymm4,ymm1,ymm4
                  vsubps  ymm5,ymm2,ymm5
                  vmulps  ymm6,ymm3,ymm3
                  vmulps  ymm7,ymm4,ymm4
                  vmulps  ymm8,ymm5,ymm5
                  vaddps  ymm6,ymm6,ymm7
                  vaddps  ymm6,ymm6,ymm8
                vrsqrtps  ymm6,ymm6
                  vmulps  ymm3,ymm3,ymm6
                  vmulps  ymm4,ymm4,ymm6
                  vmulps  ymm5,ymm5,ymm6                ; (ymm3,ymm4,ymm5) = normalized(iz)
                 vmovaps  [eye_zaxis],ymm3
                 vmovaps  [eye_zaxis+32],ymm4
                 vmovaps  [eye_zaxis+64],ymm5
                  vxorps  ymm8,ymm8,ymm8
                  vsubps  ymm8,ymm8,ymm3
                  vxorps  ymm7,ymm7,ymm7
                 vmovaps  ymm6,ymm5                     ; (ymm6,ymm7,ymm8) = ix
                  vmulps  ymm9,ymm8,ymm8
                  vmulps  ymm10,ymm6,ymm6
                  vaddps  ymm9,ymm9,ymm10
                vrsqrtps  ymm9,ymm9
                  vmulps  ymm6,ymm6,ymm9
                  vmulps  ymm8,ymm8,ymm9                ; (ymm6,ymm7,ymm8) = normalized(ix)
                 vmovaps  [eye_xaxis],ymm6
                 vmovaps  [eye_xaxis+32],ymm7
                 vmovaps  [eye_xaxis+64],ymm8
                  vmulps  ymm9,ymm5,ymm7
                  vmulps  ymm10,ymm3,ymm8
                  vmulps  ymm11,ymm4,ymm6
             vfmsub231ps  ymm9,ymm4,ymm8
             vfmsub231ps  ymm10,ymm5,ymm6
             vfmsub231ps  ymm11,ymm3,ymm7               ; (ymm9,ymm10,ymm11) = iy
                  vmulps  ymm12,ymm9,ymm9
                  vmulps  ymm13,ymm10,ymm10
                  vmulps  ymm14,ymm11,ymm11
                  vaddps  ymm12,ymm12,ymm13
                  vaddps  ymm12,ymm12,ymm14
                vrsqrtps  ymm12,ymm12
                  vmulps  ymm9,ymm9,ymm12
                  vmulps  ymm10,ymm10,ymm12
                  vmulps  ymm11,ymm11,ymm12             ; (ymm9,ymm10,ymm11) = normalized(iy)
                 vmovaps  [eye_yaxis],ymm9
                 vmovaps  [eye_yaxis+32],ymm10
                 vmovaps  [eye_yaxis+64],ymm11
                     mov  [tileidx],0
                  invoke  ReleaseSemaphore,[main_thrd_semaphore],k_thrd_count,NULL
                  invoke  WaitForMultipleObjects,k_thrd_count,thrd_semaphore,TRUE,INFINITE
                     add  rsp,24
                     ret
;========================================================================
else if qjulia_section = 'data'

align 4
eye_position dd 0.0,3.0,7.0
eye_focus dd 0.0,0.0,0.0
k_background_color dd 0.1,0.3,0.6

align 32
eye_xaxis: dd 8 dup 1.0,8 dup 0.0,8 dup 0.0
eye_yaxis: dd 8 dup 0.0,8 dup 1.0,8 dup 0.0
eye_zaxis: dd 8 dup 0.0,8 dup 0.0,8 dup 1.0

align 32
@generate_fractal:
.k_x_offset: dd 0.5,1.5,2.5,3.5,0.5,1.5,2.5,3.5
.k_y_offset: dd 0.5,0.5,0.5,0.5,1.5,1.5,1.5,1.5
.k_win_width_rcp: dd 8 dup 0.0027765625                   ; 1.777f * 2.0f / k_win_width, k_win_width = 1280
.k_win_height_rcp: dd 8 dup 0.0027777777777778            ; 2.0f / k_win_height, k_win_height = 720
.k_rd_z: dd 8 dup -1.732

align 32
k_1: dd 8 dup 1
k_2: dd 8 dup 2
k_1_0: dd 8 dup 1.0
k_7_0: dd 8 dup 7.0
k_255_0: dd 8 dup 255.0
k_hit_distance: dd 8 dup 0.0001
k_view_distance: dd 8 dup 25.0

align 32
scene:
.param_x:
dd 8 dup -1.0
dd 8 dup 0.0
dd 8 dup 0.0
dd 8 dup 0.0
.param_y:
dd 8 dup 0.0
dd 8 dup 1.0
dd 8 dup 0.0
dd 8 dup 1.0
.param_z:
dd 8 dup 0.0
dd 8 dup 3.0
dd 8 dup 4.0
dd 8 dup 0.0
.param_w:
dd 8 dup 2.0
dd 8 dup 0.5
dd 8 dup 0.25
dd 8 dup 2.0
.red:
dd 8 dup 1.0
dd 8 dup 0.0
dd 8 dup 0.0
dd 8 dup 1.0
.green:
dd 8 dup 0.0
dd 8 dup 1.0
dd 8 dup 0.0
dd 8 dup 0.8
.blue:
dd 8 dup 0.0
dd 8 dup 0.0
dd 8 dup 1.0
dd 8 dup 0.1

align 32
@sincos:
.k_inv_sign_mask: dd 8 dup not 0x80000000
.k_sign_mask: dd 8 dup 0x80000000
.k_2_div_pi: dd 8 dup 0.636619772
.k_p0: dd 8 dup 0.15707963267948963959e1
.k_p1: dd 8 dup -0.64596409750621907082e0
.k_p2: dd 8 dup 0.7969262624561800806e-1
.k_p3: dd 8 dup -0.468175413106023168e-2

end if
;========================================================================