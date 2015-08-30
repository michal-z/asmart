
; structures

struc POINT p0,p1
{
  .x dd p0
  .y dd p1
}

struc MSG p0,p1,p2,p3,p4,p5
{
    .hwnd    dq    p0
    .message dd    p1,?
    .wParam  dq    p2
    .lParam  dq    p3
    .time    dd    p4
    .pt      POINT p5
             dd    ?
}

struc WNDCLASSEX p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10
{
    .cbSize        dd 80
    .style         dd p0
    .lpfnWndProc   dq p1
    .cbClsExtra    dd p2
    .cbWndExtra    dd p3
    .hInstance     dq p4
    .hIcon         dq p5
    .hCursor       dq p6
    .hbrBackground dq p7
    .lpszMenuName  dq p8
    .lpszClassName dq p9
    .hIconSm       dq p10
}

struc RECT p0,p1,p2,p3
{
    .left   dd p0
    .top    dd p1
    .right  dd p2
    .bottom dd p3
}

; constants

EVENT_ALL_ACCESS = 000f0000h+00100000h+3h

INFINITE = 0xffffffff

INVALID_HANDLE_VALUE = 0xffffffffffffffff

INVALID_FILE_SIZE = 0xffffffff

CREATE_NEW        = 1
CREATE_ALWAYS     = 2
OPEN_EXISTING     = 3
OPEN_ALWAYS       = 4
TRUNCATE_EXISTING = 5

GENERIC_READ    = 0x80000000
GENERIC_WRITE   = 0x40000000
GENERIC_EXECUTE = 0x20000000
GENERIC_ALL     = 0x10000000

FILE_ATTRIBUTE_NORMAL = 0x00000080

IDC_ARROW       = 32512

IDI_APPLICATION = 32512

WS_OVERLAPPED   = 000000000h
WS_CAPTION      = 000C00000h
WS_SYSMENU      = 000080000h
WS_VISIBLE      = 010000000h
WS_MINIMIZEBOX  = 000020000h

CW_USEDEFAULT = 80000000h

PM_REMOVE   = 0001h

WM_QUIT                   = 0012h
WM_KEYDOWN                = 0100h
WM_DESTROY                = 0002h

VK_ESCAPE    = 01Bh

macro $invoke proc,[arg]
 { common $fastcall [proc],arg }

macro $fastcall proc,[arg]
 { common local counter
    counter = 0
   forward
    counter = counter + 1
    define type@param
    define definition@param arg
    match =float value,definition@param
    \{ define definition@param value
       define type@param float \}
    match =addr value,definition@param
    \{ define definition@param value
       define type@param addr \}
    match any=,any,definition@param
    \{ \local ..string,..continue
       jmp ..continue
       align sizeof.TCHAR
       ..string TCHAR definition@param,0
       ..continue:
       define definition@param ..string
       define type@param addr \}
    match any,definition@param
    \{ match \`any,any
       \\{ \\local ..string,..continue
           jmp ..continue
           align sizeof.TCHAR
           ..string TCHAR definition@param,0
           ..continue:
           define definition@param ..string
           define type@param addr \\} \}
    match param,definition@param
    \{ local opcode,origin
       size@param = 0
       if param eqtype 0 | param eqtype 0f | type@param eq addr
        size@param = 8
       else if param eqtype byte 0 | param eqtype byte 0f
        match prefix value,definition@param
         \\{ if prefix eq qword
              size@param = 8
             else if prefix eq dword
              size@param = 4
             else if prefix eq word
              size@param = 2
             else if prefix eq byte
              size@param = 1
             end if \\}
       else if ~ param in <xmm0,xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15>
        virtual
         origin = $
         inc param
         load opcode byte from origin
         if opcode = 67h | opcode = 41h
          load opcode byte from origin+1
         end if
         if opcode and 0F8h = 48h
          size@param = 8
         else if opcode = 66h
          size@param = 2
         else if opcode = 0FFh
          size@param = 4
         else
          size@param = 1
         end if
        end virtual
       end if
       if counter = 1
        if type@param eq float
         if ~ param eq xmm0
          if size@param = 4
           if param eqtype byte 0 | param eqtype byte 0f
            mov eax,param
            movd xmm0,eax
           else
            movd xmm0,param
           end if
          else
           if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
            mov rax,param
            movq xmm0,rax
           else
            movq xmm0,param
           end if
          end if
         end if
         if vararg@fastcall & ~ param eq rcx
           movq rcx,xmm0
         end if
        else if type@param eq addr
         if ~ param eq rcx
          lea rcx,[param]
         end if
        else if size@param = 8
         if ~ param eq rcx
          mov rcx,param
         end if
        else if size@param = 4
         if ~ param eq ecx
          mov ecx,param
         end if
        else if size@param = 2
         if ~ param eq cx
          mov cx,param
         end if
        else if size@param = 1
         if ~ param eq cl
          mov cl,param
         end if
        end if
       else if counter = 2
        if type@param eq float
         if ~ param eq xmm1
          if size@param = 4
           if param eqtype byte 0 | param eqtype byte 0f
            mov eax,param
            movd xmm1,eax
           else
            movd xmm1,param
           end if
          else
           if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
            mov rax,param
            movq xmm1,rax
           else
            movq xmm1,param
           end if
          end if
         end if
         if vararg@fastcall & ~ param eq rdx
           movq rdx,xmm1
         end if
        else if type@param eq addr
         if ~ param eq rdx
          lea rdx,[param]
         end if
        else if size@param = 8
         if ~ param eq rdx
          mov rdx,param
         end if
        else if size@param = 4
         if ~ param eq edx
          mov edx,param
         end if
        else if size@param = 2
         if ~ param eq dx
          mov dx,param
         end if
        else if size@param = 1
         if ~ param eq dl
          mov dl,param
         end if
        end if
       else if counter = 3
        if type@param eq float
         if ~ param eq xmm2
          if size@param = 4
           if param eqtype byte 0 | param eqtype byte 0f
            mov eax,param
            movd xmm2,eax
           else
            movd xmm2,param
           end if
          else
           if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
            mov rax,param
            movq xmm2,rax
           else
            movq xmm2,param
           end if
          end if
         end if
         if vararg@fastcall & ~ param eq r8
           movq r8,xmm2
         end if
        else if type@param eq addr
         if ~ param eq r8
          lea r8,[param]
         end if
        else if size@param = 8
         if ~ param eq r8
          mov r8,param
         end if
        else if size@param = 4
         if ~ param eq r8d
          mov r8d,param
         end if
        else if size@param = 2
         if ~ param eq r8w
          mov r8w,param
         end if
        else if size@param = 1
         if ~ param eq r8b
          mov r8b,param
         end if
        end if
       else if counter = 4
        if type@param eq float
         if ~ param eq xmm3
          if size@param = 4
           if param eqtype byte 0 | param eqtype byte 0f
            mov eax,param
            movd xmm3,eax
           else
            movd xmm3,param
           end if
          else
           if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
            mov rax,param
            movq xmm3,rax
           else
            movq xmm3,param
           end if
          end if
         end if
         if vararg@fastcall & ~ param eq r9
           movq r9,xmm3
         end if
        else if type@param eq addr
         if ~ param eq r9
          lea r9,[param]
         end if
        else if size@param = 8
         if ~ param eq r9
          mov r9,param
         end if
        else if size@param = 4
         if ~ param eq r9d
          mov r9d,param
         end if
        else if size@param = 2
         if ~ param eq r9w
          mov r9w,param
         end if
        else if size@param = 1
         if ~ param eq r9b
          mov r9b,param
         end if
        end if
       else
         if type@param eq addr
          lea rax,[param]
          mov [rsp+(counter-1)*8],rax
         else if param eqtype [0] | param eqtype byte [0]
          if size@param = 8
           mov rax,param
           mov [rsp+(counter-1)*8],rax
          else if size@param = 4
           mov eax,param
           mov [rsp+(counter-1)*8],eax
          else if size@param = 2
           mov ax,param
           mov [rsp+(counter-1)*8],ax
          else
           mov al,param
           mov [rsp+(counter-1)*8],al
          end if
         else if size@param = 8
          virtual
           origin = $
           mov rax,param
           load opcode byte from origin+1
          end virtual
          if opcode = 0B8h
           mov rax,param
           mov [rsp+(counter-1)*8],rax
          else
           mov qword [rsp+(counter-1)*8],param
          end if
         else if param in <xmm0,xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15>
          movq [rsp+(counter-1)*8],param
         else
          mov [rsp+(counter-1)*8],param
         end if
       end if \}
   common
    call proc }

macro $comcall handle,interfaceproc,[arg]
 { common
    macro call dummy
    \{ if handle eqtype rcx | handle eqtype 0
        local ..handle
        label ..handle at handle
        mov rax,[..handle]
       else
        mov rcx,handle
        mov rax,[rcx]
       end if
       call [rax+interfaceproc] \}
    $fastcall ,rcx,arg
    purge call }

macro $comcallv handle,vtable,interfaceproc,[arg]
 { common
    macro call dummy
    \{ call [vtable+interfaceproc] \}
    $fastcall ,handle,arg
    purge call }