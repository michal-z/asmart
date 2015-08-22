
; Macroinstructions for making import section (64-bit) [taken from fasm package]

macro library [name,string]
 { common
    import.data:
   forward
    local _label
    if defined name#.redundant
     if ~ name#.redundant
      dd RVA name#.lookup,0,0,RVA _label,RVA name#.address
     end if
    end if
    name#.referred = 1
   common
    dd 0,0,0,0,0
   forward
    if defined name#.redundant
     if ~ name#.redundant
      _label db string,0
             rb RVA $ and 1
     end if
    end if }

macro import name,[label,string]
 { common
    rb (- rva $) and 7
    if defined name#.referred
     name#.lookup:
   forward
     if used label
      if string eqtype ''
       local _label
       dq RVA _label
      else
       dq 8000000000000000h + string
      end if
     end if
   common
     if $ > name#.lookup
      name#.redundant = 0
      dq 0
     else
      name#.redundant = 1
     end if
     name#.address:
   forward
     if used label
      if string eqtype ''
       label dq RVA _label
      else
       label dq 8000000000000000h + string
      end if
     end if
   common
     if ~ name#.redundant
      dq 0
     end if
   forward
     if used label & string eqtype ''
     _label dw 0
            db string,0
            rb RVA $ and 1
     end if
   common
    end if }

; Windows structures

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

; Windows constants

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
