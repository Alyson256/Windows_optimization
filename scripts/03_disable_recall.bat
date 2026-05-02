@echo off
setlocal EnableExtensions

:: ============================================================
:: 03_disable_recall.bat — Disable Windows Recall (AI Snapshots)
::
:: Windows Recall (introduced in Windows 11 24H2) continuously
:: captures screenshots and indexes their content locally using AI.
:: This script disables it via Group Policy registry keys.
::
:: Requires: Windows 11 24H2 or later, Administrator
:: References:
::   HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI
::   HKCU\Software\Policies\Microsoft\Windows\WindowsAI
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[03] Disable Windows Recall%RESET%
echo  %DIM%  Disabling AI snapshot capture (Windows 11 24H2+)...%RESET%
echo.

:: Check Windows build — Recall is only on 24H2+
for /f "tokens=3" %%b in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do set "BUILD=%%b"

if defined BUILD (
    if %BUILD% LSS 26100 (
        echo  %YELLOW%  [!] Windows build %BUILD% detected. Recall requires build 26100+.%RESET%
        echo  %DIM%      Applying keys anyway for future-proofing.%RESET%
    ) else (
        echo  %DIM%  Windows build %BUILD% — Recall may be present.%RESET%
    )
)

:: Machine-level policy (applies to all users)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" ^
    /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1

:: User-level policy
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsAI" ^
    /v "DisableAIDataAnalysis" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable the Recall feature toggle in Settings
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" ^
    /v "AllowRecallEnablement" /t REG_DWORD /d 0 /f >nul 2>&1

:: Stop and disable the AI Recall background service (if running)
sc query "CoreAIPlatform" >nul 2>&1
if %errorLevel% == 0 (
    sc stop "CoreAIPlatform" >nul 2>&1
    sc config "CoreAIPlatform" start=disabled >nul 2>&1
    echo  %GREEN%  [+] CoreAIPlatform service disabled.%RESET%
)

:: Remove Recall from startup (if registered as a scheduled task)
powershell -NonInteractive -Command ^
    "Get-ScheduledTask -TaskName '*Recall*' -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue" >nul 2>&1

echo  %GREEN%  ✓ Windows Recall disabled via policy keys.%RESET%
echo  %DIM%    Keys written:%RESET%
echo  %DIM%    HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI — DisableAIDataAnalysis = 1%RESET%
echo  %DIM%    HKCU\Software\Policies\Microsoft\Windows\WindowsAI — DisableAIDataAnalysis = 1%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Windows Recall disabled" "SUCCESS"
exit /b 0
