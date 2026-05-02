@echo off
setlocal EnableExtensions

:: ============================================================
:: 09_startup_cleanup.bat — Startup Entry Audit (READ-ONLY)
::
:: Scans all startup registry locations and outputs the findings
:: to the console and log file. Does NOT remove anything.
:: Review the output and manually disable unwanted entries via
:: Task Manager > Startup Apps.
::
:: Requires: Administrator (for HKLM keys)
:: Safe: No system modifications.
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[09] Startup Entry Audit%RESET%
echo  %DIM%  Scanning startup registry locations (read-only)...%RESET%
echo.

if defined LOG_FILE (
    echo. >> "%LOG_FILE%"
    echo [STARTUP AUDIT - %DATE% %TIME%] >> "%LOG_FILE%"
    echo ========================== >> "%LOG_FILE%"
)

set "FOUND=0"

:: ── HKCU Run ─────────────────────────────────────────────────
echo  %YELLOW%  [HKCU] HKEY_CURRENT_USER\...\Run%RESET%
call :scan_key "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
call :scan_key "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"

:: ── HKLM Run ─────────────────────────────────────────────────
echo.
echo  %YELLOW%  [HKLM] HKEY_LOCAL_MACHINE\...\Run%RESET%
call :scan_key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
call :scan_key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
call :scan_key "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"

:: ── Scheduled Tasks (startup trigger) ────────────────────────
echo.
echo  %YELLOW%  [TASKS] Scheduled tasks with startup triggers%RESET%
powershell -NonInteractive -Command ^
    "Get-ScheduledTask | Where-Object { $_.Triggers -match 'AtStartup|AtLogon' } | Select-Object -ExpandProperty TaskName | ForEach-Object { Write-Host ('    ' + $_) }"

echo.
echo  %CYAN%  ═══════════════════════════════════════════════%RESET%
echo  %WHITE%  Total startup entries found: %FOUND%%RESET%
echo  %CYAN%  ═══════════════════════════════════════════════%RESET%
echo.
echo  %DIM%  Tip: Open Task Manager ^> Startup Apps to disable unwanted entries.%RESET%
echo  %DIM%  This script made NO changes to your system.%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Startup audit completed — %FOUND% entries found" "INFO"
exit /b 0

:: ============================================================
:scan_key  <registry_path>
:: ============================================================
for /f "tokens=1,* skip=4 delims= " %%a in ('reg query "%~1" 2^>nul') do (
    if not "%%a"=="(Default)" (
        echo  %DIM%    [%%a]  %%b%RESET%
        if defined LOG_FILE echo     STARTUP: [%~1] %%a = %%b >> "%LOG_FILE%"
        set /a FOUND+=1
    )
)
goto :EOF
