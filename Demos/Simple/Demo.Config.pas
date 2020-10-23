(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Demo.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.IOUtils,
  System.Generics.Collections,
  Trysil.Classes;

type

{ TConnectionConfig }

  TConnectionConfig = class
  strict private
    FName: String;
    FServer: String;
    FUsername: String;
    FPassword: String;
    FDatabaseName: String;
  private // internal
    procedure LoadFromJSon(const AJSon: TJSonValue);
  public
    property Name: String read FName;
    property Server: String read FServer;
    property Username: String read FUsername;
    property Password: String read FPassword;
    property DatabaseName: String read FDatabaseName;
  end;

{ TConnectionsConfig }

  TConnectionsConfig = class
  strict private
    FConnections: TObjectList<TConnectionConfig>;
  private // internal
    procedure LoadFromJSon(const AJSon: TJSonArray);
  public
    constructor Create;
    destructor Destroy; override;

    function GetEnumerator: TTListEnumerator<TConnectionConfig>;
  end;

{ TConfig }

  TConfig = class
  strict private
    FConnections: TConnectionsConfig;

    function GetJSonConfig: TJSonValue;
    procedure Load;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    property Connections: TConnectionsConfig read FConnections;
  end;

resourcestring
  SConfigNotFound = 'Configuration file "%s" not found.';
  SConfigNotValid = 'Configuration file "%s" not valid.';

implementation

{ TConnectionConfig }

procedure TConnectionConfig.LoadFromJSon(const AJSon: TJSonValue);
begin
  FName := AJSon.GetValue<String>('name', '');
  FServer := AJSon.GetValue<String>('server', '');
  FUsername := AJSon.GetValue<String>('username', '');
  FPassword := AJSon.GetValue<String>('password', '');
  FDatabaseName := AJSon.GetValue<String>('databasename', '');
end;

{ TConnectionsConfig }

constructor TConnectionsConfig.Create;
begin
  inherited Create;
  FConnections := TObjectList<TConnectionConfig>.Create(True);
end;

destructor TConnectionsConfig.Destroy;
begin
  FConnections.Free;
  inherited Destroy;
end;

procedure TConnectionsConfig.LoadFromJSon(const AJSon: TJSonArray);
var
  LItem: TJSonValue;
  LConnection: TConnectionConfig;
begin
    for LItem in AJSon do
    begin
      LConnection := TConnectionConfig.Create;
      try
        LConnection.LoadFromJSon(LItem);
        FConnections.Add(LConnection);
      except
        LConnection.Free;
        raise;
      end;
    end;
end;

function TConnectionsConfig.GetEnumerator: TTListEnumerator<TConnectionConfig>;
begin
  result := TTListEnumerator<TConnectionConfig>.Create(FConnections);
end;

{ TConfig }

constructor TConfig.Create;
begin
  inherited Create;
  FConnections := TConnectionsConfig.Create;
end;

destructor TConfig.Destroy;
begin
  FConnections.Free;
  inherited Destroy;
end;

procedure TConfig.AfterConstruction;
begin
  inherited AfterConstruction;
  Load;
end;

function TConfig.GetJSonConfig: TJSonValue;
var
    LFileName: String;
begin
    LFileName := TPath.ChangeExtension(ParamStr(0), '.config.json');
    if not TFile.Exists(LFileName, False) then
        raise EFileNotFoundException.CreateFmt(SConfigNotFound, [LFileName]);

    result := TJSonObject.ParseJSONValue(TFile.ReadAllText(LFileName));
    if not Assigned(result) then
        raise EJSonException.CreateFmt(SConfigNotValid, [LFileName]);
end;

procedure TConfig.Load;
var
  LJSon: TJSonValue;
  LConnections: TJSonArray;
begin
  LJSon := GetJSonConfig;
  try
    LConnections := LJSon.GetValue<TJSonArray>('connections', nil);
    if Assigned(LConnections) then
      FConnections.LoadFromJSon(LConnections);
  finally
    LJSon.Free;
  end;
end;

end.
