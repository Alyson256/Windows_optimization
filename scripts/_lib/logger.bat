@echo off
:: ============================================================
:: _lib/logger.bat — Append a timestamped entry to the log file
:: Usage: call logger.bat "Message" [INFO|WARN|ERROR|SUCCESS]
:: Requires: LOG_FILE env var set by the caller script
:: ============================================================

if not defined LOG_FILE set "LOG_FILE=%TEMP%\winopt_log.txt"

set "_msg=%~1"
set "_lvl=%~2"
if "%_lvl%"=="" set "_lvl=INFO"

for /f "tokens=1-2 delims=: " %%a in ("%time: =0%") do set "_ts=%%a:%%b"
echo [%date% %_ts%] [%_lvl%] %_msg% >> "%LOG_FILE%"
exit /b 0
