@echo off
:: ============================================================
:: _lib/colors.bat — ANSI color macros for console output
:: Compatible with Windows 11 (ConHost + Windows Terminal)
:: Usage: call "%~dp0_lib\colors.bat"
::        echo %GREEN%Success!%RESET%
:: ============================================================

for /f %%a in ('echo prompt $E^| cmd /q /v:on /c "set /p .="') do set "ESC=%%a"

set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "MAGENTA=%ESC%[95m"
