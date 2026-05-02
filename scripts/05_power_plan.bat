@echo off
setlocal EnableExtensions

:: ============================================================
:: 05_power_plan.bat — Set High Performance Power Plan
::
:: Activates the built-in "High Performance" power plan.
:: Optionally disables hibernation to reclaim hiberfil.sys space.
:: Does NOT touch CPU voltage or frequency offsets.
::
:: Requires: Windows 11, Administrator
:: Undo: 10_undo_all.bat restores "Balanced" plan
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[05] Power Plan — High Performance%RESET%
echo  %DIM%  Configuring power settings for maximum responsiveness...%RESET%
echo.

:: ── Activate High Performance plan ───────────────────────────
:: GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c (High Performance)
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

if %errorLevel% == 0 (
    echo  %GREEN%  [+]%RESET% High Performance plan activated.
) else (
    :: Plan may not exist — create it from the built-in scheme
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    echo  %GREEN%  [+]%RESET% High Performance plan created and activated.
)

:: ── USB Selective Suspend ─────────────────────────────────────
:: Disable: prevents USB devices from being suspended (reduces latency)
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
echo  %GREEN%  [+]%RESET% USB Selective Suspend disabled

:: ── Hard Disk sleep ──────────────────────────────────────────
:: Set to 0 = never (prevents spin-up latency spikes)
powercfg /setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0 >nul 2>&1
echo  %GREEN%  [+]%RESET% Hard disk sleep — disabled (never)

:: Apply the changes
powercfg /setactive SCHEME_CURRENT >nul 2>&1

:: ── Hibernate ────────────────────────────────────────────────
echo.
set /p "HIB_ANS=  Disable Hibernate? Frees hiberfil.sys disk space (Y/N): "
if /i "%HIB_ANS%"=="Y" (
    powercfg /h off
    echo  %GREEN%  [+]%RESET% Hibernate disabled — hiberfil.sys removed.
) else (
    echo  %YELLOW%  [-]%RESET% Hibernate left unchanged.
)

:: ── Fast Startup ─────────────────────────────────────────────
:: Disable Fast Startup — it's a hybrid sleep that can mask driver issues
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" ^
    /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo  %GREEN%  [+]%RESET% Fast Startup disabled  %DIM%(prevents hybrid-sleep conflicts)%RESET%

echo.
echo  %GREEN%  ✓ Power plan configured.%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Power plan set to High Performance" "SUCCESS"
exit /b 0
