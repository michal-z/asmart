
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
