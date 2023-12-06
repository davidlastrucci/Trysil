<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Dark.png">
    <img img width="300" height="107" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil_Light.png" alt="Trysil - Delphi ORM" title="Trysil - Delphi ORM">
  </picture>
</p>

> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

# Setup
### Git Bush
<pre>
$ cd C:/
$ mkdir Trysil
$ cd Trysil
$ git init
$ git remote add trysil https://github.com/davidlastrucci/Trysil.git
$ git pull trysil master
</pre>

### Build Lib
Open **Trysil.groupproj** in Packages\\[Version] directory and Build packages (Trysil, Trysil.JSon and Trysil.Http) in all configurations and platforms you need.<br><br>
The Lib\\[Version]\\\$(Platform)\\\$(Config) directory now contains all Bpl, Dcp and Dcu. 

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
---

Make With ❤ @davidlastrucci<br>
[https://www.lastrucci.net/](https://www.lastrucci.net)
