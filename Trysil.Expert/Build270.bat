@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/21.0/bin/rsvars.bat"
MSBuild ".\Trysil.Expert270.dproj" /t:Build /p:Config=Release /p:platform=Win32
