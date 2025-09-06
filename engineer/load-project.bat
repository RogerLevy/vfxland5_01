@echo off
cd "%~dp0\..\.."
set "PATH=%~dp0\..\bin;%PATH%"
if exist main.vfx (
    echo Loading project from %cd%
    engineer.exe ldp . %*
) else (
    echo No main.vfx found, starting Engineer normally
    engineer.exe %*
)