setlocal

:: Move to correct directory
cd /d "%~dp0"

:: Run the first PowerShell script and log output
powershell.exe -ExecutionPolicy Bypass -File "FolderCheck.ps1" >> "NormalizeAudio2.log" 2>&1
if errorlevel 1 exit /b 1

:: Run the second PowerShell script and log output
powershell.exe -ExecutionPolicy Bypass -File "ConvertToWav.ps1" >> "NormalizeAudio2.log" 2>&1
if errorlevel 1 exit /b 1

:: Run the third PowerShell script and log output
powershell.exe -ExecutionPolicy Bypass -File "ConvertToOgg.ps1" >> "NormalizeAudio2.log" 2>&1
if errorlevel 1 exit /b 1

endlocal
