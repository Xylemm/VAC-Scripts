Start-Transcript -Path "log.txt"

Write-Host "All output being saved to log.txt"

# Define paths
$rootPath = ".\RenameThese"
$ffmpegPath = ".\ffmpeg.exe"

# Create the output base directory if it doesn't exist
if (-not (Test-Path -Path $rootPath)) {
    Write-Host "Creating directory: $rootPath"
    New-Item -Path $rootPath -ItemType Directory
}


# Process each directory and its subdirectories
function Process-Directory {
    param (
        [string]$directoryPath
    )

    Write-Host "Processing directory: $directoryPath"

    # Define paths for the transcription directory
    $transcriptionPath = Join-Path -Path $directoryPath -ChildPath "Transcription"
    if (-not (Test-Path -Path $transcriptionPath)) {
        Write-Host "Creating directory: $transcriptionPath"
        New-Item -Path $transcriptionPath -ItemType Directory
    }

    # Convert all audio files to WAV format in the current directory if they are not already WAV
    Write-Host "Starting audio conversion to WAV in directory: $directoryPath..."
    $audioFiles = Get-ChildItem -Path $directoryPath -File -Recurse | Where-Object { $_.Extension -ne ".txt" }
    foreach ($audioFile in $audioFiles) {
        if ($audioFile.Extension -ne ".wav") {
            $wavFilePath = [System.IO.Path]::ChangeExtension($audioFile.FullName, ".wav")

            # Run ffmpeg to convert files to WAV
            & $ffmpegPath -i $audioFile.FullName -c:a pcm_s16le -ar 44100 $wavFilePath
            Write-Host "Converted file: $($audioFile.FullName) to $wavFilePath"

            # Optionally delete the original audio file if not needed
            Remove-Item -Path $audioFile.FullName -Force
            Write-Host "Deleted original file: $($audioFile.FullName)"
        } else {
            Write-Host "File is already in WAV format: $($audioFile.FullName)"
        }
    }

    # Convert all WAV files to OGG Vorbis 32k in the current directory
    Write-Host "Starting audio conversion to OGG Vorbis 32k in directory: $directoryPath..."
    $wavFiles = Get-ChildItem -Path $directoryPath -File -Recurse | Where-Object { $_.Extension -eq ".wav" }
    foreach ($wavFile in $wavFiles) {
        $oggFilePath = [System.IO.Path]::ChangeExtension($wavFile.FullName, ".ogg")

        # Run ffmpeg to convert files to OGG Vorbis 32k with normalization
        & $ffmpegPath -i $wavFile.FullName -af "volume=-4.5dB" -c:a libvorbis -b:a 32k $oggFilePath
        Write-Host "Converted file: $($wavFile.FullName) to $oggFilePath with normalization to -4.5 dB"

        # Optionally delete the original WAV file if not needed
        Remove-Item -Path $wavFile.FullName -Force
        Write-Host "Deleted WAV file: $($wavFile.FullName)"
    }

    Write-Host "Audio conversion completed in directory: $directoryPath."

    # Run the Whisper command for the current directory
    Write-Host "Starting transcription in directory: $directoryPath..."
    & ".\faster-whisper-xxl.exe" --beep_off --output_format txt --language=en --model=tiny.en -o="$transcriptionPath" --batch_recursive --vad_filter=false "$directoryPath"
    Write-Host "Transcription completed in directory: $directoryPath."

    # Initialize counter for blank filenames
    $blankCounter = 1

    # Get all transcription text files in the transcription directory
    $textFiles = Get-ChildItem -Path $transcriptionPath -Filter "*.txt"
    foreach ($textFile in $textFiles) {
        Write-Host "Processing transcription file: $($textFile.FullName)"
        
        # Read the content of the transcription text file
        $transcriptionLines = Get-Content -Path $textFile.FullName
        $transcriptionText = $transcriptionLines -join ' ' # Combine lines into a single string

        # Remove any timestamp patterns and extra content
        $cleanedText = $transcriptionText -replace '\[.*?\]', '' # Remove timestamps enclosed in brackets
        $cleanedText = $cleanedText.Trim() # Remove any leading or trailing whitespace
        $cleanedText = $cleanedText.Substring(0, [Math]::Min(100, $cleanedText.Length)) # Limit length to avoid excessively long names
        $cleanedText = $cleanedText -replace '\.$', '' # Remove trailing "." character if present

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
            Write-Host "Renamed file: $($audioFile.FullName) to $newFilePath"

            # Remove the transcription text file
            Remove-Item -Path $textFile.FullName -Force
            Write-Host "Removed transcription file: $($textFile.FullName)"
        } else {
            Write-Host "No matching ogg file found for transcription file: $($textFile.FullName)"
        }
    }

    # Delete the Transcription folder for the current directory
    Write-Host "Deleting folder: $transcriptionPath"
    Remove-Item -Path $transcriptionPath -Recurse -Force
    Write-Host "Folder deleted."

    Write-Host "Completed processing for directory: $directoryPath."
}

# Process the root directory itself
Process-Directory -directoryPath $rootPath

# Process each subdirectory under the root path
$directories = Get-ChildItem -Path $rootPath -Directory -Recurse
foreach ($directory in $directories) {
    Process-Directory -directoryPath $directory.FullName
}

Write-Host ""
Write-Host "####################################################"
Write-Host ""
Write-Host "All audio files compressed, normalized, and renamed."
Write-Host ""
Write-Host "####################################################"

# Beep to indicate completion
[console]::beep(400, 250)  # 1000 Hz frequency, 500 ms duration
[console]::beep(400, 250)  # 1000 Hz frequency, 500 ms duration

Stop-Transcript
