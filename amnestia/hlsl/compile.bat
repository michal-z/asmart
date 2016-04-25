@echo off

set FXC=..\..\fxc\fxc.exe

set CSO_PATH=..\data




%FXC% /Ges /O3 /E vs_transform /Fo %CSO_PATH%\vs_transform.cso /WX /T vs_5_1 vs_transform.hlsl

if errorlevel 1 goto eof



%FXC% /Ges /O3 /E ps_shade /Fo %CSO_PATH%\ps_shade.cso /WX /T ps_5_1 ps_shade.hlsl

if errorlevel 1 goto eof

:eof
