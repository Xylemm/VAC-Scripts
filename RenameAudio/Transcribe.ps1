# Define the log file path
$logFilePath = ".\RenameAudio.log"

$fasterWhisperPath = ".\faster-whisper-xxl.exe"

# Check if the faster-whisper-xxl.exe file exists
if (-Not (Test-Path -Path $fasterWhisperPath)) {
    Write-Host "faster-whisper-xxl.exe not found in the current directory. Exiting script."
    exit
}

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

Write-Log "Starting Transcription"

# Define paths
$rootPath = ".\RenameThese"
$whisperPath = ".\faster-whisper-xxl.exe"
$ffmpegPath = ".\ffmpeg.exe"
$basePath = ".\RenameThese"

# Initialize the directories arrays
$nonEmptyDirectories = @()

# Get all directories and subdirectories, then check each for files
$directories = Get-ChildItem -Path $basePath -Directory -Recurse | ForEach-Object {
    $files = Get-ChildItem -Path $_.FullName -File -Force
    if ($files.Count -gt 0) {
        $nonEmptyDirectories += [PSCustomObject]@{ Path = $_.FullName; FileCount = $files.Count }
    }
}

# Create the Transcription directory if it doesn't exist
function Create-TranscriptionFolder {
    param (
        [string]$directoryPath
    )

    $transcriptionPath = Join-Path -Path $directoryPath -ChildPath "Transcription"
    if (-not (Test-Path -Path $transcriptionPath)) {
        New-Item -Path $transcriptionPath -ItemType Directory
    }
}

# Run Whisper on all .ogg files in the directory
function Run-Whisper {
    param (
        [string]$directoryPath
    )

    Write-Log "Starting transcription in directory: $directoryPath..."
    & $whisperPath --beep_off --output_format txt --language=en --model=tiny.en -o="$directoryPath\Transcription" --batch_recursive --vad_filter=false "$directoryPath"
    Write-Log "Transcription completed in directory: $directoryPath."
}

# Check if the directory contains any .ogg files
function HasOggFiles {
    param (
        [string]$directoryPath
    )

    return (Get-ChildItem -Path $directoryPath -Filter "*.ogg" -File).Count -gt 0
}

# Process each directory and its subdirectories
function Process-Directory {
    param (
        [string]$directoryPath
    )

    Write-Log "Processing directory: $directoryPath"

    if (-not (HasOggFiles -directoryPath $directoryPath)) {
        Write-Log "No .ogg files found in directory: $directoryPath. Skipping renaming."
        return
    }

    Create-TranscriptionFolder -directoryPath $directoryPath
    Run-Whisper -directoryPath $directoryPath

    # Initialize counter for blank filenames
    $blankCounter = 1

    # Get all transcription text files in the transcription directory
    $transcriptionPath = Join-Path -Path $directoryPath -ChildPath "Transcription"
    $textFiles = Get-ChildItem -Path $transcriptionPath -Filter "*.txt"
    foreach ($textFile in $textFiles) {
        Write-Log "Processing transcription file: $($textFile.FullName)"
        
        # Read the content of the transcription text file
        $transcriptionLines = Get-Content -Path $textFile.FullName
        $transcriptionText = $transcriptionLines -join ' ' # Combine lines into a single string
    
        # Remove any timestamp patterns and extra content
        $cleanedText = $transcriptionText -replace '\[.*?\]', '' # Remove timestamps enclosed in brackets
        $cleanedText = $cleanedText.Trim() # Remove any leading or trailing whitespace
        $cleanedText = $cleanedText.Substring(0, [Math]::Min(100, $cleanedText.Length)) # Limit length to avoid excessively long names
        $cleanedText = $cleanedText -replace '\.$', '' # Remove trailing "." character if present

        # Replace question marks with tilde symbol
        $cleanedText = $cleanedText -replace '[\\/:*?"<>|]', '~'

        # If cleaned text is empty, create a unique default name
        if (-not $cleanedText) {
            $cleanedText = "$blankCounter"
            $blankCounter++
        }

        # Get the corresponding ogg audio file
        $audioFile = Get-ChildItem -Path $directoryPath -File | Where-Object { $_.Extension -eq ".ogg" -and $_.BaseName -eq $textFile.BaseName }

        if ($audioFile) {
            # Construct the new file name
            $newFileName = "$cleanedText$($audioFile.Extension)"
            $newFilePath = Join-Path -Path $audioFile.DirectoryName -ChildPath $newFileName

            # Check if a file with the same name already exists, and if so, add a number to make it unique
            $fileCounter = 1
            while (Test-Path $newFilePath) {
                $newFileName = "$cleanedText-$fileCounter$($audioFile.Extension)"
                $newFilePath = Join-Path -Path $audioFile.DirectoryName -ChildPath $newFileName
                $fileCounter++
            }

            # Rename the audio file
            Rename-Item -Path $audioFile.FullName -NewName $newFilePath -Force
            Write-Log "Renamed file: $($audioFile.FullName) to $newFilePath"
        } else {
            Write-Log "No matching ogg file found for transcription file: $($textFile.FullName)"
        }
    }

    # Comment out or remove the code that deletes the Transcription folder
    # Write-Log "Deleting folder: $transcriptionPath"
    # Remove-Item -Path $transcriptionPath -Recurse -Force
    # Write-Log "Folder deleted."

    Write-Log "Completed processing for directory: $directoryPath."
}

# Process only the non-empty directories
foreach ($dir in $nonEmptyDirectories) {
    Process-Directory -directoryPath $dir.Path
}

Write-Log ""
Write-Log "####################################################"
Write-Log ""
Write-Log "All audio files transcribed and renamed."
Write-Log ""
Write-Log "####################################################"
Write-Host "Logging complete. Check $logFilePath for details."
[console]::beep(550, 250)
[console]::beep(550, 250)
