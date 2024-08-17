# DebugScript.ps1

# Define the log file path
$logFilePath = ".\DebugLog2.log"

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
