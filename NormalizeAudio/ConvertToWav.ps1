# Get the directory of the currently running script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Change to that directory
Set-Location -Path $scriptDir

# Define paths relative to the script location
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootPath = Join-Path -Path $scriptPath -ChildPath "Sounds"
$ffmpegPath = Join-Path -Path $scriptPath -ChildPath "ffmpeg.exe"

# Define the log file path relative to the script location
$logFilePath = Join-Path -Path $scriptPath -ChildPath "NormalizeAudio.log"

# Define a function to write messages to the log file and console
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yy-M-d H:m")
    $logMessage = "$timestamp - $message"
    
    # Write to the log file
    $logMessage | Out-File -FilePath $logFilePath -Append
    
    # Also write to the console
    Write-Host $logMessage
}
# Log the current directory
$currentDir = Get-Location
Write-Log "Current directory is: $currentDir"

# Log the names of every subfolder in the current directory
Write-Log "Subfolders in the current directory:"
Get-ChildItem -Path $currentDir -Directory | ForEach-Object {
    Write-Log "Subfolder: $($_.FullName)"
}

Write-Log "Completed directory and file checks."

# Remove the existing log file if it exists
if (Test-Path -Path $logFilePath) {
    Remove-Item -Path $logFilePath -Force
    Write-Host "Deleted existing log file: $logFilePath"
} else {
    Write-Host "Log file does not exist, creating a new one."
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "Starting audio file converting and renaming"
Write-Log ""
Write-Log "NormalizeAudio.bat version 0.2.8"
Write-Log ""
Write-Log "####################################################"

# Initialize the directories arrays
$directories = @()
$nonEmptyDirectories = @()

# Add the base directory to the directories array
$directories += $rootPath

# Add all directories and subdirectories to the directories array recursively
$directories += Get-ChildItem -Path $rootPath -Directory -Recurse | ForEach-Object { $_.FullName }

# Output the list of directories
Write-Log "Checking the following folders:"
Write-Log ""

# Adjust paths to be relative to the base path and replace base path with 'Sounds'
$directories | ForEach-Object {
    $relativePath = $_.Substring($rootPath.Length).TrimStart('\')
    $relativePath = "Sounds" + ($relativePath -replace "^", "\")
    Write-Log "\$relativePath"
}

# Check each directory for emptiness and count files
foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -File -Force
    if ($files.Count -eq 0) {
        $relativePath = $dir.Substring($rootPath.Length).TrimStart('\')
        $relativePath = "Sounds" + ($relativePath -replace "^", "\")
    } else {
        # Add non-empty directories to the array
        $nonEmptyDirectories += [PSCustomObject]@{ Path = $dir; FileCount = $files.Count }
    }
}
    
Write-Log ""
Write-Log "------------------------"

# Adjust paths to be relative to the base path and replace base path with 'Sounds'
$nonEmptyDirectories | ForEach-Object {
    $relativePath = $_.Path.Substring($rootPath.Length).TrimStart('\')
    $relativePath = "Sounds" + ($relativePath -replace "^", "\")
    Write-Log ""
    Write-Log "\$relativePath contains $($_.FileCount) files"
}

Write-Log ""
Write-Log "------------------------"
Write-Log ""


# Convert audio files to WAV format
function Convert-ToWav {
    param (
        [string]$directoryPath
    )

    Write-Log "Converting to WAV in directory: $directoryPath"

    $audioFiles = Get-ChildItem -Path $directoryPath -File | Where-Object { $_.Extension -ne ".txt" }
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
}

# Process all directories
foreach ($directory in $directories) {
    $itemsInDirectory = Get-ChildItem -Path $directory

    if ($itemsInDirectory.Count -eq 0) {
        continue
    }

    Convert-ToWav -directoryPath $directory
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "All audio files converted to WAV format."
Write-Log ""
Write-Log "####################################################"
