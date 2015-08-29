@echo off

set FXC="C:\Program Files (x86)\Windows Kits\10\bin\x64\fxc.exe"

%FXC% /Ges /O3 /E vs_triangle /Fo data\vs_triangle.cso /WX /T vs_5_0 d3d12tri_shaders.hlsl
if errorlevel 1 goto eof
%FXC% /Ges /O3 /E ps_triangle /Fo data\ps_triangle.cso /WX /T ps_5_0 d3d12tri_shaders.hlsl
if errorlevel 1 goto eof

