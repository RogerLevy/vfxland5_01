@echo off
echo Building textmode_renderer.dll...

REM Set up Visual Studio environment for 32-bit builds
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"

REM Build using MSBuild
msbuild textmode_renderer.sln /p:Configuration=Release /p:Platform=x86 /p:OutDir=..\bin\

if %ERRORLEVEL% EQU 0 (
    echo Build successful!
    echo DLL output to ..\bin\ directory
    if exist ..\bin\textmode_renderer.dll (
        echo textmode_renderer.dll created successfully
    ) else (
        echo Warning: DLL not found in expected location
    )
) else (
    echo Build failed with error %ERRORLEVEL%
)

pause