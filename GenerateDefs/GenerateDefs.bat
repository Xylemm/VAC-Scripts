setlocal

:: Move to correct directory
cd /d "%~dp0"

:: Run the first PowerShell script and log output
powershell.exe -ExecutionPolicy Bypass -File "FolderCheck.ps1" >> log.txt 2>&1
if errorlevel 1 exit /b 1

:: Run the fourth PowerShell script and log output
powershell.exe -ExecutionPolicy Bypass -File "SoundDefs.ps1" >> log.txt 2>&1
if errorlevel 1 exit /b 1

:: Run the fifth PowerShell script and log output
powershell.exe -ExecutionPolicy Bypass -File "VoicePackDefs.ps1" >> log.txt 2>&1
if errorlevel 1 exit /b 1

endlocal
