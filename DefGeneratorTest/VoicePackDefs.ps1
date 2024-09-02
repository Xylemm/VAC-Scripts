# Define the root directory based on the location of the script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = "$scriptPath"
Write-Output "Root directory: $root"

$projectPath = "$root/Sounds/VAC"
if (-not (Test-Path $projectPath)) {
    Write-Error "The path '$projectPath' does not exist. Please check your folder structure."
    exit 1
}

# Get the project directory
$project = Get-ChildItem $projectPath -Directory | Select-Object -First 1 | Select-Object -ExpandProperty Name
Write-Output "Project folder: $project"

$voicePackDefsDir = "$root/Defs/VoicePackDefs"

# Ensure the output directory exists
if (-not (Test-Path $voicePackDefsDir)) {
    New-Item -Path $voicePackDefsDir -ItemType Directory | Out-Null
}

# Iterate through Gender folders, including Male, Female, and Any
foreach ($gender in @("Male", "Female", "Any")) {
    $genderPath = "$projectPath/$project/$gender"
    Write-Output "Processing gender directory: $genderPath"
    
    if (Test-Path $genderPath) {
        # Iterate through Voice folders
        foreach ($voice in Get-ChildItem $genderPath -Directory) {
            $voiceName = $voice.Name
            Write-Output "Processing voice folder: $voiceName"

            # Initialize XML content
            $xmlContent = @"
<Defs>
    <VAC.VoicePackDef>
        <defName>VoicePack_$voiceName</defName>
        <label>$voiceName</label>
        <description>description</description>
        <category>category1</category>
        <gender>$gender</gender>`n
"@

            # Check for each action folder and add corresponding list element if folder is not empty
            $actions = @{
                "selectList"  = "Select"
                "attackList"  = "Attack"
                "movingList"  = "Move"
                "deathList"   = "Death"
                "downList"    = "Downed"
                "downingList" = "DowningPawn"
                "hittingList" = "Hitting"
                "painList"    = "Pain"
            }

            foreach ($listName in $actions.Keys) {
                $actionName = $actions[$listName]
                $actionPath = "$genderPath/$voiceName/$actionName"

                if (Test-Path $actionPath) {
                    # Check if folder contains .ogg files
                    $hasOggFiles = (Get-ChildItem $actionPath -File -Filter "*.ogg").Count -gt 0

                    if ($hasOggFiles) {
                        $xmlContent += @"
        <$listName>
            <li>VACDB_${voiceName}_$actionName</li>
        </$listName>`n
"@
                    }
                }
            }

            # Close the XML content
            $xmlContent += @"
    </VAC.VoicePackDef>
</Defs>
"@

            # Define the XML file path
            $xmlFilePath = "$voicePackDefsDir/$voiceName.xml"
            
            # Output the XML content to the file
            $xmlContent | Out-File -FilePath $xmlFilePath -Encoding UTF8
        }
    } else {
        Write-Error "The path '$genderPath' does not exist."
    }
}
