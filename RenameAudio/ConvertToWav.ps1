# Define paths
$rootPath = ".\RenameThese"
$ffmpegPath = ".\ffmpeg.exe"
$fasterWhisperPath = ".\faster-whisper-xxl.exe"

# Check if the faster-whisper-xxl.exe file exists
if (-Not (Test-Path -Path $fasterWhisperPath)) {
    Write-Host "faster-whisper-xxl.exe not found in the current directory. Exiting script."
    exit
}

# Define the log file path
$logFilePath = "RenameAudio.log"

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

# Define the base path for relative paths
$basePath = "C:\VoiceLines\Tools\Faster-Whisper-XXL\RenameThese"

# Initialize the directories arrays
$directories = @()
$nonEmptyDirectories = @()

# Add the base directory to the directories array
$directories += $basePath

# Add all directories and subdirectories to the directories array recursively
$directories += Get-ChildItem -Path $basePath -Directory -Recurse | ForEach-Object { $_.FullName }

# Output the list of directories
Write-Log "Checking the following folders:"
Write-Log ""

# Adjust paths to be relative to the base path and replace base path with 'RenameThese'
$directories | ForEach-Object {
    $relativePath = $_.Substring($basePath.Length).TrimStart('\')
    $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
    Write-Log "\$relativePath"
}

# Check each directory for emptiness and count files
foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -File -Force
    if ($files.Count -eq 0) {
        $relativePath = $dir.Substring($basePath.Length).TrimStart('\')
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
    $relativePath = $_.Path.Substring($basePath.Length).TrimStart('\')
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
        $newFilename = Sanitize-Filename -filename $audioFile.BaseName
        $newFilePath = Join-Path -Path $audioFile.DirectoryName -ChildPath "$newFilename$($audioFile.Extension)"

        if ($audioFile.FullName -ne $newFilePath) {
            Rename-Item -Path $audioFile.FullName -NewName $newFilePath
        } else {
        }
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
