
D3D_FEATURE_LEVEL_9_1   = 0x9100
D3D_FEATURE_LEVEL_9_2   = 0x9200
D3D_FEATURE_LEVEL_9_3   = 0x9300
D3D_FEATURE_LEVEL_10_0  = 0xa000
D3D_FEATURE_LEVEL_10_1  = 0xa100
D3D_FEATURE_LEVEL_11_0  = 0xb000
D3D_FEATURE_LEVEL_11_1  = 0xb100
D3D_FEATURE_LEVEL_12_0  = 0xc000
D3D_FEATURE_LEVEL_12_1  = 0xc100

struc GUID p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10
{
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
    db p10
}

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

D3D12_RESOURCE_STATE_COMMON                     = 0
D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER = 0x1
D3D12_RESOURCE_STATE_INDEX_BUFFER               = 0x2
D3D12_RESOURCE_STATE_RENDER_TARGET              = 0x4
D3D12_RESOURCE_STATE_UNORDERED_ACCESS           = 0x8
D3D12_RESOURCE_STATE_DEPTH_WRITE                = 0x10
D3D12_RESOURCE_STATE_DEPTH_READ                 = 0x20
D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE  = 0x40
D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE      = 0x80
D3D12_RESOURCE_STATE_STREAM_OUT                 = 0x100
D3D12_RESOURCE_STATE_INDIRECT_ARGUMENT          = 0x200
D3D12_RESOURCE_STATE_COPY_DEST                  = 0x400
D3D12_RESOURCE_STATE_COPY_SOURCE                = 0x800
D3D12_RESOURCE_STATE_RESOLVE_DEST               = 0x1000
D3D12_RESOURCE_STATE_RESOLVE_SOURCE             = 0x2000
D3D12_RESOURCE_STATE_GENERIC_READ               = 0x1+0x2+0x40+0x80+0x200+0x800
D3D12_RESOURCE_STATE_PRESENT                    = 0
D3D12_RESOURCE_STATE_PREDICATION                = 0x200

D3D12_RESOURCE_BARRIER_TYPE_TRANSITION  = 0
D3D12_RESOURCE_BARRIER_TYPE_ALIASING    = ( D3D12_RESOURCE_BARRIER_TYPE_TRANSITION + 1 )
D3D12_RESOURCE_BARRIER_TYPE_UAV         = ( D3D12_RESOURCE_BARRIER_TYPE_ALIASING + 1 )

D3D12_RESOURCE_BARRIER_FLAG_NONE       = 0
D3D12_RESOURCE_BARRIER_FLAG_BEGIN_ONLY = 0x1
D3D12_RESOURCE_BARRIER_FLAG_END_ONLY   = 0x2

D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES = 0xffffffff

D3D12_DESCRIPTOR_RANGE_TYPE_SRV     = 0
D3D12_DESCRIPTOR_RANGE_TYPE_UAV     = ( D3D12_DESCRIPTOR_RANGE_TYPE_SRV + 1 )
D3D12_DESCRIPTOR_RANGE_TYPE_CBV     = ( D3D12_DESCRIPTOR_RANGE_TYPE_UAV + 1 )
D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER = ( D3D12_DESCRIPTOR_RANGE_TYPE_CBV + 1 )

D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE = 0
D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS  = ( D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE + 1 )
D3D12_ROOT_PARAMETER_TYPE_CBV              = ( D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS + 1 )
D3D12_ROOT_PARAMETER_TYPE_SRV              = ( D3D12_ROOT_PARAMETER_TYPE_CBV + 1 )
D3D12_ROOT_PARAMETER_TYPE_UAV              = ( D3D12_ROOT_PARAMETER_TYPE_SRV + 1 )

D3D12_SHADER_VISIBILITY_ALL      = 0
D3D12_SHADER_VISIBILITY_VERTEX   = 1
D3D12_SHADER_VISIBILITY_HULL     = 2
D3D12_SHADER_VISIBILITY_DOMAIN   = 3
D3D12_SHADER_VISIBILITY_GEOMETRY = 4
D3D12_SHADER_VISIBILITY_PIXEL    = 5

D3D12_ROOT_SIGNATURE_FLAG_NONE                               = 0
D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT = 0x1
D3D12_ROOT_SIGNATURE_FLAG_DENY_VERTEX_SHADER_ROOT_ACCESS     = 0x2
D3D12_ROOT_SIGNATURE_FLAG_DENY_HULL_SHADER_ROOT_ACCESS       = 0x4
D3D12_ROOT_SIGNATURE_FLAG_DENY_DOMAIN_SHADER_ROOT_ACCESS     = 0x8
D3D12_ROOT_SIGNATURE_FLAG_DENY_GEOMETRY_SHADER_ROOT_ACCESS   = 0x10
D3D12_ROOT_SIGNATURE_FLAG_DENY_PIXEL_SHADER_ROOT_ACCESS      = 0x20
D3D12_ROOT_SIGNATURE_FLAG_ALLOW_STREAM_OUTPUT                = 0x40

struc D3D12_VIEWPORT p0,p1,p2,p3,p4,p5
{
    .TopLeftX dd p0
    .TopLeftY dd p1
    .Width    dd p2
    .Height   dd p3
    .MinDepth dd p4
    .MaxDepth dd p5
}

D3D12_RECT fix RECT

struc D3D12_COMMAND_QUEUE_DESC p0,p1,p2,p3
{
    .Type     dd p0
    .Priority dd p1
    .Flags    dd p2
    .NodeMask dd p3
}

struc D3D12_DESCRIPTOR_HEAP_DESC p0,p1,p2,p3
{
    .Type           dd p0
    .NumDescriptors dd p1
    .Flags          dd p2
    .NodeMask       dd p3
}

struc D3D12_RESOURCE_TRANSITION_BARRIER p0,p1,p2,p3
{
    .pResource   dq p0
    .Subresource dd p1
    .StateBefore dd p2
    .StateAfter  dd p3
                 dd ?
}

struc D3D12_RESOURCE_ALIASING_BARRIER p0,p1
{
    .pResourceBefore dq p0
    .pResourceAfter  dq p1
}

struc D3D12_RESOURCE_UAV_BARRIER p0
{
    .pResource dq p0
}

struc D3D12_RESOURCE_BARRIER p0,p1,p2
{
    .Type       dd                                p0
    .Flags      dd                                p1
    virtual
    .Transition D3D12_RESOURCE_TRANSITION_BARRIER p2
    end virtual
    virtual
    .Aliasing   D3D12_RESOURCE_ALIASING_BARRIER   ?,?
    end virtual
    virtual
    .UAV        D3D12_RESOURCE_UAV_BARRIER        ?
    end virtual
                rb 24
}

struc D3D12_DESCRIPTOR_RANGE p0,p1,p2,p3,p4
{
    .RangeType                         dd p0
    .NumDescriptors                    dd p1
    .BaseShaderRegister                dd p2
    .RegisterSpace                     dd p3
    .OffsetInDescriptorsFromTableStart dd p4
}

struc D3D12_ROOT_DESCRIPTOR_TABLE p0,p1
{
    .NumDescriptorRanges dd p0
                         dd ?
    .pDescriptorRanges   dq p1
}

struc D3D12_ROOT_CONSTANTS p0,p1,p2
{
    .ShaderRegister dd p0
    .RegisterSpace  dd p1
    .Num32BitValues dd p2
}

struc D3D12_ROOT_DESCRIPTOR p0,p1
{
    .ShaderRegister dd p0
    .RegisterSpace  dd p1
}

struc D3D12_ROOT_PARAMETER p0,p1,p2
{
    .ParameterType    dd                          p0
                      dd                          ?
    virtual
    .DescriptorTable  D3D12_ROOT_DESCRIPTOR_TABLE p1
    end virtual
    virtual
    .Constants        D3D12_ROOT_CONSTANTS        ?,?,?
    end virtual
    virtual
    .Descriptor       D3D12_ROOT_DESCRIPTOR       ?,?
    end virtual
                      rb 16
    .ShaderVisibility dd                          p2
                      dd                          ?
}

struc D3D12_STATIC_SAMPLER_DESC p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12
{
    .Filter           dd p0
    .AddressU         dd p1
    .AddressV         dd p2
    .AddressW         dd p3
    .MipLODBias       dd p4
    .MaxAnisotropy    dd p5
    .ComparisonFunc   dd p6
    .BorderColor      dd p7
    .MinLOD           dd p8
    .MaxLOD           dd p9
    .ShaderRegister   dd p10
    .RegisterSpace    dd p11
    .ShaderVisibility dd p12
}

struc D3D12_ROOT_SIGNATURE_DESC p0,p1,p2,p3,p4
{
    .NumParameters     dd p0
                       dd ?
    .pParameters       dq p1
    .NumStaticSamplers dd p2
                       dd ?
    .pStaticSamplers   dq p3
    .Flags             dd p4
                       dd ?
}

virtual at 0
ID3D12Device.QueryInterface rq 1
ID3D12Device.AddRef rq 1
ID3D12Device.Release rq 1
ID3D12Device.GetPrivateData rq 1
ID3D12Device.SetPrivateData rq 1
ID3D12Device.SetPrivateDataInterface rq 1
ID3D12Device.SetName rq 1
ID3D12Device.GetNodeCount rq 1
ID3D12Device.CreateCommandQueue rq 1
ID3D12Device.CreateCommandAllocator rq 1
ID3D12Device.CreateGraphicsPipelineState rq 1
ID3D12Device.CreateComputePipelineState rq 1
ID3D12Device.CreateCommandList rq 1
ID3D12Device.CheckFeatureSupport rq 1
ID3D12Device.CreateDescriptorHeap rq 1
ID3D12Device.GetDescriptorHandleIncrementSize rq 1
ID3D12Device.CreateRootSignature rq 1
ID3D12Device.CreateConstantBufferView rq 1
ID3D12Device.CreateShaderResourceView rq 1
ID3D12Device.CreateUnorderedAccessView rq 1
ID3D12Device.CreateRenderTargetView rq 1
ID3D12Device.CreateDepthStencilView rq 1
ID3D12Device.CreateSampler rq 1
ID3D12Device.CopyDescriptors rq 1
ID3D12Device.CopyDescriptorsSimple rq 1
ID3D12Device.GetResourceAllocationInfo rq 1
ID3D12Device.GetCustomHeapProperties rq 1
ID3D12Device.CreateCommittedResource rq 1
ID3D12Device.CreateHeap rq 1
ID3D12Device.CreatePlacedResource rq 1
ID3D12Device.CreateReservedResource rq 1
ID3D12Device.CreateSharedHandle rq 1
ID3D12Device.OpenSharedHandle rq 1
ID3D12Device.OpenSharedHandleByName rq 1
ID3D12Device.MakeResident rq 1
ID3D12Device.Evict rq 1
ID3D12Device.CreateFence rq 1
ID3D12Device.GetDeviceRemovedReason rq 1
ID3D12Device.GetCopyableFootprints rq 1
ID3D12Device.CreateQueryHeap rq 1
ID3D12Device.SetStablePowerState rq 1
ID3D12Device.CreateCommandSignature rq 1
ID3D12Device.GetResourceTiling rq 1
ID3D12Device.GetAdapterLuid rq 1
end virtual

virtual at 0
ID3D12CommandQueue.QueryInterface rq 1
ID3D12CommandQueue.AddRef rq 1
ID3D12CommandQueue.Release rq 1
ID3D12CommandQueue.GetPrivateData rq 1
ID3D12CommandQueue.SetPrivateData rq 1
ID3D12CommandQueue.SetPrivateDataInterface rq 1
ID3D12CommandQueue.SetName rq 1
ID3D12CommandQueue.GetDevice rq 1
ID3D12CommandQueue.UpdateTileMappings rq 1
ID3D12CommandQueue.CopyTileMappings rq 1
ID3D12CommandQueue.ExecuteCommandLists rq 1
ID3D12CommandQueue.SetMarker rq 1
ID3D12CommandQueue.BeginEvent rq 1
ID3D12CommandQueue.EndEvent rq 1
ID3D12CommandQueue.Signal rq 1
ID3D12CommandQueue.Wait rq 1
ID3D12CommandQueue.GetTimestampFrequency rq 1
ID3D12CommandQueue.GetClockCalibration rq 1
ID3D12CommandQueue.GetDesc rq 1
end virtual

virtual at 0
ID3D12CommandAllocator.QueryInterface rq 1
ID3D12CommandAllocator.AddRef rq 1
ID3D12CommandAllocator.Release rq 1
ID3D12CommandAllocator.GetPrivateData rq 1
ID3D12CommandAllocator.SetPrivateData rq 1
ID3D12CommandAllocator.SetPrivateDataInterface rq 1
ID3D12CommandAllocator.SetName rq 1
ID3D12CommandAllocator.GetDevice rq 1
ID3D12CommandAllocator.Reset rq 1
end virtual

virtual at 0
ID3D12DescriptorHeap.QueryInterface rq 1
ID3D12DescriptorHeap.AddRef rq 1
ID3D12DescriptorHeap.Release rq 1
ID3D12DescriptorHeap.GetPrivateData rq 1
ID3D12DescriptorHeap.SetPrivateData rq 1
ID3D12DescriptorHeap.SetPrivateDataInterface rq 1
ID3D12DescriptorHeap.SetName rq 1
ID3D12DescriptorHeap.GetDevice rq 1
ID3D12DescriptorHeap.GetDesc rq 1
ID3D12DescriptorHeap.GetCPUDescriptorHandleForHeapStart rq 1
ID3D12DescriptorHeap.GetGPUDescriptorHandleForHeapStart rq 1
end virtual

virtual at 0
ID3D12CommandList.QueryInterface rq 1
ID3D12CommandList.AddRef rq 1
ID3D12CommandList.Release rq 1
ID3D12CommandList.GetPrivateData rq 1
ID3D12CommandList.SetPrivateData rq 1
ID3D12CommandList.SetPrivateDataInterface rq 1
ID3D12CommandList.SetName rq 1
ID3D12CommandList.GetDevice rq 1
ID3D12CommandList.GetType rq 1
end virtual

virtual at 0
ID3D12GraphicsCommandList.QueryInterface rq 1
ID3D12GraphicsCommandList.AddRef rq 1
ID3D12GraphicsCommandList.Release rq 1
ID3D12GraphicsCommandList.GetPrivateData rq 1
ID3D12GraphicsCommandList.SetPrivateData rq 1
ID3D12GraphicsCommandList.SetPrivateDataInterface rq 1
ID3D12GraphicsCommandList.SetName rq 1
ID3D12GraphicsCommandList.GetDevice rq 1
ID3D12GraphicsCommandList.GetType rq 1
ID3D12GraphicsCommandList.Close rq 1
ID3D12GraphicsCommandList.Reset rq 1
ID3D12GraphicsCommandList.ClearState rq 1
ID3D12GraphicsCommandList.DrawInstanced rq 1
ID3D12GraphicsCommandList.DrawIndexedInstanced rq 1
ID3D12GraphicsCommandList.Dispatch rq 1
ID3D12GraphicsCommandList.CopyBufferRegion rq 1
ID3D12GraphicsCommandList.CopyTextureRegion rq 1
ID3D12GraphicsCommandList.CopyResource rq 1
ID3D12GraphicsCommandList.CopyTiles rq 1
ID3D12GraphicsCommandList.ResolveSubresource rq 1
ID3D12GraphicsCommandList.IASetPrimitiveTopology rq 1
ID3D12GraphicsCommandList.RSSetViewports rq 1
ID3D12GraphicsCommandList.RSSetScissorRects rq 1
ID3D12GraphicsCommandList.OMSetBlendFactor rq 1
ID3D12GraphicsCommandList.OMSetStencilRef rq 1
ID3D12GraphicsCommandList.SetPipelineState rq 1
ID3D12GraphicsCommandList.ResourceBarrier rq 1
ID3D12GraphicsCommandList.ExecuteBundle rq 1
ID3D12GraphicsCommandList.SetDescriptorHeaps rq 1
ID3D12GraphicsCommandList.SetComputeRootSignature rq 1
ID3D12GraphicsCommandList.SetGraphicsRootSignature rq 1
ID3D12GraphicsCommandList.SetComputeRootDescriptorTable rq 1
ID3D12GraphicsCommandList.SetGraphicsRootDescriptorTable rq 1
ID3D12GraphicsCommandList.SetComputeRoot32BitConstant rq 1
ID3D12GraphicsCommandList.SetGraphicsRoot32BitConstant rq 1
ID3D12GraphicsCommandList.SetComputeRoot32BitConstants rq 1
ID3D12GraphicsCommandList.SetGraphicsRoot32BitConstants rq 1
ID3D12GraphicsCommandList.SetComputeRootConstantBufferView rq 1
ID3D12GraphicsCommandList.SetGraphicsRootConstantBufferView rq 1
ID3D12GraphicsCommandList.SetComputeRootShaderResourceView rq 1
ID3D12GraphicsCommandList.SetGraphicsRootShaderResourceView rq 1
ID3D12GraphicsCommandList.SetComputeRootUnorderedAccessView rq 1
ID3D12GraphicsCommandList.SetGraphicsRootUnorderedAccessView rq 1
ID3D12GraphicsCommandList.IASetIndexBuffer rq 1
ID3D12GraphicsCommandList.IASetVertexBuffers rq 1
ID3D12GraphicsCommandList.SOSetTargets rq 1
ID3D12GraphicsCommandList.OMSetRenderTargets rq 1
ID3D12GraphicsCommandList.ClearDepthStencilView rq 1
ID3D12GraphicsCommandList.ClearRenderTargetView rq 1
ID3D12GraphicsCommandList.ClearUnorderedAccessViewUint rq 1
ID3D12GraphicsCommandList.ClearUnorderedAccessViewFloat rq 1
ID3D12GraphicsCommandList.DiscardResource rq 1
ID3D12GraphicsCommandList.BeginQuery rq 1
ID3D12GraphicsCommandList.EndQuery rq 1
ID3D12GraphicsCommandList.ResolveQueryData rq 1
ID3D12GraphicsCommandList.SetPredication rq 1
ID3D12GraphicsCommandList.SetMarker rq 1
ID3D12GraphicsCommandList.BeginEvent rq 1
ID3D12GraphicsCommandList.EndEvent rq 1
ID3D12GraphicsCommandList.ExecuteIndirect rq 1
end virtual

virtual at 0
ID3D12Fence.QueryInterface rq 1
ID3D12Fence.AddRef rq 1
ID3D12Fence.Release rq 1
ID3D12Fence.GetPrivateData rq 1
ID3D12Fence.SetPrivateData rq 1
ID3D12Fence.SetPrivateDataInterface rq 1
ID3D12Fence.SetName rq 1
ID3D12Fence.GetDevice rq 1
ID3D12Fence.GetCompletedValue rq 1
ID3D12Fence.SetEventOnCompletion rq 1
ID3D12Fence.Signal rq 1
end virtual

virtual at 0
ID3D12Resource.QueryInterface rq 1
ID3D12Resource.AddRef rq 1
ID3D12Resource.Release rq 1
ID3D12Resource.GetPrivateData rq 1
ID3D12Resource.SetPrivateData rq 1
ID3D12Resource.SetPrivateDataInterface rq 1
ID3D12Resource.SetName rq 1
ID3D12Resource.GetDevice rq 1
ID3D12Resource.Map rq 1
ID3D12Resource.Unmap rq 1
ID3D12Resource.GetDesc rq 1
ID3D12Resource.GetGPUVirtualAddress rq 1
ID3D12Resource.WriteToSubresource rq 1
ID3D12Resource.ReadFromSubresource rq 1
ID3D12Resource.GetHeapProperties rq 1
end virtual

; D3D12 debug layer

virtual at 0
ID3D12Debug.QueryInterface rq 1
ID3D12Debug.AddRef rq 1
ID3D12Debug.Release rq 1
ID3D12Debug.EnableDebugLayer rq 1
end virtual

; DXGI

DXGI_FORMAT_R8G8B8A8_UNORM = 28

DXGI_USAGE_RENDER_TARGET_OUTPUT = 0x00000020

DXGI_SWAP_EFFECT_DISCARD         = 0
DXGI_SWAP_EFFECT_SEQUENTIAL      = 1
DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = 3
DXGI_SWAP_EFFECT_FLIP_DISCARD    = 4

DXGI_PRESENT_RESTART = 0x00000004

struc DXGI_RATIONAL p0,p1
{
    .Numerator   dd p0
    .Denominator dd p1
}

struc DXGI_MODE_DESC p0,p1,p2,p3,p4,p5
{
    .Width            dd            p0
    .Height           dd            p1
    .RefreshRate      DXGI_RATIONAL p2
    .Format           dd            p3
    .ScanlineOrdering dd            p4
    .Scaling          dd            p5
}

struc DXGI_SAMPLE_DESC p0,p1
{
    .Count   dd p0
    .Quality dd p1
}

struc DXGI_SWAP_CHAIN_DESC p0,p1,p2,p3,p4,p5,p6,p7
{
    .BufferDesc   DXGI_MODE_DESC   p0
    .SampleDesc   DXGI_SAMPLE_DESC p1
    .BufferUsage  dd               p2
    .BufferCount  dd               p3
                  dd               ?
    .OutputWindow dq               p4
    .Windowed     dd               p5
    .SwapEffect   dd               p6
    .Flags        dd               p7
                  dd               ?
}

virtual at 0
IDXGIFactory.QueryInterface rq 1
IDXGIFactory.AddRef rq 1
IDXGIFactory.Release rq 1
IDXGIFactory.SetPrivateData rq 1
IDXGIFactory.SetPrivateDataInterface rq 1
IDXGIFactory.GetPrivateData rq 1
IDXGIFactory.GetParent rq 1
IDXGIFactory.EnumAdapters rq 1
IDXGIFactory.MakeWindowAssociation rq 1
IDXGIFactory.GetWindowAssociation rq 1
IDXGIFactory.CreateSwapChain rq 1
IDXGIFactory.CreateSoftwareAdapter rq 1
end virtual

virtual at 0
IDXGISwapChain.QueryInterface rq 1
IDXGISwapChain.AddRef rq 1
IDXGISwapChain.Release rq 1
IDXGISwapChain.SetPrivateData rq 1
IDXGISwapChain.SetPrivateDataInterface rq 1
IDXGISwapChain.GetPrivateData rq 1
IDXGISwapChain.GetParent rq 1
IDXGISwapChain.GetDevice rq 1
IDXGISwapChain.Present rq 1
IDXGISwapChain.GetBuffer rq 1
IDXGISwapChain.SetFullscreenState rq 1
IDXGISwapChain.GetFullscreenState rq 1
IDXGISwapChain.GetDesc rq 1
IDXGISwapChain.ResizeBuffers rq 1
IDXGISwapChain.ResizeTarget rq 1
IDXGISwapChain.GetContainingOutput rq 1
IDXGISwapChain.GetFrameStatistics rq 1
IDXGISwapChain.GetLastPresentCount rq 1
end virtual