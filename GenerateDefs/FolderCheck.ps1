# Load the required .NET assembly for popup windows
Add-Type -AssemblyName System.Windows.Forms

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Step 1: Move to the current directory
Set-Location -Path (Get-Location)

# Step 2: Get the script's location
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Step 3: Get the current working directory
$currentDirectory = Get-Location

# Step 4: Check if the current directory matches the script's location
if ($currentDirectory.Path -ne $scriptPath) {
    Write-Host "Error: The script is not running from its own directory." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Script is running from the correct directory." -ForegroundColor Green
}

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

# Check if the "VAC" folder exists and contains subfolders
$vacContents = Get-ChildItem -Path $vacPath -Directory
if ($vacContents.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("The 'VAC' folder must contain at least one subfolder. Exiting script.", "Error", 'OK', 'Error')
    exit 1
}

# Check if any of the subfolders in "VAC" contain allowed gender folders
$allowedGenders = @("Male", "Female", "Any")
$foundValidFolder = $false

foreach ($subfolder in $vacContents) {
    $subfolderPath = $subfolder.FullName
    $subfolderContents = Get-ChildItem -Path $subfolderPath -Directory | Select-Object -ExpandProperty Name

    # Check if the subfolder contains at least one allowed gender folder
    $validGenderFolder = $subfolderContents | Where-Object { $_ -in $allowedGenders }
    
    if ($validGenderFolder.Count -gt 0) {
        $foundValidFolder = $true
        break
    }
}

# If no valid folder with gender folders was found, display an error and exit
if (-not $foundValidFolder) {
    [System.Windows.Forms.MessageBox]::Show("No subfolders in 'VAC' contain the required gender folders (Male, Female, Any). Exiting script.", "Error", 'OK', 'Error')
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

# Assign a function to detect unique filenames
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
# Get-ChildItem -Path $projectPath -Recurse -File -Filter "*.*" | ForEach-Object {
#    $originalFilePath = $_.FullName
#    $directory = $_.DirectoryName
#    $fileName = $_.BaseName
#    $fileExtension = $_.Extension
    
    # Sanitize the filename
#    $sanitizedFileName = Sanitize-Name -name $fileName
    
    # Generate a unique filename if necessary
#    $newFilePath = Get-UniqueFileName -basePath $directory -fileName $sanitizedFileName -extension $fileExtension
    
#    if ($originalFilePath -ne $newFilePath) {
#        Rename-Item -Path $originalFilePath -NewName (Split-Path -Leaf $newFilePath) -Force
#    }
#}

# Rename folders with spaces
#Get-ChildItem -Path $projectPath -Recurse -Directory | ForEach-Object {
#    $originalFolderPath = $_.FullName
#    $parentFolder = $_.Parent.FullName
#    $folderName = $_.Name
    
    # Sanitize the folder name
#    $sanitizedFolderName = Sanitize-Name -name $folderName
    
    # Create the new folder path
#    $newFolderPath = Join-Path -Path $parentFolder -ChildPath $sanitizedFolderName
    
#   if ($originalFolderPath -ne $newFolderPath) {
#      Rename-Item -Path $originalFolderPath -NewName (Split-Path -Leaf $newFolderPath) -Force
#    }
#}

# If all checks pass, output success message
Write-Output "Folder structure is correct" #, and files and folders have been renamed."
