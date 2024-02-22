@ECHO OFF
CALL "c:/Program Files (x86)/Embarcadero/Studio/20.0/bin/rsvars.bat"

MSBuild ".\260\Trysil260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.FirebirdSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.FirebirdSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.FirebirdSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.FirebirdSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.PostgreSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.PostgreSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.PostgreSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.PostgreSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.SQLite260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.SQLite260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.SQLite260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.SQLite260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.SqlServer260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.SqlServer260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.SqlServer260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.SqlServer260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.JSon260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.JSon260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.JSon260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.JSon260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.Http260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.Http260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.Http260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.Http260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.Http.FirebirdSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.Http.FirebirdSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.Http.FirebirdSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.Http.FirebirdSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.Http.PostgreSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.Http.PostgreSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.Http.PostgreSQL260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.Http.PostgreSQL260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.Http.SQLite260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.Http.SQLite260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.Http.SQLite260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.Http.SQLite260.dproj" /t:Build /p:Config=Release /p:platform=Win64

MSBuild ".\260\Trysil.Http.SqlServer260.dproj" /t:Build /p:Config=Debug /p:platform=Win32
MSBuild ".\260\Trysil.Http.SqlServer260.dproj" /t:Build /p:Config=Release /p:platform=Win32
MSBuild ".\260\Trysil.Http.SqlServer260.dproj" /t:Build /p:Config=Debug /p:platform=Win64
MSBuild ".\260\Trysil.Http.SqlServer260.dproj" /t:Build /p:Config=Release /p:platform=Win64
