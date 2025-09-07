set "PATH=%~dp0..\bin;%PATH%"
set oldpath=%cd%
cd /d "%~dp0"
VfxForth_x86_win include build.vfx %*
set errorlevel_backup=%errorlevel%
cd /d "%oldpath%"
exit /b %errorlevel_backup%
 