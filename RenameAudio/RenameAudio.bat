@echo off
set LOGFILE=RenameAudio2.log

(
    echo Running ConvertToWav.ps1...
    powershell.exe -ExecutionPolicy Bypass -File ConvertToWav.ps1

    echo Running ConvertToOgg.ps1...
    powershell.exe -ExecutionPolicy Bypass -File ConvertToOgg.ps1

    echo Running Transcribe.ps1...
    powershell.exe -ExecutionPolicy Bypass -File Transcribe.ps1
) > %LOGFILE% 2>&1

echo Done.
