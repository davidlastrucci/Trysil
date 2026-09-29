(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRest.Configuration;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSon,

  Trysil.Expert.Classes,
  Trysil.Expert.Consts,
  Trysil.Expert.APIRest.Parameters,
  Trysil.Expert.APIRest.Features;

type

{ TTApiRestJSonFile }

  TTApiRestJSonFile = class
  strict private
    FFileName: String;
    FRoot: TJSonObject;
  public
    constructor Create(const AFileName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure Save;

    function Find(const APath: String): TJSonObject;

    class procedure SetText(
      const AObject: TJSonObject;
      const AName: String;
      const AValue: String); static;
    class procedure SetNumber(
      const AObject: TJSonObject;
      const AName: String;
      const AValue: Integer); static;

    property Root: TJSonObject read FRoot;
  end;

{ TTApiRestRules }

  TTApiRestRules = class
  strict private
    FDirectory: String;
    FFeatures: TTApiRestFeatures;

    function Keep(const AConditions: TJSonArray): Boolean;
    function FullPath(const APath: String): String;
    procedure RemovePath(const APath: String);
    procedure RemoveMember(const AFileName: String; const AMember: String);
    procedure RemoveFromObject(
      const AValue: TJSonValue;
      const AParts: TArray<String>;
      const AIndex: Integer);
    procedure RemoveFromArray(
      const AValue: TJSonValue;
      const AParts: TArray<String>;
      const AIndex: Integer);
    procedure Remove(const AKey: String);
  public
    constructor Create(
      const ADirectory: String; const AFeatures: TTApiRestFeatures);

    procedure Apply(const ARules: String);
  end;

{ TTApiRestConfiguration }

  TTApiRestConfiguration = class
  strict private
    const PrivateKeyFile = 'keys\private.pem';
    const PublicKeyFile = 'keys\public.pem';
  strict private
    FParameters: TTApiRestParameters;

    function ConfigFolder: String;
    procedure SetDatabase(
      const AObject: TJSonObject; const ADatabase: TTApiRestDatabase);
    procedure SetSecrets(const AFile: TTApiRestJSonFile);
    procedure ConfigureMain;
    function RenameTenant: String;
    procedure ConfigureTenant;
    procedure ConfigureSettings;
  public
    constructor Create(const AParameters: TTApiRestParameters);

    procedure Apply;
  end;

implementation

{ TTApiRestJSonFile }

constructor TTApiRestJSonFile.Create(const AFileName: String);
begin
  inherited Create;
  FFileName := AFileName;
end;

destructor TTApiRestJSonFile.Destroy;
begin
  if Assigned(FRoot) then
    FRoot.Free;
  inherited Destroy;
end;

procedure TTApiRestJSonFile.AfterConstruction;
var
  LValue: TJSonValue;
begin
  inherited AfterConstruction;
  LValue := TJSonObject.ParseJSONValue(
    TFile.ReadAllText(FFileName, TEncoding.UTF8));
  if not (LValue is TJSonObject) then
  begin
    if Assigned(LValue) then
      LValue.Free;
    raise ETExpertException.CreateFmt(SJSonNotValid, [FFileName]);
  end;
  FRoot := TJSonObject(LValue);
end;

procedure TTApiRestJSonFile.Save;
begin
  TFile.WriteAllBytes(FFileName, TEncoding.UTF8.GetBytes(FRoot.Format(2)));
end;

function TTApiRestJSonFile.Find(const APath: String): TJSonObject;
var
  LName: String;
  LValue: TJSonValue;
begin
  result := FRoot;
  for LName in APath.Split(['.']) do
    if Assigned(result) then
    begin
      LValue := result.GetValue(LName);
      if LValue is TJSonObject then
        result := TJSonObject(LValue)
      else
        result := nil;
    end;
end;

class procedure TTApiRestJSonFile.SetText(
  const AObject: TJSonObject; const AName: String; const AValue: String);
begin
  if Assigned(AObject) then
  begin
    AObject.RemovePair(AName).Free;
    AObject.AddPair(AName, AValue);
  end;
end;

class procedure TTApiRestJSonFile.SetNumber(
  const AObject: TJSonObject; const AName: String; const AValue: Integer);
begin
  if Assigned(AObject) then
  begin
    AObject.RemovePair(AName).Free;
    AObject.AddPair(AName, TJSonNumber.Create(AValue));
  end;
end;

{ TTApiRestRules }

constructor TTApiRestRules.Create(
  const ADirectory: String; const AFeatures: TTApiRestFeatures);
begin
  inherited Create;
  FDirectory := ADirectory;
  FFeatures := AFeatures;
end;

function TTApiRestRules.Keep(const AConditions: TJSonArray): Boolean;
var
  LCondition: TJSonValue;
begin
  result := True;
  for LCondition in AConditions do
    result := result and
      TTApiRestCondition.Holds(FFeatures, LCondition.Value);
end;

function TTApiRestRules.FullPath(const APath: String): String;
begin
  result := TPath.Combine(
    FDirectory,
    APath.TrimRight(['/']).Replace('/', PathDelim, [rfReplaceAll]));
end;

procedure TTApiRestRules.RemovePath(const APath: String);
begin
  if APath.EndsWith('/') then
  begin
    if TDirectory.Exists(FullPath(APath)) then
      TDirectory.Delete(FullPath(APath), True);
  end
  else if TFile.Exists(FullPath(APath)) then
    TFile.Delete(FullPath(APath));
end;

procedure TTApiRestRules.RemoveFromArray(
  const AValue: TJSonValue;
  const AParts: TArray<String>;
  const AIndex: Integer);
var
  LItem: TJSonValue;
begin
  if (AValue is TJSonArray) and (AIndex <= High(AParts)) then
    for LItem in TJSonArray(AValue) do
      RemoveFromObject(LItem, AParts, AIndex);
end;

procedure TTApiRestRules.RemoveFromObject(
  const AValue: TJSonValue;
  const AParts: TArray<String>;
  const AIndex: Integer);
var
  LObject: TJSonObject;
  LName: String;
begin
  if AValue is TJSonObject then
  begin
    LObject := TJSonObject(AValue);
    LName := AParts[AIndex];
    if LName.EndsWith('[]') then
      RemoveFromArray(
        LObject.GetValue(LName.Substring(0, LName.Length - 2)),
        AParts,
        AIndex + 1)
    else if AIndex = High(AParts) then
      LObject.RemovePair(LName).Free
    else
      RemoveFromObject(LObject.GetValue(LName), AParts, AIndex + 1);
  end;
end;

procedure TTApiRestRules.RemoveMember(
  const AFileName: String; const AMember: String);
var
  LFile: TTApiRestJSonFile;
begin
  if TFile.Exists(FullPath(AFileName)) then
  begin
    LFile := TTApiRestJSonFile.Create(FullPath(AFileName));
    try
      RemoveFromObject(LFile.Root, AMember.Split(['.']), 0);
      LFile.Save;
    finally
      LFile.Free;
    end;
  end;
end;

procedure TTApiRestRules.Remove(const AKey: String);
var
  LIndex: Integer;
begin
  LIndex := AKey.IndexOf('#');
  if LIndex < 0 then
    RemovePath(AKey)
  else
    RemoveMember(AKey.Substring(0, LIndex), AKey.Substring(LIndex + 1));
end;

procedure TTApiRestRules.Apply(const ARules: String);
var
  LValue: TJSonValue;
  LPair: TJSonPair;
begin
  LValue := TJSonObject.ParseJSONValue(ARules);
  if not (LValue is TJSonObject) then
  begin
    if Assigned(LValue) then
      LValue.Free;
    raise ETExpertException.Create(SRulesNotValid);
  end;
  try
    for LPair in TJSonObject(LValue) do
      if not Keep(LPair.JsonValue as TJSonArray) then
        Remove(LPair.JsonString.Value);
  finally
    LValue.Free;
  end;
end;

{ TTApiRestConfiguration }

constructor TTApiRestConfiguration.Create(
  const AParameters: TTApiRestParameters);
begin
  inherited Create;
  FParameters := AParameters;
end;

function TTApiRestConfiguration.ConfigFolder: String;
begin
  result := TPath.Combine(FParameters.Directory, '_Config');
end;

procedure TTApiRestConfiguration.SetDatabase(
  const AObject: TJSonObject; const ADatabase: TTApiRestDatabase);
begin
  TTApiRestJSonFile.SetText(AObject, 'driver', ADatabase.Driver);
  TTApiRestJSonFile.SetText(AObject, 'server', ADatabase.Host);
  TTApiRestJSonFile.SetNumber(AObject, 'port', ADatabase.Port);
  TTApiRestJSonFile.SetText(AObject, 'username', ADatabase.Username);
  TTApiRestJSonFile.SetText(AObject, 'password', ADatabase.Password);
  TTApiRestJSonFile.SetText(
    AObject, 'databaseName', ADatabase.DatabaseName);
end;

procedure TTApiRestConfiguration.SetSecrets(const AFile: TTApiRestJSonFile);
var
  LKeys: TJSonArray;
  LKey: TJSonObject;
begin
  TTApiRestJSonFile.SetText(
    AFile.Find('secrets'), 'password', FParameters.PasswordSecret);
  if FParameters.Has(TTApiRestFeature.RS256) then
    TTApiRestJSonFile.SetText(
      AFile.Find('secrets.jwtKeys'), 'signingKey', PrivateKeyFile);

  LKey := nil;
  if Assigned(AFile.Find('secrets.jwtKeys')) then
  begin
    LKeys := AFile.Find('secrets.jwtKeys').GetValue('keys') as TJSonArray;
    if Assigned(LKeys) and (LKeys.Count > 0) then
      LKey := LKeys.Items[0] as TJSonObject;
  end;

  if FParameters.Has(TTApiRestFeature.RS256) then
    TTApiRestJSonFile.SetText(LKey, 'publicKey', PublicKeyFile)
  else
    TTApiRestJSonFile.SetText(LKey, 'secret', FParameters.JWTSecret);
end;

procedure TTApiRestConfiguration.ConfigureMain;
var
  LFile: TTApiRestJSonFile;
begin
  LFile := TTApiRestJSonFile.Create(TPath.Combine(
    ConfigFolder, Format('%s.json', [FParameters.ProjectName])));
  try
    TTApiRestJSonFile.SetText(
      LFile.Find('server'), 'baseUri', FParameters.BaseUri);
    TTApiRestJSonFile.SetNumber(
      LFile.Find('server'), 'port', FParameters.Port);
    SetDatabase(LFile.Find('database'), FParameters.Database);
    SetDatabase(LFile.Find('log.database'), FParameters.LogDatabase);
    if FParameters.Has(TTApiRestFeature.Auth) then
      SetSecrets(LFile);
    LFile.Save;
  finally
    LFile.Free;
  end;
end;

function TTApiRestConfiguration.RenameTenant: String;
var
  LFolders: TArray<String>;
begin
  LFolders := TDirectory.GetDirectories(
    TPath.Combine(ConfigFolder, 'Tenants'));
  if Length(LFolders) <> 1 then
    raise ETExpertException.Create(STenantFolderNotValid);

  result := TPath.Combine(
    TPath.Combine(ConfigFolder, 'Tenants'),
    Format('localhost-%d', [FParameters.Port]));
  if not SameText(LFolders[0], result) then
    TDirectory.Move(LFolders[0], result);
end;

procedure TTApiRestConfiguration.ConfigureTenant;
var
  LFile: TTApiRestJSonFile;
begin
  LFile := TTApiRestJSonFile.Create(
    TPath.Combine(RenameTenant, '_config.json'));
  try
    SetDatabase(LFile.Find('database'), FParameters.Database);
    SetDatabase(LFile.Find('log.database'), FParameters.LogDatabase);
    LFile.Save;
  finally
    LFile.Free;
  end;
end;

procedure TTApiRestConfiguration.ConfigureSettings;
var
  LFileName: String;
  LFile: TTApiRestJSonFile;
begin
  LFileName := TPath.Combine(
    FParameters.Directory, '__trysil\__settings\settings.json');
  if TFile.Exists(LFileName) then
  begin
    LFile := TTApiRestJSonFile.Create(LFileName);
    try
      TTApiRestJSonFile.SetNumber(
        LFile.Root, 'databaseType', FParameters.Database.DriverIndex);
      LFile.Save;
    finally
      LFile.Free;
    end;
  end;
end;

procedure TTApiRestConfiguration.Apply;
begin
  ConfigureMain;
  if FParameters.Has(TTApiRestFeature.MultiTenant) then
    ConfigureTenant;
  ConfigureSettings;
end;

end.
