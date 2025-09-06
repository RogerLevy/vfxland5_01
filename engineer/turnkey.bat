cd "%~dp0\..\.."

mkdir ..\rel\%1
mkdir ..\rel\%1-debug
del ..\rel\%1\*.* /s /q
del ..\rel\%1-debug\*.* /s /q
xcopy dat ..\rel\%1\dat /i /s /q /y /e
xcopy dat ..\rel\%1-debug\dat /i /s /q /y /e
copy %~dp0\..\bin\*.dll ..\rel\%1
copy %~dp0\..\bin\*.dll ..\rel\%1-debug

call %~dp0\load-project.bat save-release ..\rel\%1\%1 save-debug ..\rel\%1-debug\%1-debug bye
cd ..\rel\%1
%1.exe