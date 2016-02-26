@echo off

..\fasm\fasm.exe amnestia.asm
:: ..\fasm\fasm.exe -s amnestia.fas amnestia.asm
if errorlevel 1 goto eof

set FXC=..\fxc\fxc.exe
set CSO_PATH=.\data
set HLSL_PATH=.\hlsl

%FXC% /Ges /O3 /E vs_transform /Fo %CSO_PATH%\vs_transform.cso /WX /T vs_5_1 %HLSL_PATH%\vs_transform.hlsl
if errorlevel 1 goto eof

%FXC% /Ges /O3 /E ps_shade /Fo %CSO_PATH%\ps_shade.cso /WX /T ps_5_1 %HLSL_PATH%\ps_shade.hlsl
if errorlevel 1 goto eof

:eof
