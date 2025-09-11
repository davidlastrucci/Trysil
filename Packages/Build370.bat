@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/37.0/bin/rsvars.bat"

MSBuild ".\370\Trysil370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil370.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\370\Trysil.FirebirdSQL370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil.FirebirdSQL370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil.FirebirdSQL370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil.FirebirdSQL370.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\370\Trysil.PostgreSQL370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil.PostgreSQL370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil.PostgreSQL370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil.PostgreSQL370.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\370\Trysil.SQLite370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil.SQLite370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil.SQLite370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil.SQLite370.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\370\Trysil.SqlServer370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil.SqlServer370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil.SqlServer370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil.SqlServer370.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\370\Trysil.JSon370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil.JSon370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil.JSon370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil.JSon370.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\370\Trysil.Http370.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\370\Trysil.Http370.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\370\Trysil.Http370.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\370\Trysil.Http370.dproj" /t:Build /p:Config=Release /p:platform=Win64
