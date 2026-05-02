@echo off
setlocal EnableExtensions

:: ============================================================
:: 07_network_tweaks.bat — Network Performance Optimization
::
:: - Disables Nagle's algorithm (reduces TCP latency)
:: - Sets TCP auto-tuning to normal
:: - Disables network throttling index
:: - Configures DNS cache size
::
:: Requires: Administrator
:: NOTE: These are global system settings, not interface-specific.
::       Individual NIC GUIDs are handled via PowerShell.
:: ============================================================

call "%~dp0_lib\colors.bat"
call "%~dp0_lib\require_admin.bat" || exit /b 1

echo.
echo  %CYAN%[07] Network Tweaks%RESET%
echo  %DIM%  Optimizing TCP/IP stack and DNS settings...%RESET%
echo.

:: ── TCP Auto-Tuning ──────────────────────────────────────────
netsh int tcp set global autotuninglevel=normal >nul 2>&1
echo  %GREEN%  [+]%RESET% TCP auto-tuning = normal

:: ── Disable ECN (Explicit Congestion Notification) ───────────
:: Can cause issues with some routers/ISPs
netsh int tcp set global ecncapability=disabled >nul 2>&1
echo  %GREEN%  [+]%RESET% ECN capability = disabled

:: ── RSS (Receive-Side Scaling) ───────────────────────────────
netsh int tcp set global rss=enabled >nul 2>&1
echo  %GREEN%  [+]%RESET% Receive-Side Scaling = enabled

:: ── Chimney Offload (deprecated in Win11, safe to set) ───────
netsh int tcp set global chimney=disabled >nul 2>&1

:: ── Network Throttling Index ─────────────────────────────────
:: Default = 10 (packets/ms). Set to 0xFFFFFFFF = disabled
:: This benefits gaming and real-time audio
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" ^
    /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul
echo  %GREEN%  [+]%RESET% Network throttling index = disabled

:: ── System responsiveness ────────────────────────────────────
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" ^
    /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul
echo  %GREEN%  [+]%RESET% System responsiveness = 0 (games/apps get more CPU)

:: ── Nagle's Algorithm (per-interface via PowerShell) ─────────
echo.
echo  %DIM%  Disabling Nagle algorithm on active adapters...%RESET%
powershell -NonInteractive -Command ^
    "$ifaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'; foreach ($iface in $ifaces) { $ip = (Get-ItemProperty $iface.PSPath -ErrorAction SilentlyContinue).IPAddress; if ($ip) { Set-ItemProperty $iface.PSPath -Name 'TcpAckFrequency' -Value 1 -Type DWord -Force; Set-ItemProperty $iface.PSPath -Name 'TCPNoDelay' -Value 1 -Type DWord -Force; Write-Host ('  [+] Nagle disabled on: '+$iface.PSChildName) } }"

:: ── DNS Client Cache ─────────────────────────────────────────
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" ^
    /v "CacheHashTableBucketSize" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" ^
    /v "CacheHashTableSize" /t REG_DWORD /d 384 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" ^
    /v "MaxCacheEntryTtlLimit" /t REG_DWORD /d 64000 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" ^
    /v "MaxSOACacheEntryTtlLimit" /t REG_DWORD /d 301 /f >nul
echo  %GREEN%  [+]%RESET% DNS cache parameters optimized

:: ── Keep LargeSystemCache disabled (workstation default) ─────
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" ^
    /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul

echo.
echo  %GREEN%  ✓ Network stack optimized.%RESET%
echo  %DIM%    Nagle disabled per active adapter. DNS cache enlarged.%RESET%
echo.

if defined LOG_FILE call "%~dp0_lib\logger.bat" "Network tweaks applied" "SUCCESS"
exit /b 0
