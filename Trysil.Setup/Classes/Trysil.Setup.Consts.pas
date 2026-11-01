(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Consts;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ ETSetupException }

  ETSetupException = class(Exception);

const
  SReleaseUrl =
    'https://api.github.com/repos/davidlastrucci/Trysil/releases/latest';
  SArchiveUrl =
    'https://github.com/davidlastrucci/Trysil/archive/refs/tags/%s.zip';
  SMasterArchiveUrl =
    'https://github.com/davidlastrucci/Trysil/archive/refs/heads/master.zip';
  SMasterBranch = 'master';
  SProjectUrl = 'https://github.com/davidlastrucci/Trysil';
  SMeasureText = 'X';
  SUserAgent = 'Trysil.Setup';
  STagName = 'tag_name';
  SArchiveFileName = 'Trysil-%s.zip';

  SMachineKey = 'Software\Embarcadero\BDS\%s';
  SUserKey = 'Software\Embarcadero\BDS\%s\%s';
  SRootDirValue = 'RootDir';
  SApp64Value = 'App x64';
  SEnvironmentKey = 'Environment Variables';
  SEnvironment64Key = 'Environment Variables x64';
  SExpertsKey = 'Experts';
  SExperts64Key = 'Experts x64';
  SLibraryKey = 'Library\%s';
  SSearchPathValue = 'Search Path';
  STrysilName = 'Trysil';
  STrysilReference = '$(Trysil)';
  SSearchPathSeparator = ';';

  SUninstallKey =
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\Trysil';
  SDisplayNameValue = 'DisplayName';
  SDisplayVersionValue = 'DisplayVersion';
  SPublisherValue = 'Publisher';
  SUrlInfoAboutValue = 'URLInfoAbout';
  SInstallLocationValue = 'InstallLocation';
  SDisplayIconValue = 'DisplayIcon';
  SUninstallStringValue = 'UninstallString';
  SNoModifyValue = 'NoModify';
  SNoRepairValue = 'NoRepair';
  SVersionsValue = 'DelphiVersions';
  SExpertValue = 'Expert';
  SDisplayName = 'Trysil - Delphi ORM';
  SPublisher = 'David Lastrucci';
  SUninstallCommand = '"%s" /%s';

  SAppDataVariable = 'APPDATA';
  SLocalAppDataVariable = 'LOCALAPPDATA';
  SComSpecVariable = 'ComSpec';
  SDefaultFolder = 'Programs\Trysil';
  SRsvars = 'bin\rsvars.bat';
  SEnvOptions = 'Embarcadero\BDS\%s\EnvOptions.proj';
  SPlatformCondition = '''$(Platform)''==''%s''';
  SLibraryPathElement = '<DelphiLibraryPath>';
  SSystemUnit = 'lib\%s\release\System.dcu';
  SDriverUnit = 'lib\%s\release\%s';
  SMSBuildCommand =
    '%s /S /C ""%s" >nul && msbuild "%s" /t:Build /p:Config=%s ' +
    '/p:Platform=%s /nr:false /v:minimal /nologo"';

  SProbeDirectory = 'Trysil.Setup.Probe.%s';
  SProbeDprResource = 'PROBE_DPR';
  SProbeDprojResource = 'PROBE_DPROJ';
  SProbeDpr = 'Probe.dpr';
  SProbeDproj = 'Probe.dproj';

  SPackageProject = 'Packages\%s\%s.dproj';
  SPackagesLibrary = 'Lib\%s';
  SPackagesSearchPath = '$(Trysil)\$(Platform)\Release';
  SSourceSearchPath = '$(Trysil)\%s';
  SExpertProject = 'Trysil.Expert\Trysil.Expert%s.dproj';
  SExpertLibrary = 'Trysil.Expert\%s\Trysil.Expert%s.dll';
  SSqlServerPackage = 'Trysil.SqlServer';
  SOraclePackage = 'Trysil.Oracle';
  SMSSQLUnit = 'FireDAC.Phys.MSSQL.dcu';
  SOracleUnit = 'FireDAC.Phys.Oracle.dcu';

  SWin32 = 'Win32';
  SWin64 = 'Win64';
  SDebug = 'Debug';
  SRelease = 'Release';

  SLogFileName = 'Setup.log';
  SSetupFileName = 'Trysil.Setup.exe';
  STemporarySetupFileName = 'Trysil.Setup.%s.exe';
  SUninstallSwitch = 'uninstall';
  SIDEProcess = 'bds.exe';

  Packages: array[0..10] of String = (
    'Trysil',
    'Trysil.FirebirdSQL',
    'Trysil.InterBase',
    'Trysil.PostgreSQL',
    'Trysil.SQLite',
    'Trysil.SqlServer',
    'Trysil.MariaDB',
    'Trysil.Oracle',
    'Trysil.JSon',
    'Trysil.Http',
    'Trysil.OpenAPI');

  SourceFolders: array[0..9] of String = (
    'Trysil',
    'Trysil\Data',
    'Trysil\Data\FireDAC',
    'Trysil\Data\SqlSyntax',
    'Trysil.JSon',
    'Trysil.Http',
    'Trysil.Http\Authentication',
    'Trysil.Http\Log',
    'Trysil.Http\MultiTenant',
    'Trysil.OpenAPI');

  Platforms: array[0..1] of String = (SWin32, SWin64);

  Configurations: array[0..1] of String = (SDebug, SRelease);

resourcestring
  SNotInstalled = '%s: not installed.';
  SRsvarsNotFound = '%s: rsvars.bat not found, skipped.';
  SEnvOptionsNotFound = '%s: EnvOptions.proj not found, skipped.';
  SNoPlatform = '%s: no platform ready, skipped.';
  SProbing = '%s: checking the command line build...';
  SProbeSucceeded = '%s: command line build available, packages.';
  SProbeFailed = '%s: command line build not available, sources.';
  SPackagesPath = 'packages';
  SSourcesPath = 'sources';
  SVersionDescription = '%s (%s, %s)';

  SHttpError = 'HTTP error %d downloading %s.';
  SReleaseNotFound = 'Latest release of Trysil not found.';
  SLatestRelease = 'Latest release: Trysil %s.';
  SMasterVersion = 'Development version: Trysil %s.';
  SDownloading = 'Downloading Trysil %s...';
  SExtracting = 'Extracting into %s...';
  SInvalidArchiveEntry = 'Invalid entry %s in the archive.';
  SProcessFailed = 'Cannot start the build: %s';
  SFolderNotOwned = 'Folder %s is not empty and was not created by setup.';
  SInstallingVersion = 'Installing in %s...';
  SBuilding = 'Building %s %s %s...';
  SBuildFailed = 'Build of %s %s %s failed.';
  SPackageSkipped = '%s skipped on %s: FireDAC driver not available.';
  SExpertFailed = 'Build of Trysil Expert failed, not registered.';
  SVersionInstalled = '%s: done.';
  SVersionFailed = '%s: failed.';
  SCompleted = 'Trysil %s installed in %d Delphi version(s).';
  SNothingInstalled = 'Trysil %s was not installed in any Delphi version.';
  SUpToDate = 'Trysil %s is already up to date.';
  SRemovingVersion = 'Removing Trysil from the settings of BDS %s...';
  SRemovingFolder = 'Removing %s...';
  SUninstalled = 'Trysil uninstalled.';
  SError = 'Error: %s';

  SCloseIDE = 'Close Delphi before running Trysil Setup.';
  SNotInstalledInfo = 'Trysil is not installed';
  SInstalledInfo = 'Trysil is installed';
  SFolderEmpty = 'Folder cannot be empty.';
  SFolderNotAbsolute = 'Folder must be an absolute path.';
  SFolderNotEmpty = 'Folder is not empty and was not created by setup.';
  SNoDelphiVersion = 'No Delphi version ready for Trysil was found.';
  SSelectVersion = 'Select at least one Delphi version.';
  SInstallDescription =
    'Download Trysil from GitHub and set it up in your Delphi versions.';
  SAlreadyInstalledDescription = 'Trysil is already installed.';
  SUpdateDescription =
    'Replace the installed version with the latest release.';
  SUninstallDescription =
    'Remove Trysil from this computer and from the Delphi settings.';
  SNotInstalledDescription = 'Available when Trysil is installed.';
  SPackagesChip = 'Packages';
  SSourcesChip = 'Sources';

  SInstallTitle = 'Ready to install';
  SUpdateTitle = 'Ready to update';
  SUninstallTitle = 'Ready to uninstall';
  SInstallSubtitle =
    'Trysil will be downloaded from GitHub and installed with these settings.';
  SUpdateSubtitle = 'Trysil will be updated with these settings.';
  SUninstallSubtitle =
    'Trysil will be removed from this computer and from the Delphi settings.';
  SVersionKey = 'Version';
  SInstalledKey = 'Installed';
  SFolderKey = 'Folder';
  SVersionsKey = 'Delphi versions';
  SExpertKey = 'Trysil Expert';
  SLatestReleaseValue = 'Latest release';
  SMasterValue = 'Development version (master)';
  SInstalledValue = 'Trysil %s';
  SYesValue = 'Yes';
  SNoValue = 'No';

  SInstallingTitle = 'Installing Trysil';
  SUpdatingTitle = 'Updating Trysil';
  SUninstallingTitle = 'Uninstalling Trysil';
  SCompletedTitle = 'Trysil Setup completed';
  SCompletedWithErrorsTitle = 'Trysil Setup completed with errors';
  SFailedTitle = 'Trysil Setup failed';

  SNextCaption = '&Next';
  SInstallCaption = '&Install';
  SUpdateCaption = '&Update';
  SUninstallCaption = '&Uninstall';
  SShowLogCaption = '&Show log';
  SHideLogCaption = '&Hide log';
  SCloseCaption = '&Close';

implementation

end.
