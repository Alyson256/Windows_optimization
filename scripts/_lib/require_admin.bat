@echo off
:: ============================================================
:: _lib/require_admin.bat — Verify Administrator privileges
:: Usage: call "%~dp0_lib\require_admin.bat" || exit /b 1
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ERROR] Administrator privileges required.
    echo  Right-click the script and select "Run as administrator".
    echo.
    exit /b 1
)
exit /b 0
