---
title: Installation
---

# Installation

## Supported Delphi Versions

| Delphi Version | Code | Registry |
|---|---|---|
| Delphi 10.3 Rio | 260 | 20.0 |
| Delphi 10.4 Sydney | 270 | 21.0 |
| Delphi 11 Alexandria | 280 | 22.0 |
| Delphi 12 Athens | 290 | 23.0 |
| Delphi 13 Florence | 370 | 37.0 |

Delphi 13 Florence (370) is the active development version.

Trysil 2.0.0 was compiled on Delphi 11 and 13, and its test suite was run on
Delphi 13. The package sets for 10.3, 10.4 and 12 are kept aligned with the
other two, but were not compiled for this release. If one of them does not
build, please [open an issue](https://github.com/davidlastrucci/Trysil/issues).

## Clone the Repository

```bash
cd C:/
mkdir Trysil
cd Trysil
git init
git remote add trysil https://github.com/davidlastrucci/Trysil.git
git pull trysil master
```

## Build the Packages

### From the IDE

Open the group project for your Delphi version:

```
Packages/<version>/Trysil.groupproj
```

For example, for Delphi 13 Florence open `Packages/370/Trysil.groupproj`, then use **Build All**.

The group project builds all packages in the correct dependency order:

1. **Trysil** -- core ORM
2. **Trysil.SQLite** / **Trysil.SqlServer** / **Trysil.PostgreSQL** / **Trysil.FirebirdSQL** / **Trysil.InterBase** / **Trysil.MariaDB** / **Trysil.Oracle** -- database drivers (seven, and the build groups carry all of them)
3. **Trysil.JSon** -- JSON serialization
4. **Trysil.Http** -- HTTP REST server

### From the Command Line

Run the batch file for your target version from the `Packages/` directory:

```batch
Packages\Build370.bat
```

Each batch file loads `rsvars.bat` from the matching Embarcadero Studio installation, then calls MSBuild for all packages across Win32/Win64 and Debug/Release configurations.

!!! note "Win32 and Win64 are the release perimeter"
    Win32 and Win64 are the only platforms enabled in the packages, on all
    five Delphi versions. The project files for Delphi 12 and 13 used to carry
    a **Linux64** platform as well; from 2.0.0 it is disabled in every project
    and the build groups that referenced it are gone. It was never built by the
    batch files, never exercised by the test suite and never part of what a
    release is verified on.

Available batch files:

```
Packages\Build260.bat   :: Delphi 10.3 Rio
Packages\Build270.bat   :: Delphi 10.4 Sydney
Packages\Build280.bat   :: Delphi 11 Alexandria
Packages\Build290.bat   :: Delphi 12 Athens
Packages\Build370.bat   :: Delphi 13 Florence
```

### Build Output

Compiled output lands in:

```
Lib/<version>/$(Platform)/$(Config)/
```

This includes `.bpl` (runtime packages), `.dcp` (design-time packages), and `.dcu` (compiled units).

## Configure Your Environment

### Set the Environment Variable

Add a **user** environment variable so your projects can find the compiled Trysil units:

| Variable | Value |
|---|---|
| `Trysil` | `C:\Trysil\Lib\<version>` |

For example, for Delphi 13 Florence:

| Variable | Value |
|---|---|
| `Trysil` | `C:\Trysil\Lib\370` |

### Configure a New Project

In your Delphi project options, add the following to the **Search Path**:

```
$(Trysil)\$(Platform)\$(Config)
```

This resolves at build time to the correct platform (Win32/Win64) and configuration (Debug/Release) subdirectory.

## Edition Note

`Trysil.SqlServer` and `Trysil.Oracle` require the **Enterprise** (or Architect) edition of Delphi — their FireDAC driver units (`FireDAC.Phys.MSSQL`, `FireDAC.Phys.Oracle`) ship only with those editions. The other packages (core, SQLite, InterBase, PostgreSQL, MariaDB, Firebird, JSON, HTTP) build on the **Community** edition.

At runtime, FireDAC's edition matrix also applies: on Community/Professional, PostgreSQL, MySQL/MariaDB and Firebird connect to **localhost/embedded** only — connecting to a **remote** server requires Enterprise/Architect. See the [RAD Studio FireDAC page](https://www.embarcadero.com/products/rad-studio/firedac).

## Expert Installation (Optional)

Trysil includes an optional IDE Expert that integrates with the Delphi IDE.

1. Build the expert for your Delphi version, from the `Trysil.Expert` directory - it is a project of its own, not one of the packages:

    ```
    Trysil.Expert/Trysil.Expert<version>.dproj
    ```

    Build it for **Win32**: the IDE is a 32-bit process and loads 32-bit experts only.

2. Close Delphi, then add a string value under

    ```
    HKCU\SOFTWARE\Embarcadero\BDS\<registry>\Experts
    ```

    where `<registry>` is the registry column of the table above. Name it `Trysil` and set it to the full path of the DLL you have just built:

    ```
    Name:  Trysil
    Value: C:\Trysil\Trysil.Expert\Win32\Trysil.Expert370.dll
    ```

3. Restart Delphi. The splash screen names Trysil, and a **Trysil** entry appears in the main menu.

Once registered, the **Trysil** menu offers a visual entity designer, model and DDL generators, a REST API scaffolder, and an **Install AI assistant skills** command — see [AI Assistant Skills](../tooling/ai-skills.md).
