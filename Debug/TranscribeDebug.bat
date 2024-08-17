cd /d %~dp0
setlocal

REM Define the log file path
set logFile=.\DebugLog.log

REM Run the PowerShell script for directory and file checks
powershell -ExecutionPolicy Bypass -File ".\DebugScript.ps1"

REM Check if faster-whisper-xxl.exe exists and run with no arguments
if exist ".\faster-whisper-xxl.exe" (
    echo Running faster-whisper-xxl with no arguments... >> %logFile%
    echo ---------------------------- >> %logFile%
    ".\faster-whisper-xxl.exe" >> %logFile% 2>&1
    echo ---------------------------- >> %logFile%
) else (
    echo faster-whisper-xxl.exe not found. Skipping execution. >> %logFile%
)

REM Run faster-whisper-xxl on test.ogg
if exist ".\faster-whisper-xxl.exe" (
    if exist ".\test.ogg" (
        echo Running faster-whisper-xxl on test.ogg... >> %logFile%
        echo ---------------------------- >> %logFile%
        ".\faster-whisper-xxl.exe" test.ogg >> %logFile% 2>&1
        echo ---------------------------- >> %logFile%
    ) else (
        echo test.ogg not found. Skipping test file execution. >> %logFile%
    )
) else (
    echo faster-whisper-xxl.exe not found. Skipping execution. >> %logFile%
)

Pause
endlocal
