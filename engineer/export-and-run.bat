@echo off
set "PATH=%~dp0\bin;%~dp0\bin\dll\;%~dp0\bin\engineer\;%PATH%"
cd /d "%~dp0\.."

echo Exporting game...
"%~dp0\bin\engineer.exe" "include %1.vfx turnkey bye"

if errorlevel 1 (
    echo Export failed
    exit /b 1
)

echo Starting exported game...
start "" "rel\%2.exe"
