@echo off
setlocal EnableExtensions

:: ============================================================
:: 08_privacy_tweaks.bat — Windows 11 Privacy Hardening
::
:: Disables advertising ID, location tracking, activity history,
:: suggested content, and Windows feedback prompts.
:: All changes are in HKCU (user-level) and HKLM policy keys.
::
:: Requires: Administrator (for HKLM keys)
:: Safe: None of these affect system stability.
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[08] Privacy Tweaks%RESET%
echo  %DIM%  Disabling advertising, location, activity history...%RESET%
echo.

:: ── Advertising ID ───────────────────────────────────────────
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" ^
    /v "Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" ^
    /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul
echo  %GREEN%  [+]%RESET% Advertising ID — disabled

:: ── Location Services ────────────────────────────────────────
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" ^
    /v "Value" /t REG_SZ /d "Deny" /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" ^
    /v "DisableLocation" /t REG_DWORD /d 1 /f >nul
echo  %GREEN%  [+]%RESET% Location services — denied

:: ── Activity History / Timeline ──────────────────────────────
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" ^
    /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" ^
    /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" ^
    /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% Activity history / Timeline — disabled

:: ── Windows Feedback ─────────────────────────────────────────
reg add "HKCU\Software\Microsoft\Siuf\Rules" ^
    /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" ^
    /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul
echo  %GREEN%  [+]%RESET% Windows Feedback prompts — disabled

:: ── Start Menu suggestions / Spotlight ──────────────────────
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" ^
    /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" ^
    /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" ^
    /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" ^
    /v "SubscribedContent-353698Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" ^
    /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" ^
    /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% Start menu suggestions + silent app installs — disabled

:: ── Cortana / Search ─────────────────────────────────────────
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" ^
    /v "AllowCortana" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" ^
    /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% Cortana consent — revoked

:: ── Biometric data ───────────────────────────────────────────
reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" ^
    /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo  %GREEN%  [+]%RESET% Biometrics policy — disabled

:: ── Camera / Microphone global access (policy) ───────────────
:: Note: This sets the *policy* deny, not the user toggle
:: Uncomment only if you never want apps to access cam/mic system-wide
:: reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCamera" /t REG_DWORD /d 2 /f >nul
:: reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessMicrophone" /t REG_DWORD /d 2 /f >nul

echo.
echo  %GREEN%  ✓ Privacy settings hardened.%RESET%
echo  %DIM%    Camera/microphone app access left unchanged (user-controlled via Settings).%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Privacy tweaks applied" "SUCCESS"
exit /b 0
