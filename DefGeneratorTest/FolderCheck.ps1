# Load the required .NET assembly for popup windows
Add-Type -AssemblyName System.Windows.Forms

# Define the root directory based on the location of the script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$soundsPath = "$scriptPath/Sounds"
$vacPath = "$soundsPath/VAC"

# Check if the "Sounds" folder exists
if (-not (Test-Path -Path $soundsPath)) {
    [System.Windows.Forms.MessageBox]::Show("The 'Sounds' folder does not exist in the current directory. Exiting script.", "Error", 'OK', 'Error')
    exit 1
}

# Check if the "Sounds" folder contains only the "VAC" folder
$soundsContents = Get-ChildItem -Path $soundsPath -Directory
if ($soundsContents.Count -ne 1 -or $soundsContents.Name -ne "VAC") {
    [System.Windows.Forms.MessageBox]::Show("The 'Sounds' folder must only contain the 'VAC' folder. Exiting script.", "Error", 'OK', 'Error')
    exit 1
}

# Check if the "VAC" folder exists and contains only one subfolder
$vacContents = Get-ChildItem -Path $vacPath -Directory
if ($vacContents.Count -ne 1) {
    [System.Windows.Forms.MessageBox]::Show("The 'VAC' folder must contain exactly one subfolder. Exiting script.", "Error", 'OK', 'Error')
    exit 1
}

# Get the name of the single subfolder inside "VAC"
$projectName = $vacContents.Name
$projectPath = "$vacPath/$projectName"

# Check if the "VAC" folder contains only allowed gender folders
$allowedGenders = @("Male", "Female", "Any")
$vacContents = Get-ChildItem -Path $projectPath -Directory | Select-Object -ExpandProperty Name

# Ensure only allowed gender folders are present and at least one is required
$invalidFolders = $vacContents | Where-Object { $_ -notin $allowedGenders }
if ($invalidFolders.Count -gt 0 -or $vacContents.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("Incorrect folder structure found. Please ensure correct folders exist:

Sounds\VAC\$projectName\Male
Sounds\VAC\$projectName\Female
Sounds\VAC\$projectName\Any

Exiting script.", "Error", 'OK', 'Error')
    exit 1
}

# Function to sanitize file and folder names
function Sanitize-Name {
    param (
        [string]$name
    )
    $illegalChars = [System.IO.Path]::GetInvalidFileNameChars()
    $sanitizedName = $name -replace '[\s]', '_'  # Replace spaces with underscores
    foreach ($char in $illegalChars) {
        $sanitizedName = $sanitizedName -replace [regex]::Escape($char), ''  # Remove illegal characters
    }
    if ($sanitizedName.Length -gt 50) {
        $sanitizedName = $sanitizedName.Substring(0, 50)
    }
    return $sanitizedName
}

#Assign a function to detect unique filenames
function Get-UniqueFileName {
    param (
        [string]$basePath,
        [string]$fileName,
        [string]$extension
    )
    
    # Define the base filename and path
    $baseFileName = "$fileName$extension"
    $newFilePath = Join-Path -Path $basePath -ChildPath $baseFileName
    
    Write-Host "Checking base file name: $baseFileName" -ForegroundColor Yellow

    # Check if the base filename already exists
    if (-not (Test-Path -Path $newFilePath)) {
        Write-Host "No conflict detected. Using base filename: $newFilePath" -ForegroundColor Green
        return $newFilePath
    }

    # Initialize counter starting from 1
    $counter = 1
    Write-Host "Base filename exists. Starting counter loop..." -ForegroundColor Yellow
    
    # Loop to find an available filename by incrementing the counter
    while ($true) {
        $newFileName = "$fileName`_$counter$extension"
        $newFilePath = Join-Path -Path $basePath -ChildPath $newFileName
        
        Write-Host "Checking filename with counter: $newFileName" -ForegroundColor Yellow
        
        if (-not (Test-Path -Path $newFilePath)) {
            Write-Host "Final unique file path determined: $newFilePath" -ForegroundColor Green
            return $newFilePath
        }
        
        $counter++
    }
}


# Rename files
Get-ChildItem -Path $projectPath -Recurse -File -Filter "*.*" | ForEach-Object {
    $originalFilePath = $_.FullName
    $directory = $_.DirectoryName
    $fileName = $_.BaseName
    $fileExtension = $_.Extension
    
    # Sanitize the filename
    $sanitizedFileName = Sanitize-Name -name $fileName
    
    # Generate a unique filename if necessary
    $newFilePath = Get-UniqueFileName -basePath $directory -fileName $sanitizedFileName -extension $fileExtension
    
    if ($originalFilePath -ne $newFilePath) {
        Rename-Item -Path $originalFilePath -NewName (Split-Path -Leaf $newFilePath) -Force
    }
}

# Rename folders with spaces
Get-ChildItem -Path $projectPath -Recurse -Directory | ForEach-Object {
    $originalFolderPath = $_.FullName
    $parentFolder = $_.Parent.FullName
    $folderName = $_.Name
    
    # Sanitize the folder name
    $sanitizedFolderName = Sanitize-Name -name $folderName
    
    # Create the new folder path
    $newFolderPath = Join-Path -Path $parentFolder -ChildPath $sanitizedFolderName
    
    if ($originalFolderPath -ne $newFolderPath) {
        Rename-Item -Path $originalFolderPath -NewName (Split-Path -Leaf $newFolderPath) -Force
    }
}

# If all checks pass, output success message
Write-Output "Folder structure is correct, and files and folders have been renamed."