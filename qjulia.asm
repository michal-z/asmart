format PE64 GUI 4.0
entry start
include 'win64a.inc'

DIB_RGB_COLORS = 0

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
                     mov  r12d,k_tile_width
                     mov  r13d,k_tile_height
                    imul  edx,r12d                                ; edx = (k_tile_count % k_tile_x_count) * k_tile_width
                    imul  eax,r13d                                ; eax = (k_tile_count / k_tile_x_count) * k_tile_height
                     mov  r10d,edx                                ; r10d = x0
                     mov  r11d,eax                                ; r11d = y0
                     add  r12d,r10d                               ; r12d = x1 = x0 + k_tile_width
                     add  r13d,r11d                               ; r13d = y1 = y0 + k_tile_height
                    imul  eax,k_win_width
                     add  eax,edx
                     shl  eax,2
                     mov  rbx,[displayptr]
                     add  rbx,rax
    align 32
    .for_each_4x2:
                  vxorps  xmm0,xmm0,xmm0
                  vxorps  xmm1,xmm1,xmm1
                     mov  eax,r10d
                     mov  edx,r11d
                     sub  eax,k_win_width/2
                     sub  edx,k_win_height/2
               vcvtsi2ss  xmm0,xmm0,eax                           ; (0, 0, 0, xf = (float)(x - k_win_width / 2))
               vcvtsi2ss  xmm1,xmm1,edx                           ; (0, 0, 0, yf = (float)(y - k_win_height / 2))
            vbroadcastss  ymm0,xmm0                               ; ymm0 = (xf ... xf)
            vbroadcastss  ymm1,xmm1                               ; ymm1 = (yf ... yf)
                  vaddps  ymm0,ymm0,[.k_x_offset]
                  vaddps  ymm1,ymm1,[.k_y_offset]
                  vmulps  ymm0,ymm0,[.k_win_width_rcp]
                  vmulps  ymm1,ymm1,[.k_win_height_rcp]
                  vmulps  ymm0,ymm0,ymm0
                  vmulps  ymm1,ymm1,ymm1
                  vxorps  ymm4,ymm4,ymm4                          ; ymm4 = (0 ... 0)
                 vmovaps  ymm3,[.k_1_0]                           ; ymm3 = (1.0 ... 1.0)
                 vmovaps  ymm2,[.k_255_0]                         ; ymm2 = (255.0 ... 255.0)
                  vmaxps  ymm0,ymm0,ymm4
                  vmaxps  ymm1,ymm1,ymm4
                  vminps  ymm0,ymm0,ymm3
                  vminps  ymm1,ymm1,ymm3
                  vmulps  ymm0,ymm0,ymm2
                  vmulps  ymm1,ymm1,ymm2
              vcvttps2dq  ymm0,ymm0
              vcvttps2dq  ymm1,ymm1
                  vpslld  ymm0,ymm0,16
                  vpslld  ymm1,ymm1,8
                    vpor  ymm0,ymm0,ymm1
                 vmovdqa  [rbx],xmm0
            vextracti128  [rbx+k_win_width*4],ymm0,1
                     add  rbx,16
                     add  r10d,4
                     cmp  r10d,r12d
                      jb  .for_each_4x2
                     add  rbx,2*(k_win_width*4)-k_tile_width*4
                     sub  r10d,k_tile_width
                     add  r11d,2
                     cmp  r11d,r13d
                      jb  .for_each_4x2
                     jmp  .for_each_tile
    .return:
                     add  rsp,24
                     pop  r15 r14 r13 r12 rbp rbx rdi rsi
                     ret
    align 32
    .k_color: dd 8 dup 0xffffffff
    .k_x_offset: dd 0.5,1.5,2.5,3.5,0.5,1.5,2.5,3.5
    .k_y_offset: dd 0.5,0.5,0.5,0.5,1.5,1.5,1.5,1.5
    .k_win_width_rcp: dd 8 dup 0.0027765625                   ; 1.777f * 2.0f / k_win_width, k_win_width = 1280
    .k_win_height_rcp: dd 8 dup 0.0027777777777778            ; 2.0f / k_win_height, k_win_height = 720
    .k_255_0: dd 8 dup 255.0
    .k_1_0: dd 8 dup 1.0
;========================================================================
  align 16
  get_time:
    virtual at rsp
    .perf_counter dq ?
    .k_stack_size = $-$$
    end virtual
                     sub  rsp,.k_stack_size
                     mov  rax,[get_time@perf_freq]
                    test  eax,eax
                     jnz  @f
                     mov  rcx,get_time@perf_freq
                  invoke  QueryPerformanceFrequency
    @@:              lea  rcx,[.perf_counter]
                  invoke  QueryPerformanceCounter
                     mov  rcx,[.perf_counter]
                     mov  rdx,[get_time@perf_freq]
                  vxorps  xmm0,xmm0,xmm0
               vcvtsi2sd  xmm1,xmm0,rcx
               vcvtsi2sd  xmm2,xmm0,rdx
                  vdivsd  xmm0,xmm1,xmm2
                     add  rsp,.k_stack_size
                     ret
;========================================================================
  align 16
  update_frame_stats:
                     sub  rsp,8
                     mov  rax,[update_frame_stats@prev_time]
                    test  rax,rax
                     jnz  @f
                    call  get_time
                  vmovsd  [update_frame_stats@prev_time],xmm0
                  vmovsd  [update_frame_stats@prev_update_time],xmm0
    @@:             call  get_time                                        ; xmm0 = (0, time)
                  vmovsd  [time],xmm0
                  vsubsd  xmm1,xmm0,[update_frame_stats@prev_time]        ; xmm1 = (0, time_delta)
                  vmovsd  [update_frame_stats@prev_time],xmm0
                  vxorps  xmm2,xmm2,xmm2
               vcvtsd2ss  xmm1,xmm2,xmm1                                  ; xmm1 = (0, 0, 0, time_delta)
                  vmovss  [time_delta],xmm1
                  vmovsd  xmm1,[update_frame_stats@prev_update_time]      ; xmm1 = (0, prev_update_time)
                  vsubsd  xmm2,xmm0,xmm1                                  ; xmm2 = (0, time - prev_update_time)
                  vmovsd  xmm3,[.k_1_0]                                   ; xmm3 = (0, 1.0)
                 vcomisd  xmm2,xmm3
                      jb  @f
                  vmovsd  [update_frame_stats@prev_update_time],xmm0
                     mov  eax,[update_frame_stats@frame]
                  vxorpd  xmm1,xmm1,xmm1
               vcvtsi2sd  xmm1,xmm1,eax                                   ; xmm1 = (0, frame)
                  vdivsd  xmm0,xmm1,xmm2                                  ; xmm0 = (0, frame / (time - prev_update_time))
                  vdivsd  xmm1,xmm2,xmm1
                  vmulsd  xmm1,xmm1,[.k_1000000_0]
               vcvtsd2si  r10,xmm0
               vcvtsd2si  r11,xmm1
                     mov  [update_frame_stats@frame],0
                 cinvoke  wsprintf,win_title,win_title_fmt,r10,r11
                  invoke  SetWindowText,[win_handle],win_title
    @@:              add  [update_frame_stats@frame],1
                     add  rsp,8
                     ret
    align 8
    .k_1_0 dq 1.0
    .k_1000000_0 dq 1000000.0
;========================================================================
  align 16
  update:
                     sub  rsp,8
            vbroadcastss  ymm0,[eyepxyz]
            vbroadcastss  ymm1,[eyepxyz+4]
            vbroadcastss  ymm2,[eyepxyz+8]
            vbroadcastss  ymm3,[eyefxyz]
            vbroadcastss  ymm4,[eyefxyz+4]
            vbroadcastss  ymm5,[eyefxyz+8]
                     mov  [tileidx],0
                    call  generate_fractal
                     add  rsp,8
                     ret
;========================================================================
  align 16
  init:
                     sub  rsp,8
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
                     mov  eax,1
                     add  rsp,8
                     ret
    .error:          xor  eax,eax
                     add  rsp,8
                     ret
;========================================================================
  align 16
  deinit:
                     sub  rsp,8
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
                     ret
;========================================================================
  align 16
  start:
                     sub  rsp,8
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
  time_delta dd 0,0

  get_time@perf_freq dq 0

  update_frame_stats@prev_time dq 0
  update_frame_stats@prev_update_time dq 0
  update_frame_stats@frame dd 0,0

  displayptr dq 0
  tileidx dd 0,0

  eyepxyz dd 0.0,0.0,7.0
  eyefxyz dd 0.0,0.0,0.0

  align 32


;========================================================================
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\gdi32.inc'
;========================================================================