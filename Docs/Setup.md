# Setup
### Git Bash
<pre>
$ cd C:/
$ git clone https://github.com/davidlastrucci/Trysil.git
$ cd Trysil
</pre>

### Build Lib
Open **Trysil.groupproj** in Packages\\[Version] directory and Build All to compile every package (Trysil, the database drivers, Trysil.JSon, Trysil.Http) in the configurations and platforms you need.<br><br>
Alternatively, run **Build[Version].bat** in the Packages directory from a command prompt &mdash; it builds Win32 and Win64 in Debug and Release. To target other platforms, edit the file (one line) and pass them as the third argument, e.g. **"Win32 Win64 Linux64"**.<br><br>
The Lib\\[Version]\\\$(Platform)\\\$(Config) directory now contains all Bpl, Dcp and Dcu.

### Edition Compatibility
Not every package builds on every Delphi edition &mdash; FireDAC drivers are gated by license:<br><br>

|Driver|Community|Professional|Enterprise|Architect|
|-|-|-|-|-|
|Trysil.SQLite|✓|✓|✓|✓|
|Trysil.PostgreSQL|✓ (localhost only)|✓ (localhost only)|✓|✓|
|Trysil.FirebirdSQL|✓ (localhost / embedded)|✓ (localhost / embedded)|✓|✓|
|Trysil.SqlServer|✗|✗|✓|✓|

On Community and Professional, **Trysil.SqlServer** fails to compile because the FireDAC SQL Server units ship only with Enterprise and Architect. The build continues regardless and every other driver still produces its output.

### Environment Variables
In Tools->Options->Environment Variables add a new User Variable:<br><br>
Variable name: **Trysil**<br>
Variable value: **C:\Trysil\Lib\\[Version]**

### Expert
Open **Trysil.Expert[Version].dproj** in Trysil.Expert directory, build the project and close Delphi.<br><br>
Run Regedit and go to HKCU\SOFTWARE\Embarcadero\BDS\\[Registry Version]\Expert. Add a new string value:<br><br>
Name: **Trysil**<br>
Value: **C:\Trysil\Trysil.Expert\Win32\Trysil.Expert[Version].dll**<br><br>
Restart Delphi. In the splash screen you can see Trysil and in the main menu there is now Trysil item.

### New Delphi Project
Create a new Delphi Project and in Project->Options->Building->Delphi Compiler select All configurations - All Platforms and in Search Path write **\$(Trysil)\\\$(Platform)\\\$(Config)**.

**Use Trysil and enjoy**

### Versions
|Delphi version|Version|Registry Version|
|-|-|-|
|Delphi 10.3 Rio|260|20.0|
|Delphi 10.4 Sydney|270|21.0|
|Delphi 11 Alexandria|280|22.0|
|Delphi 12 Athens|290|23.0|
|Delphi 13 Florence|370|37.0|
