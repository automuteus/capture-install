@echo off
del %APPDATA%\AmongUsCapture\AmongUsGUI\Settings.txt
type %APPDATA%\AmongUsCapture\AmongUsGUI\Settings.json | findstr /v discordToken > %APPDATA%\AmongUsCapture\AmongUsGUI\Settings.txt
del %APPDATA%\AmongUsCapture\AmongUsGUI\Settings.json
powershell -Command "Compress-Archive -Path %APPDATA%\AmongUsCapture -DestinationPath %userprofile%/desktop/Debug_Files"
del %APPDATA%\AmongUsCapture
explorer "aucapture://"
DEL "%~f0"