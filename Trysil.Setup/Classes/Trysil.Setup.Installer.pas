(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Installer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,

  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Delphi,
  Trysil.Setup.Detector,
  Trysil.Setup.Release,
  Trysil.Setup.Folder,
  Trysil.Setup.IDESettings,
  Trysil.Setup.Installation,
  Trysil.Setup.Builder;

type

{ TTInstallOptions }

  TTInstallOptions = class
  strict private
    FDirectory: String;
    FExpert: Boolean;
    FVersions: TList<TTDelphiVersion>;
  public
    constructor Create(const ADirectory: String; const AExpert: Boolean);
    destructor Destroy; override;

    property Directory: String read FDirectory;
    property Expert: Boolean read FExpert;
    property Versions: TList<TTDelphiVersion> read FVersions;
  end;

{ TTInstaller }

  TTInstaller = class
  strict private
    FLog: TTSetupLog;
    FInstallation: TTInstallation;
    FDownloader: TTReleaseDownloader;

    procedure CleanDirectory(const ADirectory: String);
    procedure ExtractArchive(
      const AFileName: String; const ADirectory: String);
    procedure DownloadRelease(const ADirectory: String);
    function SourceSearchPath: TArray<String>;
    function InstallSources(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions;
      const ASettings: TTIDESettings): Boolean;
    procedure InstallExpert(
      const ABuilder: TTBuilder; const ASettings: TTIDESettings);
    function InstallPackages(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions;
      const ASettings: TTIDESettings): Boolean;
    function InstallVersion(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions): Boolean;
    function InstallVersions(const AOptions: TTInstallOptions): TArray<String>;
    procedure CopySetup(const ADirectory: String);
    procedure Deploy(const AOptions: TTInstallOptions);
    procedure DetectInstalled(const AVersions: TObjectList<TTDelphiVersion>);
    procedure UpdateVersions;
    procedure RemoveVersion(const AKey: String);
    procedure RemoveDirectory(const ADirectory: String);
  public
    constructor Create(
      const ALog: TTSetupLog; const AInstallation: TTInstallation);
    destructor Destroy; override;

    procedure Install(const AOptions: TTInstallOptions);
    procedure Update;
    procedure Uninstall;
  end;

implementation

{ TTInstallOptions }

constructor TTInstallOptions.Create(
  const ADirectory: String; const AExpert: Boolean);
begin
  inherited Create;
  FDirectory := ExcludeTrailingPathDelimiter(ADirectory);
  FExpert := AExpert;
  FVersions := TList<TTDelphiVersion>.Create;
end;

destructor TTInstallOptions.Destroy;
begin
  FVersions.Free;
  inherited Destroy;
end;

{ TTInstaller }

constructor TTInstaller.Create(
  const ALog: TTSetupLog; const AInstallation: TTInstallation);
begin
  inherited Create;
  FLog := ALog;
  FInstallation := AInstallation;
  FDownloader := TTReleaseDownloader.Create(ALog);
end;

destructor TTInstaller.Destroy;
begin
  FDownloader.Free;
  inherited Destroy;
end;

procedure TTInstaller.CleanDirectory(const ADirectory: String);
var
  LFolder: TTInstallFolder;
begin
  LFolder := TTInstallFolder.Create(ADirectory);
  try
    LFolder.Clean;
  finally
    LFolder.Free;
  end;
end;

procedure TTInstaller.ExtractArchive(
  const AFileName: String; const ADirectory: String);
var
  LArchive: TTReleaseArchive;
begin
  FLog.AddFormat(SExtracting, [ADirectory]);
  LArchive := TTReleaseArchive.Create(ADirectory);
  try
    LArchive.Extract(AFileName);
  finally
    LArchive.Free;
  end;
end;

procedure TTInstaller.DownloadRelease(const ADirectory: String);
var
  LFileName: String;
begin
  LFileName := TPath.Combine(
    TPath.GetTempPath, Format(SArchiveFileName, [FDownloader.Tag]));
  try
    FDownloader.Download(LFileName);
    CleanDirectory(ADirectory);
    ExtractArchive(LFileName, ADirectory);
  finally
    if TFile.Exists(LFileName) then
      TFile.Delete(LFileName);
  end;
end;

function TTInstaller.SourceSearchPath: TArray<String>;
var
  LFolder: String;
begin
  result := [];
  for LFolder in SourceFolders do
    result := result + [Format(SSourceSearchPath, [LFolder])];
end;

function TTInstaller.InstallSources(
  const AVersion: TTDelphiVersion;
  const AOptions: TTInstallOptions;
  const ASettings: TTIDESettings): Boolean;
begin
  ASettings.SetVariable(AOptions.Directory);
  ASettings.SetSearchPath(AVersion.Platforms, SourceSearchPath);
  result := True;
end;

procedure TTInstaller.InstallExpert(
  const ABuilder: TTBuilder; const ASettings: TTIDESettings);
var
  LPlatform: String;
begin
  if ABuilder.BuildExpert then
  begin
    for LPlatform in ABuilder.ExpertPlatforms do
      ASettings.SetExpert(LPlatform, ABuilder.ExpertLibrary(LPlatform));
  end
  else
    FLog.Add(SExpertFailed);
end;

function TTInstaller.InstallPackages(
  const AVersion: TTDelphiVersion;
  const AOptions: TTInstallOptions;
  const ASettings: TTIDESettings): Boolean;
var
  LBuilder: TTBuilder;
begin
  LBuilder := TTBuilder.Create(AVersion, AOptions.Directory, FLog);
  try
    result := LBuilder.BuildPackages;
    if result then
    begin
      ASettings.SetVariable(LBuilder.LibraryDirectory);
      ASettings.SetSearchPath(AVersion.Platforms, [SPackagesSearchPath]);
      if AOptions.Expert then
        InstallExpert(LBuilder, ASettings);
    end;
  finally
    LBuilder.Free;
  end;
end;

function TTInstaller.InstallVersion(
  const AVersion: TTDelphiVersion;
  const AOptions: TTInstallOptions): Boolean;
var
  LSettings: TTIDESettings;
begin
  FLog.AddFormat(SInstallingVersion, [AVersion.Name]);
  LSettings := TTIDESettings.Create(AVersion.Key, AVersion.HasIDE64);
  try
    LSettings.Clear;
    if AVersion.CanBuild then
      result := InstallPackages(AVersion, AOptions, LSettings)
    else
      result := InstallSources(AVersion, AOptions, LSettings);
  finally
    LSettings.Free;
  end;
end;

function TTInstaller.InstallVersions(
  const AOptions: TTInstallOptions): TArray<String>;
var
  LVersion: TTDelphiVersion;
begin
  result := [];
  for LVersion in AOptions.Versions do
    if InstallVersion(LVersion, AOptions) then
    begin
      result := result + [LVersion.Key];
      FLog.AddFormat(SVersionInstalled, [LVersion.Name]);
    end
    else
      FLog.AddFormat(SVersionFailed, [LVersion.Name]);
end;

procedure TTInstaller.CopySetup(const ADirectory: String);
var
  LFileName: String;
begin
  LFileName := TPath.Combine(ADirectory, SSetupFileName);
  if not SameText(LFileName, ParamStr(0)) then
    TFile.Copy(ParamStr(0), LFileName, True);
end;

procedure TTInstaller.Deploy(const AOptions: TTInstallOptions);
var
  LVersions: TArray<String>;
begin
  DownloadRelease(AOptions.Directory);
  LVersions := InstallVersions(AOptions);
  CopySetup(AOptions.Directory);
  FInstallation.Save(
    AOptions.Directory, FDownloader.Version, LVersions, AOptions.Expert);
  FLog.AddFormat(SCompleted, [FDownloader.Version, Length(LVersions)]);
end;

procedure TTInstaller.Install(const AOptions: TTInstallOptions);
begin
  FDownloader.FetchLatest;
  Deploy(AOptions);
end;

procedure TTInstaller.DetectInstalled(
  const AVersions: TObjectList<TTDelphiVersion>);
var
  LDetector: TTDelphiDetector;
begin
  LDetector := TTDelphiDetector.Create(FLog);
  try
    LDetector.DetectKeys(FInstallation.Versions, AVersions);
  finally
    LDetector.Free;
  end;
end;

procedure TTInstaller.UpdateVersions;
var
  LVersions: TObjectList<TTDelphiVersion>;
  LOptions: TTInstallOptions;
begin
  LVersions := TObjectList<TTDelphiVersion>.Create;
  try
    DetectInstalled(LVersions);
    LOptions := TTInstallOptions.Create(
      FInstallation.Directory, FInstallation.Expert);
    try
      LOptions.Versions.AddRange(LVersions);
      Deploy(LOptions);
    finally
      LOptions.Free;
    end;
  finally
    LVersions.Free;
  end;
end;

procedure TTInstaller.Update;
begin
  FDownloader.FetchLatest;
  if SameText(FDownloader.Version, FInstallation.Version) then
    FLog.AddFormat(SUpToDate, [FInstallation.Version])
  else
    UpdateVersions;
end;

procedure TTInstaller.RemoveVersion(const AKey: String);
var
  LSettings: TTIDESettings;
begin
  FLog.AddFormat(SRemovingVersion, [AKey]);
  LSettings := TTIDESettings.Create(AKey, True);
  try
    LSettings.Clear;
  finally
    LSettings.Free;
  end;
end;

procedure TTInstaller.RemoveDirectory(const ADirectory: String);
var
  LFolder: TTInstallFolder;
begin
  FLog.AddFormat(SRemovingFolder, [ADirectory]);
  LFolder := TTInstallFolder.Create(ADirectory);
  try
    LFolder.Remove;
  finally
    LFolder.Free;
  end;
end;

procedure TTInstaller.Uninstall;
var
  LKey: String;
begin
  for LKey in FInstallation.Versions do
    RemoveVersion(LKey);
  RemoveDirectory(FInstallation.Directory);
  FInstallation.Delete;
  FLog.Add(SUninstalled);
end;

end.
