@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/23.0/bin/rsvars.bat"

MSBuild ".\290\Trysil290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil290.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\290\Trysil.FirebirdSQL290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil.FirebirdSQL290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil.FirebirdSQL290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil.FirebirdSQL290.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\290\Trysil.PostgreSQL290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil.PostgreSQL290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil.PostgreSQL290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil.PostgreSQL290.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\290\Trysil.SQLite290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil.SQLite290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil.SQLite290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil.SQLite290.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\290\Trysil.SqlServer290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil.SqlServer290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil.SqlServer290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil.SqlServer290.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\290\Trysil.JSon290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil.JSon290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil.JSon290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil.JSon290.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\290\Trysil.Http290.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\290\Trysil.Http290.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\290\Trysil.Http290.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\290\Trysil.Http290.dproj" /t:Build /p:Config=Release /p:platform=Win64
