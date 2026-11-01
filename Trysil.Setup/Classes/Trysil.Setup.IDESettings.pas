(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.IDESettings;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  System.Generics.Collections,

  Trysil.Setup.Consts;

type

{ TTSearchPath }

  TTSearchPath = class
  strict private
    FValue: String;
    FEntries: TList<String>;
  public
    constructor Create(const AValue: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RemoveTrysil;
    procedure Add(const AEntry: String);
    function ToString: String; override;
  end;

{ TTIDERegistry }

  TTIDERegistry = class
  strict private
    FKey: String;

    function KeyName(const ASubKey: String): String;
  public
    constructor Create(const AKey: String);

    function ReadValue(const ASubKey: String; const AName: String): String;
    procedure WriteValue(
      const ASubKey: String; const AName: String; const AValue: String);
    procedure DeleteValue(const ASubKey: String; const AName: String);
  end;

{ TTIDESettings }

  TTIDESettings = class
  strict private
    FRegistry: TTIDERegistry;
    FHasIDE64: Boolean;

    function ExpertsKey(const APlatform: String): String;
    procedure UpdateSearchPath(
      const APlatform: String; const AEntries: TArray<String>);
    procedure RemoveSearchPath(const APlatform: String);
  public
    constructor Create(const AKey: String; const AHasIDE64: Boolean);
    destructor Destroy; override;

    procedure SetVariable(const AValue: String);
    procedure SetSearchPath(
      const APlatforms: TArray<String>; const AEntries: TArray<String>);
    procedure SetExpert(const APlatform: String; const ALibrary: String);
    procedure Clear;
  end;

implementation

{ TTSearchPath }

constructor TTSearchPath.Create(const AValue: String);
begin
  inherited Create;
  FValue := AValue;
  FEntries := TList<String>.Create;
end;

destructor TTSearchPath.Destroy;
begin
  FEntries.Free;
  inherited Destroy;
end;

procedure TTSearchPath.AfterConstruction;
begin
  inherited AfterConstruction;
  FEntries.AddRange(FValue.Split(
    [SSearchPathSeparator], TStringSplitOptions.ExcludeEmpty));
end;

procedure TTSearchPath.RemoveTrysil;
var
  LIndex: Integer;
begin
  for LIndex := FEntries.Count - 1 downto 0 do
    if FEntries[LIndex].ToLower.Contains(STrysilReference.ToLower) then
      FEntries.Delete(LIndex);
end;

procedure TTSearchPath.Add(const AEntry: String);
begin
  FEntries.Add(AEntry);
end;

function TTSearchPath.ToString: String;
begin
  result := String.Join(SSearchPathSeparator, FEntries.ToArray);
end;

{ TTIDERegistry }

constructor TTIDERegistry.Create(const AKey: String);
begin
  inherited Create;
  FKey := AKey;
end;

function TTIDERegistry.KeyName(const ASubKey: String): String;
begin
  result := Format(SUserKey, [FKey, ASubKey]);
end;

function TTIDERegistry.ReadValue(
  const ASubKey: String; const AName: String): String;
var
  LRegistry: TRegistry;
begin
  result := String.Empty;
  LRegistry := TRegistry.Create;
  try
    if LRegistry.OpenKey(KeyName(ASubKey), False) and
      LRegistry.ValueExists(AName) then
      result := LRegistry.ReadString(AName);
  finally
    LRegistry.Free;
  end;
end;

procedure TTIDERegistry.WriteValue(
  const ASubKey: String; const AName: String; const AValue: String);
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create;
  try
    if LRegistry.OpenKey(KeyName(ASubKey), True) then
      LRegistry.WriteString(AName, AValue);
  finally
    LRegistry.Free;
  end;
end;

procedure TTIDERegistry.DeleteValue(
  const ASubKey: String; const AName: String);
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create;
  try
    if LRegistry.OpenKey(KeyName(ASubKey), False) and
      LRegistry.ValueExists(AName) then
      LRegistry.DeleteValue(AName);
  finally
    LRegistry.Free;
  end;
end;

{ TTIDESettings }

constructor TTIDESettings.Create(const AKey: String; const AHasIDE64: Boolean);
begin
  inherited Create;
  FRegistry := TTIDERegistry.Create(AKey);
  FHasIDE64 := AHasIDE64;
end;

destructor TTIDESettings.Destroy;
begin
  FRegistry.Free;
  inherited Destroy;
end;

function TTIDESettings.ExpertsKey(const APlatform: String): String;
begin
  if SameText(APlatform, SWin64) then
    result := SExperts64Key
  else
    result := SExpertsKey;
end;

procedure TTIDESettings.UpdateSearchPath(
  const APlatform: String; const AEntries: TArray<String>);
var
  LSubKey: String;
  LSearchPath: TTSearchPath;
  LEntry: String;
begin
  LSubKey := Format(SLibraryKey, [APlatform]);
  LSearchPath := TTSearchPath.Create(
    FRegistry.ReadValue(LSubKey, SSearchPathValue));
  try
    LSearchPath.RemoveTrysil;
    for LEntry in AEntries do
      LSearchPath.Add(LEntry);
    FRegistry.WriteValue(LSubKey, SSearchPathValue, LSearchPath.ToString);
  finally
    LSearchPath.Free;
  end;
end;

procedure TTIDESettings.RemoveSearchPath(const APlatform: String);
var
  LSubKey: String;
  LValue: String;
begin
  LSubKey := Format(SLibraryKey, [APlatform]);
  LValue := FRegistry.ReadValue(LSubKey, SSearchPathValue);
  if LValue.ToLower.Contains(STrysilReference.ToLower) then
    UpdateSearchPath(APlatform, []);
end;

procedure TTIDESettings.SetVariable(const AValue: String);
begin
  FRegistry.WriteValue(SEnvironmentKey, STrysilName, AValue);
  if FHasIDE64 then
    FRegistry.WriteValue(SEnvironment64Key, STrysilName, AValue);
end;

procedure TTIDESettings.SetSearchPath(
  const APlatforms: TArray<String>; const AEntries: TArray<String>);
var
  LPlatform: String;
begin
  for LPlatform in APlatforms do
    UpdateSearchPath(LPlatform, AEntries);
end;

procedure TTIDESettings.SetExpert(
  const APlatform: String; const ALibrary: String);
begin
  FRegistry.WriteValue(ExpertsKey(APlatform), STrysilName, ALibrary);
end;

procedure TTIDESettings.Clear;
var
  LPlatform: String;
begin
  FRegistry.DeleteValue(SEnvironmentKey, STrysilName);
  FRegistry.DeleteValue(SEnvironment64Key, STrysilName);
  FRegistry.DeleteValue(SExpertsKey, STrysilName);
  FRegistry.DeleteValue(SExperts64Key, STrysilName);
  for LPlatform in Platforms do
    RemoveSearchPath(LPlatform);
end;

end.
