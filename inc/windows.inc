INFINITE = 0xffffffff
IDI_APPLICATION = 32512
IDC_ARROW = 32512
WS_VISIBLE = 010000000h
WS_OVERLAPPED = 000000000h
WS_CAPTION = 000C00000h
WS_SYSMENU = 000080000h
WS_VISIBLE = 010000000h
WS_MINIMIZEBOX = 000020000h
CW_USEDEFAULT = 80000000h
PM_REMOVE = 0001h
WM_QUIT = 0012h
WM_KEYDOWN = 0100h
WM_DESTROY = 0002h
VK_ESCAPE = 01Bh
SRCCOPY = 0x00CC0020
OPEN_EXISTING = 3
GENERIC_READ = 0x80000000
INVALID_HANDLE_VALUE = 0xffffffffffffffff
INVALID_FILE_SIZE = 0xffffffff
FILE_ATTRIBUTE_NORMAL = 128
EVENT_ALL_ACCESS = 0x1F0003
PFD_TYPE_RGBA = 0
PFD_DOUBLEBUFFER = 0x00000001
PFD_DRAW_TO_WINDOW = 0x00000004
PFD_SUPPORT_OPENGL = 0x00000020

k_funcparam5 = 32
k_funcparam6 = k_funcparam5 + 8
k_funcparam7 = k_funcparam6 + 8
k_funcparam8 = k_funcparam7 + 8
k_funcparam9 = k_funcparam8 + 8
k_funcparam10 = k_funcparam9 + 8
k_funcparam11 = k_funcparam10 + 8
k_funcparam12 = k_funcparam11 + 8

struc POINT {
.x dd 0
.y dd 0 }

struc MSG {
.hwnd    dq    0
.message dd    0,0
.wParam  dq    0
.lParam  dq    0
.time    dd    0
.pt      POINT
         dd    0 }

struc WNDCLASS proc,name {
.style         dd 0,0
.lpfnWndProc   dq proc
.cbClsExtra    dd 0
.cbWndExtra    dd 0
.hInstance     dq 0
.hIcon         dq 0
.hCursor       dq 0
.hbrBackground dq 0
.lpszMenuName  dq 0
.lpszClassName dq name }

struc RECT l,t,r,b {
.left   dd l
.top    dd t
.right  dd r
.bottom dd b }

struc PIXELFORMATDESCRIPTOR {
.nSize           dw 40
.nVersion        dw 1
.dwFlags         dd PFD_DRAW_TO_WINDOW+PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER
.iPixelType      db PFD_TYPE_RGBA
.cColorBits      db 32
.cRedBits        db 0
.cRedShift       db 0
.cGreenBits      db 0
.cGreenShift     db 0
.cBlueBits       db 0
.cBlueShift      db 0
.cAlphaBits      db 0
.cAlphaShift     db 0
.cAccumBits      db 0
.cAccumRedBits   db 0
.cAccumGreenBits db 0
.cAccumBlueBits  db 0
.cAccumAlphaBits db 0
.cDepthBits      db 24
.cStencilBits    db 8
.cAuxBuffers     db 0
.iLayerType      db 0
.bReserved       db 0
.dwLayerMask     dd 0
.dwVisibleMask   dd 0
.dwDamageMask    dd 0 }

struc BITMAPINFOHEADER w,h,b,s {
.biSize          dd 40
.biWidth         dd w
.biHeight        dd h
.biPlanes        dw 1
.biBitCount      dw b
.biCompression   dd 0
.biSizeImage     dd s
.biXPelsPerMeter dd 0
.biYPelsPerMeter dd 0
.biClrUsed       dd 0
.biClrImportant  dd 0 }

struc SYSTEM_INFO {
.dwOemId                     dd 0
.dwPageSize                  dd 0
.lpMinimumApplicationAddress dq 0
.lpMaximumApplicationAddress dq 0
.dwActiveProcessorMask       dq 0
.dwNumberOfProcessors        dd 0
.dwProcessorType             dd 0
.dwAllocationGranularity     dd 0
.wProcessorLevel             dw 0
.wProcessorRevision          dw 0 }

; vim: set ft=fasm:
