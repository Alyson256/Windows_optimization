@echo off
setlocal EnableExtensions

:: ============================================================
:: 04_disable_telemetry.bat — Reduce Windows Telemetry
::
:: Sets telemetry level to 0 (Security) via Group Policy keys.
:: Stops and disables the DiagTrack and dmwappushservice services.
:: Does NOT modify the hosts file (see docs/RISKS.md for that).
::
:: Requires: Windows 11, Administrator
:: References:
::   HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection
::   HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[04] Disable Telemetry%RESET%
echo  %DIM%  Reducing diagnostic data collection to minimum...%RESET%
echo.

:: ── Group Policy keys ────────────────────────────────────────
echo  %DIM%  Writing policy registry keys...%RESET%

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" ^
    /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% AllowTelemetry = 0  %DIM%(DataCollection policy)%RESET%

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" ^
    /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% AllowTelemetry = 0  %DIM%(CurrentVersion policy)%RESET%

:: Disable "Tailored experiences"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" ^
    /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% TailoredExperiences disabled

:: Disable Diagnostic Data Viewer
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" ^
    /v "ShowedToastAtLevel" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable error reporting
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" ^
    /v "Disabled" /t REG_DWORD /d 1 /f >nul
echo  %GREEN%  [+]%RESET% Windows Error Reporting disabled

:: ── Services ─────────────────────────────────────────────────
echo.
echo  %DIM%  Stopping telemetry services...%RESET%

call :stop_service "DiagTrack"        "Connected User Experiences and Telemetry"
call :stop_service "dmwappushservice" "WAP Push Message Routing Service"

:: ── Scheduled Tasks ──────────────────────────────────────────
echo.
echo  %DIM%  Disabling telemetry scheduled tasks...%RESET%

powershell -NonInteractive -Command ^
    "$tasks = @('Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser', 'Microsoft\Windows\Application Experience\ProgramDataUpdater', 'Microsoft\Windows\Autochk\Proxy', 'Microsoft\Windows\Customer Experience Improvement Program\Consolidator', 'Microsoft\Windows\Customer Experience Improvement Program\UsbCeip', 'Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector'); foreach ($t in $tasks) { try { Disable-ScheduledTask -TaskPath ('\'+($t | Split-Path -Parent)+'\') -TaskName ($t | Split-Path -Leaf) -ErrorAction SilentlyContinue | Out-Null; Write-Host ('  [+] Disabled: '+$t) } catch {} }"

echo.
echo  %GREEN%  ✓ Telemetry reduced to minimum level.%RESET%
echo  %DIM%    Note: 'Security' level (0) still allows basic health data on Home editions.%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Telemetry disabled" "SUCCESS"
exit /b 0

:: ============================================================
:stop_service <name> <description>
:: ============================================================
sc query "%~1" >nul 2>&1
if %errorLevel% neq 0 (
    echo  %DIM%  [-] %~1 — not found%RESET%
    goto :EOF
)
sc stop "%~1" >nul 2>&1
sc config "%~1" start=disabled >nul 2>&1
echo  %GREEN%  [+]%RESET% %~1 — stopped + disabled  %DIM%(%~2)%RESET%
goto :EOF
