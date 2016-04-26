format PE64 GUI 4.0
entry start

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
  FILE_FLAG_SEQUENTIAL_SCAN = 0x08000000
  EVENT_ALL_ACCESS = 0x1F0003

  CLSCTX_INPROC_SERVER = 0x1
  CLSCTX_INPROC_HANDLER = 0x2
  CLSCTX_LOCAL_SERVER = 0x4
  CLSCTX_REMOTE_SERVER = 0x10
  CLSCTX_ALL = CLSCTX_INPROC_SERVER+CLSCTX_INPROC_HANDLER+CLSCTX_LOCAL_SERVER+CLSCTX_REMOTE_SERVER
  eRender = 0
  eConsole = 0
  WAVE_FORMAT_PCM = 1
  AUDCLNT_SHAREMODE_EXCLUSIVE = 1
  AUDCLNT_STREAMFLAGS_EVENTCALLBACK = 0x00040000
  AUDCLNT_E_BUFFER_SIZE_NOT_ALIGNED = 0x88890019

struc POINT {
  .x dd ?
  .y dd ? }

struc MSG {
  .hwnd dq ?
  .message dd ?,?
  .wParam dq ?
  .lParam dq ?
  .time dd ?
  .pt POINT
  dd ? }

struc WNDCLASS {
  .style dd ?,?
  .lpfnWndProc dq ?
  .cbClsExtra dd ?
  .cbWndExtra dd ?
  .hInstance dq ?
  .hIcon dq ?
  .hCursor dq ?
  .hbrBackground dq ?
  .lpszMenuName dq ?
  .lpszClassName dq ? }

struc RECT {
  .left dd ?
  .top dd ?
  .right dd ?
  .bottom dd ? }

struc WAVEFORMATEX p0,p1,p2,p3,p4,p5 {
  .wFormatTag dw p0
  .nChannels dw p1
  .nSamplesPerSec dd p2
  .nAvgBytesPerSec dd p3
  .nBlockAlign dw p4
  .wBitsPerSample dw p5
  .cbSize dw 0
  dw 0 }

struc GUID p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10 {
  dd p0
  dw p1
  dw p2
  db p3
  db p4
  db p5
  db p6
  db p7
  db p8
  db p9
  db p10 }

macro struc_offsets_size s {
virtual at 0
  s s
  sizeof.#s = $
end virtual }

include 'd3d12.inc'

virtual at 0
  IUnknown:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
end virtual

virtual at 0
  IMMDeviceEnumerator:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .EnumAudioEndpoints rq 1
    .GetDefaultAudioEndpoint rq 1
    .GetDevice rq 1
    .RegisterEndpointNotificationCallback rq 1
    .UnregisterEndpointNotificationCallback rq 1
end virtual

virtual at 0
  IMMDevice:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .Activate rq 1
    .OpenPropertyStore rq 1
    .GetId rq 1
    .GetState rq 1
end virtual

virtual at 0
  IAudioClient:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .Initialize rq 1
    .GetBufferSize rq 1
    .GetStreamLatency rq 1
    .GetCurrentPadding rq 1
    .IsFormatSupported rq 1
    .GetMixFormat rq 1
    .GetDevicePeriod rq 1
    .Start rq 1
    .Stop rq 1
    .Reset rq 1
    .SetEventHandle rq 1
    .GetService rq 1
end virtual

virtual at 0
  IAudioRenderClient:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetBuffer rq 1
    .ReleaseBuffer rq 1
end virtual
;========================================================================
macro emit [inst] {
  forward
                       inst }
macro iaca_begin {
                        mov   ebx,111
                         db   $64,$67,$90 }
macro iaca_end {
                        mov   ebx,222
                         db   $64,$67,$90 }
macro malloc size* {
                        mov   rcx,[process_heap]
                        xor   edx,edx
                        mov   r8d,size
                       call   [HeapAlloc] }
macro free ptr* {
  local .end
                        mov   r8,ptr
                       test   r8,r8
                         jz   .end
                        mov   rcx,[process_heap]
                        xor   edx,edx
                       call   [HeapFree]
  .end: }

macro safe_close handle* {
  local .end
                        mov   rcx,handle
                       test   rcx,rcx
                         jz   .end
                       call   [CloseHandle]
                        mov   handle,0
  .end: }

macro safe_release iface* {
  local .end
                        mov   rcx,iface
                       test   rcx,rcx
                         jz   .end
                        mov   rax,[rcx]
                       call   [IUnknown.Release+rax]
                        mov   iface,0
  .end: }

macro falign { align 16 }

macro debug_break {
                       int3
                        nop }

macro transition_barrier ptr*,res*,sbefore*,safter* {
                        mov   [ptr+D3D12_RESOURCE_BARRIER.Transition.pResource],res
                        mov   [ptr+D3D12_RESOURCE_BARRIER.Transition.StateBefore],sbefore
                        mov   [ptr+D3D12_RESOURCE_BARRIER.Transition.StateAfter],safter }

macro mov3 dst*,reg*,mem* {
                        mov   reg,mem
                        mov   dst,reg }

macro lea3 dst*,reg*,mem* {
                        lea   reg,mem
                        mov   dst,reg }

macro zero_stack size* {
                      vpxor   ymm0,ymm0,ymm0
                        xor   eax,eax
                        mov   ecx,size/32
  @@:               vmovdqa   [rsp+rax],ymm0
                        add   eax,32
                        sub   ecx,1
                        jnz   @b }
macro comcall target {
                        mov   rax,[rcx]
                       call   [rax+target] }
macro icall target {
                       call   [target] }
macro checkhr res,err {
                        test  res,res
                          js  err }

k_frame_count equ 3
k_win_style equ WS_OVERLAPPED+WS_SYSMENU+WS_CAPTION+WS_MINIMIZEBOX
k_swapchain_buffer_count equ 4
;=============================================================================
section '.text' code readable executable

program_section = 'code'
include 'amnestia_demo.inc'
include 'amnestia_audio.inc'
include 'amnestia_math.inc'
include 'amnestia_scene1.inc'
include 'amnestia_lib.inc'
;=============================================================================
falign
check_cpu_extensions:
;-----------------------------------------------------------------------------
                        mov   eax,1
                      cpuid
                        and   ecx,$58001000          ; check RDRAND,AVX,OSXSAVE,FMA
                        cmp   ecx,$58001000
                        jne   .not_supported
                        mov   eax,7
                        xor   ecx,ecx
                      cpuid
                        and   ebx,$20                ; check AVX2
                        cmp   ebx,$20
                        jne   .not_supported
                        xor   ecx,ecx
                     xgetbv
                        and   eax,$6                 ; check OS support
                        cmp   eax,$6
                        jne   .not_supported
                        mov   eax,1
                        jmp   .ret
  .not_supported:
                        xor   eax,eax
  .ret:                 ret
;=============================================================================
falign
get_time:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub   rsp,.k_stack_size
                        mov   rax,[.perf_freq]
                       test   rax,rax
                        jnz   @f
                        lea   rcx,[.perf_freq]
                       call   [QueryPerformanceFrequency]
                        lea   rcx,[.first_perf_counter]
                       call   [QueryPerformanceCounter]

  @@:                   lea   rcx,[.perf_counter]
                       call   [QueryPerformanceCounter]
                        mov   rcx,[.perf_counter]
                        sub   rcx,[.first_perf_counter]
                        mov   rdx,[.perf_freq]
                     vxorps   xmm0,xmm0,xmm0
                  vcvtsi2sd   xmm1,xmm0,rcx
                  vcvtsi2sd   xmm2,xmm0,rdx
                     vdivsd   xmm0,xmm1,xmm2
                        add   rsp,.k_stack_size
                        ret
;=============================================================================
falign
update_frame_stats:
;-----------------------------------------------------------------------------
virtual at 0
  rq 4
  .text rb 64
  align 32
  .k_stack_size = $+24
end virtual
                        sub   rsp,.k_stack_size
                        mov   rax,[.prev_time]
                       test   rax,rax
                        jnz   @f
                       call   get_time
                     vmovsd   [.prev_time],xmm0
                     vmovsd   [.prev_update_time],xmm0
  @@:                  call   get_time                     ; xmm0 = (0,time)
                     vmovsd   [time],xmm0
                     vsubsd   xmm1,xmm0,[.prev_time]       ; xmm1 = (0,time_delta)
                     vmovsd   [.prev_time],xmm0
                     vxorps   xmm2,xmm2,xmm2
                  vcvtsd2ss   xmm1,xmm2,xmm1               ; xmm1 = (0,0,0,time_delta)
                     vmovss   [time_delta],xmm1
                     vmovsd   xmm1,[.prev_update_time]     ; xmm1 = (0,prev_update_time)
                     vsubsd   xmm2,xmm0,xmm1               ; xmm2 = (0,time-prev_update_time)
                     vmovsd   xmm3,[.k_1_0]                ; xmm3 = (0,1.0)
                    vcomisd   xmm2,xmm3
                         jb   @f
                     vmovsd   [.prev_update_time],xmm0
                        mov   eax,[.frame]
                     vxorpd   xmm1,xmm1,xmm1
                  vcvtsi2sd   xmm1,xmm1,eax                ; xmm1 = (0,frame)
                     vdivsd   xmm0,xmm1,xmm2               ; xmm0 = (0,frame/(time-prev_update_time))
                     vdivsd   xmm1,xmm2,xmm1
                     vmulsd   xmm1,xmm1,[.k_1000000_0]
                        mov   [.frame],0
                        lea   rcx,[.text+rsp]
                        lea   rdx,[.k_win_text_fmt]
                  vcvtsd2si   r8,xmm0
                  vcvtsd2si   r9,xmm1
                       call   [wsprintf]
                        mov   rcx,[win_handle]
                        lea   rdx,[.text+rsp]
                       call   [SetWindowText]
  @@:                   add   [.frame],1
                        add   rsp,.k_stack_size
                        ret
  align 1
  .k_win_text_fmt db '[%d fps  %d us] amnestia',0
  align 8
  .k_1000000_0 dq 1000000.0
  .k_1_0 dq 1.0
;=============================================================================
falign
init_window:
;-----------------------------------------------------------------------------
virtual at 0
  rq 12
  .wc WNDCLASS
  align 8
  .rect RECT
  align 32
  .k_stack_size = $+16
end virtual
                       push   rsi
                            ; alloc and clear the stack
                        sub   rsp,.k_stack_size
                 zero_stack   .k_stack_size
                            ; create window class
                       lea3   [.wc.lpfnWndProc+rsp],rax,[winproc]
                       lea3   [.wc.lpszClassName+rsp],rax,[k_win_class_name]
                        xor   ecx,ecx
                       call   [GetModuleHandle]
                        mov   [.wc.hInstance+rsp],rax
                        xor   ecx,ecx
                        mov   edx,IDC_ARROW
                       call   [LoadCursor]
                        mov   [.wc.hCursor+rsp],rax
                        lea   rcx,[.wc+rsp]
                       call   [RegisterClass]
                       test   eax,eax
                         jz   .error
                            ; compute window size
                       mov3   [.rect.right+rsp],eax,[win_width]
                       mov3   [.rect.bottom+rsp],eax,[win_height]
                        lea   rcx,[.rect+rsp]
                        mov   edx,k_win_style
                        xor   r8d,r8d
                       call   [AdjustWindowRect]
                        mov   r10d,[.rect.right+rsp]
                        mov   r11d,[.rect.bottom+rsp]
                        sub   r10d,[.rect.left+rsp]
                        sub   r11d,[.rect.top+rsp]
                            ; create window
                        xor   ecx,ecx
                        lea   rdx,[k_win_class_name]
                        mov   r8,rdx
                        mov   r9d,WS_VISIBLE+k_win_style
                        mov   eax,CW_USEDEFAULT
                        mov   [rsp+32],eax
                        mov   [rsp+40],eax
                        mov   [rsp+48],r10d
                        mov   [rsp+56],r11d
                        mov   [rsp+64],ecx
                        mov   [rsp+72],ecx
                       mov3   [rsp+80],rax,[.wc.hInstance+rsp]
                        mov   [rsp+88],ecx
                       call   [CreateWindowEx]
                        mov   [win_handle],rax
                       test   rax,rax
                         jz   .error
                            ; success
                        mov   eax,1
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
  .error:               xor   eax,eax
                        add   rsp,.k_stack_size
                        pop   rsi
                        ret
;=============================================================================
falign
init:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub   rsp,.k_stack_size
                            ; check cpu
                       call   check_cpu_extensions
                       test   eax,eax
                         jz   .error
                            ; get process heap
                       call   [GetProcessHeap]
                        mov   [process_heap],rax
                       test   rax,rax
                         jz   .error
                            ; create window
                       call   init_window
                       test   eax,eax
                         jz   .error
                            ; init demo
                       call   demo_init
                       test   eax,eax
                         jz   .error
                            ; success
                        mov   eax,1
                        add   rsp,.k_stack_size
                        ret
  .error:               xor   eax,eax
                        add   rsp,.k_stack_size
                        ret
;=============================================================================
falign
deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub   rsp,.k_stack_size
                       call   demo_deinit
                        add   rsp,.k_stack_size
                        ret
;=============================================================================
falign
update:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
                        sub   rsp,.k_stack_size
                       call   update_frame_stats
                       call   demo_update
                        add   rsp,.k_stack_size
                        ret
;=============================================================================
falign
start:
;-----------------------------------------------------------------------------
virtual at 0
  rq 5
  .msg MSG
  align 32
  .k_stack_size = $
end virtual
                        and   rsp,-32
                        sub   rsp,.k_stack_size
                       call   init
                       test   eax,eax
                         jz   .quit
  .main_loop:
                        lea   rcx,[.msg+rsp]
                        xor   edx,edx
                        xor   r8d,r8d
                        xor   r9d,r9d
                        mov   dword[rsp+32],PM_REMOVE
                       call   [PeekMessage]
                       test   eax,eax
                         jz   .update

                        lea   rcx,[.msg+rsp]
                       call   [DispatchMessage]
                        cmp   [.msg.message+rsp],WM_QUIT
                         je   .quit

                        jmp   .main_loop
  .update:
                       call   update
                        jmp   .main_loop
  .quit:
                       call   deinit
                        xor   ecx,ecx
                       call   [ExitProcess]
;=============================================================================
falign
winproc:
;-----------------------------------------------------------------------------
  .k_stack_size = 16*2+8
                        sub   rsp,.k_stack_size
                        cmp   edx,WM_KEYDOWN
                         je   .keydown
                        cmp   edx,WM_DESTROY
                         je   .destroy
                       call   [DefWindowProc]
                        jmp   .return
  .keydown:
                        cmp   r8d,VK_ESCAPE
                        jne   .return
                        xor   ecx,ecx
                       call   [PostQuitMessage]
                        xor   eax,eax
                        jmp   .return
  .destroy:
                        xor   ecx,ecx
                       call   [PostQuitMessage]
                        xor   eax,eax
  .return:
                        add   rsp,.k_stack_size
                        ret
;========================================================================
section '.data' data readable

  program_section = 'cdata'
  include 'amnestia_math.inc'

  align 1
  k_win_class_name db 'amnestia',0

  align 8
  CLSID_MMDeviceEnumerator GUID 0xBCDE0395,0xE52F,0x467C,0x8E,0x3D,0xC4,0x57,0x92,0x91,0x69,0x2E
  IID_IMMDeviceEnumerator GUID 0xA95664D2,0x9614,0x4F35,0xA7,0x46,0xDE,0x8D,0xB6,0x36,0x17,0xE6
  IID_IAudioClient GUID 0x1CB9AD4C,0xDBFA,0x4c32,0xB1,0x78,0xC2,0xF5,0x68,0xA7,0x03,0xB2
  IID_IAudioRenderClient GUID 0xF294ACFC,0x3146,0x4483,0xA7,0xBF,0xAD,0xDC,0xA7,0xC2,0x60,0xE2

  IID_IDXGISwapChain3 GUID 0x94d99bdb,0xf1f8,0x4ab0,0xb2,0x36,0x7d,0xa0,0x17,0x0e,0xda,0xb1
  IID_IDXGIFactory4 GUID 0x1bc6ea02,0xef36,0x464f,0xbf,0x0c,0x21,0xca,0x39,0xe5,0x16,0x8a
  IID_ID3D12Device GUID 0x189819f1,0x1db6,0x4b57,0xbe,0x54,0x18,0x21,0x33,0x9b,0x85,0xf7
  IID_ID3D12Debug GUID 0x344488b7,0x6846,0x474b,0xb9,0x89,0xf0,0x27,0x44,0x82,0x45,0xe0
  IID_ID3D12CommandQueue GUID 0x0ec870a6,0x5d7e,0x4c22,0x8c,0xfc,0x5b,0xaa,0xe0,0x76,0x16,0xed
  IID_ID3D12CommandAllocator GUID 0x6102dee4,0xaf59,0x4b09,0xb9,0x99,0xb4,0x4d,0x73,0xf0,0x9b,0x24
  IID_ID3D12CommandList GUID 0x7116d91c,0xe7e4,0x47ce,0xb8,0xc6,0xec,0x81,0x68,0xf4,0x37,0xe5
  IID_ID3D12GraphicsCommandList GUID 0x5b160d0f,0xac1b,0x4185,0x8b,0xa8,0xb3,0xae,0x42,0xa5,0xa4,0x55
  IID_ID3D12DescriptorHeap GUID 0x8efb471d,0x616c,0x4f49,0x90,0xf7,0x12,0x7b,0xb7,0x63,0xfa,0x51
  IID_ID3D12Resource GUID 0x696442be,0xa72e,0x4059,0xbc,0x79,0x5b,0x5c,0x98,0x04,0x0f,0xad
  IID_ID3D12Fence GUID 0x0a753dcf,0xc4d8,0x4b91,0xad,0xf6,0xbe,0x5a,0x60,0xd9,0x5a,0x76
  IID_ID3D12RootSignature GUID 0xc54a6b66,0x72df,0x4ee8,0x8b,0xe5,0xa9,0x46,0xa1,0x42,0x92,0x14
  IID_ID3D12PipelineState GUID 0x765a30f3,0xf624,0x4c6f,0xa8,0x28,0xac,0xe9,0x48,0x62,0x24,0x45
;========================================================================
section '.data' data readable writeable

  program_section = 'data'
  include 'amnestia_audio.inc'
  include 'amnestia_demo.inc'
  include 'amnestia_scene1.inc'

  align 8
  win_handle dq 0
  win_width dd 1280
  win_height dd 720

  align 8
  process_heap dq 0
  time dq 0
  time_delta dd 0,0

  align 8
  get_time.perf_counter dq 0
  get_time.perf_freq dq 0
  get_time.first_perf_counter dq 0

  update_frame_stats.prev_time dq 0
  update_frame_stats.prev_update_time dq 0
  update_frame_stats.frame dd 0,0
;========================================================================
section '.idata' import data readable writeable

  dd 0,0,0,rva _kernel32,rva _kernel32_table
  dd 0,0,0,rva _user32,rva _user32_table
  dd 0,0,0,rva _gdi32,rva _gdi32_table
  dd 0,0,0,rva _ole32,rva _ole32_table
  dd 0,0,0,rva _avrt,rva _avrt_table
  dd 0,0,0,rva _dxgi,rva _dxgi_table
  dd 0,0,0,rva _d3d12,rva _d3d12_table
  dd 0,0,0,0,0

  _kernel32_table:
  GetModuleHandle dq rva _GetModuleHandle
  ExitProcess dq rva _ExitProcess
  ExitThread dq rva _ExitThread
  QueryPerformanceFrequency dq rva _QueryPerformanceFrequency
  QueryPerformanceCounter dq rva _QueryPerformanceCounter
  CloseHandle dq rva _CloseHandle
  Sleep dq rva _Sleep
  LoadLibrary dq rva _LoadLibrary
  FreeLibrary dq rva _FreeLibrary
  GetProcAddress dq rva _GetProcAddress
  HeapAlloc dq rva _HeapAlloc
  HeapReAlloc dq rva _HeapReAlloc
  HeapFree dq rva _HeapFree
  CreateFile dq rva _CreateFile
  ReadFile dq rva _ReadFile
  GetFileSize dq rva _GetFileSize
  GetProcessHeap dq rva _GetProcessHeap
  CreateEventEx dq rva _CreateEventEx
  CreateThread dq rva _CreateThread
  SetEvent dq rva _SetEvent
  WaitForSingleObject dq rva _WaitForSingleObject
  WaitForMultipleObjects dq rva _WaitForMultipleObjects
  dq 0

  _user32_table:
  wsprintf dq rva _wsprintf
  RegisterClass dq rva _RegisterClass
  CreateWindowEx dq rva _CreateWindowEx
  DefWindowProc dq rva _DefWindowProc
  PeekMessage dq rva _PeekMessage
  DispatchMessage dq rva _DispatchMessage
  LoadCursor dq rva _LoadCursor
  SetWindowText dq rva _SetWindowText
  AdjustWindowRect dq rva _AdjustWindowRect
  GetDC dq rva _GetDC
  ReleaseDC dq rva _ReleaseDC
  PostQuitMessage dq rva _PostQuitMessage
  MessageBox dq rva _MessageBox
  dq 0

  _gdi32_table:
  DeleteDC dq rva _DeleteDC
  SetPixelFormat dq rva _SetPixelFormat
  ChoosePixelFormat dq rva _ChoosePixelFormat
  SwapBuffers dq rva _SwapBuffers
  dq 0

  _ole32_table:
  CoInitialize dq rva _CoInitialize
  CoCreateInstance dq rva _CoCreateInstance
  dq 0

  _avrt_table:
  AvSetMmThreadCharacteristics dq rva _AvSetMmThreadCharacteristics
  dq 0

  _dxgi_table:
  CreateDXGIFactory1 dq rva _CreateDXGIFactory1
  dq 0

  _d3d12_table:
  D3D12CreateDevice dq rva _D3D12CreateDevice
  D3D12GetDebugInterface dq rva _D3D12GetDebugInterface
  D3D12SerializeRootSignature dq rva _D3D12SerializeRootSignature
  dq 0

  _kernel32 db 'kernel32.dll',0
  _user32 db 'user32.dll',0
  _gdi32 db 'gdi32.dll',0
  _ole32 db 'ole32.dll',0
  _avrt db 'avrt.dll',0
  _dxgi db 'dxgi.dll',0
  _d3d12 db 'd3d12.dll',0

emit <_GetModuleHandle dw 0>,<db 'GetModuleHandleA',0>
emit <_ExitProcess dw 0>,<db 'ExitProcess',0>
emit <_ExitThread dw 0>,<db 'ExitThread',0>
emit <_QueryPerformanceFrequency dw 0>,<db 'QueryPerformanceFrequency',0>
emit <_QueryPerformanceCounter dw 0>,<db 'QueryPerformanceCounter',0>
emit <_CloseHandle dw 0>,<db 'CloseHandle',0>
emit <_Sleep dw 0>,<db 'Sleep',0>
emit <_LoadLibrary dw 0>,<db 'LoadLibraryA',0>
emit <_FreeLibrary dw 0>,<db 'FreeLibrary',0>
emit <_GetProcAddress dw 0>,<db 'GetProcAddress',0>
emit <_HeapAlloc dw 0>,<db 'HeapAlloc',0>
emit <_HeapReAlloc dw 0>,<db 'HeapReAlloc',0>
emit <_HeapFree dw 0>,<db 'HeapFree',0>
emit <_CreateFile dw 0>,<db 'CreateFileA',0>
emit <_ReadFile dw 0>,<db 'ReadFile',0>
emit <_GetFileSize dw 0>,<db 'GetFileSize',0>
emit <_GetProcessHeap dw 0>,<db 'GetProcessHeap',0>
emit <_CreateEventEx dw 0>,<db 'CreateEventExA',0>
emit <_CreateThread dw 0>,<db 'CreateThread',0>
emit <_SetEvent dw 0>,<db 'SetEvent',0>
emit <_WaitForSingleObject dw 0>,<db 'WaitForSingleObject',0>
emit <_WaitForMultipleObjects dw 0>,<db 'WaitForMultipleObjects',0>

emit <_wsprintf dw 0>,<db 'wsprintfA',0>
emit <_RegisterClass dw 0>,<db 'RegisterClassA',0>
emit <_CreateWindowEx dw 0>,<db 'CreateWindowExA',0>
emit <_DefWindowProc dw 0>,<db 'DefWindowProcA',0>
emit <_PeekMessage dw 0>,<db 'PeekMessageA',0>
emit <_DispatchMessage dw 0>,<db 'DispatchMessageA',0>
emit <_LoadCursor dw 0>,<db 'LoadCursorA',0>
emit <_SetWindowText dw 0>,<db 'SetWindowTextA',0>
emit <_AdjustWindowRect dw 0>,<db 'AdjustWindowRect',0>
emit <_GetDC dw 0>,<db 'GetDC',0>
emit <_ReleaseDC dw 0>,<db 'ReleaseDC',0>
emit <_PostQuitMessage dw 0>,<db 'PostQuitMessage',0>
emit <_MessageBox dw 0>,<db 'MessageBoxA',0>

emit <_DeleteDC dw 0>,<db 'DeleteDC',0>
emit <_SetPixelFormat dw 0>,<db 'SetPixelFormat',0>
emit <_ChoosePixelFormat dw 0>,<db 'ChoosePixelFormat',0>
emit <_SwapBuffers dw 0>,<db 'SwapBuffers',0>

emit <_CoInitialize dw 0>,<db 'CoInitialize',0>
emit <_CoCreateInstance dw 0>,<db 'CoCreateInstance',0>

emit <_AvSetMmThreadCharacteristics dw 0>,<db 'AvSetMmThreadCharacteristicsA',0>

emit <_CreateDXGIFactory1 dw 0>,<db 'CreateDXGIFactory1',0>

emit <_D3D12CreateDevice dw 0>,<db 'D3D12CreateDevice',0>
emit <_D3D12GetDebugInterface dw 0>,<db 'D3D12GetDebugInterface',0>
emit <_D3D12SerializeRootSignature dw 0>,< db 'D3D12SerializeRootSignature',0>
;========================================================================
