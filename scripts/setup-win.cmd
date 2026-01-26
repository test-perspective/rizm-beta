@echo off
setlocal enabledelayedexpansion

REM Wrapper to run setup-win.ps1 from any shell (cmd.exe / PowerShell / etc.)
REM Usage:
REM   scripts\setup-win.cmd local
REM   scripts\setup-win.cmd domain your-domain.com your-email@example.com

set "MODE=%~1"
set "DOMAIN=%~2"
set "EMAIL=%~3"
set "API_IMAGE=%~4"
set "WEB_IMAGE=%~5"

if "%MODE%"=="" set "MODE=local"

set "SCRIPT_DIR=%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup-win.ps1" -Mode "%MODE%" -Domain "%DOMAIN%" -Email "%EMAIL%" -ApiImage "%API_IMAGE%" -WebImage "%WEB_IMAGE%"
exit /b %ERRORLEVEL%

