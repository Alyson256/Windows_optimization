@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
:: 10_undo_all.bat — Revert All Win11 Optimizer Changes
::
:: Restores system defaults for everything changed by scripts
:: 02 through 08. Does NOT delete the restore point created
:: by 01_restore_point.bat (use System Restore for that).
::
:: Requires: Windows 11, Administrator privileges
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

call "%~dp0_lib\colors.bat"

echo.
echo  %MAGENTA%%BOLD%  ╔══════════════════════════════════════════════════╗%RESET%
echo  %MAGENTA%%BOLD%  ║           WIN11 OPTIMIZER — UNDO ALL             ║%RESET%
echo  %MAGENTA%%BOLD%  ╚══════════════════════════════════════════════════╝%RESET%
echo.
echo  %YELLOW%  [!] This will revert all optimizations to Windows defaults.%RESET%
echo.
set /p "CONFIRM=  >> Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo  %RED%  Aborted.%RESET%
    pause
    exit /b 0
)
echo.

:: ============================================================
echo  %CYAN%  [02] Restore Services to Automatic%RESET%
:: ============================================================
for %%S in (SysMain WSearch DiagTrack dmwappushservice PcaSvc DPS ^
            XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc ^
            RetailDemo MapsBroker WMPNetworkSvc Fax ^
            TabletInputService icssvc RemoteRegistry TrkWks) do (
    sc query "%%S" >nul 2>&1
    if !errorLevel! == 0 (
        sc config "%%S" start=auto >nul 2>&1
        sc start "%%S" >nul 2>&1
        echo  %GREEN%    [+]%RESET% %%S — Automatic
    )
)
echo.

:: ============================================================
echo  %CYAN%  [03] Re-enable Windows Recall%RESET%
:: ============================================================
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecallEnablement" /f >nul 2>&1
reg delete "HKCU\Software\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /f >nul 2>&1
sc config "CoreAIPlatform" start=auto >nul 2>&1
echo  %GREEN%    [+]%RESET% Recall policy keys removed (Windows default restored)
echo.

:: ============================================================
echo  %CYAN%  [04] Restore Telemetry Defaults%RESET%
:: ============================================================
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 0 /f >nul 2>&1
sc config "DiagTrack" start=auto >nul 2>&1
sc start "DiagTrack" >nul 2>&1
echo  %GREEN%    [+]%RESET% Telemetry policy keys removed
echo  %GREEN%    [+]%RESET% DiagTrack service restored to Automatic
echo.

:: ============================================================
echo  %CYAN%  [05] Restore Balanced Power Plan%RESET%
:: ============================================================
:: GUID: 381b4222-f694-41f0-9685-ff5bb260df2e = Balanced
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
powercfg /h on >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" ^
    /v "HiberbootEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo  %GREEN%    [+]%RESET% Balanced power plan restored
echo  %GREEN%    [+]%RESET% Hibernate and Fast Startup re-enabled
echo.

:: ============================================================
echo  %CYAN%  [06] Restore Visual Effects Defaults%RESET%
:: ============================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" ^
    /v "VisualFXSetting" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" ^
    /v "EnableTransparency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "ListviewAlphaSelect" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "ListviewShadow" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "TaskbarAnimations" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "1" /f >nul 2>&1
echo  %GREEN%    [+]%RESET% Visual effects restored to Windows defaults
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe
echo.

:: ============================================================
echo  %CYAN%  [07] Restore Network Defaults%RESET%
:: ============================================================
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global ecncapability=enabled >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" ^
    /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" ^
    /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
powershell -NonInteractive -Command ^
    "$ifaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'; foreach ($i in $ifaces) { Remove-ItemProperty $i.PSPath -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue; Remove-ItemProperty $i.PSPath -Name 'TCPNoDelay' -ErrorAction SilentlyContinue }" >nul 2>&1
echo  %GREEN%    [+]%RESET% Network settings restored to Windows defaults
echo.

:: ============================================================
echo  %CYAN%  [08] Restore Privacy Defaults%RESET%
:: ============================================================
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /f >nul 2>&1
echo  %GREEN%    [+]%RESET% Privacy settings restored to Windows defaults
echo.

echo  %MAGENTA%  ════════════════════════════════════════════════%RESET%
echo  %GREEN%  ✓ All changes reverted to Windows defaults.%RESET%
echo  %YELLOW%  A system restart is recommended.%RESET%
echo  %MAGENTA%  ════════════════════════════════════════════════%RESET%
echo.
pause
exit /b 0
