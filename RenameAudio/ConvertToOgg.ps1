# Define the log file path
$logFilePath = "RenameAudio.log"

# Ensure the log file exists
if (-not (Test-Path -Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File
}

# Define a function to write messages to the log file
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp - $message" | Out-File -FilePath $logFilePath -Append
}

# Define paths
$rootPath = ".\RenameThese"
$ffmpegPath = ".\ffmpeg.exe"

# Process each directory and its subdirectories
function Convert-ToOgg {
    param (
        [string]$directoryPath
    )

    Write-Log "Processing directory: $directoryPath"

    # Convert all WAV files to OGG Vorbis 32k in the current directory
    Write-Log "Starting audio conversion to OGG Vorbis 32k in directory: $directoryPath..."
    $wavFiles = Get-ChildItem -Path $directoryPath -File -Recurse | Where-Object { $_.Extension -eq ".wav" }
    foreach ($wavFile in $wavFiles) {
        $oggFilePath = [System.IO.Path]::ChangeExtension($wavFile.FullName, ".ogg")

        # Check if OGG file already exists
        if (-not (Test-Path -Path $oggFilePath)) {
            # Run ffmpeg to convert files to OGG Vorbis 32k with normalization
            & $ffmpegPath -i $wavFile.FullName -af "volume=-4.5dB" -c:a libvorbis -b:a 32k $oggFilePath
            Write-Log "Converted file: $($wavFile.FullName) to $oggFilePath with normalization to -4.5 dB"

            # Optionally delete the original WAV file if not needed
            Remove-Item -Path $wavFile.FullName -Force
            Write-Log "Deleted WAV file: $($wavFile.FullName)"
        } else {
            Write-Log "OGG file already exists: $oggFilePath"
        }
    }

    Write-Log "Audio conversion to OGG Vorbis 32k completed in directory: $directoryPath."
}

# Process the root directory itself
Convert-ToOgg -directoryPath $rootPath

# Process each subdirectory under the root path
$directories = Get-ChildItem -Path $rootPath -Directory -Recurse
foreach ($directory in $directories) {
    Convert-ToOgg -directoryPath $directory.FullName
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "All WAV files converted to OGG Vorbis 32k format."
Write-Log ""
Write-Log "####################################################"
