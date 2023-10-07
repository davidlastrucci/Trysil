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
  System.JSon,
  System.IOUtils,
  System.Win.Registry,
  Winapi.Windows,
  ToolsAPI,

  Trysil.Expert.IOTA;

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

{ TTLocalConfig }

  TTLocalConfig = class
  strict private
    FFilename: String;

    FModelDirectory: String;
    FUnitFilenames: String;
    FControllers: Boolean;
    FDatabaseType: Integer;

    function GetConfigFileName: String;
    procedure LoadFromFile;
    procedure LoadFromConfig;
  public
    procedure AfterConstruction; override;

    procedure Save;

    property ModelDirectory: String read FModelDirectory write FModelDirectory;
    property UnitFilenames: String read FUnitFilenames write FUnitFilenames;
    property Controllers: Boolean read FControllers write FControllers;
    property DatabaseType: Integer read FDatabaseType write FDatabaseType;
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

{ TTLocalConfig }

procedure TTLocalConfig.AfterConstruction;
begin
  inherited AfterConstruction;
  FFilename := GetConfigFileName;
  if TFile.Exists(FFilename) then
    LoadFromFile
  else
    LoadFromConfig;
end;

function TTLocalConfig.GetConfigFileName: String;
var
  LProject: IOTAProject;
begin
  LProject := TTIOTA.ActiveProject;
  result := TPath.Combine(
    TPath.GetDirectoryName(LProject.FileName),
    TTConfig.Instance.TrysilDirectory);
  result := TPath.Combine(result, '__settings');
  result := TPath.Combine(result, 'settings.json');
end;

procedure TTLocalConfig.LoadFromFile;
var
  LJSon: TJSonValue;
begin
  LJSon := TJSonObject.ParseJSonValue(
    TFile.ReadAllText(FFilename), False, True);
  try
    FModelDirectory := LJSon.GetValue<String>('modelDirectory', TTConfig.Instance.ModelDirectory);
    FUnitFilenames := LJSon.GetValue<String>('unitFilenames', TTConfig.Instance.UnitFilenames);
    FControllers := LJSon.GetValue<Boolean>('controllers', True);
    FDatabaseType := LJSon.GetValue<Integer>('databaseType', 0);
  finally
    LJSon.Free;
  end;
end;

procedure TTLocalConfig.LoadFromConfig;
begin
  FModelDirectory := TTConfig.Instance.ModelDirectory;
  FUnitFilenames := TTConfig.Instance.UnitFilenames;
  FControllers := True;
  FDatabaseType := 0;
end;

procedure TTLocalConfig.Save;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create();
  try
    LJSon.AddPair('modelDirectory', FModelDirectory);
    LJSon.AddPair('unitFilenames', FUnitFilenames);
    LJSon.AddPair('controllers', TJSonBool.Create(FControllers));
    LJSon.AddPair('databaseType', TJSonNumber.Create(FDatabaseType));

    TDirectory.CreateDirectory(TPath.GetDirectoryName(FFilename));
    TFile.WriteAllText(FFilename, LJSon.Format(2));
  finally
    LJSon.Free;
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
