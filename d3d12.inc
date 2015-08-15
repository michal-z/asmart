
D3D_FEATURE_LEVEL_9_1   = 0x9100
D3D_FEATURE_LEVEL_9_2   = 0x9200
D3D_FEATURE_LEVEL_9_3   = 0x9300
D3D_FEATURE_LEVEL_10_0  = 0xa000
D3D_FEATURE_LEVEL_10_1  = 0xa100
D3D_FEATURE_LEVEL_11_0  = 0xb000
D3D_FEATURE_LEVEL_11_1  = 0xb100
D3D_FEATURE_LEVEL_12_0  = 0xc000
D3D_FEATURE_LEVEL_12_1  = 0xc100

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

interface ID3D12Debug,\
    QueryInterface,\
    AddRef,\
    Release,\
    EnableDebugLayer

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