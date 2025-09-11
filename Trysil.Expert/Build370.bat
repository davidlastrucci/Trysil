@ECHO OFF
"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\brcc32.exe" -foTrysil.Expert.Resources.res Resources\Trysil.Expert.Resources.rc
CALL "c:/Program Files (x86)/Embarcadero/Studio/37.0/bin/rsvars.bat"
MSBuild ".\Trysil.Expert370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\Trysil.Expert370.dproj" /t:Build /p:Config=Release /p:platform=Win64
