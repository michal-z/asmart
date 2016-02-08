if program_section = 'code'
;=============================================================================
FALIGN
demo_init:
;-----------------------------------------------------------------------------
virtual at 0
  rq 4
  .dbgi dq ?
  align 8
  .cmdqueue_desc D3D12_COMMAND_QUEUE_DESC
  align 8
  .swapchain_desc DXGI_SWAP_CHAIN_DESC
  align 32
  .k_stack_size = $+24
end virtual
  ; alloc and clear the stack
        sub rsp,.k_stack_size
        vpxor ymm0,ymm0,ymm0
        xor eax,eax
        mov ecx,.k_stack_size/32
  @@:   vmovdqa [rsp+rax],ymm0
        add eax,32
        sub ecx,1
        jnz @b
  ; debug layer
        lea rcx,[IID_ID3D12Debug]
        lea rdx,[.dbgi+rsp]
        call [D3D12GetDebugInterface]
        test eax,eax
        js @f
        mov rcx,[.dbgi+rsp]
        mov rax,[rcx]
        call [rax+ID3D12Debug.EnableDebugLayer]
        SAFE_RELEASE [.dbgi+rsp]
  @@:
  ; DXGI factory
        lea rcx,[IID_IDXGIFactory4]
        lea rdx,[dxgifactory]
        call [CreateDXGIFactory1]
        test eax,eax
        js .error
  ; device
        xor ecx,ecx
        mov edx,D3D_FEATURE_LEVEL_11_0
        lea r8,[IID_ID3D12Device]
        lea r9,[device]
        call [D3D12CreateDevice]
        test eax,eax
        js .error
  ; command queue
        mov [.cmdqueue_desc.Type+rsp],D3D12_COMMAND_LIST_TYPE_DIRECT
        mov rcx,[device]
        lea rdx,[.cmdqueue_desc+rsp]
        lea r8,[IID_ID3D12CommandQueue]
        lea r9,[cmdqueue]
        mov rax,[rcx]
        call [ID3D12Device.CreateCommandQueue+rax]
        test eax,eax
        js .error
  ; command allocator
        mov rcx,[device]
        mov edx,D3D12_COMMAND_LIST_TYPE_DIRECT
        lea r8,[IID_ID3D12CommandAllocator]
        lea r9,[cmdallocator]
        mov rax,[rcx]
        call [ID3D12Device.CreateCommandAllocator+rax]
        test eax,eax
        js .error
  ; swapchain
        mov [.swapchain_desc.BufferDesc.Width+rsp],k_win_width
        mov [.swapchain_desc.BufferDesc.Height+rsp],k_win_height
        mov [.swapchain_desc.BufferDesc.Format+rsp],DXGI_FORMAT_R8G8B8A8_UNORM
        mov [.swapchain_desc.SampleDesc.Count+rsp],1
        mov [.swapchain_desc.BufferCount+rsp],4
        mov rax,[win_handle]
        mov [.swapchain_desc.OutputWindow+rsp],rax
        mov [.swapchain_desc.Windowed+rsp],1
        mov [.swapchain_desc.SwapEffect+rsp],DXGI_SWAP_EFFECT_FLIP_DISCARD
        mov rcx,[dxgifactory]
        mov rdx,[cmdqueue]
        lea r8,[.swapchain_desc+rsp]
        lea r9,[swapchain]
        mov rax,[rcx]
        call [IDXGIFactory4.CreateSwapChain+rax]
        test eax,eax
        js .error
  ; audio
        call audio_play
        test eax,eax
        jz .error
  ; success
        mov eax,1
        add rsp,.k_stack_size
        ret
  .error:
        xor eax,eax
        add rsp,.k_stack_size
        ret
;=============================================================================
FALIGN
demo_deinit:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
        sub rsp,.k_stack_size
        call audio_stop
        add rsp,.k_stack_size
        ret
;=============================================================================
FALIGN
demo_update:
;-----------------------------------------------------------------------------
  .k_stack_size = 32*1+24
        sub rsp,.k_stack_size

        add rsp,.k_stack_size
        ret
;=============================================================================
else if program_section = 'data'

align 8
  dxgifactory dq 0
  device dq 0
  cmdqueue dq 0
  cmdallocator dq 0
  swapchain dq 0

end if
;=============================================================================
; vim: ft=fasm autoindent tabstop=8 softtabstop=8 shiftwidth=8 :
