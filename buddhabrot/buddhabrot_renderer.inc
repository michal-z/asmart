;=============================================================================
; in: ecx - thread id
align 32
generate_image:
;-----------------------------------------------------------------------------
virtual at 0
  rq 4
  .k_stack_size = $+16
end virtual
        push        rdi
        sub         rsp,.k_stack_size
        mov         rdi,[thread_xyseq+rcx*8]
        mov         ecx,100000
  .loop:
  ; generate u64 random numbers
  @@:   rdrand      rax
        jnc         @b
  @@:   rdrand      rdx
        jnc         @b
  ; convert u64 to [0.0 1.0) double
        vmovsd      xmm2,[k_1_div_2pow53]
        shr         rax,11                      ; discard 11 LSB
        shr         rdx,11                      ; discard 11 LSB
        mov         [rsp],rax
        mov         [rsp+8],rdx
        fild        qword[rsp]
        fild        qword[rsp+8]
        fstp        qword[rsp+8]
        fstp        qword[rsp]
        vmovq       xmm0,[rsp]
        vmovq       xmm1,[rsp+8]
        vmulsd      xmm0,xmm0,xmm2
        vmulsd      xmm1,xmm1,xmm2
  ; map to [-3.0 3.0) range
        vmovsd      xmm3,[k_6_0]
        vmovsd      xmm4,[k_3_0]
        vfmsub132sd xmm0,xmm4,xmm3
        vfmsub132sd xmm1,xmm4,xmm3
  ; x = 0, y = 0
        vxorpd      xmm2,xmm2,xmm2
        vxorpd      xmm3,xmm3,xmm3
        xor         eax,eax
        vmovsd      xmm6,[k_10_0]
  .iterate:
  ; xnew = x * x - y * y + x0
        vmovapd     xmm4,xmm0
        vfnmadd231sd xmm4,xmm3,xmm3
        vfmadd231sd xmm4,xmm2,xmm2
  ; ynew = 2 * x * y + y0
        vaddsd      xmm5,xmm2,xmm2
        vfmadd132sd xmm5,xmm1,xmm3
        vmovsd      [rdi+rax],xmm4
        vmovsd      [rdi+rax+8],xmm5
        vmovapd     xmm2,xmm4
        vmovapd     xmm3,xmm5
  ; break if (xnew*xnew + ynew*ynew) > 10.0
        vmulsd      xmm4,xmm4,xmm4
        vmulsd      xmm5,xmm5,xmm5
        vaddsd      xmm4,xmm4,xmm5
        vcomisd     xmm4,xmm6
        ja          .update_density
        add         eax,16
        cmp         eax,k_bailout*16
        jb          .iterate
        sub         ecx,1
        jnz         .loop
        jmp         .ret
  .update_density:
        xor         edx,edx
        vmovsd      xmm6,[k_view_bias]
        vmovsd      xmm7,[k_view_scale]
  .for_each_point:
        vmovsd      xmm0,[rdi+rdx]
        vmovsd      xmm1,[rdi+rdx+8]
        vaddsd      xmm0,xmm0,[k_0_5]
        vsubsd      xmm1,xmm1,[k_0_5]
        vfmadd213sd xmm0,xmm7,xmm6
        vfmadd213sd xmm1,xmm7,xmm6
        vcvttsd2si  r8d,xmm0
        vcvttsd2si  r9d,xmm1
        test        r8d,r8d
        js          @f
        test        r9d,r9d
        js          @f
        cmp         r8d,k_win_width
        jae         @f
        cmp         r9d,k_win_height
        jae         @f
        imul        r9d,k_win_width
        add         r9d,r8d
        shl         r9d,2
        mov         r8,[density]
        lock add    dword[r8+r9],1
  @@:   add         edx,16
        cmp         edx,eax
        jbe         .for_each_point
        sub         ecx,1
        jnz         .loop
  .ret: add         rsp,.k_stack_size
        pop         rdi
        ret
;=============================================================================