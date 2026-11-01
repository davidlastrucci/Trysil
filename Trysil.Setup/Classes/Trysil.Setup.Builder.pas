(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Builder;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,

  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Progress,
  Trysil.Setup.MSBuild,
  Trysil.Setup.Delphi;

type

{ TTBuilder }

  TTBuilder = class
  strict private
    FVersion: TTDelphiVersion;
    FDirectory: String;
    FLog: TTSetupLog;
    FProgress: TTSetupProgress;
    FMSBuild: TTMSBuild;

    function CanBuildPackage(
      const APackage: String; const APlatform: String): Boolean;
    function PackageCount(const APlatform: String): Integer;
    function BuildProject(
      const AProject: String;
      const AConfig: String;
      const APlatform: String): Boolean;
    function BuildPackage(
      const APackage: String;
      const AConfig: String;
      const APlatform: String): Boolean;
    function BuildConfig(
      const AConfig: String; const APlatform: String): Boolean;
  public
    constructor Create(
      const AVersion: TTDelphiVersion;
      const ADirectory: String;
      const ALog: TTSetupLog;
      const AProgress: TTSetupProgress);
    destructor Destroy; override;

    function StepCount(const AExpert: Boolean): Integer;
    function BuildPackages: Boolean;
    function BuildExpert: Boolean;
    function LibraryDirectory: String;
    function ExpertPlatforms: TArray<String>;
    function ExpertLibrary(const APlatform: String): String;
  end;

implementation

{ TTBuilder }

constructor TTBuilder.Create(
  const AVersion: TTDelphiVersion;
  const ADirectory: String;
  const ALog: TTSetupLog;
  const AProgress: TTSetupProgress);
begin
  inherited Create;
  FVersion := AVersion;
  FDirectory := ADirectory;
  FLog := ALog;
  FProgress := AProgress;
  FMSBuild := TTMSBuild.Create(AVersion.RootDir, ALog);
end;

destructor TTBuilder.Destroy;
begin
  FMSBuild.Free;
  inherited Destroy;
end;

function TTBuilder.CanBuildPackage(
  const APackage: String; const APlatform: String): Boolean;
begin
  if SameText(APackage, SSqlServerPackage) then
    result := FVersion.HasUnit(APlatform, SMSSQLUnit)
  else if SameText(APackage, SOraclePackage) then
    result := FVersion.HasUnit(APlatform, SOracleUnit)
  else
    result := True;
end;

function TTBuilder.PackageCount(const APlatform: String): Integer;
var
  LPackage: String;
begin
  result := 0;
  for LPackage in Packages do
    if CanBuildPackage(LPackage, APlatform) then
      Inc(result);
end;

function TTBuilder.StepCount(const AExpert: Boolean): Integer;
var
  LPlatform: String;
begin
  result := 0;
  for LPlatform in FVersion.Platforms do
    Inc(result, PackageCount(LPlatform) * Length(Configurations));
  if AExpert then
    Inc(result, Length(ExpertPlatforms));
end;

function TTBuilder.BuildProject(
  const AProject: String;
  const AConfig: String;
  const APlatform: String): Boolean;
var
  LName: String;
begin
  LName := TPath.GetFileNameWithoutExtension(AProject);
  FLog.AddFormat(SBuilding, [LName, AConfig, APlatform]);
  result := FMSBuild.Build(
    TPath.Combine(FDirectory, AProject), AConfig, APlatform);
  FProgress.Step;
  if not result then
    FLog.AddFormat(SBuildFailed, [LName, AConfig, APlatform]);
end;

function TTBuilder.BuildPackage(
  const APackage: String;
  const AConfig: String;
  const APlatform: String): Boolean;
begin
  result := True;
  if CanBuildPackage(APackage, APlatform) then
    result := BuildProject(
      Format(SPackageProject, [FVersion.Suffix, APackage]),
      AConfig,
      APlatform)
  else
    FLog.AddFormat(SPackageSkipped, [APackage, APlatform]);
end;

function TTBuilder.BuildConfig(
  const AConfig: String; const APlatform: String): Boolean;
var
  LPackage: String;
begin
  result := True;
  for LPackage in Packages do
    result := result and BuildPackage(LPackage, AConfig, APlatform);
end;

function TTBuilder.BuildPackages: Boolean;
var
  LPlatform: String;
  LConfig: String;
begin
  result := True;
  for LPlatform in FVersion.Platforms do
    for LConfig in Configurations do
      result := result and BuildConfig(LConfig, LPlatform);
end;

function TTBuilder.LibraryDirectory: String;
begin
  result := TPath.Combine(
    FDirectory, Format(SPackagesLibrary, [FVersion.Suffix]));
end;

function TTBuilder.ExpertPlatforms: TArray<String>;
begin
  result := [SWin32];
  if FVersion.HasIDE64 and FVersion.HasPlatform(SWin64) then
    result := result + [SWin64];
end;

function TTBuilder.BuildExpert: Boolean;
var
  LPlatform: String;
begin
  result := True;
  for LPlatform in ExpertPlatforms do
    result := result and BuildProject(
      Format(SExpertProject, [FVersion.Suffix]), SRelease, LPlatform);
end;

function TTBuilder.ExpertLibrary(const APlatform: String): String;
begin
  result := TPath.Combine(
    FDirectory, Format(SExpertLibrary, [APlatform, FVersion.Suffix]));
end;

end.
