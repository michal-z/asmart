@echo off

set FXC=..\..\fxc\fxc.exe /Ges /O3 /WX /Qstrip_reflect /Qstrip_debug /Qstrip_priv /Qstrip_rootsignature

%FXC% /E vs_transform /Fo vs_transform.cso /T vs_5_1 vs_transform.hlsl
if errorlevel 1 goto eof

%FXC% /E ps_shade /Fo ps_shade.cso /T ps_5_1 ps_shade.hlsl
if errorlevel 1 goto eof

:eof
