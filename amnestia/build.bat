@echo off

..\fasm\fasm.exe amnestia.asm
if errorlevel 1 goto eof

set FXC=..\fxc\fxc.exe

%FXC% /Ges /O3 /E vs_triangle /Fo data\vs_triangle.cso /WX /T vs_5_1 shader.hlsl 
if errorlevel 1 goto eof

%FXC% /Ges /O3 /E ps_triangle /Fo data\ps_triangle.cso /WX /T ps_5_1 shader.hlsl
if errorlevel 1 goto eof

:eof
