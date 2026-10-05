@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0InitializeProject.ps1" %*
exit /b %ERRORLEVEL%
