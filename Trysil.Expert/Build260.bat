@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/20.0/bin/rsvars.bat"
MSBuild ".\Trysil.Expert260.dproj" /t:Build /p:Config=Release /p:platform=Win32
