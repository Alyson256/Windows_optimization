@echo off
setlocal EnableExtensions

:: ============================================================
:: 11_remove_bloatware.bat — Remove Non-Essential UWP Apps
::
:: Removes pre-installed Windows 11 apps that most users
:: never use. Only targets clearly non-essential packages.
:: Apps can be reinstalled from the Microsoft Store at any time.
::
:: Requires: Windows 11, Administrator
:: Safe: UWP removal via PowerShell Remove-AppxPackage
:: Undo: Reinstall from Microsoft Store
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[11] Remove Non-Essential Bloatware%RESET%
echo  %DIM%  Removing pre-installed UWP apps (reinstallable via Store)...%RESET%
echo.
echo  %YELLOW%  [!] Apps marked with (*) will be removed for ALL users.%RESET%
echo.

set "REMOVED=0"
set "SKIPPED=0"

:: ── Entertainment / Microsoft extras ─────────────────────────
call :remove_app "Microsoft.BingNews"           "Microsoft News"
call :remove_app "Microsoft.BingWeather"        "Microsoft Weather"
call :remove_app "Microsoft.BingFinance"        "Microsoft Finance"
call :remove_app "Microsoft.BingSports"         "Microsoft Sports"
call :remove_app "Microsoft.BingSearch"         "Bing Search integration"
call :remove_app "Microsoft.MicrosoftSolitaireCollection" "Solitaire Collection"
call :remove_app "Microsoft.ZuneMusic"          "Groove Music"
call :remove_app "Microsoft.ZuneVideo"          "Movies & TV"
call :remove_app "Microsoft.WindowsMaps"        "Maps"
call :remove_app "Microsoft.WindowsFeedbackHub" "Feedback Hub"
call :remove_app "Microsoft.Getstarted"         "Tips / Get Started"
call :remove_app "Microsoft.MicrosoftOfficeHub" "Office Hub"
call :remove_app "Microsoft.549981C3F5F10"      "Cortana (standalone app)"

:: ── Clipchamp (video editor) ─────────────────────────────────
call :remove_app "Clipchamp.Clipchamp"          "Clipchamp Video Editor"

:: ── Consumer Teams (not the enterprise version) ──────────────
call :remove_app "MicrosoftTeams"               "Teams (consumer)"
call :remove_app "MSTeams"                      "Teams (new, consumer)"

:: ── Xbox (comment these out if you use Xbox) ─────────────────
call :remove_app "Microsoft.XboxApp"            "Xbox (old)"
call :remove_app "Microsoft.GamingApp"          "Xbox (new)"

echo.
set /p "XBOX_ANS=  Remove Xbox Game Bar (Win+G recording)? (Y/N): "
if /i "%XBOX_ANS%"=="Y" (
    call :remove_app "Microsoft.XboxGamingOverlay"  "Xbox Game Bar"
    call :remove_app "Microsoft.XboxIdentityProvider" "Xbox Identity Provider"
    call :remove_app "Microsoft.XboxSpeechToTextOverlay" "Xbox Speech Overlay"
) else (
    echo  %YELLOW%  [-] Skipped Xbox Game Bar%RESET%
)
echo.

:: ── Other pre-installed non-essentials ───────────────────────
call :remove_app "Microsoft.MixedReality.Portal"    "Mixed Reality Portal"
call :remove_app "Microsoft.People"                 "People"
call :remove_app "Microsoft.SkypeApp"               "Skype"
call :remove_app "Microsoft.PowerAutomateDesktop"   "Power Automate Desktop"
call :remove_app "Microsoft.Todos"                  "Microsoft To Do"
call :remove_app "Microsoft.OutlookForWindows"      "Outlook (new, standalone)"
call :remove_app "Microsoft.OneDriveSync"           "OneDrive (sync app UWP)"

:: ── 3rd-party preinstalled (OEM/MS deals) ────────────────────
call :remove_app "Disney.37853D22215B2"         "Disney+"
call :remove_app "SpotifyAB.SpotifyMusic"       "Spotify (pre-installed)"
call :remove_app "king.com.CandyCrushSaga"      "Candy Crush Saga"
call :remove_app "king.com.CandyCrushFriends"   "Candy Crush Friends"
call :remove_app "Facebook.InstagramApp"        "Instagram"
call :remove_app "TikTok.TikTok"               "TikTok"
call :remove_app "BytedancePte.Ltd.TikTok"     "TikTok (alt package)"

echo.
echo  %CYAN%  ════════════════════════════════════════════════%RESET%
echo  %GREEN%  ✓ Removed: %REMOVED%   %YELLOW%  Skipped/not found: %SKIPPED%%RESET%
echo  %CYAN%  ════════════════════════════════════════════════%RESET%
echo.
echo  %DIM%  All removed apps can be reinstalled from the Microsoft Store.%RESET%
echo  %DIM%  Xbox Game Bar can be re-enabled via Settings > Gaming.%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Bloatware removed: %REMOVED% packages" "SUCCESS"
exit /b 0

:: ============================================================
:remove_app  <PackageName>  <FriendlyName>
:: ============================================================
powershell -NonInteractive -Command ^
    "$pkg = Get-AppxPackage -Name '%~1' -AllUsers -ErrorAction SilentlyContinue; if ($pkg) { Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue; exit 0 } else { exit 1 }" >nul 2>&1

if %errorLevel% == 0 (
    echo  %GREEN%  [+]%RESET% Removed: %~2  %DIM%(%~1)%RESET%
    if defined LOG_FILE call "%~dp0_lib\logger.bat" "Removed: %~1" "INFO"
    set /a REMOVED+=1
) else (
    echo  %DIM%  [-] Not found: %~2%RESET%
    set /a SKIPPED+=1
)
goto :EOF
