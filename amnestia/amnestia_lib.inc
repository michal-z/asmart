;========================================================================
FALIGN
load_file:
;------------------------------------------------------------------------
virtual at 0
  rq 7
  .bytes_read dd ?
  align 32
  .k_stack_size = $
end virtual
        push rdi rsi rbx
        sub rsp,.k_stack_size
        xor esi,esi                                 ; file handle
        xor edi,edi                                 ; memory pointer
        mov edx,GENERIC_READ
        xor r8d,r8d
        xor r9d,r9d
        mov dword[k_funcparam5+rsp],OPEN_EXISTING
        mov dword[k_funcparam6+rsp],FILE_ATTRIBUTE_NORMAL
        mov [k_funcparam7+rsp],r9
        call [CreateFile]
        cmp rax,INVALID_HANDLE_VALUE
        je .err
        mov rsi,rax
        mov rcx,rsi
        xor edx,edx
        call [GetFileSize]
        cmp eax,INVALID_FILE_SIZE
        je .err
        mov ebx,eax
        MALLOC ebx
        test rax,rax
        jz .err
        mov rdi,rax
        mov rcx,rsi
        mov rdx,rdi
        mov r8d,ebx
        lea r9,[.bytes_read+rsp]
        mov qword[k_funcparam5+rsp],0
        call [ReadFile]
        test eax,eax
        jz .err
        cmp [.bytes_read+rsp],ebx
        jne .err
        mov rcx,rsi
        call [CloseHandle]
        mov rax,rdi
        mov edx,ebx
        jmp .ret
  .err: test rsi,rsi
        jz @f
        mov rcx,rsi
        call [CloseHandle]
  @@:   test rdi,rdi
        jz @f
        FREE rdi
  @@:   xor eax,eax
        xor edx,edx
  .ret: add rsp,.k_stack_size
        pop rbx rsi rdi
        ret
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
