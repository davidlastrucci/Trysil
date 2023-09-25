(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Win.Registry,
  Winapi.Windows;

type

{ TTConfig }

  TTConfig = class
  strict private
    const RegistryPath: String = '\SOFTWARE\Trysil\Expert';
  strict private
    class var FInstance: TTConfig;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FTrysilDirectory: String;
    FModelDirectory: String;
    FUnitFilenames: String;

    procedure Load;
  public
    procedure AfterConstruction; override;

    procedure Save;

    property TrysilDirectory: String
      read FTrysilDirectory write FTrysilDirectory;
    property ModelDirectory: String read FModelDirectory write FModelDirectory;
    property UnitFilenames: String read FUnitFilenames write FUnitFilenames;

    class property Instance: TTConfig read FInstance;
  end;

{ TTUtils }

  TTUtils = class
  strict private
    class function GetFolder(
      const AFolder1: String; const AFolder2: String): String;
  public
    class function TrysilFolder(const AProjectDirectory: String): String;
    class function ModelFolder(
      const AProjectDirectory: String; const ASubFolder: String): String;

    class function UnitName(
      const AUnitNames: String;
      const AProjectName: String;
      const AEntityName: String): String;
  end;

implementation

type

{ TTConfigDefaults }

  TTConfigDefaults = class
  public
    const TrysilDirectory: String = '__trysil';
    const ModelDirectory: String = 'Model';
    const UnitFilenames: String = '{ProjectName}.Model.{EntityName}';
  end;

{ TTConfig }

class constructor TTConfig.ClassCreate;
begin
  FInstance := TTConfig.Create;
end;

class destructor TTConfig.ClassDestroy;
begin
  FInstance.Free;
end;

procedure TTConfig.AfterConstruction;
begin
  inherited AfterConstruction;
  Load;
end;

procedure TTConfig.Load;
var
  LRegistry: TRegIniFile;
begin
  LRegistry := TRegIniFile.Create('', KEY_READ);
  try
    LRegistry.RootKey := HKEY_CURRENT_USER;

    FTrysilDirectory := LRegistry.ReadString(RegistryPath, 'TrysilDirectory', TTConfigDefaults.TrysilDirectory);
    FModelDirectory := LRegistry.ReadString(RegistryPath, 'ModelDirectory', TTConfigDefaults.ModelDirectory);
    FUnitFilenames := LRegistry.ReadString(RegistryPath, 'UnitFilenames', TTConfigDefaults.UnitFilenames);
  finally
    LRegistry.Free;
  end;
end;

procedure TTConfig.Save;
var
  LRegistry: TRegIniFile;
begin
  LRegistry := TRegIniFile.Create('', KEY_WRITE);
  try
    LRegistry.RootKey := HKEY_CURRENT_USER;

    LRegistry.WriteString(RegistryPath, 'TrysilDirectory', FTrysilDirectory);
    LRegistry.WriteString(RegistryPath, 'ModelDirectory', FModelDirectory);
    LRegistry.WriteString(RegistryPath, 'UnitFilenames', FUnitFilenames);
  finally
    LRegistry.Free;
  end;
end;

{ TTUtils }

class function TTUtils.GetFolder(
  const AFolder1: String; const AFolder2: String): String;
var
  LDirectories: TArray<String>;
  LDirectory: String;
begin
  result := AFolder1;
  LDirectories := AFolder2.Split(['/', '\']);
  for LDirectory in LDirectories do
  begin
    result := TPath.Combine(result, LDirectory);
    TDirectory.CreateDirectory(result);
  end;
end;

class function TTUtils.TrysilFolder(const AProjectDirectory: String): String;
begin
  result := GetFolder(AProjectDirectory, TTConfig.Instance.TrysilDirectory);
end;

class function TTUtils.ModelFolder(
  const AProjectDirectory: String; const ASubFolder: String): String;
begin
  result := GetFolder(AProjectDirectory, ASubfolder);
end;

class function TTUtils.UnitName(
  const AUnitNames: String;
  const AProjectName: String;
  const AEntityName: String): String;
begin
  result := AUnitnames
    .Replace('{ProjectName}', AProjectName, [rfReplaceAll, rfIgnoreCase])
    .Replace('{EntityName}', AEntityName, [rfReplaceAll, rfIgnoreCase]);
end;

end.
