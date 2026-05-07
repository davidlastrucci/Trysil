@ECHO OFF
IF "%~1"=="" GOTO :usage
IF "%~2"=="" GOTO :usage
IF "%~3"=="" GOTO :usage

SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"

SET STUDIO=%1
SET PKG=%2
SET PLATFORMS=%~3
SET FAILED=0
SET LOG=%TEMP%\trysil_expert_build.log

FOR /F %%a IN ('echo prompt $E ^| cmd') DO SET ESC=%%a

<nul SET /P=Trysil.Expert.Resources %PKG% ...
"C:\Program Files (x86)\Embarcadero\Studio\%STUDIO%\bin\brcc32.exe" -foTrysil.Expert.Resources.res Resources\Trysil.Expert.Resources.rc > "!LOG!" 2>&1
IF ERRORLEVEL 1 (
  ECHO !ESC![91m[FAIL]!ESC![0m
  TYPE "!LOG!"
  SET FAILED=1
  GOTO :done
) ELSE (
  ECHO !ESC![92m[OK]!ESC![0m
)

CALL "c:/Program Files (x86)/Embarcadero/Studio/%STUDIO%/bin/rsvars.bat" >nul

FOR %%X IN (%PLATFORMS%) DO (
  <nul SET /P=Trysil.Expert %PKG% Release %%X ...
  MSBuild ".\Trysil.Expert%PKG%.dproj" /t:Build /p:Config=Release /p:platform=%%X /v:quiet /nologo > "!LOG!" 2>&1
  IF ERRORLEVEL 1 (
    ECHO !ESC![91m[FAIL]!ESC![0m
    TYPE "!LOG!"
    SET FAILED=1
  ) ELSE (
    ECHO !ESC![92m[OK]!ESC![0m
  )
)

:done
IF !FAILED! EQU 0 (
  ECHO !ESC![92mBUILD SUCCESS!ESC![0m
  ENDLOCAL
  EXIT /B 0
)

ECHO !ESC![91mBUILD FAILED!ESC![0m
ENDLOCAL
EXIT /B 1

:usage
ECHO Usage  : MainBuild.bat ^<studio-ver^> ^<pkg-ver^> ^<platforms^>
ECHO Example: MainBuild.bat 37.0 370 "Win32 Win64"
EXIT /B 1
