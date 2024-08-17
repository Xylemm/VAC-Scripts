# Get the directory of the currently running script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Change to that directory
Set-Location -Path $scriptDir

# Log the current directory
$currentDir = Get-Location
Write-Log "Current directory is: $currentDir"

# Log the names of every subfolder in the current directory
Write-Log "Subfolders in the current directory:"
Get-ChildItem -Path $currentDir -Directory | ForEach-Object {
    Write-Log "Subfolder: $($_.FullName)"
}

# Check if faster-whisper-xxl.exe exists in the current directory
$fasterWhisperPath = ".\faster-whisper-xxl.exe"
if (Test-Path -Path $fasterWhisperPath) {
    Write-Log "faster-whisper-xxl.exe exists in the current directory."
} else {
    Write-Log "faster-whisper-xxl.exe NOT found in the current directory."
}

# Count the number of files in _xxl_data and its subfolders
$xxlDataPath = ".\_xxl_data"
if (Test-Path -Path $xxlDataPath) {
    $xxlFileCount = (Get-ChildItem -Path $xxlDataPath -File -Recurse).Count
    Write-Log "There are $xxlFileCount files in _xxl_data and its subfolders."
} else {
    Write-Log "_xxl_data directory does not exist."
}

# Count the number of .ogg files in \RenameThis and its subfolders
$renameThesePath = ".\RenameThese"
if (Test-Path -Path $renameThesePath) {
    $oggFileCount = (Get-ChildItem -Path $renameThesePath -Filter "*.ogg" -File -Recurse).Count
    Write-Log "There are $oggFileCount .ogg files in RenameThese and its subfolders."
} else {
    Write-Log "RenameThese directory does not exist."
}

Write-Log "Completed directory and file checks."

# Define paths relative to the script location
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootPath = Join-Path -Path $scriptPath -ChildPath "RenameThese"
$ffmpegPath = Join-Path -Path $scriptPath -ChildPath "ffmpeg.exe"
$fasterWhisperPath = Join-Path -Path $scriptPath -ChildPath "faster-whisper-xxl.exe"

# Define the log file path relative to the script location
$logFilePath = Join-Path -Path $scriptPath -ChildPath "RenameAudio.log"

# Remove the existing log file if it exists
if (Test-Path -Path $logFilePath) {
    Remove-Item -Path $logFilePath -Force
    Write-Host "Deleted existing log file: $logFilePath"
} else {
    Write-Host "Log file does not exist, creating a new one."
}

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

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "Starting audio file converting and renaming"
Write-Log ""
Write-Log "RenameAudio.bat version 0.2.6"
Write-Log ""
Write-Log "####################################################"

# Check if the faster-whisper-xxl.exe file exists
if (-Not (Test-Path -Path $fasterWhisperPath)) {
    Write-Host "faster-whisper-xxl.exe not found in the current directory. Exiting script."
    exit
}

# Define a function to sanitize filenames
function Sanitize-Filename {
    param (
        [string]$filename
    )

    # Remove special characters and replace spaces with underscores
    $sanitized = $filename -replace '[^a-zA-Z0-9_\.\-]', '' -replace '\s+', '_'

    # Limit the filename length to 50 characters (excluding extension)
    if ($sanitized.Length -gt 50) {
        $sanitized = $sanitized.Substring(0, 50)
    }

    return $sanitized
}

# Define a function to rename audio files
function Rename-AudioFile {
    param (
        [string]$directoryPath,
        [string]$oldFileName,
        [string]$newFileName
    )
    
    # Construct the full paths
    $oldFilePath = Join-Path -Path $directoryPath -ChildPath $oldFileName
    $newFilePath = Join-Path -Path $directoryPath -ChildPath $newFileName
    
    if (Test-Path -LiteralPath $oldFilePath) {
        try {
            # Rename the file using -LiteralPath to handle special characters like brackets
            Rename-Item -LiteralPath $oldFilePath -NewName $newFileName -Force
            Write-Host "File renamed successfully: $oldFilePath to $newFilePath"
            Write-Log "Renamed file: $oldFilePath to $newFilePath"
        } catch {
            Write-Host "Error renaming file: $oldFilePath to $newFilePath. Error: $($_.Exception.Message)"
            Write-Log "Error renaming file: $oldFilePath to $newFilePath. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "File does not exist: $oldFilePath"
        Write-Log "File does not exist: $oldFilePath"
    }
}

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

# Adjust paths to be relative to the base path and replace base path with 'RenameThese'
$directories | ForEach-Object {
    $relativePath = $_.Substring($rootPath.Length).TrimStart('\')
    $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
    Write-Log "\$relativePath"
}

# Check each directory for emptiness and count files
foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -File -Force
    if ($files.Count -eq 0) {
        $relativePath = $dir.Substring($rootPath.Length).TrimStart('\')
        $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
    } else {
        # Add non-empty directories to the array
        $nonEmptyDirectories += [PSCustomObject]@{ Path = $dir; FileCount = $files.Count }
    }
}
    
Write-Log ""
Write-Log "------------------------"

# Adjust paths to be relative to the base path and replace base path with 'RenameThese'
$nonEmptyDirectories | ForEach-Object {
    $relativePath = $_.Path.Substring($rootPath.Length).TrimStart('\')
    $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
    Write-Log ""
    Write-Log "\$relativePath contains $($_.FileCount) files"
}

Write-Log ""
Write-Log "------------------------"
Write-Log ""

# Rename and sanitize filenames
function Rename-AudioFiles {
    param (
        [string]$directoryPath
    )

    $audioFiles = Get-ChildItem -Path $directoryPath -File | Where-Object { $_.Extension -ne ".txt" }
    foreach ($audioFile in $audioFiles) {
        $sanitizedFileName = Sanitize-Filename -filename $audioFile.BaseName
        $newFileName = "$sanitizedFileName$($audioFile.Extension)"
        Rename-AudioFile -directoryPath $directoryPath -oldFileName $audioFile.Name -newFileName $newFileName
    }
}

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

    Rename-AudioFiles -directoryPath $directory
    Convert-ToWav -directoryPath $directory
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "All audio files converted to WAV format."
Write-Log ""
Write-Log "####################################################"
