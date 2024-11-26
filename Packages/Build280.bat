@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/22.0/bin/rsvars.bat"

MSBuild ".\280\Trysil280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil280.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\280\Trysil.FirebirdSQL280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil.FirebirdSQL280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil.FirebirdSQL280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil.FirebirdSQL280.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\280\Trysil.PostgreSQL280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil.PostgreSQL280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil.PostgreSQL280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil.PostgreSQL280.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\280\Trysil.SQLite280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil.SQLite280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil.SQLite280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil.SQLite280.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\280\Trysil.SqlServer280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil.SqlServer280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil.SqlServer280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil.SqlServer280.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\280\Trysil.JSon280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil.JSon280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil.JSon280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil.JSon280.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\280\Trysil.Http280.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\280\Trysil.Http280.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\280\Trysil.Http280.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\280\Trysil.Http280.dproj" /t:Build /p:Config=Release /p:platform=Win64
