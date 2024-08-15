# Define paths
$soundsPath = "$PSScriptRoot/Sounds/VAC"
$outputPath = "$PSScriptRoot/Defs/SoundDefs"

# Ensure output directory exists
if (-not (Test-Path -Path $outputPath)) {
    New-Item -Path $outputPath -ItemType Directory -Force
}

# Function to sanitize file names
function Sanitize-FileName {
    param (
        [string]$fileName
    )
    # Replace spaces with underscores and remove punctuation
    $sanitized = $fileName -replace '[\s]', '_' -replace '[^\w_]', ''
    # Truncate file name to 30 characters
    if ($sanitized.Length -gt 30) {
        $sanitized = $sanitized.Substring(0, 30)
    }
    return $sanitized
}

# Process each project directory (e.g., IcewindDale)
foreach ($project in Get-ChildItem -Path $soundsPath -Directory) {
    $projectPath = $project.FullName

    # Process each gender directory (e.g., Female, Male)
    foreach ($gender in Get-ChildItem -Path $projectPath -Directory) {
        $genderPath = $gender.FullName

        # Process each voice directory (e.g., Aggressive, Calm)
        foreach ($voice in Get-ChildItem -Path $genderPath -Directory) {
            $voicePath = $voice.FullName
            $voiceName = $voice.Name

            # Sanitize file names in the action directories
            foreach ($action in @("Attack", "Select", "Move", "Death", "Downed")) {
                $actionPath = Join-Path -Path $voicePath -ChildPath $action

                if (Test-Path -Path $actionPath) {
                    $oggFiles = Get-ChildItem -Path $actionPath -Filter *.ogg

                    foreach ($file in $oggFiles) {
                        $sanitizedName = Sanitize-FileName -fileName $file.BaseName
                        $sanitizedFilePath = Join-Path -Path $actionPath -ChildPath "$sanitizedName.ogg"
                        Rename-Item -Path $file.FullName -NewName $sanitizedFilePath -Force
                    }
                }
            }

            # Initialize the XML content
            $xmlContent = @("<Defs>")

            # Define the actions
            $actions = @("Attack", "Select", "Move", "Death", "Downed")

            foreach ($action in $actions) {
                $actionPath = Join-Path -Path $voicePath -ChildPath $action

                if (Test-Path -Path $actionPath) {
                    # Get .ogg files in the action path
                    $oggFiles = Get-ChildItem -Path $actionPath -Filter *.ogg

                    if ($oggFiles.Count -gt 0) {
                        # Add SoundDef start tag
                        $xmlContent += @"
    <SoundDef>
        <defName>VACDB_$($voiceName)_$($action)</defName>
        <context>MapOnly</context>
        <maxSimultaneous>1</maxSimultaneous>
        <subSounds>
            <li>
                <grains>
"@
                        
                        # Add each .ogg file as a grain, removing the .ogg extension
                        foreach ($file in $oggFiles) {
                            $clipPath = "VAC/$($project.Name)/$($gender.Name)/$($voice.Name)/$($action)/$($file.BaseName)"
                            $xmlContent += @"
                    <li Class="AudioGrain_Clip">
                        <clipPath>$clipPath</clipPath>
                    </li>
"@
                        }

                        # Close the grains and SoundDef elements
                        $xmlContent += @"
                </grains>
                <volumeRange>42</volumeRange>
                <distRange>20~50</distRange>
            </li>
        </subSounds>
    </SoundDef>
"@
                    }
                }
            }

            # Close the Defs element
            $xmlContent += "</Defs>"

            # Write to the output XML file
            $outputFile = Join-Path -Path $outputPath -ChildPath "$voiceName.xml"
            $xmlContent -join "`r`n" | Out-File -FilePath $outputFile -Encoding UTF8
        }
    }
}
