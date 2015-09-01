
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

k_funcparam5 = 32
k_funcparam6 = k_funcparam5 + 8
k_funcparam7 = k_funcparam6 + 8
k_funcparam8 = k_funcparam7 + 8
k_funcparam9 = k_funcparam8 + 8
k_funcparam10 = k_funcparam9 + 8
k_funcparam11 = k_funcparam10 + 8
k_funcparam12 = k_funcparam11 + 8
