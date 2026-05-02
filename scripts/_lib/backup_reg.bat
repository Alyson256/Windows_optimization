@echo off
:: ============================================================
:: _lib/backup_reg.bat — Backup a registry key before modifying
:: Usage: call "%~dp0_lib\backup_reg.bat" "HKCU\Path\To\Key" "backup_name"
:: ============================================================

set "KEY=%~1"
set "NAME=%~2"
set "BACKUP_DIR=%~dp0..\..\backups"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Extract the root key and rest of the path to make a safe filename if name is not provided
if "%NAME%"=="" (
    set "NAME=reg_backup_%RANDOM%"
)

set "BACKUP_FILE=%BACKUP_DIR%\%NAME%.reg"

:: Check if the key exists before trying to export
reg query "%KEY%" >nul 2>&1
if %errorLevel% == 0 (
    if not exist "%BACKUP_FILE%" (
        reg export "%KEY%" "%BACKUP_FILE%" /y >nul 2>&1
        echo  %DIM%  [Backup] Saved %KEY% to %NAME%.reg%RESET%
    )
)
exit /b 0
