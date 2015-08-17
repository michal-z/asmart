
D3D_FEATURE_LEVEL_9_1   = 0x9100
D3D_FEATURE_LEVEL_9_2   = 0x9200
D3D_FEATURE_LEVEL_9_3   = 0x9300
D3D_FEATURE_LEVEL_10_0  = 0xa000
D3D_FEATURE_LEVEL_10_1  = 0xa100
D3D_FEATURE_LEVEL_11_0  = 0xb000
D3D_FEATURE_LEVEL_11_1  = 0xb100
D3D_FEATURE_LEVEL_12_0  = 0xc000
D3D_FEATURE_LEVEL_12_1  = 0xc100

struct GUID
    D0 dd ?
    D1 dw ?
    D2 dw ?
    D3 db ?
    D4 db ?
    D5 db ?
    D6 db ?
    D7 db ?
    D8 db ?
    D9 db ?
    DA db ?
ends

; D3D12

D3D12_COMMAND_LIST_TYPE_DIRECT  = 0
D3D12_COMMAND_LIST_TYPE_BUNDLE  = 1
D3D12_COMMAND_LIST_TYPE_COMPUTE = 2
D3D12_COMMAND_LIST_TYPE_COPY    = 3

D3D12_COMMAND_QUEUE_FLAG_NONE                = 0
D3D12_COMMAND_QUEUE_FLAG_DISABLE_GPU_TIMEOUT = 0x1

D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV  = 0
D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER      = ( D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV + 1 )
D3D12_DESCRIPTOR_HEAP_TYPE_RTV          = ( D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER + 1 )
D3D12_DESCRIPTOR_HEAP_TYPE_DSV          = ( D3D12_DESCRIPTOR_HEAP_TYPE_RTV + 1 )
D3D12_DESCRIPTOR_HEAP_TYPE_NUM_TYPES    = ( D3D12_DESCRIPTOR_HEAP_TYPE_DSV + 1 )

D3D12_DESCRIPTOR_HEAP_FLAG_NONE           = 0
D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE = 0x1

D3D12_FENCE_FLAG_NONE                 = 0
D3D12_FENCE_FLAG_SHARED               = 0x1
D3D12_FENCE_FLAG_SHARED_CROSS_ADAPTER = 0x2

struct D3D12_VIEWPORT
    TopLeftX dd ?
    TopLeftY dd ?
    Width    dd ?
    Height   dd ?
    MinDepth dd ?
    MaxDepth dd ?
ends

struct D3D12_RECT
    left   dd ?
    top    dd ?
    right  dd ?
    bottom dd ?
ends

struct D3D12_COMMAND_QUEUE_DESC
    Type     dd ?
    Priority dd ?
    Flags    dd ?
    NodeMask dd ?
ends

struct D3D12_DESCRIPTOR_HEAP_DESC
    Type           dd ?
    NumDescriptors dd ?
    Flags          dd ?
    NodeMask       dd ?
ends

interface ID3D12Device,\
    QueryInterface,\
    AddRef,\
    Release,\
    GetPrivateData,\
    SetPrivateData,\
    SetPrivateDataInterface,\
    SetName,\
    GetNodeCount,\
    CreateCommandQueue,\
    CreateCommandAllocator,\
    CreateGraphicsPipelineState,\
    CreateComputePipelineState,\
    CreateCommandList,\
    CheckFeatureSupport,\
    CreateDescriptorHeap,\
    GetDescriptorHandleIncrementSize,\
    CreateRootSignature,\
    CreateConstantBufferView,\
    CreateShaderResourceView,\
    CreateUnorderedAccessView,\
    CreateRenderTargetView,\
    CreateDepthStencilView,\
    CreateSampler,\
    CopyDescriptors,\
    CopyDescriptorsSimple,\
    GetResourceAllocationInfo,\
    GetCustomHeapProperties,\
    CreateCommittedResource,\
    CreateHeap,\
    CreatePlacedResource,\
    CreateReservedResource,\
    CreateSharedHandle,\
    OpenSharedHandle,\
    OpenSharedHandleByName,\
    MakeResident,\
    Evict,\
    CreateFence,\
    GetDeviceRemovedReason,\
    GetCopyableFootprints,\
    CreateQueryHeap,\
    SetStablePowerState,\
    CreateCommandSignature,\
    GetResourceTiling,\
    GetAdapterLuid

interface ID3D12CommandQueue,\
    QueryInterface,\
    AddRef,\
    Release,\
    GetPrivateData,\
    SetPrivateData,\
    SetPrivateDataInterface,\
    SetName,\
    GetDevice,\
    UpdateTileMappings,\
    CopyTileMappings,\
    ExecuteCommandLists,\
    SetMarker,\
    BeginEvent,\
    EndEvent,\
    Signal,\
    Wait,\
    GetTimestampFrequency,\
    GetClockCalibration,\
    GetDesc

interface ID3D12CommandAllocator,\
    QueryInterface,\
    AddRef,\
    Release,\
    GetPrivateData,\
    SetPrivateData,\
    SetPrivateDataInterface,\
    SetName,\
    GetDevice,\
    Reset

interface ID3D12DescriptorHeap,\
    QueryInterface,\
    AddRef,\
    Release,\
    GetPrivateData,\
    SetPrivateData,\
    SetPrivateDataInterface,\
    SetName,\
    GetDevice,\
    GetDesc,\
    GetCPUDescriptorHandleForHeapStart,\
    GetGPUDescriptorHandleForHeapStart

; D3D12 debug layer

interface ID3D12Debug,\
    QueryInterface,\
    AddRef,\
    Release,\
    EnableDebugLayer

; DXGI

DXGI_FORMAT_R8G8B8A8_UNORM = 28

DXGI_USAGE_RENDER_TARGET_OUTPUT = 0x00000020

DXGI_SWAP_EFFECT_DISCARD         = 0
DXGI_SWAP_EFFECT_SEQUENTIAL      = 1
DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = 3
DXGI_SWAP_EFFECT_FLIP_DISCARD    = 4

struct DXGI_RATIONAL
    Numerator   dd ?
    Denominator dd ?
ends

struct DXGI_MODE_DESC
    Width            dd ?
    Height           dd ?
    RefreshRate      DXGI_RATIONAL
    Format           dd ?
    ScanlineOrdering dd ?
    Scaling          dd ?
ends

struct DXGI_SAMPLE_DESC
    Count   dd ?
    Quality dd ?
ends

struct DXGI_SWAP_CHAIN_DESC
    BufferDesc   DXGI_MODE_DESC
    SampleDesc   DXGI_SAMPLE_DESC
    BufferUsage  dd ?
    BufferCount  dd ?
                 dd ?
    OutputWindow dq ?
    Windowed     dd ?
    SwapEffect   dd ?
    Flags        dd ?
                 dd ?
ends

interface IDXGIFactory,\
    QueryInterface,\
    AddRef,\
    Release,\
    SetPrivateData,\
    SetPrivateDataInterface,\
    GetPrivateData,\
    GetParent,\
    EnumAdapters,\
    MakeWindowAssociation,\
    GetWindowAssociation,\
    CreateSwapChain,\
    CreateSoftwareAdapter

interface IDXGISwapChain,\
    QueryInterface,\
    AddRef,\
    Release,\
    SetPrivateData,\
    SetPrivateDataInterface,\
    GetPrivateData,\
    GetParent,\
    GetDevice,\
    Present,\
    GetBuffer,\
    SetFullscreenState,\
    GetFullscreenState,\
    GetDesc,\
    ResizeBuffers,\
    ResizeTarget,\
    GetContainingOutput,\
    GetFrameStatistics,\
    GetLastPresentCount
                                            