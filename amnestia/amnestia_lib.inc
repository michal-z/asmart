;========================================================================
falign
load_file:
;------------------------------------------------------------------------
virtual at 0
  rq 7
  .bytes_read dd ?
  align 32
  .k_stack_size = $
end virtual
                       push   rdi rsi rbx
                        sub   rsp,.k_stack_size
                        xor   esi,esi                                 ; file handle
                        xor   edi,edi                                 ; memory pointer
                        mov   edx,GENERIC_READ
                        xor   r8d,r8d
                        xor   r9d,r9d
                        mov   dword[rsp+32],OPEN_EXISTING
                        mov   dword[rsp+40],FILE_ATTRIBUTE_NORMAL
                        mov   [rsp+48],r9
                       call   [CreateFile]
                        cmp   rax,INVALID_HANDLE_VALUE
                         je   .err
                        mov   rsi,rax
                        mov   rcx,rsi
                        xor   edx,edx
                       call   [GetFileSize]
                        cmp   eax,INVALID_FILE_SIZE
                         je   .err
                        mov   ebx,eax
                  mem_alloc   ebx
                       test   rax,rax
                         jz   .err
                        mov   rdi,rax
                        mov   rcx,rsi
                        mov   rdx,rdi
                        mov   r8d,ebx
                        lea   r9,[.bytes_read+rsp]
                        mov   qword[rsp+32],0
                       call   [ReadFile]
                       test   eax,eax
                         jz   .err
                        cmp   [.bytes_read+rsp],ebx
                        jne   .err
                        mov   rcx,rsi
                       call   [CloseHandle]
                        mov   rax,rdi
                        mov   edx,ebx
                        jmp   .ret
  .err:                test   rsi,rsi
                         jz   @f
                        mov   rcx,rsi
                       call   [CloseHandle]
  @@:                  test   rdi,rdi
                         jz   @f
                   mem_free   rdi
  @@:                   xor   eax,eax
                        xor   edx,edx
  .ret:                 add   rsp,.k_stack_size
                        pop   rbx rsi rdi
                        ret
;=============================================================================
