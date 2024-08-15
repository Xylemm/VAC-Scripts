# Scripts for Voice-Acted Colonists

This is a set of tools modders can use to help them build new voicepacks for the Voice-Acted Colonists Rimworld mod

### Voice Line Renamer-Converter

When working with voice lines, you will often have folders filled with hundreds of unlabeled audio files. It can be very tedious to listen to each one before sorting them into the approriate folder.

This tool uses OpenAI Whisper to transcribe an entire folder and subfolders full of audio files, then rename each file to the voice line itself. So if a file named "gl330h41.ogg" contains the line "They'll never see us coming!", this tool will rename that file to "Theyll_never_see_us_coming!.ogg".

Now you can quickly look over your list of files and move them to the correct folder.

At the same time, it will convert the files to .ogg format to reduce file sizes without losing quality. It will also normalize the volume so it isn't too loud or too soft.

<details>
<summary><h2>How to use the Renamer</h2></summary>
 -
First, you'll need to download a specific version of Whisper: https://github.com/Purfview/whisper-standalone-win

Be aware that this download is over 1GB compressed, and almost 4GB when unzipped

Extract the downloaded Faster-Whisper-XXL

Place the contents of the "RenameAudio" folder in the folder which contains Faster-Whisper-XXL.exe

Copy your voice line audio files into the RenameThese folder

Make sure you close any audio players or anything that might be using these files

Run "RenameAudio.bat"

This will rename and convert all audio files in the Transcribe folder and any subfolders within it

Audio files that are shorter than one or two seconds, as well as some files that only contain grunts but no actual words, will be renamed with a number (1.ogg, 2.ogg, etc)

If you have an Nvidia GPU, Whisper will use it to process your files very quickly. However, AMD GPUs are not supported. If you have an AMD GPU, your CPU will be used instead. With my CPU (i9 12900K), this will process about 70 voice lines per minute.
</details>


How to use this with your voicepack:
-
1. Your file structure MUST be the same as this voicepack. This is also the same structure as the DirtyBomb voicepack.
2. Sounds/VAC/Project is the project folder. Name your project folder whatever you like.
3. Put your voices in the Male and Female folders
4. Put your sound files in Attack, Select, Move, Downed, and Death folders
5. Double click "GenerateDefs.bat". This automatically generates all of the SoundDefs and VoicePackDefs for your mod.
6. Make sure you delete the .bat and .ps1 files before uploading your voicepack to Steam

Here's how it works (and doesn't work):
-
It scans for all sound files in the Sounds/VAC/Project/Gender/Voice/Action folders. It adds appropriate defs for each of these into the SoundDef and VoicePackDef for that voice. If a folder exists that is empty, it does not add a def.

Currently only .ogg files are supported, only Male and Female genders are supported, and only Attack, Select, Move, Downed, and Death actions are supported. All of these can be expanded easily at a later date.

These scripts have been verified to work fine with this voicepack and with the DirtyBomb voicepack, but have not been tested with any other voicepack. As long as your file types and folder structure match, it should work fine. If you have any issues, you can bring it up on this repo, in discord, or you can fork this and modify to suit your needs.
