@echo off

echo DEBUG: %1

if "%1"=="--help" (
    echo Usage: turnkey.bat GAMENAME [FORTH-CODE]
    echo.
    echo Creates release builds of a VFXLand5 game
    echo.
    echo Arguments:
    echo   GAMENAME    Name of the game ^(required^)
    echo   FORTH-CODE  Optional Forth code to execute before save-release
    echo.
    echo Examples:
    echo   turnkey.bat mygame
    echo   turnkey.bat mygame "custom-setup-word"
    exit /b 0
)

@echo on
set "PATH=%~dp0\..\bin;%PATH%"

cd "%~dp0\..\.."

mkdir ..\rel\%1
mkdir ..\rel\%1-debug
del ..\rel\%1\*.* /s /q
del ..\rel\%1-debug\*.* /s /q
xcopy dat ..\rel\%1\dat /i /s /q /y /e
xcopy dat ..\rel\%1-debug\dat /i /s /q /y /e
copy %~dp0\..\bin\*.dll ..\rel\%1
copy %~dp0\..\bin\*.dll ..\rel\%1-debug

SET saveString=%2 save-release ..\rel\%1\%1 save-debug ..\rel\%1-debug\%1-debug bye
SET configString=debug off validations off safety off 

if exist main.vfx (
    engineer.exe %configString% ldp . %saveString%
) else (
    engineer.exe %configString% %saveString%
)
