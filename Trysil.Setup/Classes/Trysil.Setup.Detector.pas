(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Detector;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Win.Registry,
  System.Generics.Collections,

  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Probe,
  Trysil.Setup.Delphi;

type

{ TTDelphiDetector }

  TTDelphiDetector = class
  strict private
    FLog: TTSetupLog;
    FReleases: TTDelphiReleases;
    FProbe: TTProbe;

    function ReadMachineValue(const AKey: String; const AName: String): String;
    function ReadRootDir(const AKey: String): String;
    function EnvOptionsFileName(const AKey: String): String;
    function IsInstalled(
      const ARelease: TTDelphiRelease; const ARootDir: String): Boolean;
    function IsPlatformReady(
      const ARootDir: String;
      const AEnvOptions: String;
      const APlatform: String): Boolean;
    function DetectPlatforms(
      const ARelease: TTDelphiRelease;
      const ARootDir: String): TArray<String>;
    function CanBuild(
      const ARelease: TTDelphiRelease; const ARootDir: String): Boolean;
    function CreateVersion(
      const ARelease: TTDelphiRelease;
      const ARootDir: String): TTDelphiVersion;
    function Detect(const ARelease: TTDelphiRelease): TTDelphiVersion;
    procedure AddVersion(
      const AVersion: TTDelphiVersion;
      const AVersions: TObjectList<TTDelphiVersion>);
  public
    constructor Create(const ALog: TTSetupLog);
    destructor Destroy; override;

    procedure DetectAll(const AVersions: TObjectList<TTDelphiVersion>);
    procedure DetectKeys(
      const AKeys: TArray<String>;
      const AVersions: TObjectList<TTDelphiVersion>);
  end;

implementation

{ TTDelphiDetector }

constructor TTDelphiDetector.Create(const ALog: TTSetupLog);
begin
  inherited Create;
  FLog := ALog;
  FReleases := TTDelphiReleases.Create;
  FProbe := TTProbe.Create(ALog);
end;

destructor TTDelphiDetector.Destroy;
begin
  FProbe.Free;
  FReleases.Free;
  inherited Destroy;
end;

function TTDelphiDetector.ReadMachineValue(
  const AKey: String; const AName: String): String;
var
  LRegistry: TRegistry;
begin
  result := String.Empty;
  LRegistry := TRegistry.Create(KEY_READ);
  try
    LRegistry.RootKey := HKEY_LOCAL_MACHINE;
    if LRegistry.OpenKeyReadOnly(Format(SMachineKey, [AKey])) and
      LRegistry.ValueExists(AName) then
      result := LRegistry.ReadString(AName);
  finally
    LRegistry.Free;
  end;
end;

function TTDelphiDetector.ReadRootDir(const AKey: String): String;
begin
  result := ReadMachineValue(AKey, SRootDirValue);
  if not result.IsEmpty then
    result := IncludeTrailingPathDelimiter(result);
end;

function TTDelphiDetector.EnvOptionsFileName(const AKey: String): String;
begin
  result := TPath.Combine(
    GetEnvironmentVariable(SAppDataVariable), Format(SEnvOptions, [AKey]));
end;

function TTDelphiDetector.IsInstalled(
  const ARelease: TTDelphiRelease; const ARootDir: String): Boolean;
begin
  result := False;
  if ARootDir.IsEmpty or (not TDirectory.Exists(ARootDir)) then
    FLog.AddFormat(SNotInstalled, [ARelease.Name])
  else if not TFile.Exists(TPath.Combine(ARootDir, SRsvars)) then
    FLog.AddFormat(SRsvarsNotFound, [ARelease.Name])
  else if not TFile.Exists(EnvOptionsFileName(ARelease.Key)) then
    FLog.AddFormat(SEnvOptionsNotFound, [ARelease.Name])
  else
    result := True;
end;

function TTDelphiDetector.IsPlatformReady(
  const ARootDir: String;
  const AEnvOptions: String;
  const APlatform: String): Boolean;
begin
  result :=
    TFile.Exists(TPath.Combine(
      ARootDir, Format(SSystemUnit, [APlatform.ToLower]))) and
    AEnvOptions.Contains(Format(SPlatformCondition, [APlatform])) and
    AEnvOptions.Contains(SLibraryPathElement);
end;

function TTDelphiDetector.DetectPlatforms(
  const ARelease: TTDelphiRelease;
  const ARootDir: String): TArray<String>;
var
  LEnvOptions: String;
  LPlatform: String;
begin
  result := [];
  LEnvOptions := TFile.ReadAllText(EnvOptionsFileName(ARelease.Key));
  for LPlatform in Platforms do
    if IsPlatformReady(ARootDir, LEnvOptions, LPlatform) then
      result := result + [LPlatform];
end;

function TTDelphiDetector.CanBuild(
  const ARelease: TTDelphiRelease; const ARootDir: String): Boolean;
begin
  FLog.AddFormat(SProbing, [ARelease.Name]);
  result := FProbe.Run(ARootDir);
  if result then
    FLog.AddFormat(SProbeSucceeded, [ARelease.Name])
  else
    FLog.AddFormat(SProbeFailed, [ARelease.Name]);
end;

function TTDelphiDetector.CreateVersion(
  const ARelease: TTDelphiRelease;
  const ARootDir: String): TTDelphiVersion;
var
  LPlatforms: TArray<String>;
begin
  result := nil;
  LPlatforms := DetectPlatforms(ARelease, ARootDir);
  if Length(LPlatforms) > 0 then
    result := TTDelphiVersion.Create(
      ARelease,
      ARootDir,
      not ReadMachineValue(ARelease.Key, SApp64Value).IsEmpty,
      LPlatforms,
      CanBuild(ARelease, ARootDir))
  else
    FLog.AddFormat(SNoPlatform, [ARelease.Name]);
end;

function TTDelphiDetector.Detect(
  const ARelease: TTDelphiRelease): TTDelphiVersion;
var
  LRootDir: String;
begin
  result := nil;
  LRootDir := ReadRootDir(ARelease.Key);
  if IsInstalled(ARelease, LRootDir) then
    result := CreateVersion(ARelease, LRootDir);
end;

procedure TTDelphiDetector.AddVersion(
  const AVersion: TTDelphiVersion;
  const AVersions: TObjectList<TTDelphiVersion>);
begin
  if Assigned(AVersion) then
    AVersions.Add(AVersion);
end;

procedure TTDelphiDetector.DetectAll(
  const AVersions: TObjectList<TTDelphiVersion>);
var
  LRelease: TTDelphiRelease;
begin
  for LRelease in FReleases do
    AddVersion(Detect(LRelease), AVersions);
end;

procedure TTDelphiDetector.DetectKeys(
  const AKeys: TArray<String>;
  const AVersions: TObjectList<TTDelphiVersion>);
var
  LKey: String;
  LRelease: TTDelphiRelease;
begin
  for LKey in AKeys do
  begin
    LRelease := FReleases.Find(LKey);
    if Assigned(LRelease) then
      AddVersion(Detect(LRelease), AVersions);
  end;
end;

end.
