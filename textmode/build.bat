@echo off
echo Building textmode_renderer.dll...

REM Set up Visual Studio environment for 32-bit builds
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"

echo.
echo Building Release configuration...
msbuild textmode_renderer.sln /p:Configuration=Release /p:Platform=x86 /p:OutDir=..\bin\Release\

if %ERRORLEVEL% EQU 0 (
    echo Release build successful!
    if exist ..\bin\Release\textmode_renderer.dll (
        copy /Y ..\bin\Release\textmode_renderer.dll ..\bin\textmode_renderer.dll
        echo textmode_renderer.dll created in ..\bin\
    ) else (
        echo Warning: Release DLL not found in expected location
    )
) else (
    echo Release build failed with error %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Building Debug configuration...
msbuild textmode_renderer.sln /p:Configuration=Debug /p:Platform=x86 /p:OutDir=..\bin\Debug\

if %ERRORLEVEL% EQU 0 (
    echo Debug build successful!
    if exist ..\bin\Debug\textmode_renderer.dll (
        copy /Y ..\bin\Debug\textmode_renderer.dll ..\bin\textmode_renderer_debug.dll
        echo textmode_renderer_debug.dll created in ..\bin\
    ) else (
        echo Warning: Debug DLL not found in expected location
    )
) else (
    echo Debug build failed with error %ERRORLEVEL%
)

echo.
echo Both configurations built successfully!
pause