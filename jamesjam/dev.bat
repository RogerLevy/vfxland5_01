@REM We call COLD here for the time being since we still rely on the VFX IDE
@REM for output.

@set PATH="%PATH%;engineer\bin\"
cd ..\engineer
bin\engineer.exe cwd %~dp0 cold