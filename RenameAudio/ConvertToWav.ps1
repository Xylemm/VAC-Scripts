# Define the log file path
$logFilePath = "RenameAudio.log"

# Remove the existing log file if it exists
if (Test-Path -Path $logFilePath) {
    Remove-Item -Path $logFilePath -Force
    Write-Host "Deleted existing log file: $logFilePath"
} else {
    Write-Host "Log file does not exist, creating a new one."
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

# Create the output base directory if it doesn't exist
if (-not (Test-Path -Path $rootPath)) {
    Write-Log "Creating directory: $rootPath"
    New-Item -Path $rootPath -ItemType Directory
} else {
    Write-Log "Directory already exists: $rootPath"
}

# Process each directory and its subdirectories
function Convert-ToWav {
    param (
        [string]$directoryPath
    )

    Write-Log "Processing directory: $directoryPath"

    # Convert all audio files to WAV format in the current directory if they are not already WAV
    Write-Log "Starting audio conversion to WAV in directory: $directoryPath..."
    $audioFiles = Get-ChildItem -Path $directoryPath -File -Recurse | Where-Object { $_.Extension -ne ".txt" }
    foreach ($audioFile in $audioFiles) {
        if ($audioFile.Extension -ne ".wav") {
            $wavFilePath = [System.IO.Path]::ChangeExtension($audioFile.FullName, ".wav")

            # Run ffmpeg to convert files to WAV
            Write-Log "Running ffmpeg command: & $ffmpegPath -i $($audioFile.FullName) -c:a pcm_s16le -ar 44100 $wavFilePath"
            & $ffmpegPath -i $audioFile.FullName -c:a pcm_s16le -ar 44100 $wavFilePath
            Write-Log "Converted file: $($audioFile.FullName) to $wavFilePath"

            # Optionally delete the original audio file if not needed
            Remove-Item -Path $audioFile.FullName -Force
            Write-Log "Deleted original file: $($audioFile.FullName)"
        } else {
            Write-Log "File is already in WAV format: $($audioFile.FullName)"
        }
    }

    Write-Log "Audio conversion to WAV completed in directory: $directoryPath."
}

# Process the root directory itself
Convert-ToWav -directoryPath $rootPath

# Process each subdirectory under the root path
$directories = Get-ChildItem -Path $rootPath -Directory -Recurse
foreach ($directory in $directories) {
    Convert-ToWav -directoryPath $directory.FullName
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "All audio files converted to WAV format."
Write-Log ""
Write-Log "####################################################"

Write-Host "Logging complete. Check $logFilePath for details."
