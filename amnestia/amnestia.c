#include "amnestia.h"

//-----------------------------------------------------------------------------
#define k_swap_buffer_count 4
#define k_shader_count 1
//-----------------------------------------------------------------------------
#define SAFE_RELEASE(x) if ((x)) { IUnknown_Release((x)); (x) = NULL; }
//-----------------------------------------------------------------------------
typedef struct {
  ID3D12DescriptorHeap *heap;
  D3D12_CPU_DESCRIPTOR_HANDLE cpu_handle;
  D3D12_GPU_DESCRIPTOR_HANDLE gpu_handle;
} descriptor_heap_t;

typedef struct {
  const char *name;
  ID3D12PipelineState *pso;
} shader_t;

typedef struct {
  IMMDeviceEnumerator *enumerator;
  IMMDevice *device;
  IAudioClient *client;
  IAudioRenderClient *render_client;
} audio_state_t;

typedef struct {
  const char *name;
  int swap_buffer_index;
  double time;
  float time_delta;
  int resolution[2];
  int fullscreen;
  HWND hwnd;
  HANDLE heap;
  IDXGIFactory *dxgi_factory;
  IDXGISwapChain *dxgi_swap_chain;
  ID3D12Device *device;
  ID3D12CommandQueue *cmd_queue;
  ID3D12CommandAllocator *cmd_allocator;
  ID3D12GraphicsCommandList *cmd_list;
  ID3D12RootSignature *root_signature;
  shader_t shader[k_shader_count];
  int current_shader;
  descriptor_heap_t rtv_dh;
  descriptor_heap_t cbv_srv_uav_dh;
  UINT rtv_dh_size;
  UINT cbv_srv_uav_dh_size;
  ID3D12Resource *swap_buffer[k_swap_buffer_count];
  D3D12_VIEWPORT viewport;
  D3D12_RECT scissor_rect;
  ID3D12Fence *fence;
  UINT64 fence_value;
  HANDLE fence_event;
  ID3D12Resource *constant_buffer;
  audio_state_t audio;
} demo_t;
//-----------------------------------------------------------------------------
int _fltused;
//-----------------------------------------------------------------------------
static void *load_binary_file(const char *filename, size_t *filesize)
{
  if (!filename || !filesize) return NULL;

  HANDLE file = CreateFile(filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (file == INVALID_HANDLE_VALUE) return NULL;

  DWORD size = GetFileSize(file, NULL);
  if (size == INVALID_FILE_SIZE) {
    CloseHandle(file);
    return NULL;
  }

  HANDLE heap = GetProcessHeap();
  void *data = HeapAlloc(heap, 0, size);
  if (!data) {
    CloseHandle(file);
    return NULL;
  }

  DWORD bytes;
  BOOL res = ReadFile(file, data, size, &bytes, NULL);
  if (!res || bytes != size) {
    CloseHandle(file);
    HeapFree(heap, 0, data);
    return NULL;
  }

  CloseHandle(file);
  *filesize = size;
  return data;
}
//-----------------------------------------------------------------------------
static LRESULT CALLBACK winproc(HWND win, UINT msg, WPARAM wparam, LPARAM lparam)
{
  switch (msg) {
  case WM_DESTROY:
  case WM_KEYDOWN:
    PostQuitMessage(0);
    return 0;
  }
  return DefWindowProc(win, msg, wparam, lparam);
}
//-----------------------------------------------------------------------------
static double get_time(void)
{
  static LARGE_INTEGER freq = { 0 };
  static LARGE_INTEGER counter0 = { 0 };

  if (freq.QuadPart == 0) {
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&counter0);
  }
  LARGE_INTEGER counter;
  QueryPerformanceCounter(&counter);
  return (counter.QuadPart - counter0.QuadPart) / (double)freq.QuadPart;
}
//-----------------------------------------------------------------------------
static int init_audio(audio_state_t *audio)
{
  /*
    EXIT_ON_ERROR(hr)

    // Tell the audio source which format to use.
    hr = pMySource->SetFormat(pwfx);
    EXIT_ON_ERROR(hr)

    // Create an event handle and register it for
    // buffer-event notifications.
    hEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
    if (hEvent == NULL)
    {
        hr = E_FAIL;
        goto Exit;
    }

    hr = pAudioClient->SetEventHandle(hEvent);
    EXIT_ON_ERROR(hr);

    // Get the actual size of the two allocated buffers.
    hr = pAudioClient->GetBufferSize(&bufferFrameCount);
    EXIT_ON_ERROR(hr)

    hr = pAudioClient->GetService(
                         IID_IAudioRenderClient,
                         (void**)&pRenderClient);
    EXIT_ON_ERROR(hr)

    */
  if (FAILED(CoInitialize(NULL))) return 0;

  HRESULT hr;
  hr = CoCreateInstance(&CLSID_MMDeviceEnumerator, NULL, CLSCTX_ALL, &IID_IMMDeviceEnumerator, (void **)&audio->enumerator);
  if (FAILED(hr)) return 0;

  hr = IMMDeviceEnumerator_GetDefaultAudioEndpoint(audio->enumerator, eRender, eConsole, &audio->device);
  if (FAILED(hr)) return 0;

  hr = IMMDevice_Activate(audio->device, &IID_IAudioClient, CLSCTX_ALL, NULL, (void **)&audio->client);
  if (FAILED(hr)) return 0;

  WAVEFORMATEX format = {
    .wFormatTag = WAVE_FORMAT_PCM, .nChannels = 2, .nSamplesPerSec = 44100, .nAvgBytesPerSec = 44100*4, .nBlockAlign = 4,
    .wBitsPerSample = 16
  };
  hr = IAudioClient_IsFormatSupported(audio->client, AUDCLNT_SHAREMODE_EXCLUSIVE, &format, NULL);
  if (FAILED(hr)) return 0;

  REFERENCE_TIME period;
  hr = IAudioClient_GetDevicePeriod(audio->client, NULL, &period);
  if (FAILED(hr)) return 0;

  hr = IAudioClient_Initialize(audio->client, AUDCLNT_SHAREMODE_EXCLUSIVE, AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
                               period, period, &format, NULL);
  UINT32 size = 0;
  if (hr == AUDCLNT_E_BUFFER_SIZE_NOT_ALIGNED) {
    IAudioClient_GetBufferSize(audio->client, &size);
    period = (REFERENCE_TIME)(10000000.0 * size / 44100.0 + 0.5);

    SAFE_RELEASE(audio->client);

    hr = IMMDevice_Activate(audio->device, &IID_IAudioClient, CLSCTX_ALL, NULL, (void **)&audio->client);
    if (FAILED(hr)) return 0;

    hr = IAudioClient_Initialize(audio->client, AUDCLNT_SHAREMODE_EXCLUSIVE, AUDCLNT_STREAMFLAGS_EVENTCALLBACK,
                                 period, period, &format, NULL);
  }
  if (FAILED(hr)) return 0;
  IAudioClient_GetBufferSize(audio->client, &size);

  return 1;
}
//-----------------------------------------------------------------------------
static int compile_shaders(demo_t *demo)
{
  size_t vs_bytecode_size;
  void *vs_bytecode = load_binary_file("data/vs_full_triangle.cso", &vs_bytecode_size);
  if (!vs_bytecode) return 0;

  for (int i = 0; i < k_shader_count; ++i) {
    char path[128];
    strcpy(path, "data/ps_");
    strcat(path, demo->shader[i].name);
    strcat(path, ".cso");

    SAFE_RELEASE(demo->shader[i].pso);
    size_t ps_bytecode_size;
    void *ps_bytecode = load_binary_file(path, &ps_bytecode_size);

    D3D12_GRAPHICS_PIPELINE_STATE_DESC pso_desc = {
      .pRootSignature = demo->root_signature,
      .VS = { vs_bytecode, vs_bytecode_size },
      .PS = { ps_bytecode, ps_bytecode_size },
      .RasterizerState.FillMode = D3D12_FILL_MODE_SOLID,
      .RasterizerState.CullMode = D3D12_CULL_MODE_NONE,
      .BlendState.RenderTarget[0].RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_ALL,
      .SampleMask = UINT_MAX,
      .PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE,
      .NumRenderTargets = 1,
      .RTVFormats[0] = DXGI_FORMAT_R8G8B8A8_UNORM,
      .SampleDesc.Count = 1
    };
    HRESULT r = ID3D12Device_CreateGraphicsPipelineState(demo->device, &pso_desc, &IID_ID3D12PipelineState,
                                                         (void **)&demo->shader[i].pso);
    if (ps_bytecode) HeapFree(demo->heap, 0, ps_bytecode);
    if (FAILED(r)) {
      HeapFree(demo->heap, 0, vs_bytecode);
      return 0;
    }
  }

  HeapFree(demo->heap, 0, vs_bytecode);
  return 1;
}
//-----------------------------------------------------------------------------
static void resource_barrier(ID3D12GraphicsCommandList *cmd_list, ID3D12Resource *resource,
                             D3D12_RESOURCE_STATES state_before, D3D12_RESOURCE_STATES state_after)
{
  D3D12_RESOURCE_BARRIER barrier_desc = {
    .Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION,
    .Flags = D3D12_RESOURCE_BARRIER_FLAG_NONE,
    .Transition.pResource = resource,
    .Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
    .Transition.StateBefore = state_before,
    .Transition.StateAfter = state_after
  };
  ID3D12GraphicsCommandList_ResourceBarrier(cmd_list, 1, &barrier_desc);
}
//-----------------------------------------------------------------------------
static void generate_device_commands(demo_t *demo)
{
  ID3D12CommandAllocator_Reset(demo->cmd_allocator);

  ID3D12GraphicsCommandList_Reset(demo->cmd_list, demo->cmd_allocator,
                                  demo->shader[demo->current_shader].pso);
  ID3D12GraphicsCommandList_SetDescriptorHeaps(demo->cmd_list, 1, &demo->cbv_srv_uav_dh.heap);

  ID3D12GraphicsCommandList_SetGraphicsRootSignature(demo->cmd_list, demo->root_signature);
  ID3D12GraphicsCommandList_RSSetViewports(demo->cmd_list, 1, &demo->viewport);
  ID3D12GraphicsCommandList_RSSetScissorRects(demo->cmd_list, 1, &demo->scissor_rect);

  resource_barrier(demo->cmd_list, demo->swap_buffer[demo->swap_buffer_index], D3D12_RESOURCE_STATE_PRESENT,
                   D3D12_RESOURCE_STATE_RENDER_TARGET);

  float clear_color[] = { 0.0f, 0.2f, 0.4f, 1.0f };

  D3D12_CPU_DESCRIPTOR_HANDLE rtv_handle = demo->rtv_dh.cpu_handle;
  rtv_handle.ptr += demo->swap_buffer_index * demo->rtv_dh_size;

  ID3D12GraphicsCommandList_SetGraphicsRootDescriptorTable(demo->cmd_list, 0, demo->cbv_srv_uav_dh.gpu_handle);

  ID3D12GraphicsCommandList_ClearRenderTargetView(demo->cmd_list, rtv_handle, clear_color, 0, NULL);
  ID3D12GraphicsCommandList_OMSetRenderTargets(demo->cmd_list, 1, &rtv_handle, TRUE, NULL);
  ID3D12GraphicsCommandList_IASetPrimitiveTopology(demo->cmd_list, D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

  ID3D12GraphicsCommandList_DrawInstanced(demo->cmd_list, 3, 1, 0, 0);

  resource_barrier(demo->cmd_list, demo->swap_buffer[demo->swap_buffer_index], D3D12_RESOURCE_STATE_RENDER_TARGET,
                   D3D12_RESOURCE_STATE_PRESENT);

  ID3D12GraphicsCommandList_Close(demo->cmd_list);
}
//-----------------------------------------------------------------------------
static void wait_for_device(demo_t *demo)
{
  UINT64 value = demo->fence_value;
  ID3D12CommandQueue_Signal(demo->cmd_queue, demo->fence, value);
  demo->fence_value++;

  if (ID3D12Fence_GetCompletedValue(demo->fence) < value) {
    ID3D12Fence_SetEventOnCompletion(demo->fence, value, demo->fence_event);
    WaitForSingleObject(demo->fence_event, INFINITE);
  }
}
//-----------------------------------------------------------------------------
static void update_frame_stats(demo_t *demo)
{
  static double prev_time = -1.0;
  static double prev_fps_time = 0.0;
  static int fps_frame = 0;

  if (prev_time < 0.0) {
    prev_time = get_time();
    prev_fps_time = prev_time;
  }

  demo->time = get_time();
  demo->time_delta = (float)(demo->time - prev_time);
  prev_time = demo->time;

  if ((demo->time - prev_fps_time) >= 1.0) {
    double fps = fps_frame / (demo->time - prev_fps_time);
    double us = (1.0 / fps) * 1000000.0;
    char text[256];
    wsprintf(text, "[%d fps  %d us] %s", (int)fps, (int)us, demo->name);
    SetWindowText(demo->hwnd, text);
    prev_fps_time = demo->time;
    fps_frame = 0;
  }
  fps_frame++;
}
//-----------------------------------------------------------------------------
static int init(demo_t *demo)
{
  if (!init_audio(&demo->audio)) return 0;

  WNDCLASS winclass = {
    .lpfnWndProc = winproc,
    .hInstance = GetModuleHandle(NULL),
    .hCursor = LoadCursor(NULL, IDC_ARROW),
    .lpszClassName = demo->name
  };
  if (!RegisterClass(&winclass)) return 0;

  if (demo->fullscreen) {
    demo->resolution[0] = GetSystemMetrics(SM_CXSCREEN);
    demo->resolution[1] = GetSystemMetrics(SM_CYSCREEN);
    ShowCursor(FALSE);
  }

  RECT rect = { 0, 0, demo->resolution[0], demo->resolution[1] };
  if (!AdjustWindowRect(&rect, WS_OVERLAPPED | WS_SYSMENU | WS_CAPTION | WS_MINIMIZEBOX, FALSE))
    return 0;

  demo->hwnd = CreateWindow(
    demo->name, demo->name,
    WS_OVERLAPPED | WS_SYSMENU | WS_CAPTION | WS_MINIMIZEBOX | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT,
    rect.right - rect.left, rect.bottom - rect.top,
    NULL, NULL, NULL, 0);
  if (!demo->hwnd) return 0;

  HRESULT res = CreateDXGIFactory1(&IID_IDXGIFactory, &demo->dxgi_factory);
  if (FAILED(res)) return 0;

#ifdef _DEBUG
  ID3D12Debug *dbg = NULL;
  D3D12GetDebugInterface(&IID_ID3D12Debug, &dbg);
  if (dbg) {
    ID3D12Debug_EnableDebugLayer(dbg);
    SAFE_RELEASE(dbg);
  }
#endif

  res = D3D12CreateDevice(0, D3D_FEATURE_LEVEL_11_0, &IID_ID3D12Device, &demo->device);
  if (FAILED(res)) return 0;

  D3D12_COMMAND_QUEUE_DESC desc_cmd_queue = {
    .Flags = D3D12_COMMAND_QUEUE_FLAG_NONE,
    .Priority = D3D12_COMMAND_QUEUE_PRIORITY_NORMAL,
    .Type = D3D12_COMMAND_LIST_TYPE_DIRECT
  };
  res = ID3D12Device_CreateCommandQueue(demo->device, &desc_cmd_queue, &IID_ID3D12CommandQueue, &demo->cmd_queue);
  if (FAILED(res)) return 0;

  res = ID3D12Device_CreateCommandAllocator(demo->device, D3D12_COMMAND_LIST_TYPE_DIRECT,
                                            &IID_ID3D12CommandAllocator, &demo->cmd_allocator);
  if (FAILED(res)) return 0;

  DXGI_SWAP_CHAIN_DESC desc_swap_chain = {
    .BufferCount = k_swap_buffer_count,
    .BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM,
    .BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT,
    .OutputWindow = demo->hwnd,
    .SampleDesc.Count = 1,
    .SwapEffect = DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL,
    .Windowed = (demo->fullscreen ? FALSE : TRUE)
  };
  res = IDXGIFactory_CreateSwapChain(demo->dxgi_factory, (IUnknown *)demo->cmd_queue, &desc_swap_chain, &demo->dxgi_swap_chain);
  if (FAILED(res)) return 0;

  demo->rtv_dh_size = ID3D12Device_GetDescriptorHandleIncrementSize(demo->device, D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
  demo->cbv_srv_uav_dh_size = ID3D12Device_GetDescriptorHandleIncrementSize(demo->device, D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV);

  // RTV descriptor heap (includes swap buffer descriptors)
  {
    D3D12_DESCRIPTOR_HEAP_DESC desc_heap = {
      .NumDescriptors = k_swap_buffer_count,
      .Type = D3D12_DESCRIPTOR_HEAP_TYPE_RTV,
      .Flags = D3D12_DESCRIPTOR_HEAP_FLAG_NONE
    };
    res = ID3D12Device_CreateDescriptorHeap(demo->device, &desc_heap, &IID_ID3D12DescriptorHeap, (void **)&demo->rtv_dh.heap);
    if (FAILED(res)) return 0;

    demo->rtv_dh.cpu_handle = ID3D12DescriptorHeap_GetCPUDescriptorHandleForHeapStart(demo->rtv_dh.heap);

    for (int i = 0; i < k_swap_buffer_count; ++i) {
      res = IDXGISwapChain_GetBuffer(demo->dxgi_swap_chain, i, &IID_ID3D12Resource, (void **)&demo->swap_buffer[i]);
      if (FAILED(res)) return 0;
      D3D12_CPU_DESCRIPTOR_HANDLE rtv_handle = demo->rtv_dh.cpu_handle;
      rtv_handle.ptr += i * demo->rtv_dh_size;
      ID3D12Device_CreateRenderTargetView(demo->device, demo->swap_buffer[i], NULL, rtv_handle);
    }
  }

  demo->viewport.TopLeftX = 0.0f;
  demo->viewport.TopLeftY = 0.0f;
  demo->viewport.Width = (float)demo->resolution[0];
  demo->viewport.Height = (float)demo->resolution[1];
  demo->viewport.MinDepth = 0.0f;
  demo->viewport.MaxDepth = 1.0f;

  demo->scissor_rect.left = 0;
  demo->scissor_rect.top = 0;
  demo->scissor_rect.right = demo->resolution[0];
  demo->scissor_rect.bottom = demo->resolution[1];

  // root signature
  {
    D3D12_DESCRIPTOR_RANGE descriptor_range[1] = { {
        .RangeType = D3D12_DESCRIPTOR_RANGE_TYPE_CBV,
        .NumDescriptors = 1,
        .BaseShaderRegister = 0,
        .OffsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND
      }
    };
    D3D12_ROOT_PARAMETER param = {
      .ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE,
      .DescriptorTable.NumDescriptorRanges = ARRAYSIZE(descriptor_range),
      .DescriptorTable.pDescriptorRanges = descriptor_range,
      .ShaderVisibility = D3D12_SHADER_VISIBILITY_ALL
    };
    D3D12_ROOT_SIGNATURE_DESC root_signature_desc = { .NumParameters = 1, .pParameters = &param };

    ID3DBlob *blob = NULL;
    res = D3D12SerializeRootSignature(&root_signature_desc, D3D_ROOT_SIGNATURE_VERSION_1, &blob, NULL);
    res |= ID3D12Device_CreateRootSignature(demo->device, 0, ID3D10Blob_GetBufferPointer(blob), ID3D10Blob_GetBufferSize(blob),
                                            &IID_ID3D12RootSignature, (void **)&demo->root_signature);
    SAFE_RELEASE(blob);
    if (FAILED(res)) return 0;
  }
  // CBV_SRV_UAV descriptor heap (visible by shaders)
  {
    D3D12_DESCRIPTOR_HEAP_DESC desc_heap = {
      .NumDescriptors = 4,
      .Type = D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV,
      .Flags = D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE
    };
    res = ID3D12Device_CreateDescriptorHeap(demo->device, &desc_heap, &IID_ID3D12DescriptorHeap,
                                            (void **)&demo->cbv_srv_uav_dh.heap);
    if (FAILED(res)) return 0;
    demo->cbv_srv_uav_dh.cpu_handle = ID3D12DescriptorHeap_GetCPUDescriptorHandleForHeapStart(demo->cbv_srv_uav_dh.heap);
    demo->cbv_srv_uav_dh.gpu_handle = ID3D12DescriptorHeap_GetGPUDescriptorHandleForHeapStart(demo->cbv_srv_uav_dh.heap);
  }
  // constant buffer
  {
    D3D12_HEAP_PROPERTIES props_heap = { .Type = D3D12_HEAP_TYPE_UPLOAD };
    D3D12_RESOURCE_DESC desc_buffer = {
      .Dimension = D3D12_RESOURCE_DIMENSION_BUFFER,
      .Width = 1024,
      .Height = 1,
      .DepthOrArraySize = 1,
      .MipLevels = 1,
      .SampleDesc.Count = 1,
      .Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR
    };
    res = ID3D12Device_CreateCommittedResource(demo->device, &props_heap, D3D12_HEAP_FLAG_NONE, &desc_buffer,
                                               D3D12_RESOURCE_STATE_GENERIC_READ, NULL,
                                               &IID_ID3D12Resource, (void **)&demo->constant_buffer);
    if (FAILED(res)) return 0;
  }
  // descriptors (cbv_srv_uav_dh)
  {
    D3D12_CPU_DESCRIPTOR_HANDLE descriptor = demo->cbv_srv_uav_dh.cpu_handle;

    D3D12_CONSTANT_BUFFER_VIEW_DESC desc_cbuffer;
    desc_cbuffer.BufferLocation = ID3D12Resource_GetGPUVirtualAddress(demo->constant_buffer);
    desc_cbuffer.SizeInBytes = 16 * 1024;

    ID3D12Device_CreateConstantBufferView(demo->device, &desc_cbuffer, descriptor);
  }

  res = ID3D12Device_CreateFence(demo->device, 0, D3D12_FENCE_FLAG_NONE, &IID_ID3D12Fence, (void **)&demo->fence);
  if (FAILED(res)) return 0;
  demo->fence_value = 1;

  demo->fence_event = CreateEventEx(NULL, NULL, 0, EVENT_ALL_ACCESS);
  if (!demo->fence_event) return 0;

  if (!compile_shaders(demo)) return 0;

  res = ID3D12Device_CreateCommandList(demo->device, 0, D3D12_COMMAND_LIST_TYPE_DIRECT, demo->cmd_allocator,
                                       NULL, &IID_ID3D12GraphicsCommandList, (void **)&demo->cmd_list);
  if (FAILED(res)) return 0;

  ID3D12GraphicsCommandList_Close(demo->cmd_list);

  ID3D12CommandList *cmd_lists[] = { (ID3D12CommandList *)demo->cmd_list };
  ID3D12CommandQueue_ExecuteCommandLists(demo->cmd_queue, ARRAYSIZE(cmd_lists), cmd_lists);

  wait_for_device(demo);
  return 1;
}
//-----------------------------------------------------------------------------
static void deinit(demo_t *demo)
{
  if (demo->fence_event) {
    wait_for_device(demo);
    CloseHandle(demo->fence_event);
  }

  SAFE_RELEASE(demo->dxgi_swap_chain);
  SAFE_RELEASE(demo->cmd_allocator);
  SAFE_RELEASE(demo->cmd_queue);
  SAFE_RELEASE(demo->device);
  SAFE_RELEASE(demo->dxgi_factory);
}
//-----------------------------------------------------------------------------
static void update(demo_t *demo)
{
  generate_device_commands(demo);

  float *ptr;
  ID3D12Resource_Map(demo->constant_buffer, 0, NULL, (void **)&ptr);
  ptr[0] = (float)demo->time;
  ptr[1] = (float)demo->resolution[0];
  ptr[2] = (float)demo->resolution[1];
  ID3D12Resource_Unmap(demo->constant_buffer, 0, NULL);

  ID3D12CommandList *cmd_lists[] = { (ID3D12CommandList *)demo->cmd_list };
  ID3D12CommandQueue_ExecuteCommandLists(demo->cmd_queue, ARRAYSIZE(cmd_lists), cmd_lists);

  IDXGISwapChain_Present(demo->dxgi_swap_chain, 0, DXGI_PRESENT_RESTART);
  demo->swap_buffer_index = (demo->swap_buffer_index + 1) % k_swap_buffer_count;

  wait_for_device(demo);
}
//-----------------------------------------------------------------------------
void start(void)
{
  demo_t demo = {
    .heap = GetProcessHeap(),
    .name = "amnestia",
    .resolution = { 1024, 1024 },
    .fullscreen = 0,
    .shader = {
      { "sketch0" }
    },
    .current_shader = 0
  };

  if (!init(&demo)) {
    deinit(&demo);
    ExitProcess(1);
  }

  MSG msg = { 0 };
  for (;;) {
    if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE)) {
      DispatchMessage(&msg);
      if (msg.message == WM_QUIT) break;
    } else {
      update_frame_stats(&demo);
      update(&demo);
    }
  }

  deinit(&demo);
  ExitProcess(0);
}
//-----------------------------------------------------------------------------
