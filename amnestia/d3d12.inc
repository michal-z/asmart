; D3D

D3D_FEATURE_LEVEL_9_1 = 0x9100
D3D_FEATURE_LEVEL_9_2 = 0x9200
D3D_FEATURE_LEVEL_9_3 = 0x9300
D3D_FEATURE_LEVEL_10_0 = 0xa000
D3D_FEATURE_LEVEL_10_1 = 0xa100
D3D_FEATURE_LEVEL_11_0 = 0xb000
D3D_FEATURE_LEVEL_11_1 = 0xb100
D3D_FEATURE_LEVEL_12_0 = 0xc000
D3D_FEATURE_LEVEL_12_1 = 0xc100

D3D_PRIMITIVE_TOPOLOGY_UNDEFINED = 0
D3D_PRIMITIVE_TOPOLOGY_POINTLIST = 1
D3D_PRIMITIVE_TOPOLOGY_LINELIST = 2
D3D_PRIMITIVE_TOPOLOGY_LINESTRIP = 3
D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST = 4
D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP = 5
D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ = 10
D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ = 11
D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ = 12
D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ = 13
D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST = 33
D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST = 34
D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST = 35
D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST = 36
D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST = 37
D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST = 38
D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST = 39
D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST = 40
D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST = 41
D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST = 42
D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST = 43
D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST = 44
D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST = 45
D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST = 46
D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST = 47
D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST = 48
D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST = 49
D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST = 50
D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST = 51
D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST = 52
D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST = 53
D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST = 54
D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST = 55
D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST = 56
D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST = 57
D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST = 58
D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST = 59
D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST = 60
D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST = 61
D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST = 62
D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST = 63
D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST = 64

; D3D12

D3D12_COMMAND_LIST_TYPE_DIRECT = 0
D3D12_COMMAND_LIST_TYPE_BUNDLE = 1
D3D12_COMMAND_LIST_TYPE_COMPUTE = 2
D3D12_COMMAND_LIST_TYPE_COPY = 3

D3D12_COMMAND_QUEUE_FLAG_NONE = 0
D3D12_COMMAND_QUEUE_FLAG_DISABLE_GPU_TIMEOUT = 0x1

D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV = 0
D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER = D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV + 1
D3D12_DESCRIPTOR_HEAP_TYPE_RTV = D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER + 1
D3D12_DESCRIPTOR_HEAP_TYPE_DSV = D3D12_DESCRIPTOR_HEAP_TYPE_RTV + 1
D3D12_DESCRIPTOR_HEAP_TYPE_NUM_TYPES = D3D12_DESCRIPTOR_HEAP_TYPE_DSV + 1

D3D12_DESCRIPTOR_HEAP_FLAG_NONE = 0
D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE = 0x1

D3D12_FENCE_FLAG_NONE = 0
D3D12_FENCE_FLAG_SHARED = 0x1
D3D12_FENCE_FLAG_SHARED_CROSS_ADAPTER = 0x2

D3D12_RESOURCE_STATE_COMMON = 0
D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER = 0x1
D3D12_RESOURCE_STATE_INDEX_BUFFER = 0x2
D3D12_RESOURCE_STATE_RENDER_TARGET = 0x4
D3D12_RESOURCE_STATE_UNORDERED_ACCESS = 0x8
D3D12_RESOURCE_STATE_DEPTH_WRITE = 0x10
D3D12_RESOURCE_STATE_DEPTH_READ = 0x20
D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE = 0x40
D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE = 0x80
D3D12_RESOURCE_STATE_STREAM_OUT = 0x100
D3D12_RESOURCE_STATE_INDIRECT_ARGUMENT = 0x200
D3D12_RESOURCE_STATE_COPY_DEST = 0x400
D3D12_RESOURCE_STATE_COPY_SOURCE = 0x800
D3D12_RESOURCE_STATE_RESOLVE_DEST = 0x1000
D3D12_RESOURCE_STATE_RESOLVE_SOURCE = 0x2000
D3D12_RESOURCE_STATE_GENERIC_READ = 0x1+0x2+0x40+0x80+0x200+0x800
D3D12_RESOURCE_STATE_PRESENT = 0
D3D12_RESOURCE_STATE_PREDICATION = 0x200

D3D12_RESOURCE_BARRIER_TYPE_TRANSITION = 0
D3D12_RESOURCE_BARRIER_TYPE_ALIASING = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION + 1
D3D12_RESOURCE_BARRIER_TYPE_UAV = D3D12_RESOURCE_BARRIER_TYPE_ALIASING + 1

D3D12_RESOURCE_BARRIER_FLAG_NONE = 0
D3D12_RESOURCE_BARRIER_FLAG_BEGIN_ONLY = 0x1
D3D12_RESOURCE_BARRIER_FLAG_END_ONLY = 0x2

D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES = 0xffffffff

D3D12_DESCRIPTOR_RANGE_TYPE_SRV = 0
D3D12_DESCRIPTOR_RANGE_TYPE_UAV = D3D12_DESCRIPTOR_RANGE_TYPE_SRV + 1
D3D12_DESCRIPTOR_RANGE_TYPE_CBV = D3D12_DESCRIPTOR_RANGE_TYPE_UAV + 1
D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER = D3D12_DESCRIPTOR_RANGE_TYPE_CBV + 1

D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE = 0
D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE + 1
D3D12_ROOT_PARAMETER_TYPE_CBV = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS + 1
D3D12_ROOT_PARAMETER_TYPE_SRV = D3D12_ROOT_PARAMETER_TYPE_CBV + 1
D3D12_ROOT_PARAMETER_TYPE_UAV = D3D12_ROOT_PARAMETER_TYPE_SRV + 1

D3D12_SHADER_VISIBILITY_ALL = 0
D3D12_SHADER_VISIBILITY_VERTEX = 1
D3D12_SHADER_VISIBILITY_HULL = 2
D3D12_SHADER_VISIBILITY_DOMAIN = 3
D3D12_SHADER_VISIBILITY_GEOMETRY = 4
D3D12_SHADER_VISIBILITY_PIXEL = 5

D3D12_ROOT_SIGNATURE_FLAG_NONE = 0
D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT = 0x1
D3D12_ROOT_SIGNATURE_FLAG_DENY_VERTEX_SHADER_ROOT_ACCESS = 0x2
D3D12_ROOT_SIGNATURE_FLAG_DENY_HULL_SHADER_ROOT_ACCESS = 0x4
D3D12_ROOT_SIGNATURE_FLAG_DENY_DOMAIN_SHADER_ROOT_ACCESS = 0x8
D3D12_ROOT_SIGNATURE_FLAG_DENY_GEOMETRY_SHADER_ROOT_ACCESS = 0x10
D3D12_ROOT_SIGNATURE_FLAG_DENY_PIXEL_SHADER_ROOT_ACCESS = 0x20
D3D12_ROOT_SIGNATURE_FLAG_ALLOW_STREAM_OUTPUT = 0x40

D3D_ROOT_SIGNATURE_VERSION_1 = 0x1

D3D12_BLEND_ZERO = 1
D3D12_BLEND_ONE = 2
D3D12_BLEND_SRC_COLOR = 3
D3D12_BLEND_INV_SRC_COLOR = 4
D3D12_BLEND_SRC_ALPHA = 5
D3D12_BLEND_INV_SRC_ALPHA = 6
D3D12_BLEND_DEST_ALPHA = 7
D3D12_BLEND_INV_DEST_ALPHA = 8
D3D12_BLEND_DEST_COLOR = 9
D3D12_BLEND_INV_DEST_COLOR = 10
D3D12_BLEND_SRC_ALPHA_SAT = 11
D3D12_BLEND_BLEND_FACTOR = 14
D3D12_BLEND_INV_BLEND_FACTOR = 15
D3D12_BLEND_SRC1_COLOR = 16
D3D12_BLEND_INV_SRC1_COLOR = 17
D3D12_BLEND_SRC1_ALPHA = 18
D3D12_BLEND_INV_SRC1_ALPHA = 19

D3D12_BLEND_OP_ADD = 1
D3D12_BLEND_OP_SUBTRACT = 2
D3D12_BLEND_OP_REV_SUBTRACT = 3
D3D12_BLEND_OP_MIN = 4
D3D12_BLEND_OP_MAX = 5

D3D12_COLOR_WRITE_ENABLE_RED = 1
D3D12_COLOR_WRITE_ENABLE_GREEN = 2
D3D12_COLOR_WRITE_ENABLE_BLUE = 4
D3D12_COLOR_WRITE_ENABLE_ALPHA = 8
D3D12_COLOR_WRITE_ENABLE_ALL = D3D12_COLOR_WRITE_ENABLE_RED+D3D12_COLOR_WRITE_ENABLE_GREEN+D3D12_COLOR_WRITE_ENABLE_BLUE+D3D12_COLOR_WRITE_ENABLE_ALPHA

D3D12_LOGIC_OP_CLEAR = 0
D3D12_LOGIC_OP_SET = D3D12_LOGIC_OP_CLEAR + 1
D3D12_LOGIC_OP_COPY = D3D12_LOGIC_OP_SET + 1
D3D12_LOGIC_OP_COPY_INVERTED = D3D12_LOGIC_OP_COPY + 1
D3D12_LOGIC_OP_NOOP = D3D12_LOGIC_OP_COPY_INVERTED + 1
D3D12_LOGIC_OP_INVERT = D3D12_LOGIC_OP_NOOP + 1
D3D12_LOGIC_OP_AND = D3D12_LOGIC_OP_INVERT + 1
D3D12_LOGIC_OP_NAND = D3D12_LOGIC_OP_AND + 1
D3D12_LOGIC_OP_OR = D3D12_LOGIC_OP_NAND + 1
D3D12_LOGIC_OP_NOR = D3D12_LOGIC_OP_OR + 1
D3D12_LOGIC_OP_XOR = D3D12_LOGIC_OP_NOR + 1
D3D12_LOGIC_OP_EQUIV = D3D12_LOGIC_OP_XOR + 1
D3D12_LOGIC_OP_AND_REVERSE = D3D12_LOGIC_OP_EQUIV + 1
D3D12_LOGIC_OP_AND_INVERTED = D3D12_LOGIC_OP_AND_REVERSE + 1
D3D12_LOGIC_OP_OR_REVERSE = D3D12_LOGIC_OP_AND_INVERTED + 1
D3D12_LOGIC_OP_OR_INVERTED = D3D12_LOGIC_OP_OR_REVERSE + 1

D3D12_FILL_MODE_WIREFRAME = 2
D3D12_FILL_MODE_SOLID = 3

D3D12_CULL_MODE_NONE = 1
D3D12_CULL_MODE_FRONT = 2
D3D12_CULL_MODE_BACK = 3

D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF = 0
D3D12_CONSERVATIVE_RASTERIZATION_MODE_ON = 1

D3D12_COMPARISON_FUNC_NEVER = 1
D3D12_COMPARISON_FUNC_LESS = 2
D3D12_COMPARISON_FUNC_EQUAL = 3
D3D12_COMPARISON_FUNC_LESS_EQUAL = 4
D3D12_COMPARISON_FUNC_GREATER = 5
D3D12_COMPARISON_FUNC_NOT_EQUAL = 6
D3D12_COMPARISON_FUNC_GREATER_EQUAL = 7
D3D12_COMPARISON_FUNC_ALWAYS = 8

D3D12_DEPTH_WRITE_MASK_ZERO = 0
D3D12_DEPTH_WRITE_MASK_ALL = 1

D3D12_STENCIL_OP_KEEP = 1
D3D12_STENCIL_OP_ZERO = 2
D3D12_STENCIL_OP_REPLACE = 3
D3D12_STENCIL_OP_INCR_SAT = 4
D3D12_STENCIL_OP_DECR_SAT = 5
D3D12_STENCIL_OP_INVERT = 6
D3D12_STENCIL_OP_INCR = 7
D3D12_STENCIL_OP_DECR = 8

D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA = 0
D3D12_INPUT_CLASSIFICATION_PER_INSTANCE_DATA = 1

D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_DISABLED = 0
D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFF = 1
D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFFFFFF = 2

D3D12_PRIMITIVE_TOPOLOGY_TYPE_UNDEFINED = 0
D3D12_PRIMITIVE_TOPOLOGY_TYPE_POINT = 1
D3D12_PRIMITIVE_TOPOLOGY_TYPE_LINE = 2
D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE = 3
D3D12_PRIMITIVE_TOPOLOGY_TYPE_PATCH = 4

D3D12_PIPELINE_STATE_FLAG_NONE = 0
D3D12_PIPELINE_STATE_FLAG_TOOL_DEBUG = 0x1

struc DXGI_RATIONAL {
  .Numerator dd ?
  .Denominator dd ? }

struc DXGI_MODE_DESC {
  .Width dd ?
  .Height dd ?
  .RefreshRate DXGI_RATIONAL
  .Format dd ?
  .ScanlineOrdering dd ?
  .Scaling dd ? }

struc DXGI_SAMPLE_DESC {
  .Count dd ?
  .Quality dd ? }

struc DXGI_SWAP_CHAIN_DESC {
  .BufferDesc DXGI_MODE_DESC
  .SampleDesc DXGI_SAMPLE_DESC
  .BufferUsage dd ?
  .BufferCount dd ?,?
  .OutputWindow dq ?
  .Windowed dd ?
  .SwapEffect dd ?
  .Flags dd ?,? }

struc D3D12_VIEWPORT {
  .TopLeftX dd ?
  .TopLeftY dd ?
  .Width dd ?
  .Height dd ?
  .MinDepth dd ?
  .MaxDepth dd ? }

D3D12_RECT fix RECT

struc D3D12_COMMAND_QUEUE_DESC {
  .Type dd ?
  .Priority dd ?
  .Flags dd ?
  .NodeMask dd ? }

struc D3D12_DESCRIPTOR_HEAP_DESC {
  .Type dd ?
  .NumDescriptors dd ?
  .Flags dd ?
  .NodeMask dd ? }

struc D3D12_RESOURCE_TRANSITION_BARRIER {
  .pResource dq ?
  .Subresource dd ?
  .StateBefore dd ?
  .StateAfter dd ?,? }

struc D3D12_RESOURCE_ALIASING_BARRIER {
  .pResourceBefore dq ?
  .pResourceAfter dq ? }
struc_offsets_size D3D12_RESOURCE_ALIASING_BARRIER

struc D3D12_RESOURCE_UAV_BARRIER {
  .pResource dq ? }

struc D3D12_RESOURCE_BARRIER {
  .Type dd ?
  .Flags dd ?
  .Transition D3D12_RESOURCE_TRANSITION_BARRIER

virtual at .Transition
  .Aliasing D3D12_RESOURCE_ALIASING_BARRIER
end virtual

virtual at .Transition
  .UAV D3D12_RESOURCE_UAV_BARRIER
end virtual }
struc_offsets_size D3D12_RESOURCE_BARRIER

struc D3D12_DESCRIPTOR_RANGE {
  .RangeType dd ?
  .NumDescriptors dd ?
  .BaseShaderRegister dd ?
  .RegisterSpace dd ?
  .OffsetInDescriptorsFromTableStart dd ? }

struc D3D12_ROOT_DESCRIPTOR_TABLE {
  .NumDescriptorRanges dd ?,?
  .pDescriptorRanges dq ? }

struc D3D12_ROOT_CONSTANTS {
  .ShaderRegister dd ?
  .RegisterSpace dd ?
  .Num32BitValues dd ? }

struc D3D12_ROOT_DESCRIPTOR {
  .ShaderRegister dd ?
  .RegisterSpace dd ? }

struc D3D12_ROOT_PARAMETER {
  .ParameterType dd ?,?
  .DescriptorTable D3D12_ROOT_DESCRIPTOR_TABLE

virtual at .DescriptorTable
  .Constants D3D12_ROOT_CONSTANTS
end virtual

virtual at .DescriptorTable
  .Descriptor D3D12_ROOT_DESCRIPTOR
end virtual

  .ShaderVisibility dd ?,? }

struc D3D12_STATIC_SAMPLER_DESC {
  .Filter dd ?
  .AddressU dd ?
  .AddressV dd ?
  .AddressW dd ?
  .MipLODBias dd ?
  .MaxAnisotropy dd ?
  .ComparisonFunc dd ?
  .BorderColor dd ?
  .MinLOD dd ?
  .MaxLOD dd ?
  .ShaderRegister dd ?
  .RegisterSpace dd ?
  .ShaderVisibility dd ? }

struc D3D12_ROOT_SIGNATURE_DESC {
  .NumParameters dd ?,?
  .pParameters dq ?
  .NumStaticSamplers dd ?,?
  .pStaticSamplers dq ?
  .Flags dd ?,? }

struc D3D12_SHADER_BYTECODE {
  .pShaderBytecode dq ?
  .BytecodeLength dq ? }

struc D3D12_SO_DECLARATION_ENTRY {
  .Stream dd ?,?
  .SemanticName dq ?
  .SemanticIndex dd ?
  .StartComponent db ?
  .ComponentCount db ?
  .OutputSlot db ?,? }

struc D3D12_STREAM_OUTPUT_DESC {
  .pSODeclaration dq ?
  .NumEntries dd ?,?
  .pBufferStrides dq ?
  .NumStrides dd ?
  .RasterizedStream dd ? }

struc D3D12_RENDER_TARGET_BLEND_DESC {
  .BlendEnable dd ?
  .LogicOpEnable dd ?
  .SrcBlend dd ?
  .DestBlend dd ?
  .BlendOp dd ?
  .SrcBlendAlpha dd ?
  .DestBlendAlpha dd ?
  .BlendOpAlpha dd ?
  .LogicOp dd ?
  .RenderTargetWriteMask db ?,?,?,? }

struc D3D12_BLEND_DESC {
  .AlphaToCoverageEnable dd ?
  .IndependentBlendEnable dd ?
rept 8 n:0 \{
  .RenderTarget\#n D3D12_RENDER_TARGET_BLEND_DESC \} }

struc D3D12_RASTERIZER_DESC {
  .FillMode dd ?
  .CullMode dd ?
  .FrontCounterClockwise dd ?
  .DepthBias dd ?
  .DepthBiasClamp dd ?
  .SlopeScaledDepthBias dd ?
  .DepthClipEnable dd ?
  .MultisampleEnable dd ?
  .AntialiasedLineEnable dd ?
  .ForcedSampleCount dd ?
  .ConservativeRaster dd ? }

struc D3D12_DEPTH_STENCILOP_DESC {
  .StencilFailOp dd ?
  .StencilDepthFailOp dd ?
  .StencilPassOp dd ?
  .StencilFunc dd ? }

struc D3D12_DEPTH_STENCIL_DESC {
  .DepthEnable dd ?
  .DepthWriteMask dd ?
  .DepthFunc dd ?
  .StencilEnable dd ?
  .StencilReadMask db ?
  .StencilWriteMask db ?,?,?
  .FrontFace D3D12_DEPTH_STENCILOP_DESC
  .BackFace D3D12_DEPTH_STENCILOP_DESC }

struc D3D12_INPUT_ELEMENT_DESC {
  .SemanticName dq ?
  .SemanticIndex dd ?
  .Format dd ?
  .InputSlot dd ?
  .AlignedByteOffset dd ?
  .InputSlotClass dd ?
  .InstanceDataStepRate dd ? }

struc D3D12_INPUT_LAYOUT_DESC {
  .pInputElementDescs dq ?
  .NumElements dd ?,? }

struc D3D12_CACHED_PIPELINE_STATE {
  .pCachedBlob dq ?
  .CachedBlobSizeInBytes dq ? }

struc D3D12_GRAPHICS_PIPELINE_STATE_DESC {
  .pRootSignature dq ?
  .VS D3D12_SHADER_BYTECODE
  .PS D3D12_SHADER_BYTECODE
  .DS D3D12_SHADER_BYTECODE
  .HS D3D12_SHADER_BYTECODE
  .GS D3D12_SHADER_BYTECODE
  .StreamOutput D3D12_STREAM_OUTPUT_DESC
  .BlendState D3D12_BLEND_DESC
  .SampleMask dd ?
  .RasterizerState D3D12_RASTERIZER_DESC
  .DepthStencilState D3D12_DEPTH_STENCIL_DESC
  dd ?
  .InputLayout D3D12_INPUT_LAYOUT_DESC
  .IBStripCutValue dd ?
  .PrimitiveTopologyType dd ?
  .NumRenderTargets dd ?
  .RTVFormats dd 8 dup ?
  .DSVFormat dd ?
  .SampleDesc DXGI_SAMPLE_DESC
  .NodeMask dd ?,?
  .CachedPSO D3D12_CACHED_PIPELINE_STATE
  .Flags dd ?,? }
STRUC_OFFSETS_SIZE D3D12_GRAPHICS_PIPELINE_STATE_DESC

struc D3D12_RANGE {
  .Begin dq ?
  .End dq ? }

struc D3D12_VERTEX_BUFFER_VIEW {
  .BufferLocation dq ?
  .SizeInBytes dd ?
  .StrideInBytes dd ? }
struc_offsets_size D3D12_VERTEX_BUFFER_VIEW

struc D3D12_INDEX_BUFFER_VIEW {
  .BufferLocation dq ?
  .SizeInBytes dd ?
  .Format dd ? }
struc_offsets_size D3D12_INDEX_BUFFER_VIEW

D3D12_HEAP_TYPE_DEFAULT = 1
D3D12_HEAP_TYPE_UPLOAD = 2
D3D12_HEAP_TYPE_READBACK = 3
D3D12_HEAP_TYPE_CUSTOM = 4

D3D12_CPU_PAGE_PROPERTY_UNKNOWN = 0
D3D12_CPU_PAGE_PROPERTY_NOT_AVAILABLE = 1
D3D12_CPU_PAGE_PROPERTY_WRITE_COMBINE = 2
D3D12_CPU_PAGE_PROPERTY_WRITE_BACK = 3

D3D12_MEMORY_POOL_UNKNOWN = 0
D3D12_MEMORY_POOL_L0 = 1
D3D12_MEMORY_POOL_L1 = 2

D3D12_HEAP_FLAG_NONE = 0
D3D12_HEAP_FLAG_SHARED = 0x1
D3D12_HEAP_FLAG_DENY_BUFFERS = 0x4
D3D12_HEAP_FLAG_ALLOW_DISPLAY = 0x8
D3D12_HEAP_FLAG_SHARED_CROSS_ADAPTER = 0x20
D3D12_HEAP_FLAG_DENY_RT_DS_TEXTURES = 0x40
D3D12_HEAP_FLAG_DENY_NON_RT_DS_TEXTURES = 0x80
D3D12_HEAP_FLAG_ALLOW_ALL_BUFFERS_AND_TEXTURES = 0
D3D12_HEAP_FLAG_ALLOW_ONLY_BUFFERS = 0xc0
D3D12_HEAP_FLAG_ALLOW_ONLY_NON_RT_DS_TEXTURES = 0x44
D3D12_HEAP_FLAG_ALLOW_ONLY_RT_DS_TEXTURES = 0x84

struc D3D12_HEAP_PROPERTIES {
  .Type dd ?
  .CPUPageProperty dd ?
  .MemoryPoolPreference dd ?
  .CreationNodeMask dd ?
  .VisibleNodeMask dd ? }

D3D12_RESOURCE_DIMENSION_UNKNOWN = 0
D3D12_RESOURCE_DIMENSION_BUFFER = 1
D3D12_RESOURCE_DIMENSION_TEXTURE1D = 2
D3D12_RESOURCE_DIMENSION_TEXTURE2D = 3
D3D12_RESOURCE_DIMENSION_TEXTURE3D = 4

D3D12_TEXTURE_LAYOUT_UNKNOWN = 0
D3D12_TEXTURE_LAYOUT_ROW_MAJOR = 1
D3D12_TEXTURE_LAYOUT_64KB_UNDEFINED_SWIZZLE = 2
D3D12_TEXTURE_LAYOUT_64KB_STANDARD_SWIZZLE = 3

D3D12_RESOURCE_FLAG_NONE = 0
D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET = 0x1
D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL = 0x2
D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS = 0x4
D3D12_RESOURCE_FLAG_DENY_SHADER_RESOURCE = 0x8
D3D12_RESOURCE_FLAG_ALLOW_CROSS_ADAPTER = 0x10
D3D12_RESOURCE_FLAG_ALLOW_SIMULTANEOUS_ACCESS = 0x20

struc D3D12_RESOURCE_DESC {
  .Dimension dd ?,?
  .Alignment dq ?
  .Width dq ?
  .Height dd ?
  .DepthOrArraySize dw ?
  .MipLevels dw ?
  .Format dd ?
  .SampleDesc DXGI_SAMPLE_DESC
  .Layout dd ?
  .Flags dd ?,? }

virtual at 0
  ID3D12Device:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetNodeCount rq 1
    .CreateCommandQueue rq 1
    .CreateCommandAllocator rq 1
    .CreateGraphicsPipelineState rq 1
    .CreateComputePipelineState rq 1
    .CreateCommandList rq 1
    .CheckFeatureSupport rq 1
    .CreateDescriptorHeap rq 1
    .GetDescriptorHandleIncrementSize rq 1
    .CreateRootSignature rq 1
    .CreateConstantBufferView rq 1
    .CreateShaderResourceView rq 1
    .CreateUnorderedAccessView rq 1
    .CreateRenderTargetView rq 1
    .CreateDepthStencilView rq 1
    .CreateSampler rq 1
    .CopyDescriptors rq 1
    .CopyDescriptorsSimple rq 1
    .GetResourceAllocationInfo rq 1
    .GetCustomHeapProperties rq 1
    .CreateCommittedResource rq 1
    .CreateHeap rq 1
    .CreatePlacedResource rq 1
    .CreateReservedResource rq 1
    .CreateSharedHandle rq 1
    .OpenSharedHandle rq 1
    .OpenSharedHandleByName rq 1
    .MakeResident rq 1
    .Evict rq 1
    .CreateFence rq 1
    .GetDeviceRemovedReason rq 1
    .GetCopyableFootprints rq 1
    .CreateQueryHeap rq 1
    .SetStablePowerState rq 1
    .CreateCommandSignature rq 1
    .GetResourceTiling rq 1
    .GetAdapterLuid rq 1
end virtual

virtual at 0
  ID3D12CommandQueue:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .UpdateTileMappings rq 1
    .CopyTileMappings rq 1
    .ExecuteCommandLists rq 1
    .SetMarker rq 1
    .BeginEvent rq 1
    .EndEvent rq 1
    .Signal rq 1
    .Wait rq 1
    .GetTimestampFrequency rq 1
    .GetClockCalibration rq 1
    .GetDesc rq 1
end virtual

virtual at 0
  ID3D12CommandAllocator:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .Reset rq 1
end virtual

virtual at 0
  ID3D12DescriptorHeap:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .GetDesc rq 1
    .GetCPUDescriptorHandleForHeapStart rq 1
    .GetGPUDescriptorHandleForHeapStart rq 1
end virtual

virtual at 0
  ID3D12CommandList:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .GetType rq 1
end virtual

virtual at 0
  ID3D12GraphicsCommandList:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .GetType rq 1
    .Close rq 1
    .Reset rq 1
    .ClearState rq 1
    .DrawInstanced rq 1
    .DrawIndexedInstanced rq 1
    .Dispatch rq 1
    .CopyBufferRegion rq 1
    .CopyTextureRegion rq 1
    .CopyResource rq 1
    .CopyTiles rq 1
    .ResolveSubresource rq 1
    .IASetPrimitiveTopology rq 1
    .RSSetViewports rq 1
    .RSSetScissorRects rq 1
    .OMSetBlendFactor rq 1
    .OMSetStencilRef rq 1
    .SetPipelineState rq 1
    .ResourceBarrier rq 1
    .ExecuteBundle rq 1
    .SetDescriptorHeaps rq 1
    .SetComputeRootSignature rq 1
    .SetGraphicsRootSignature rq 1
    .SetComputeRootDescriptorTable rq 1
    .SetGraphicsRootDescriptorTable rq 1
    .SetComputeRoot32BitConstant rq 1
    .SetGraphicsRoot32BitConstant rq 1
    .SetComputeRoot32BitConstants rq 1
    .SetGraphicsRoot32BitConstants rq 1
    .SetComputeRootConstantBufferView rq 1
    .SetGraphicsRootConstantBufferView rq 1
    .SetComputeRootShaderResourceView rq 1
    .SetGraphicsRootShaderResourceView rq 1
    .SetComputeRootUnorderedAccessView rq 1
    .SetGraphicsRootUnorderedAccessView rq 1
    .IASetIndexBuffer rq 1
    .IASetVertexBuffers rq 1
    .SOSetTargets rq 1
    .OMSetRenderTargets rq 1
    .ClearDepthStencilView rq 1
    .ClearRenderTargetView rq 1
    .ClearUnorderedAccessViewUint rq 1
    .ClearUnorderedAccessViewFloat rq 1
    .DiscardResource rq 1
    .BeginQuery rq 1
    .EndQuery rq 1
    .ResolveQueryData rq 1
    .SetPredication rq 1
    .SetMarker rq 1
    .BeginEvent rq 1
    .EndEvent rq 1
    .ExecuteIndirect rq 1
end virtual

virtual at 0
  ID3D12Fence:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .GetCompletedValue rq 1
    .SetEventOnCompletion rq 1
    .Signal rq 1
end virtual

virtual at 0
  ID3D12Resource:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
    .Map rq 1
    .Unmap rq 1
    .GetDesc rq 1
    .GetGPUVirtualAddress rq 1
    .WriteToSubresource rq 1
    .ReadFromSubresource rq 1
    .GetHeapProperties rq 1
end virtual

virtual at 0
  ID3DBlob:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetBufferPointer rq 1
    .GetBufferSize rq 1
end virtual

virtual at 0
  ID3D12RootSignature:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .GetPrivateData rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .SetName rq 1
    .GetDevice rq 1
end virtual

; D3D12 debug layer

virtual at 0
  ID3D12Debug:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .EnableDebugLayer rq 1
end virtual

; DXGI

DXGI_FORMAT_UNKNOWN = 0
DXGI_FORMAT_R32G32B32A32_TYPELESS = 1
DXGI_FORMAT_R32G32B32A32_FLOAT = 2
DXGI_FORMAT_R32G32B32A32_UINT = 3
DXGI_FORMAT_R32G32B32A32_SINT = 4
DXGI_FORMAT_R32G32B32_TYPELESS = 5
DXGI_FORMAT_R32G32B32_FLOAT = 6
DXGI_FORMAT_R32G32B32_UINT = 7
DXGI_FORMAT_R32G32B32_SINT = 8
DXGI_FORMAT_R16G16B16A16_TYPELESS = 9
DXGI_FORMAT_R16G16B16A16_FLOAT = 10
DXGI_FORMAT_R16G16B16A16_UNORM = 11
DXGI_FORMAT_R16G16B16A16_UINT = 12
DXGI_FORMAT_R16G16B16A16_SNORM = 13
DXGI_FORMAT_R16G16B16A16_SINT = 14
DXGI_FORMAT_R32G32_TYPELESS = 15
DXGI_FORMAT_R32G32_FLOAT = 16
DXGI_FORMAT_R32G32_UINT = 17
DXGI_FORMAT_R32G32_SINT = 18
DXGI_FORMAT_R32G8X24_TYPELESS = 19
DXGI_FORMAT_D32_FLOAT_S8X24_UINT = 20
DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS = 21
DXGI_FORMAT_X32_TYPELESS_G8X24_UINT = 22
DXGI_FORMAT_R10G10B10A2_TYPELESS = 23
DXGI_FORMAT_R10G10B10A2_UNORM = 24
DXGI_FORMAT_R10G10B10A2_UINT = 25
DXGI_FORMAT_R11G11B10_FLOAT = 26
DXGI_FORMAT_R8G8B8A8_TYPELESS = 27
DXGI_FORMAT_R8G8B8A8_UNORM = 28
DXGI_FORMAT_R8G8B8A8_UNORM_SRGB = 29
DXGI_FORMAT_R8G8B8A8_UINT = 30
DXGI_FORMAT_R8G8B8A8_SNORM = 31
DXGI_FORMAT_R8G8B8A8_SINT = 32
DXGI_FORMAT_R16G16_TYPELESS = 33
DXGI_FORMAT_R16G16_FLOAT = 34
DXGI_FORMAT_R16G16_UNORM = 35
DXGI_FORMAT_R16G16_UINT = 36
DXGI_FORMAT_R16G16_SNORM = 37
DXGI_FORMAT_R16G16_SINT = 38
DXGI_FORMAT_R32_TYPELESS = 39
DXGI_FORMAT_D32_FLOAT = 40
DXGI_FORMAT_R32_FLOAT = 41
DXGI_FORMAT_R32_UINT = 42
DXGI_FORMAT_R32_SINT = 43
DXGI_FORMAT_R24G8_TYPELESS = 44
DXGI_FORMAT_D24_UNORM_S8_UINT = 45
DXGI_FORMAT_R24_UNORM_X8_TYPELESS = 46
DXGI_FORMAT_X24_TYPELESS_G8_UINT = 47
DXGI_FORMAT_R8G8_TYPELESS = 48
DXGI_FORMAT_R8G8_UNORM = 49
DXGI_FORMAT_R8G8_UINT = 50
DXGI_FORMAT_R8G8_SNORM = 51
DXGI_FORMAT_R8G8_SINT = 52
DXGI_FORMAT_R16_TYPELESS = 53
DXGI_FORMAT_R16_FLOAT = 54
DXGI_FORMAT_D16_UNORM = 55
DXGI_FORMAT_R16_UNORM = 56
DXGI_FORMAT_R16_UINT = 57
DXGI_FORMAT_R16_SNORM = 58
DXGI_FORMAT_R16_SINT = 59
DXGI_FORMAT_R8_TYPELESS = 60
DXGI_FORMAT_R8_UNORM = 61
DXGI_FORMAT_R8_UINT = 62
DXGI_FORMAT_R8_SNORM = 63
DXGI_FORMAT_R8_SINT = 64
DXGI_FORMAT_A8_UNORM = 65
DXGI_FORMAT_R1_UNORM = 66
DXGI_FORMAT_R9G9B9E5_SHAREDEXP = 67
DXGI_FORMAT_R8G8_B8G8_UNORM = 68
DXGI_FORMAT_G8R8_G8B8_UNORM = 69
DXGI_FORMAT_BC1_TYPELESS = 70
DXGI_FORMAT_BC1_UNORM = 71
DXGI_FORMAT_BC1_UNORM_SRGB = 72
DXGI_FORMAT_BC2_TYPELESS = 73
DXGI_FORMAT_BC2_UNORM = 74
DXGI_FORMAT_BC2_UNORM_SRGB = 75
DXGI_FORMAT_BC3_TYPELESS = 76
DXGI_FORMAT_BC3_UNORM = 77
DXGI_FORMAT_BC3_UNORM_SRGB = 78
DXGI_FORMAT_BC4_TYPELESS = 79
DXGI_FORMAT_BC4_UNORM = 80
DXGI_FORMAT_BC4_SNORM = 81
DXGI_FORMAT_BC5_TYPELESS = 82
DXGI_FORMAT_BC5_UNORM = 83
DXGI_FORMAT_BC5_SNORM = 84
DXGI_FORMAT_B5G6R5_UNORM = 85
DXGI_FORMAT_B5G5R5A1_UNORM = 86
DXGI_FORMAT_B8G8R8A8_UNORM = 87
DXGI_FORMAT_B8G8R8X8_UNORM = 88
DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM = 89
DXGI_FORMAT_B8G8R8A8_TYPELESS = 90
DXGI_FORMAT_B8G8R8A8_UNORM_SRGB = 91
DXGI_FORMAT_B8G8R8X8_TYPELESS = 92
DXGI_FORMAT_B8G8R8X8_UNORM_SRGB = 93
DXGI_FORMAT_BC6H_TYPELESS = 94
DXGI_FORMAT_BC6H_UF16 = 95
DXGI_FORMAT_BC6H_SF16 = 96
DXGI_FORMAT_BC7_TYPELESS = 97
DXGI_FORMAT_BC7_UNORM = 98
DXGI_FORMAT_BC7_UNORM_SRGB = 99
DXGI_FORMAT_AYUV = 100
DXGI_FORMAT_Y410 = 101
DXGI_FORMAT_Y416 = 102
DXGI_FORMAT_NV12 = 103
DXGI_FORMAT_P010 = 104
DXGI_FORMAT_P016 = 105
DXGI_FORMAT_420_OPAQUE = 106
DXGI_FORMAT_YUY2 = 107
DXGI_FORMAT_Y210 = 108
DXGI_FORMAT_Y216 = 109
DXGI_FORMAT_NV11 = 110
DXGI_FORMAT_AI44 = 111
DXGI_FORMAT_IA44 = 112
DXGI_FORMAT_P8 = 113
DXGI_FORMAT_A8P8 = 114
DXGI_FORMAT_B4G4R4A4_UNORM = 115
DXGI_FORMAT_P208 = 130
DXGI_FORMAT_V208 = 131
DXGI_FORMAT_V408 = 132

DXGI_USAGE_RENDER_TARGET_OUTPUT = 0x00000020

DXGI_SWAP_EFFECT_DISCARD = 0
DXGI_SWAP_EFFECT_SEQUENTIAL = 1
DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = 3
DXGI_SWAP_EFFECT_FLIP_DISCARD = 4

virtual at 0
  IDXGIFactory4:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .GetPrivateData rq 1
    .GetParent rq 1
    .EnumAdapters rq 1
    .MakeWindowAssociation rq 1
    .GetWindowAssociation rq 1
    .CreateSwapChain rq 1
    .CreateSoftwareAdapter rq 1
    .EnumAdapters1 rq 1
    .IsCurrent rq 1
    .IsWindowedStereoEnabled rq 1
    .CreateSwapChainForHwnd rq 1
    .CreateSwapChainForCoreWindow rq 1
    .GetSharedResourceAdapterLuid rq 1
    .RegisterStereoStatusWindow rq 1
    .RegisterStereoStatusEvent rq 1
    .UnregisterStereoStatus rq 1
    .RegisterOcclusionStatusWindow rq 1
    .RegisterOcclusionStatusEvent rq 1
    .UnregisterOcclusionStatus rq 1
    .CreateSwapChainForComposition rq 1
    .GetCreationFlags rq 1
    .EnumAdapterByLuid rq 1
    .EnumWarpAdapter rq 1
end virtual

virtual at 0
  IDXGISwapChain3:
    .QueryInterface rq 1
    .AddRef rq 1
    .Release rq 1
    .SetPrivateData rq 1
    .SetPrivateDataInterface rq 1
    .GetPrivateData rq 1
    .GetParent rq 1
    .GetDevice rq 1
    .Present rq 1
    .GetBuffer rq 1
    .SetFullscreenState rq 1
    .GetFullscreenState rq 1
    .GetDesc rq 1
    .ResizeBuffers rq 1
    .ResizeTarget rq 1
    .GetContainingOutput rq 1
    .GetFrameStatistics rq 1
    .GetLastPresentCount rq 1
    .GetDesc1 rq 1
    .GetFullscreenDesc rq 1
    .GetHwnd rq 1
    .GetCoreWindow rq 1
    .Present1 rq 1
    .IsTemporaryMonoSupported rq 1
    .GetRestrictToOutput rq 1
    .SetBackgroundColor rq 1
    .GetBackgroundColor rq 1
    .SetRotation rq 1
    .GetRotation rq 1
    .SetSourceSize rq 1
    .GetSourceSize rq 1
    .SetMaximumFrameLatency rq 1
    .GetMaximumFrameLatency rq 1
    .GetFrameLatencyWaitableObject rq 1
    .SetMatrixTransform rq 1
    .GetMatrixTransform rq 1
    .GetCurrentBackBufferIndex rq 1
    .CheckColorSpaceSupport rq 1
    .SetColorSpace1 rq 1
    .ResizeBuffers1 rq 1
end virtual
