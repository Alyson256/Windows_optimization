@echo off
setlocal EnableExtensions

:: ============================================================
:: 06_visual_tweaks.bat — Visual Performance Optimization
::
:: Reduces unnecessary animations, shadows, and transparency.
:: Keeps ClearType font smoothing enabled (readability).
:: Sets VisualFXSetting to Custom and disables specific effects.
::
:: Requires: Administrator
:: Undo: 10_undo_all.bat restores "Let Windows choose" (default)
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[06] Visual Performance Tweaks%RESET%
echo  %DIM%  Disabling animations, shadows, and transparency effects...%RESET%
echo.

:: ── VisualFX — Set to Custom (2) ─────────────────────────────
:: 0 = Let Windows decide | 1 = Best appearance | 2 = Custom | 3 = Best performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" ^
    /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul
echo  %GREEN%  [+]%RESET% VisualFXSetting = Custom (2)

:: ── Transparency ─────────────────────────────────────────────
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" ^
    /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% Transparency effects — disabled

:: ── Animation switches in UserPreferencesMask ────────────────
:: Read existing value, disable specific animation bits, write back
powershell -NonInteractive -Command ^
    "$p = 'HKCU:\Control Panel\Desktop'; $n = 'UserPreferencesMask'; $m = (Get-ItemProperty $p -Name $n -ErrorAction SilentlyContinue).$n; if ($m) { $m[0] = $m[0] -band 0x5F; Set-ItemProperty $p -Name $n -Value $m -Type Binary }"
echo  %GREEN%  [+]%RESET% UserPreferencesMask updated (minimal animations)

:: ── Individual animation settings ────────────────────────────
reg add "HKCU\Control Panel\Desktop" ^
    /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
echo  %GREEN%  [+]%RESET% Menu show delay = 0ms

reg add "HKCU\Control Panel\Desktop\WindowMetrics" ^
    /v "MinAnimate" /t REG_SZ /d "0" /f >nul
echo  %GREEN%  [+]%RESET% Window minimize/maximize animation — disabled

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "ListviewAlphaSelect"  /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "ListviewShadow"       /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "TaskbarAnimations"    /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
    /v "ExtendedUIHoverTime"  /t REG_DWORD /d 1 /f >nul
echo  %GREEN%  [+]%RESET% Listview alpha, shadows, taskbar animations — disabled

:: ── Cursor blink rate ─────────────────────────────────────────
reg add "HKCU\Control Panel\Desktop" ^
    /v "CursorBlinkRate" /t REG_SZ /d "530" /f >nul

:: ── Keep ClearType enabled (readability) ─────────────────────
reg add "HKCU\Control Panel\Desktop" ^
    /v "FontSmoothing" /t REG_SZ /d "2" /f >nul
reg add "HKCU\Control Panel\Desktop" ^
    /v "FontSmoothingType" /t REG_DWORD /d 2 /f >nul
echo  %GREEN%  [+]%RESET% ClearType font smoothing — kept enabled

:: ── Restart Explorer to apply ────────────────────────────────
echo.
echo  %DIM%  Restarting Windows Explorer to apply changes...%RESET%
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe

echo.
echo  %GREEN%  ✓ Visual tweaks applied.%RESET%
echo  %DIM%    ClearType and font rendering preserved for readability.%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Visual tweaks applied" "SUCCESS"
exit /b 0
