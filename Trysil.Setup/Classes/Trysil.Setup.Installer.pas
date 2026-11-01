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
  Trysil.Setup.Progress,
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
    FBuildDirectory: String;
    FExpert: Boolean;
    FVersions: TList<TTDelphiVersion>;
  public
    constructor Create(const ADirectory: String; const AExpert: Boolean);
    destructor Destroy; override;

    procedure Stage;
    function IsStaged: Boolean;

    property Directory: String read FDirectory;
    property BuildDirectory: String read FBuildDirectory;
    property Expert: Boolean read FExpert;
    property Versions: TList<TTDelphiVersion> read FVersions;
  end;

{ TTInstaller }

  TTInstaller = class
  strict private
    FLog: TTSetupLog;
    FProgress: TTSetupProgress;
    FInstallation: TTInstallation;
    FDownloader: TTReleaseDownloader;
    FHasErrors: Boolean;

    procedure CleanDirectory(const ADirectory: String);
    procedure ExtractArchive(
      const AFileName: String; const ADirectory: String);
    procedure DownloadRelease(const ADirectory: String);
    function CreateBuilder(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions): TTBuilder;
    function VersionSteps(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions): Integer;
    function VersionNames(const AOptions: TTInstallOptions): TArray<String>;
    procedure StartProgress(const AOptions: TTInstallOptions);
    function SourceSearchPath: TArray<String>;
    function InstallSources(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions;
      const ASettings: TTIDESettings): Boolean;
    procedure InstallExpert(
      const ABuilder: TTBuilder;
      const AOptions: TTInstallOptions;
      const ASettings: TTIDESettings);
    function InstallPackages(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions;
      const ASettings: TTIDESettings): Boolean;
    function InstallVersion(
      const AVersion: TTDelphiVersion;
      const AOptions: TTInstallOptions): Boolean;
    function TrackVersion(
      const AIndex: Integer; const AOptions: TTInstallOptions): Boolean;
    function InstallVersions(const AOptions: TTInstallOptions): TArray<String>;
    procedure CopySetup(const ADirectory: String);
    function CompletedFormat: String;
    procedure PrepareDirectory(const AOptions: TTInstallOptions);
    function IsComplete(
      const AOptions: TTInstallOptions;
      const AVersions: TArray<String>): Boolean;
    procedure PromoteDirectory(const AOptions: TTInstallOptions);
    procedure SaveInstallation(
      const AOptions: TTInstallOptions; const AVersions: TArray<String>);
    procedure DiscardInstallation(const AOptions: TTInstallOptions);
    procedure Deploy(const AOptions: TTInstallOptions);
    procedure DetectInstalled(const AVersions: TObjectList<TTDelphiVersion>);
    procedure UpdateVersions;
    procedure RemoveVersion(const AKey: String);
    procedure RemoveDirectory(const ADirectory: String);
  public
    constructor Create(
      const ALog: TTSetupLog;
      const AProgress: TTSetupProgress;
      const AInstallation: TTInstallation;
      const AMaster: Boolean);
    destructor Destroy; override;

    procedure Install(const AOptions: TTInstallOptions);
    procedure Update;
    procedure Uninstall;

    property HasErrors: Boolean read FHasErrors;
  end;

implementation

{ TTInstallOptions }

constructor TTInstallOptions.Create(
  const ADirectory: String; const AExpert: Boolean);
begin
  inherited Create;
  FDirectory := ExcludeTrailingPathDelimiter(ADirectory);
  FBuildDirectory := FDirectory;
  FExpert := AExpert;
  FVersions := TList<TTDelphiVersion>.Create;
end;

destructor TTInstallOptions.Destroy;
begin
  FVersions.Free;
  inherited Destroy;
end;

procedure TTInstallOptions.Stage;
begin
  FBuildDirectory := Format(SStagingDirectory, [FDirectory]);
end;

function TTInstallOptions.IsStaged: Boolean;
begin
  result := not SameText(FDirectory, FBuildDirectory);
end;

{ TTInstaller }

constructor TTInstaller.Create(
  const ALog: TTSetupLog;
  const AProgress: TTSetupProgress;
  const AInstallation: TTInstallation;
  const AMaster: Boolean);
begin
  inherited Create;
  FLog := ALog;
  FProgress := AProgress;
  FInstallation := AInstallation;
  FDownloader := TTReleaseDownloader.Create(ALog, AMaster);
  FHasErrors := False;
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
  FProgress.Step;
end;

function TTInstaller.CreateBuilder(
  const AVersion: TTDelphiVersion;
  const AOptions: TTInstallOptions): TTBuilder;
begin
  result := TTBuilder.Create(
    AVersion, AOptions.BuildDirectory, FLog, FProgress);
end;

function TTInstaller.VersionSteps(
  const AVersion: TTDelphiVersion;
  const AOptions: TTInstallOptions): Integer;
var
  LBuilder: TTBuilder;
begin
  result := 1;
  if AVersion.CanBuild then
  begin
    LBuilder := CreateBuilder(AVersion, AOptions);
    try
      result := LBuilder.StepCount(AOptions.Expert);
    finally
      LBuilder.Free;
    end;
  end;
end;

function TTInstaller.VersionNames(
  const AOptions: TTInstallOptions): TArray<String>;
var
  LVersion: TTDelphiVersion;
begin
  result := [];
  for LVersion in AOptions.Versions do
    result := result + [LVersion.Name];
end;

procedure TTInstaller.StartProgress(const AOptions: TTInstallOptions);
var
  LTotal: Integer;
  LVersion: TTDelphiVersion;
begin
  LTotal := 1;
  for LVersion in AOptions.Versions do
    Inc(LTotal, VersionSteps(LVersion, AOptions));
  FProgress.Start(LTotal, VersionNames(AOptions));
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
  ASettings.Clear;
  ASettings.SetVariable(AOptions.Directory);
  ASettings.SetSearchPath(AVersion.Platforms, SourceSearchPath);
  result := True;
end;

procedure TTInstaller.InstallExpert(
  const ABuilder: TTBuilder;
  const AOptions: TTInstallOptions;
  const ASettings: TTIDESettings);
var
  LPlatform: String;
begin
  if ABuilder.BuildExpert then
  begin
    for LPlatform in ABuilder.ExpertPlatforms do
      ASettings.SetExpert(
        LPlatform, ABuilder.ExpertLibrary(AOptions.Directory, LPlatform));
  end
  else
  begin
    FHasErrors := True;
    FLog.Add(SExpertFailed);
  end;
end;

function TTInstaller.InstallPackages(
  const AVersion: TTDelphiVersion;
  const AOptions: TTInstallOptions;
  const ASettings: TTIDESettings): Boolean;
var
  LBuilder: TTBuilder;
begin
  LBuilder := CreateBuilder(AVersion, AOptions);
  try
    result := LBuilder.BuildPackages;
    if result then
    begin
      ASettings.Clear;
      ASettings.SetVariable(LBuilder.LibraryDirectory(AOptions.Directory));
      ASettings.SetSearchPath(AVersion.Platforms, [SPackagesSearchPath]);
      if AOptions.Expert then
        InstallExpert(LBuilder, AOptions, ASettings);
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
    if AVersion.CanBuild then
      result := InstallPackages(AVersion, AOptions, LSettings)
    else
      result := InstallSources(AVersion, AOptions, LSettings);
  finally
    LSettings.Free;
  end;
end;

function TTInstaller.TrackVersion(
  const AIndex: Integer; const AOptions: TTInstallOptions): Boolean;
var
  LVersion: TTDelphiVersion;
  LTarget: Integer;
begin
  LVersion := AOptions.Versions[AIndex];
  LTarget := FProgress.Done + VersionSteps(LVersion, AOptions);
  FProgress.SetState(AIndex, TTVersionState.Installing);
  result := InstallVersion(LVersion, AOptions);
  FProgress.Reach(LTarget);
  if result then
    FProgress.SetState(AIndex, TTVersionState.Done)
  else
    FProgress.SetState(AIndex, TTVersionState.Failed);
end;

function TTInstaller.InstallVersions(
  const AOptions: TTInstallOptions): TArray<String>;
var
  LIndex: Integer;
  LVersion: TTDelphiVersion;
begin
  result := [];
  for LIndex := 0 to AOptions.Versions.Count - 1 do
  begin
    LVersion := AOptions.Versions[LIndex];
    if TrackVersion(LIndex, AOptions) then
    begin
      result := result + [LVersion.Key];
      FLog.AddFormat(SVersionInstalled, [LVersion.Name]);
    end
    else
    begin
      FHasErrors := True;
      FLog.AddFormat(SVersionFailed, [LVersion.Name]);
    end;
  end;
end;

procedure TTInstaller.CopySetup(const ADirectory: String);
var
  LFileName: String;
begin
  LFileName := TPath.Combine(ADirectory, SSetupFileName);
  if not SameText(LFileName, ParamStr(0)) then
    TFile.Copy(ParamStr(0), LFileName, True);
end;

function TTInstaller.CompletedFormat: String;
begin
  if FInstallation.Installed then
    result := SUpdated
  else
    result := SCompleted;
end;

procedure TTInstaller.PrepareDirectory(const AOptions: TTInstallOptions);
begin
  if AOptions.IsStaged and TDirectory.Exists(AOptions.BuildDirectory) then
    TDirectory.Delete(AOptions.BuildDirectory, True);
end;

function TTInstaller.IsComplete(
  const AOptions: TTInstallOptions;
  const AVersions: TArray<String>): Boolean;
begin
  if AOptions.IsStaged then
    result := (Length(AVersions) = AOptions.Versions.Count)
  else
    result := (Length(AVersions) > 0);
end;

procedure TTInstaller.PromoteDirectory(const AOptions: TTInstallOptions);
begin
  if AOptions.IsStaged then
  begin
    RemoveDirectory(AOptions.Directory);
    TDirectory.Move(AOptions.BuildDirectory, AOptions.Directory);
  end;
end;

procedure TTInstaller.SaveInstallation(
  const AOptions: TTInstallOptions; const AVersions: TArray<String>);
var
  LFormat: String;
begin
  LFormat := CompletedFormat;
  PromoteDirectory(AOptions);
  CopySetup(AOptions.Directory);
  FInstallation.Save(
    AOptions.Directory,
    FDownloader.Version,
    FDownloader.Commit,
    AVersions,
    AOptions.Expert);
  FLog.AddFormat(LFormat, [FDownloader.Version, Length(AVersions)]);
end;

procedure TTInstaller.DiscardInstallation(const AOptions: TTInstallOptions);
var
  LFormat: String;
begin
  RemoveDirectory(AOptions.BuildDirectory);
  LFormat := SNotUpdated;
  if not AOptions.IsStaged then
  begin
    FInstallation.Delete;
    LFormat := SNothingInstalled;
  end;
  raise ETSetupException.CreateFmt(LFormat, [FDownloader.Version]);
end;

procedure TTInstaller.Deploy(const AOptions: TTInstallOptions);
var
  LVersions: TArray<String>;
begin
  PrepareDirectory(AOptions);
  StartProgress(AOptions);
  DownloadRelease(AOptions.BuildDirectory);
  LVersions := InstallVersions(AOptions);
  if IsComplete(AOptions, LVersions) then
    SaveInstallation(AOptions, LVersions)
  else
    DiscardInstallation(AOptions);
end;

procedure TTInstaller.Install(const AOptions: TTInstallOptions);
begin
  FDownloader.Fetch;
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
      LOptions.Stage;
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
  FDownloader.Fetch;
  if FDownloader.IsUpToDate(
    FInstallation.Version, FInstallation.Commit) then
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
  FProgress.Step;
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
  FProgress.Step;
end;

procedure TTInstaller.Uninstall;
var
  LKey: String;
begin
  FProgress.Start(Length(FInstallation.Versions) + 1, []);
  for LKey in FInstallation.Versions do
    RemoveVersion(LKey);
  RemoveDirectory(FInstallation.Directory);
  FInstallation.Delete;
  FLog.Add(SUninstalled);
end;

end.
