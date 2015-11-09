#pragma once

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define COBJMACROS
#include <initguid.h>
#include <d3d12.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <avrt.h>

DEFINE_GUID(CLSID_MMDeviceEnumerator, 0xBCDE0395, 0xE52F, 0x467C, 0x8E, 0x3D, 0xC4, 0x57, 0x92, 0x91, 0x69, 0x2E); 
DEFINE_GUID(IID_IMMDeviceEnumerator, 0xA95664D2, 0x9614, 0x4F35, 0xA7, 0x46, 0xDE, 0x8D, 0xB6, 0x36, 0x17, 0xE6); 
DEFINE_GUID(IID_IAudioClient, 0x1CB9AD4C, 0xDBFA, 0x4c32, 0xB1, 0x78, 0xC2, 0xF5, 0x68, 0xA7, 0x03, 0xB2);
DEFINE_GUID(IID_IAudioRenderClient, 0xF294ACFC, 0x3146, 0x4483, 0xA7, 0xBF, 0xAD, 0xDC, 0xA7, 0xC2, 0x60, 0xE2);

#undef ID3D12DescriptorHeap_GetCPUDescriptorHandleForHeapStart
#undef ID3D12DescriptorHeap_GetGPUDescriptorHandleForHeapStart

__inline D3D12_CPU_DESCRIPTOR_HANDLE WA_ID3D12DescriptorHeap_GetCPUDescriptorHandleForHeapStart(ID3D12DescriptorHeap *This)
{
  typedef void (STDMETHODCALLTYPE *func_t)(ID3D12DescriptorHeap *, D3D12_CPU_DESCRIPTOR_HANDLE *);
  func_t func = (func_t)((This)->lpVtbl->GetCPUDescriptorHandleForHeapStart);
  D3D12_CPU_DESCRIPTOR_HANDLE ret;
  func(This, &ret);
  return ret;
}
__inline D3D12_GPU_DESCRIPTOR_HANDLE WA_ID3D12DescriptorHeap_GetGPUDescriptorHandleForHeapStart(ID3D12DescriptorHeap *This)
{
  typedef void (STDMETHODCALLTYPE *func_t)(ID3D12DescriptorHeap *, D3D12_GPU_DESCRIPTOR_HANDLE *);
  func_t func = (func_t)((This)->lpVtbl->GetGPUDescriptorHandleForHeapStart);
  D3D12_GPU_DESCRIPTOR_HANDLE ret;
  func(This, &ret);
  return ret;
}

#define ID3D12DescriptorHeap_GetCPUDescriptorHandleForHeapStart(This) WA_ID3D12DescriptorHeap_GetCPUDescriptorHandleForHeapStart(This)
#define ID3D12DescriptorHeap_GetGPUDescriptorHandleForHeapStart(This) WA_ID3D12DescriptorHeap_GetGPUDescriptorHandleForHeapStart(This)
