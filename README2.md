# Voice Line Renamer-Converter

When working with voice lines, you will often have folders filled with hundreds of unlabeled audio files. It can be very tedious to listen to each one before sorting them into the approriate folder.

This tool uses OpenAI Whisper to transcribe an entire folder and subfolders full of audio files, then rename each file to the voice line itself. So if a file named "gl330h41.ogg" contains the line "They'll never see us coming!", this tool will rename that file to "Theyll_never_see_us_coming!.ogg".

Now you can quickly look over your list of files and move them to the correct folder.

At the same time, it will convert the files to .ogg format to reduce file sizes without losing quality. It will also normalize the volume so it isn't too loud or too soft.

How to use it
-

First, you'll need to download a specific version of Whisper: https://github.com/Purfview/whisper-standalone-win

Be aware that this download is over 1GB compressed, and almost 4GB when unzipped

Extract the downloaded Faster-Whisper-XXL

Place the contents of the "Renamer" folder in the folder which contains Faster-Whisper-XXL.exe

Copy your voice line audio files into the RenameThese folder

Run "Renamer.bat"

This will rename and convert all audio files in the Transcribe folder and any subfolders within it

Audio files that are shorter than one or two seconds, as well as some files that only contain grunts but no actual words, will be renamed with a number (1.ogg, 2.ogg, etc)

If you have an Nvidia GPU, Whisper will use it to process your files very quickly. However, AMD GPUs are not supported. If you have an AMD GPU, your CPU will be used instead. With my CPU (i9 12900K), this will process about 10-15 voice lines per minute.
