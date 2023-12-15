@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/21.0/bin/rsvars.bat"

MSBuild ".\270\Trysil270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil270.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\270\Trysil.FirebirdSQL270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil.FirebirdSQL270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil.FirebirdSQL270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil.FirebirdSQL270.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\270\Trysil.PostgreSQL270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil.PostgreSQL270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil.PostgreSQL270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil.PostgreSQL270.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\270\Trysil.SQLite270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil.SQLite270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil.SQLite270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil.SQLite270.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\270\Trysil.SqlServer270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil.SqlServer270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil.SqlServer270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil.SqlServer270.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\270\Trysil.JSon270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil.JSon270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil.JSon270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil.JSon270.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\270\Trysil.Http270.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\270\Trysil.Http270.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\270\Trysil.Http270.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\270\Trysil.Http270.dproj" /t:Build /p:Config=Release /p:platform=Win64
