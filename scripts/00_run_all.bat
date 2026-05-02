@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
:: 00_run_all.bat — Win11 Optimizer — Master Launcher
:: Runs all optimization scripts in sequence with per-step
:: confirmation. Auto-elevates to Administrator if needed.
::
:: Usage: Double-click or run from PowerShell/cmd
:: Requires: Windows 11, Administrator privileges
:: ============================================================

:: === Auto-Elevation =========================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: === Setup ==================================================
set "SCRIPT_DIR=%~dp0"
set "LIB=%SCRIPT_DIR%_lib"

call "%LIB%\colors.bat"

:: Build log filename using date
for /f "tokens=2 delims==" %%a in ('wmic os get LocalDateTime /value 2^>nul') do (
    if not "%%a"=="" set "DT=%%a"
)
set "LOG_FILE=%TEMP%\winopt_%DT:~0,8%.log"
echo Win11 Optimizer Log — %DATE% %TIME% > "%LOG_FILE%"
echo ============================================ >> "%LOG_FILE%"

:: === Banner =================================================
cls
echo.
echo  %CYAN%%BOLD%  ╔══════════════════════════════════════════════════╗%RESET%
echo  %CYAN%%BOLD%  ║        WIN11 OPTIMIZER — POST-INSTALL SUITE      ║%RESET%
echo  %CYAN%%BOLD%  ║         github.com/YOUR_USER/win-optimizer        ║%RESET%
echo  %CYAN%%BOLD%  ╚══════════════════════════════════════════════════╝%RESET%
echo.
echo  %DIM%  Log: %LOG_FILE%%RESET%
echo.
echo  %YELLOW%  [!] This tool will make safe, reversible system changes.%RESET%
echo  %YELLOW%      A restore point is always created first.%RESET%
echo  %YELLOW%      Use 10_undo_all.bat to revert everything.%RESET%
echo.

set /p "CONFIRM=  >> Start full optimization? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo  %RED%  Aborted.%RESET%
    echo.
    pause
    exit /b 0
)

:: === Run steps ==============================================
set "PASS=0"
set "FAIL=0"

call :run_step "01_restore_point.bat"     "System Restore Point"
call :run_step "02_services_manual.bat"   "Services → Manual"
call :run_step "03_disable_recall.bat"    "Disable Windows Recall"
call :run_step "04_disable_telemetry.bat" "Disable Telemetry"
call :run_step "05_power_plan.bat"        "Power Plan (High Performance)"
call :run_step "06_visual_tweaks.bat"     "Visual Performance Tweaks"
call :run_step "07_network_tweaks.bat"    "Network Tweaks"
call :run_step "08_privacy_tweaks.bat"    "Privacy Tweaks"
call :run_step "09_startup_cleanup.bat"   "Startup Audit (Read-Only)"

:: === Summary ================================================
echo.
echo  %CYAN%  ════════════════════════════════════════════════%RESET%
echo  %GREEN%  ✓ Completed: %PASS%   %RED%✗ Failed: %FAIL%%RESET%
echo  %DIM%  Full log: %LOG_FILE%%RESET%
echo  %CYAN%  ════════════════════════════════════════════════%RESET%
echo.
echo  %YELLOW%  A system restart is recommended to apply all changes.%RESET%
echo.
pause
exit /b 0

:: ============================================================
:run_step  <script_file>  <description>
:: ============================================================
echo.
echo  %CYAN%  ┌─[ %~2 ]%RESET%
set "STEP_ANS="
set /p "STEP_ANS=  └─ Run this step? (Y/N/Q to quit): "

if /i "%STEP_ANS%"=="Q" (
    echo.
    echo  %RED%  Execution stopped by user.%RESET%
    echo.
    pause
    exit /b 0
)
if /i not "%STEP_ANS%"=="Y" (
    echo  %YELLOW%     Skipped.%RESET%
    goto :EOF
)

call "%SCRIPT_DIR%%~1"
if %errorLevel% == 0 (
    echo  %GREEN%     ✓ Done.%RESET%
    echo [STEP] %~2 — OK >> "%LOG_FILE%"
    set /a PASS+=1
) else (
    echo  %RED%     ✗ Error occurred. Check log file.%RESET%
    echo [STEP] %~2 — FAILED >> "%LOG_FILE%"
    set /a FAIL+=1
)
goto :EOF
