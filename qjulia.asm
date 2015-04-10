format PE64 GUI 4.0
entry start
include 'win64a.inc'

DIB_RGB_COLORS = 0
INFINITE = -1

section '.text' code readable executable
;========================================================================
  macro iaca_begin
  {
                     mov  ebx,111
                      db  0x64,0x67,0x90
  }
  macro iaca_end
  {
                     mov  ebx,222
                      db  0x64,0x67,0x90
  }
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
  generate_fractal_thread:
                     and  rsp,-32
                     mov  esi,ecx       ; thread id
    .run:
                  invoke  WaitForSingleObject,[main_thrd_semaphore],INFINITE
                     mov  eax,[quit]
                    test  eax,eax
                     jnz  .return
                    call  generate_fractal
                  invoke  ReleaseSemaphore,[thrd_semaphore+rsi*8],1,NULL
                     jmp  .run
    .return:
                  invoke  ExitThread,0
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
                  vmulps  ymm4,ymm0,[eye_yaxis]
                  vmulps  ymm5,ymm0,[eye_zaxis]
                  vmulps  ymm6,ymm1,[eye_xaxis+32]
                  vmulps  ymm7,ymm1,[eye_yaxis+32]
                  vmulps  ymm8,ymm1,[eye_zaxis+32]
                  vmulps  ymm9,ymm2,[eye_xaxis+64]
                  vmulps  ymm10,ymm2,[eye_yaxis+64]
                  vmulps  ymm11,ymm2,[eye_zaxis+64]
                  vaddps  ymm3,ymm3,ymm4
                  vaddps  ymm6,ymm6,ymm7
                  vaddps  ymm9,ymm9,ymm10
                  vaddps  ymm3,ymm3,ymm5
                  vaddps  ymm6,ymm6,ymm8
                  vaddps  ymm9,ymm9,ymm11
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
                vcmpltps  ymm6,ymm0,[k_view_distance]             ; ymm6 = hit mask
                  vxorps  ymm5,ymm5,ymm5                          ; ymm5 = (0 ... 0)
                 vmovaps  ymm4,[k_1_0]                            ; ymm4 = (1.0 ... 1.0)
                 vmovaps  ymm3,[k_255_0]                          ; ymm3 = (255.0 ... 255.0)
               vblendvps  ymm0,ymm5,ymm4,ymm6
               vblendvps  ymm1,ymm5,ymm4,ymm6
               vblendvps  ymm2,ymm5,ymm4,ymm6
                  vmaxps  ymm0,ymm0,ymm5
                  vmaxps  ymm1,ymm1,ymm5
                  vmaxps  ymm2,ymm2,ymm5
                  vminps  ymm0,ymm0,ymm4
                  vminps  ymm1,ymm1,ymm4
                  vminps  ymm2,ymm2,ymm4
                  vmulps  ymm0,ymm0,ymm3
                  vmulps  ymm1,ymm1,ymm3
                  vmulps  ymm2,ymm2,ymm3
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
  get_time:
    virtual at rsp
    .perf_counter dq ?
    end virtual
                     sub  rsp,24
                     mov  rax,[@get_time.perf_freq]
                    test  eax,eax
                     jnz  @f
                     mov  rcx,@get_time.perf_freq
                  invoke  QueryPerformanceFrequency
    @@:              lea  rcx,[.perf_counter]
                  invoke  QueryPerformanceCounter
                     mov  rcx,[.perf_counter]
                     mov  rdx,[@get_time.perf_freq]
                  vxorps  xmm0,xmm0,xmm0
               vcvtsi2sd  xmm1,xmm0,rcx
               vcvtsi2sd  xmm2,xmm0,rdx
                  vdivsd  xmm0,xmm1,xmm2
                     add  rsp,24
                     ret
;========================================================================
  align 16
  update_frame_stats:
                     sub  rsp,24
                     mov  rax,[@update_frame_stats.prev_time]
                    test  rax,rax
                     jnz  @f
                    call  get_time
                  vmovsd  [@update_frame_stats.prev_time],xmm0
                  vmovsd  [@update_frame_stats.prev_update_time],xmm0
    @@:             call  get_time                                        ; xmm0 = (0, time)
                  vmovsd  [time],xmm0
                  vsubsd  xmm1,xmm0,[@update_frame_stats.prev_time]       ; xmm1 = (0, time_delta)
                  vmovsd  [@update_frame_stats.prev_time],xmm0
                  vxorps  xmm2,xmm2,xmm2
               vcvtsd2ss  xmm1,xmm2,xmm1                                  ; xmm1 = (0, 0, 0, time_delta)
                  vmovss  [time_delta],xmm1
                  vmovsd  xmm1,[@update_frame_stats.prev_update_time]     ; xmm1 = (0, prev_update_time)
                  vsubsd  xmm2,xmm0,xmm1                                  ; xmm2 = (0, time - prev_update_time)
                  vmovsd  xmm3,[@update_frame_stats.k_1_0]                ; xmm3 = (0, 1.0)
                 vcomisd  xmm2,xmm3
                      jb  @f
                  vmovsd  [@update_frame_stats.prev_update_time],xmm0
                     mov  eax,[@update_frame_stats.frame]
                  vxorpd  xmm1,xmm1,xmm1
               vcvtsi2sd  xmm1,xmm1,eax                                   ; xmm1 = (0, frame)
                  vdivsd  xmm0,xmm1,xmm2                                  ; xmm0 = (0, frame / (time - prev_update_time))
                  vdivsd  xmm1,xmm2,xmm1
                  vmulsd  xmm1,xmm1,[@update_frame_stats.k_1000000_0]
               vcvtsd2si  r10,xmm0
               vcvtsd2si  r11,xmm1
                     mov  [@update_frame_stats.frame],0
                 cinvoke  wsprintf,win_title,win_title_fmt,r10,r11
                  invoke  SetWindowText,[win_handle],win_title
    @@:              add  [@update_frame_stats.frame],1
                     add  rsp,24
                     ret
;========================================================================
  align 16
  update:
                     sub  rsp,24
              ;iaca_begin
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
                ;iaca_end
                     mov  [tileidx],0
                  invoke  ReleaseSemaphore,[main_thrd_semaphore],k_thrd_count,NULL
                  invoke  WaitForMultipleObjects,k_thrd_count,thrd_semaphore,TRUE,INFINITE
                     add  rsp,24
                     ret
;========================================================================
  align 16
  init:
                    push  rsi
                     sub  rsp,16
                  invoke  GetModuleHandle,0
                     mov  [win_class.hInstance],rax
                  invoke  LoadIcon,0,IDI_APPLICATION
                     mov  [win_class.hIcon],rax
                     mov  [win_class.hIconSm],rax
                  invoke  LoadCursor,0,IDC_ARROW
                     mov  [win_class.hCursor],rax
                  invoke  GetStockObject,BLACK_BRUSH
                     mov  [win_class.hbrBackground],rax
                  invoke  RegisterClassEx,win_class
                    test  eax,eax
                      jz  .error
                  invoke  SetRect,win_rect,0,0,k_win_width,k_win_height
                    test  eax,eax
                      jz  .error
                  invoke  AdjustWindowRect,win_rect,k_win_style,FALSE
                    test  eax,eax
                      jz  .error
                     mov  esi,[win_rect.right]
                     mov  edi,[win_rect.bottom]
                     sub  esi,[win_rect.left]
                     sub  edi,[win_rect.top]
                  invoke  CreateWindowEx,0,win_title,win_title,WS_VISIBLE+k_win_style,CW_USEDEFAULT,CW_USEDEFAULT,esi,edi,NULL,NULL,[win_class.hInstance],NULL
                     mov  [win_handle],rax
                    test  rax,rax
                      jz  .error
                  invoke  GetDC,rax
                     mov  [win_hdc],rax
                    test  rax,rax
                      jz  .error
                  invoke  CreateDIBSection,[win_hdc],bmp_info,DIB_RGB_COLORS,displayptr,NULL,0
                     mov  [bmp_handle],rax
                    test  rax,rax
                      jz  .error
                  invoke  CreateCompatibleDC,[win_hdc]
                     mov  [bmp_hdc],rax
                    test  rax,rax
                      jz  .error
                  invoke  SelectObject,[bmp_hdc],[bmp_handle]
                    test  eax,eax
                      jz  .error
                  invoke  CreateSemaphore,NULL,0,k_thrd_count,NULL
                     mov  [main_thrd_semaphore],rax
                    test  rax,rax
                      jz  .error
                     xor  esi,esi
    @@:           invoke  CreateSemaphore,NULL,0,1,NULL
                     mov  [thrd_semaphore+rsi*8],rax
                    test  rax,rax
                      jz  .error
                     add  esi,1
                     cmp  esi,k_thrd_count
                      jb  @b
                     xor  esi,esi
    @@:           invoke  CreateThread,NULL,0,generate_fractal_thread,esi,0,NULL
                     mov  [thrd_handle+rsi*8],rax
                    test  rax,rax
                      jz  .error
                     add  esi,1
                     cmp  esi,k_thrd_count
                      jb  @b
                     mov  eax,1
                     add  rsp,24
                     ret
    .error:          xor  eax,eax
                     add  rsp,16
                     pop  rsi
                     ret
;========================================================================
  align 16
  deinit:
                    push  rsi rdi
                     sub  rsp,8
                     mov  [quit],1
                  invoke  ReleaseSemaphore,[main_thrd_semaphore],k_thrd_count,NULL
                     xor  esi,esi
    .for_each_thrd:
                     mov  rdi,[thrd_handle+rsi*8]
                    test  rdi,rdi
                      jz  @f
                  invoke  WaitForSingleObject,rdi,INFINITE
                  invoke  CloseHandle,rdi
    @@:              add  esi,1
                     cmp  esi,k_thrd_count
                      jb  .for_each_thrd
                     mov  rcx,[main_thrd_semaphore]
                    test  rcx,rcx
                      jz  @f
                  invoke  CloseHandle,rcx
    @@:              xor  esi,esi
    .for_each_sem:
                     mov  rcx,[thrd_semaphore+rsi*8]
                    test  rcx,rcx
                      jz  @f
                  invoke  CloseHandle,rcx
    @@:              add  esi,1
                     cmp  esi,k_thrd_count
                      jb  .for_each_sem
                     mov  rcx,[bmp_hdc]
                    test  rcx,rcx
                      jz  @f
                  invoke  DeleteDC,rcx
    @@:              mov  rcx,[bmp_handle]
                    test  rcx,rcx
                      jz  @f
                  invoke  DeleteObject,rcx
    @@:              mov  rcx,[win_hdc]
                    test  rcx,rcx
                      jz  @f
                  invoke  ReleaseDC,rcx
    @@:              add  rsp,8
                     pop  rdi rsi
                     ret
;========================================================================
  align 16
  start:
                     and  rsp,-32
                    call  init
                    test  eax,eax
                      jz  .quit
    .main_loop:
                  invoke  PeekMessage,win_msg,NULL,0,0,PM_REMOVE
                    test  eax,eax
                      jz  @f
                  invoke  DispatchMessage,win_msg
                     cmp  [win_msg.message],WM_QUIT
                      je  .quit
                     jmp  .main_loop
    @@:
                    call  update_frame_stats
                    call  update
                  invoke  BitBlt,[win_hdc],0,0,k_win_width,k_win_height,[bmp_hdc],0,0,SRCCOPY
                     jmp  .main_loop
    .quit:
                    call  deinit
                  invoke  ExitProcess,0
;========================================================================
  align 16
  proc winproc hwnd,msg,wparam,lparam
                     mov  [hwnd],rcx
                     mov  [msg],rdx
                     mov  [wparam],r8
                     mov  [lparam],r9
                     cmp  edx,WM_KEYDOWN
                      je  .keydown
                     cmp  edx,WM_DESTROY
                      je  .destroy
                  invoke  DefWindowProc,rcx,rdx,r8,r9
                     jmp  .return
    .keydown:
                     cmp  [wparam],VK_ESCAPE
                     jne  .return
                  invoke  PostQuitMessage,0
                     xor  eax,eax
                     jmp  .return
    .destroy:
                  invoke  PostQuitMessage,0
                     xor  eax,eax
    .return:
                     ret
  endp
;========================================================================
section '.data' data readable writeable

  k_win_width = 1280
  k_win_height = 720
  k_win_style = WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX

  k_tile_width = 80
  k_tile_height = 80
  k_tile_x_count = k_win_width / k_tile_width
  k_tile_y_count = k_win_height / k_tile_height
  k_tile_count = k_tile_x_count * k_tile_y_count

  k_thrd_count = 8

  align 8
  bmp_handle dq 0
  bmp_hdc dq 0
  win_handle dq 0
  win_hdc dq 0
  win_title db 'Fractal', 64 dup 0
  win_title_fmt db '[%d fps  %d us] Fractal',0
  win_msg MSG
  win_class WNDCLASSEX sizeof.WNDCLASSEX,0,winproc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,win_title,NULL
  win_rect RECT

  align 8
  bmp_info BITMAPINFOHEADER sizeof.BITMAPINFOHEADER,k_win_width,k_win_height,1,32,BI_RGB,k_win_width*k_win_height,0,0,0,0
  dq 0,0,0,0

  align 8
  time dq 0
  time_delta dd 0
  quit dd 0

  @get_time:
  .perf_freq dq 0

  @update_frame_stats:
  .prev_time dq 0
  .prev_update_time dq 0
  .frame dd 0,0
  .k_1000000_0 dq 1000000.0
  .k_1_0 dq 1.0

  displayptr dq 0
  tileidx dd 0,0

  eye_position dd 0.0,0.0,7.0
  eye_focus dd 0.0,0.0,0.0

  align 8
  main_thrd_semaphore dq 0
  thrd_handle dq k_thrd_count dup 0
  thrd_semaphore dq k_thrd_count dup 0

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
  k_1_0: dd 8 dup 1.0
  k_255_0: dd 8 dup 255.0
  k_hit_distance: dd 8 dup 0.0001
  k_view_distance: dd 8 dup 25.0

  align 32
  scene:
  .param_x:
  dd 8 dup 0.0
  dd 8 dup 0.0
  dd 8 dup 0.0
  dd 8 dup 0.0
  .param_y:
  dd 8 dup 0.0
  dd 8 dup 0.0
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
;========================================================================
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\gdi32.inc'
;========================================================================