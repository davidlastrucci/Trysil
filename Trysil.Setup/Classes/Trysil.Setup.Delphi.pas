(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Delphi;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.IOUtils,
  System.Generics.Collections,

  Trysil.Setup.Consts;

type

{ TTDelphiRelease }

  TTDelphiRelease = class
  strict private
    FKey: String;
    FSuffix: String;
    FName: String;
  public
    constructor Create(
      const AKey: String; const ASuffix: String; const AName: String);

    property Key: String read FKey;
    property Suffix: String read FSuffix;
    property Name: String read FName;
  end;

{ TTDelphiReleases }

  TTDelphiReleases = class(TObjectList<TTDelphiRelease>)
  public
    procedure AfterConstruction; override;

    function Find(const AKey: String): TTDelphiRelease;
  end;

{ TTDelphiVersion }

  TTDelphiVersion = class
  strict private
    FKey: String;
    FSuffix: String;
    FName: String;
    FRootDir: String;
    FHasIDE64: Boolean;
    FPlatforms: TArray<String>;
    FCanBuild: Boolean;

    function GetPath: String;
  public
    constructor Create(
      const ARelease: TTDelphiRelease;
      const ARootDir: String;
      const AHasIDE64: Boolean;
      const APlatforms: TArray<String>;
      const ACanBuild: Boolean);

    function HasPlatform(const APlatform: String): Boolean;
    function HasUnit(const APlatform: String; const AUnitName: String): Boolean;
    function Description: String;

    property Key: String read FKey;
    property Suffix: String read FSuffix;
    property Name: String read FName;
    property RootDir: String read FRootDir;
    property HasIDE64: Boolean read FHasIDE64;
    property Platforms: TArray<String> read FPlatforms;
    property CanBuild: Boolean read FCanBuild;
  end;

implementation

{ TTDelphiRelease }

constructor TTDelphiRelease.Create(
  const AKey: String; const ASuffix: String; const AName: String);
begin
  inherited Create;
  FKey := AKey;
  FSuffix := ASuffix;
  FName := AName;
end;

{ TTDelphiReleases }

procedure TTDelphiReleases.AfterConstruction;
begin
  inherited AfterConstruction;
  Add(TTDelphiRelease.Create('37.0', '370', 'Delphi 13 Florence'));
  Add(TTDelphiRelease.Create('23.0', '290', 'Delphi 12 Athens'));
  Add(TTDelphiRelease.Create('22.0', '280', 'Delphi 11 Alexandria'));
  Add(TTDelphiRelease.Create('21.0', '270', 'Delphi 10.4 Sydney'));
  Add(TTDelphiRelease.Create('20.0', '260', 'Delphi 10.3 Rio'));
end;

function TTDelphiReleases.Find(const AKey: String): TTDelphiRelease;
var
  LRelease: TTDelphiRelease;
begin
  result := nil;
  for LRelease in Self do
    if LRelease.Key = AKey then
      result := LRelease;
end;

{ TTDelphiVersion }

constructor TTDelphiVersion.Create(
  const ARelease: TTDelphiRelease;
  const ARootDir: String;
  const AHasIDE64: Boolean;
  const APlatforms: TArray<String>;
  const ACanBuild: Boolean);
begin
  inherited Create;
  FKey := ARelease.Key;
  FSuffix := ARelease.Suffix;
  FName := ARelease.Name;
  FRootDir := ARootDir;
  FHasIDE64 := AHasIDE64;
  FPlatforms := APlatforms;
  FCanBuild := ACanBuild;
end;

function TTDelphiVersion.HasPlatform(const APlatform: String): Boolean;
begin
  result := MatchText(APlatform, FPlatforms);
end;

function TTDelphiVersion.HasUnit(
  const APlatform: String; const AUnitName: String): Boolean;
begin
  result := TFile.Exists(TPath.Combine(
    FRootDir, Format(SDriverUnit, [APlatform.ToLower, AUnitName])));
end;

function TTDelphiVersion.GetPath: String;
begin
  if FCanBuild then
    result := SPackagesPath
  else
    result := SSourcesPath;
end;

function TTDelphiVersion.Description: String;
begin
  result := Format(SVersionDescription, [
    FName, GetPath, String.Join(' ', FPlatforms)]);
end;

end.
