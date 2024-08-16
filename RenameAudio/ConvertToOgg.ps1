# Define paths
$rootPath = ".\RenameThese"
$ffmpegPath = ".\ffmpeg.exe"
$fasterWhisperPath = ".\faster-whisper-xxl.exe"

# Define the log file path
$logFilePath = "RenameAudio.log"

# Define a function to write messages to the log file and console
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    
    # Write to the log file
    $logMessage | Out-File -FilePath $logFilePath -Append
    
    # Also write to the console
    Write-Host $logMessage
}

# Ensure the log file exists
if (-not (Test-Path -Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File
}

# Check if the faster-whisper-xxl.exe file exists
if (-Not (Test-Path -Path $fasterWhisperPath)) {
    Write-Host "faster-whisper-xxl.exe not found in the current directory. Exiting script."
    exit
}

# Define the base path for relative paths
$basePath = ".\RenameThese"

# Initialize the directories arrays
$directories = @()
$nonEmptyDirectories = @()

# Add the base directory to the directories array
$directories += (Resolve-Path -Path $basePath).Path

# Add all directories and subdirectories to the directories array recursively
$directories += Get-ChildItem -Path $basePath -Directory -Recurse | ForEach-Object { $_.FullName }

# Output the list of directories

# Adjust paths to be relative to the base path and replace base path with 'RenameThese'
$directories | ForEach-Object {
    $relativePath = $_.Substring($basePath.Length).TrimStart('\')
    $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
    Write-Log "$relativePath"
}

# Check each directory for emptiness and count files
foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -File -Force
    if ($files.Count -eq 0) {
        $relativePath = $dir.Substring($basePath.Length).TrimStart('\')
        $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
        Write-Log "$relativePath is empty."
    } else {
        # Add non-empty directories to the array
        $nonEmptyDirectories += [PSCustomObject]@{ Path = $dir; FileCount = $files.Count }
    }
}

# Output non-empty directories
$nonEmptyDirectories | ForEach-Object {
    $relativePath = $_.Path.Substring($basePath.Length).TrimStart('\')
    $relativePath = "RenameThese" + ($relativePath -replace "^", "\")
    Write-Log "$relativePath contains $($_.FileCount) files"
}

Write-Log ""
Write-Log "------------------------"
Write-Log ""

# Function to convert WAV to OGG Vorbis
function Convert-ToOgg {
    param (
        [string]$directoryPath
    )

    Write-Log "Converting WAV to OGG in directory: $directoryPath"

    # Convert all WAV files to OGG Vorbis 32k in the current directory
    $wavFiles = Get-ChildItem -Path $directoryPath -File -Recurse | Where-Object { $_.Extension -eq ".wav" }
    foreach ($wavFile in $wavFiles) {
        $oggFilePath = [System.IO.Path]::ChangeExtension($wavFile.FullName, ".ogg")

        # Check if OGG file already exists
        if (-not (Test-Path -Path $oggFilePath)) {
            # Define the ffmpeg command
            $ffmpegCommand = "& `"$ffmpegPath`" -i `"$($wavFile.FullName)`" -af `"volume=-4.5dB`" -q:a 0 -c:a libvorbis  `"$oggFilePath`""
            
            # Log the ffmpeg command
            Write-Log "Executing ffmpeg command: $ffmpegCommand"
            
            # Run ffmpeg to convert files to OGG Vorbis 32k with normalization
            Invoke-Expression $ffmpegCommand
            
            Write-Log "Converted file: $($wavFile.FullName) to $oggFilePath with normalization to -4.5 dB"

            # Optionally delete the original WAV file if not needed
            Remove-Item -Path $wavFile.FullName -Force
            Write-Log "Deleted WAV file: $($wavFile.FullName)"
        } else {
            Write-Log "OGG file already exists: $oggFilePath"
        }
    }
}

# Process each non-empty directory
foreach ($dir in $nonEmptyDirectories) {
    Convert-ToOgg -directoryPath $dir.Path
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "All WAV files converted to OGG Vorbis 32k format."
Write-Log ""
Write-Log "####################################################"
Write-Log ""
