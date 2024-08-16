# Scripting Tools for Voice-Acted Colonists

This is a set of tools modders can use to help them build new voicepacks for the [<b>Voice-Acted Colonists</b>](https://steamcommunity.com/sharedfiles/filedetails/?id=3306119571) Rimworld mod

Two tools are included:


**Def Generator** - Rimworld mods require special Definition files. These tell the game what the mod changes. This tool automatically generates all of  the Def files your voicepack needs to run

**Renamer** - When working with voice lines, you will often have folders filled with hundreds of unlabeled audio files. It can be very tedious to listen to each one before sorting them into the approriate folder. This tool uses OpenAI Whisper to transcribe an entire folder and subfolders full of audio files, then rename each file to the voice line itself. So if a file named "xyz123.ogg" contains the line "They'll never see us coming!", this tool will rename that file to "They'll_never_see_us_coming!.ogg". Now you can quickly look over your list of files and move them to the correct folder. At the same time, it will convert the files to .ogg format to reduce file size without losing quality. It will also normalize the volume so it isn't too loud or too soft.

<details>
<summary><h2>How to use the Renamer</h2></summary>

1. Download a specific version of Whisper: https://github.com/Purfview/whisper-standalone-win. Be aware that this download is over 1GB compressed, and almost 4GB when unzipped

2. Extract the downloaded Faster-Whisper-XXL

3. Place the contents of the "RenameAudio" folder in the folder which contains Faster-Whisper-XXL.exe

4. Copy your voice line audio files into the RenameThese folder

5. Make sure you close any audio players or anything that might be using these files

6. Run "RenameAudio.bat"

All audio files in the RenameThese folder and any subfolders will be renamed and converted

Audio files that are shorter than one or two seconds, as well as some files that only contain grunts but no actual words, will be renamed with a number (1.ogg, 2.ogg, etc)

If you have an Nvidia GPU, Whisper will use it to process your files very quickly. If you have an AMD GPU, your CPU will be used instead. With my CPU (i9 12900K), this will process about 70 voice lines per minute.
</details>

<details>
<summary><h2>How to use the Def Generator</h2></summary>

1. Extract the GenerateDefs folder

2. Your file structure MUST be the same as this voicepack

3. Sounds/VAC/YourProjectName is the project folder. Name your project folder whatever you like.

4. Put your voices in the Male and Female folders

5. Put your sound files in Attack, Select, Move, Downed, and Death folders

6. Double click "GenerateDefs.bat". This automatically generates all of the SoundDefs and VoicePackDefs for your mod.

7. Make sure you delete the .bat and .ps1 files before uploading your voicepack to Steam

Here's how it works (and doesn't work):
-
It scans for all sound files in the Sounds/VAC/Project/Gender/Voice/Action folders. It adds appropriate defs for each of these into the SoundDef and VoicePackDef for that voice. If a folder exists that is empty, it does not add a def.

Currently only .ogg files are supported, only Male and Female genders are supported, and only Attack, Select, Move, Downed, and Death actions are supported. All of these can be expanded easily at a later date.

These scripts have been verified to work fine with this voicepack and with the DirtyBomb voicepack, but have not been tested with any other voicepack. As long as your file types and folder structure match, it should work fine. If you have any issues, you can bring it up on this repo, in discord, or you can fork this and modify to suit your needs.
