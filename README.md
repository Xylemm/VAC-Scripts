# VAC-Scripts
Voice-Acted Colonists (Scripts for Modders)

This is a tool modders can use to help them build new voicepacks for the Voice-Acted Colonists Rimworld mod

It includes my Icewind Dale voicepack to use as a template

How to use the voicepack:
-
1. Download the zip of this repo
2. Unzip into your local mods folder
3. Double click "GenerateDefs.bat". This generates all of the SoundDefs and VoicePackDefs you need to run my voicepack.
4. Activate Voice-Acted Colonists: Icewind Dale in your Rimworld game to try out the voicepack

How to use it with your own voicepack:
-
1. Your file structure MUST be the same as this voicepack. This is also the same structure as Alexis Popcorn's DirtyBomb voicepack.
2. Sounds/VAC/IcewindDale is the project folder. Name your project folder whatever you like.
3. Put your voices in the Male and Female folders
4. Put your sound files in Attack, Select, Move, Downed, and Death folders
5. Double click "GenerateDefs.bat". This automatically generates all of the SoundDefs and VoicePackDefs for your mod.

Here's how it works (and doesn't work):
-
It scans for all sound files in the Sounds/VAC/Project/Gender/Voice/Action folders. It adds appropriate defs for each of these into the SoundDef and VoicePackDef for that voice. If a folder exists that is empty, it does not add a def.

Currently only .ogg files are supported, only Male and Female genders are supported, and only Attack, Select, Move, Downed, and Death actions are supported. All of these can be expanded easily at a later date.

These scripts have been verified to work fine with this voicepack and with the DirtyBomb voicepack, but have not been tested with any other voicepack. As long as your file types and folder structure match, it should work fine. If you have any issues, you can bring it up on this repo, in discord, or you can fork this and modify to suit your needs.
