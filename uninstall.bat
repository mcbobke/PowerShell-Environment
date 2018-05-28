@echo off
echo Starting profile uninstall...
start "Uninstall Profile" /B /WAIT "powershell.exe" -ExecutionPolicy Bypass -File %~dp0Invoke-EnvironmentTeardown.ps1
set /P input="Press enter to exit..."