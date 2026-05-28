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
| Delphi 13 Florence | 370 | - |

Delphi 13 Florence (370) is the active development version.

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
2. **Trysil.SQLite** / **Trysil.SqlServer** / **Trysil.PostgreSQL** / **Trysil.FirebirdSQL** -- database drivers
3. **Trysil.JSon** -- JSON serialization
4. **Trysil.Http** -- HTTP REST server

### From the Command Line

Run the batch file for your target version from the `Packages/` directory:

```batch
Packages\Build370.bat
```

Each batch file loads `rsvars.bat` from the matching Embarcadero Studio installation, then calls MSBuild for all packages across Win32/Win64 and Debug/Release configurations.

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

## SQL Server Note

`Trysil.SqlServer` requires the **Enterprise** edition of Delphi. All other packages (core, SQLite, PostgreSQL, Firebird, JSON, HTTP) work with the **Community** edition.

## Expert Installation (Optional)

Trysil includes an optional IDE Expert that integrates with the Delphi IDE.

1. Build the expert package for your Delphi version:

    ```
    Packages/<version>/Trysil.Expert<version>.dproj
    ```

2. Register the expert by adding the appropriate registry key under your Delphi installation's `Experts` registry path.
