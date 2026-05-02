@echo off
setlocal EnableExtensions

:: ============================================================
:: 02_services_manual.bat — Set non-essential services to Manual
::
:: Sets startup type to MANUAL (demand-start), NOT Disabled.
:: Services will still launch on demand if needed by the OS.
:: This is the safest approach — no services are permanently killed.
::
:: Requires: Windows 11, Administrator privileges
:: Undo: 10_undo_all.bat restores all to their defaults
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[02] Services → Manual%RESET%
echo  %DIM%  Changing non-essential services to manual start...%RESET%
echo.

set "ERR=0"

:: ── Indexing & Performance ──────────────────────────────────
call :set_manual "SysMain"          "Superfetch (SysMain) — high disk I/O on HDD/SSD"
call :set_manual "WSearch"          "Windows Search Indexing"

:: ── Telemetry & Diagnostics ─────────────────────────────────
call :set_manual "DiagTrack"        "Connected User Experiences and Telemetry"
call :set_manual "dmwappushservice" "WAP Push Message Routing (telemetry helper)"
call :set_manual "PcaSvc"           "Program Compatibility Assistant"
call :set_manual "DPS"              "Diagnostic Policy Service"

:: ── Xbox / Gaming (skip if you use Xbox features) ───────────
call :set_manual "XblAuthManager"   "Xbox Live Auth Manager"
call :set_manual "XblGameSave"      "Xbox Live Game Save"
call :set_manual "XboxNetApiSvc"    "Xbox Live Networking Service"
call :set_manual "XboxGipSvc"       "Xbox Accessory Management"

:: ── Retail / OEM junk ───────────────────────────────────────
call :set_manual "RetailDemo"       "Retail Demo Service"
call :set_manual "MapsBroker"       "Downloaded Maps Manager"
call :set_manual "WMPNetworkSvc"    "Windows Media Player Network Sharing"
call :set_manual "Fax"              "Fax Service"

:: ── Mobile / Tablet (safe to manual on desktop) ─────────────
call :set_manual "TabletInputService" "Touch Keyboard and Handwriting"
call :set_manual "icssvc"           "Internet Connection Sharing"

:: ── Remote Access (safe on non-server machines) ─────────────
call :set_manual "RemoteRegistry"   "Remote Registry"
call :set_manual "TrkWks"           "Distributed Link Tracking Client"

echo.
if "%ERR%"=="0" (
    echo  %GREEN%  ✓ All services configured.%RESET%
    if defined LOG_FILE call "%~dp0_lib\logger.bat" "Services set to manual" "SUCCESS"
) else (
    echo  %YELLOW%  [!] Some services may not exist on this system (normal).%RESET%
    if defined LOG_FILE call "%~dp0_lib\logger.bat" "Services step completed with warnings" "WARN"
)
echo.
exit /b 0

:: ============================================================
:set_manual  <ServiceName>  <Description>
:: ============================================================
sc query "%~1" >nul 2>&1
if %errorLevel% neq 0 (
    echo  %DIM%  [-] %-30s — not found, skipping%RESET%" "%~1"
    goto :EOF
)
sc config "%~1" start=demand >nul 2>&1
if %errorLevel% == 0 (
    echo  %GREEN%  [+]%RESET% %-30s — Manual  %DIM%(%~2)%RESET%
    if defined LOG_FILE call "%~dp0_lib\logger.bat" "Service set to manual: %~1" "INFO"
) else (
    echo  %RED%  [!]%RESET% %-30s — Failed  %DIM%(%~2)%RESET%
    set "ERR=1"
)
goto :EOF
