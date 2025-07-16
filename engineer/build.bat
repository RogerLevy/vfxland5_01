set "PATH=%~dp0..\bin;%~dp0..\bin\dll\;%PATH%"
REM start /B /WAIT "" "VfxForth_x86_win.exe" +xrefs include build.vfx
VfxForth_x86_win include build.vfx cwd ..
EXIT /B
