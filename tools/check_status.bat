@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
:: tools/check_status.bat — System Optimization Status Audit
::
:: Read-only diagnostic tool. Checks the current state of every
:: optimization and reports whether it's applied or at default.
:: Makes NO changes to the system.
::
:: Requires: Administrator (for HKLM reads)
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "LIB=%~dp0..\scripts\_lib"
call "%LIB%\colors.bat"

cls
echo.
echo  %CYAN%%BOLD%  ╔══════════════════════════════════════════════════╗%RESET%
echo  %CYAN%%BOLD%  ║         WIN11 OPTIMIZER — STATUS CHECK           ║%RESET%
echo  %CYAN%%BOLD%  ╚══════════════════════════════════════════════════╝%RESET%
echo  %DIM%  Scanning current system state... (read-only)%RESET%
echo.

set "OK=0"
set "NOK=0"

:: ── Telemetry ────────────────────────────────────────────────
echo  %YELLOW%  ── Telemetry ──────────────────────────────────%RESET%
call :check_reg_val "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "0x0" "Telemetry level = 0"
call :check_service_state "DiagTrack" "STOPPED" "DiagTrack service"
call :check_service_start "DiagTrack" "DISABLED" "DiagTrack startup"

:: ── Windows Recall ───────────────────────────────────────────
echo.
echo  %YELLOW%  ── Windows Recall ─────────────────────────────%RESET%
call :check_reg_val "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "0x1" "Recall disabled (HKLM)"
call :check_reg_val "HKCU\Software\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "0x1" "Recall disabled (HKCU)"

:: ── Power Plan ───────────────────────────────────────────────
echo.
echo  %YELLOW%  ── Power Plan ─────────────────────────────────%RESET%
for /f "tokens=*" %%p in ('powercfg /getactivescheme 2^>nul') do set "ACTIVE_PLAN=%%p"
echo !ACTIVE_PLAN! | findstr /i "8c5e7fda" >nul
if !errorLevel! == 0 (
    echo  %GREEN%  [✓]%RESET% High Performance plan is active
    set /a OK+=1
) else (
    echo  %RED%  [✗]%RESET% High Performance NOT active — %DIM%!ACTIVE_PLAN!%RESET%
    set /a NOK+=1
)

call :check_reg_val "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" "0x0" "Fast Startup disabled"

:: ── Visual Effects ───────────────────────────────────────────
echo.
echo  %YELLOW%  ── Visual Effects ─────────────────────────────%RESET%
call :check_reg_val "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" "0x0" "Transparency disabled"
call :check_reg_val "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "0x0" "Taskbar animations disabled"

:: ── Privacy ──────────────────────────────────────────────────
echo.
echo  %YELLOW%  ── Privacy ────────────────────────────────────%RESET%
call :check_reg_val "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "0x0" "Advertising ID disabled"
call :check_reg_val "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "0x0" "Activity history disabled"
call :check_reg_val "HKCU\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "0x0" "Feedback prompts disabled"

:: ── Network ──────────────────────────────────────────────────
echo.
echo  %YELLOW%  ── Network ────────────────────────────────────%RESET%
call :check_reg_val "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "0xffffffff" "Network throttling disabled"

:: ── Services (sample check) ──────────────────────────────────
echo.
echo  %YELLOW%  ── Key Services ───────────────────────────────%RESET%
call :check_service_start "SysMain"  "DEMAND_START" "SysMain (Superfetch)"
call :check_service_start "WSearch"  "DEMAND_START" "WSearch (Indexing)"

:: ── Summary ──────────────────────────────────────────────────
echo.
echo  %CYAN%  ════════════════════════════════════════════════%RESET%
echo  %GREEN%  ✓ Applied: %OK%   %RED%✗ Not applied: %NOK%%RESET%
echo  %CYAN%  ════════════════════════════════════════════════%RESET%
echo.
pause
exit /b 0

:: ============================================================
:check_reg_val  <key>  <value_name>  <expected>  <label>
:: ============================================================
for /f "tokens=3" %%v in ('reg query "%~1" /v "%~2" 2^>nul') do (
    if /i "%%v"=="%~3" (
        echo  %GREEN%  [✓]%RESET% %~4
        set /a OK+=1
        goto :EOF
    ) else (
        echo  %RED%  [✗]%RESET% %~4  %DIM%(current: %%v, expected: %~3)%RESET%
        set /a NOK+=1
        goto :EOF
    )
)
echo  %RED%  [✗]%RESET% %~4  %DIM%(key not found)%RESET%
set /a NOK+=1
goto :EOF

:: ============================================================
:check_service_state  <name>  <expected_state>  <label>
:: ============================================================
for /f "tokens=4" %%s in ('sc query "%~1" 2^>nul ^| findstr /i "STATE"') do (
    if /i "%%s"=="%~2" (
        echo  %GREEN%  [✓]%RESET% %~3 — %~2
        set /a OK+=1
    ) else (
        echo  %RED%  [✗]%RESET% %~3 — current: %%s
        set /a NOK+=1
    )
)
goto :EOF

:: ============================================================
:check_service_start  <name>  <expected_start>  <label>
:: ============================================================
for /f "tokens=4" %%s in ('sc qc "%~1" 2^>nul ^| findstr /i "START_TYPE"') do (
    if /i "%%s"=="%~2" (
        echo  %GREEN%  [✓]%RESET% %~3 — %~2
        set /a OK+=1
    ) else (
        echo  %RED%  [✗]%RESET% %~3 — current start type: %%s
        set /a NOK+=1
    )
)
goto :EOF
