@echo off
setlocal EnableExtensions

:: ============================================================
:: 01_restore_point.bat — Create a System Restore Point
:: Creates a timestamped restore point before any changes.
:: Requires: Windows 11, Administrator, System Protection ON
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[01] System Restore Point%RESET%
echo  %DIM%  Creating a restore point before applying optimizations...%RESET%
echo.

:: Enable System Protection on C: (in case it was disabled)
powershell -NonInteractive -Command ^
    "Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue" >nul 2>&1

:: Create the restore point via PowerShell
powershell -NonInteractive -Command ^
    "Checkpoint-Computer -Description 'Win11Optimizer - Pre-optimization %DATE%' -RestorePointType 'MODIFY_SETTINGS'"

if %errorLevel% == 0 (
    echo  %GREEN%  ✓ Restore point created successfully.%RESET%
    if defined LOG_FILE call "%~dp0_lib\logger.bat" "Restore point created" "SUCCESS"
) else (
    echo  %YELLOW%  [!] Could not create restore point.%RESET%
    echo  %DIM%      System Protection may be off or a point was created recently.%RESET%
    echo  %DIM%      Windows limits restore point creation to once per 24 hours.%RESET%
    if defined LOG_FILE call "%~dp0_lib\logger.bat" "Restore point creation failed" "WARN"
    :: Not a fatal error — continue
)

echo.
exit /b 0
