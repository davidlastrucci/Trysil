(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Config;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSon;

type

{ TAPIServerConfig }

  TAPIServerConfig = record
  strict private
    FBaseUri: String;
    FPort: Word;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property BaseUri: String read FBaseUri;
    property Port: Word read FPort;
  end;

{ TAPICorsConfig }

  TAPICorsConfig = record
  strict private
    FAllowHeaders: String;
    FAllowOrigin: String;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property AllowHeaders: String read FAllowHeaders;
    property AllowOrigin: String read FAllowOrigin;
  end;

{ TAPIDatabaseConfig }

  TAPIDatabaseConfig = record
  strict private
    FConnectionName: String;
    FServer: String;
    FUsername: String;
    FPassword: String;
    FDatabaseName: String;
  private // internal
    procedure Load(const AJSon: TJSonValue);
  public
    property ConnectionName: String read FConnectionName;
    property Server: String read FServer;
    property Username: String read FUsername;
    property Password: String read FPassword;
    property DatabaseName: String read FDatabaseName;
  end;

{ TAPIConfig }

  TAPIConfig = class
  strict private
    class var FInstance: TAPIConfig;

    class constructor ClassCreate;
    class destructor ClassDestroy;

    class function GetInstance: TAPIConfig; static;
  strict private
    FServer: TAPIServerConfig;
    FCors: TAPICorsConfig;
    FDatabase: TAPIDatabaseConfig;

    function GetJSonConfig: TJSonValue;
    procedure LoadFromFile;
  public
    property Server: TAPIServerConfig read FServer;
    property Cors: TAPICorsConfig read FCors;
    property Database: TAPIDatabaseConfig read FDatabase;

    class property Instance: TAPIConfig read GetInstance;
  end;

resourcestring
  SConfigNotFound = 'Configuration file "%s" not found.';
  SConfigNotValid = 'Configuration file "%s" not valid.';

implementation

{ TAPIServerConfig }

procedure TAPIServerConfig.Load(const AJSon: TJSonValue);
begin
  if Assigned(AJSon) then
  begin
    FBaseUri := AJSon.GetValue<String>('baseUri', String.Empty);
    FPort := AJSon.GetValue<Integer>('port', 4450);
  end;
end;

{ TAPICorsConfig }

procedure TAPICorsConfig.Load(const AJSon: TJSonValue);
begin
  if Assigned(AJSon) then
  begin
    FAllowHeaders := AJSon.GetValue<String>('allowHeaders', '');
    FAllowOrigin := AJSon.GetValue<String>('allowOrigin', '');
  end;
end;

{ TAPIDatabaseConfig }

procedure TAPIDatabaseConfig.Load(const AJSon: TJSonValue);
begin
  if Assigned(AJSon) then
  begin
    FConnectionName := AJSon.GetValue<String>('connectionName', '');
    FServer := AJSon.GetValue<String>('server', '');
    FUsername := AJSon.GetValue<String>('username', '');
    FPassword := AJSon.GetValue<String>('password', '');
    FDatabaseName := AJSon.GetValue<String>('databaseName', '');
  end;
end;

{ TAPIConfig }

class constructor TAPIConfig.ClassCreate;
begin
  FInstance := nil;
end;

class destructor TAPIConfig.ClassDestroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TAPIConfig.GetInstance: TAPIConfig;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAPIConfig.Create;
    try
      FInstance.LoadFromFile;
    except
      FInstance.Free;
      FInstance := nil;
      raise;
    end;
  end;

  result := FInstance;
end;

function TAPIConfig.GetJSonConfig: TJSonValue;
var
  LFileName: String;
begin
  LFileName := TPath.ChangeExtension(ParamStr(0), '.json');
  if not TFile.Exists(LFileName, False) then
    raise EFileNotFoundException.CreateFmt(SConfigNotFound, [LFileName]);

  result := TJSonObject.ParseJSONValue(TFile.ReadAllText(LFileName));
  if not Assigned(result) then
    raise EJSonException.CreateFmt(SConfigNotValid, [LFileName]);
end;

procedure TAPIConfig.LoadFromFile;
var
  LJSon: TJSonValue;
begin
  LJSon := GetJSonConfig;
  try
    FServer.Load(LJSon.GetValue<TJSonValue>('server', nil));
    FCors.Load(LJSon.GetValue<TJSonValue>('cors', nil));
    FDatabase.Load(LJSon.GetValue<TJSonValue>('database', nil));
  finally
    LJSon.Free;
  end;
end;

end.

