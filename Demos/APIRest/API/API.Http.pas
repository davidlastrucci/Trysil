(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Http;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SqlServer,
  Trysil.JSon.Events,
  Trysil.Http,
  Trysil.Http.Classes,
  Trysil.Http.Log.Types,

  API.Config,
  API.Context,
  API.Model.Company,
  API.Model.Employee,
  API.Log.Writer,
  API.Authentication,
  API.Authentication.JWT,
  API.Authentication.Controller,
  API.Controller;

type

{ TAPIHttp }

  TAPIHttp = class
  strict private
    FServer: TTHttpServer<TAPIContext>;

    procedure RegisterLogWriter;
    procedure RegisterAuthentication;
    procedure RegisterControllers;

    function GetPort: Word;
    function GetStarted: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure Start;
    procedure Stop;

    property Port: Word read GetPort;
    property Started: Boolean read GetStarted;
  end;

implementation

{ TAPIHttp }

constructor TAPIHttp.Create;
begin
  inherited Create;
  FServer := TTHttpServer<TAPIContext>.Create;
end;

destructor TAPIHttp.Destroy;
begin
  FServer.Free;
  inherited Destroy;
end;

procedure TAPIHttp.AfterConstruction;
begin
  inherited AfterConstruction;
  FServer.BaseUri := TAPIConfig.Instance.Server.BaseUri;
  FServer.Port := TAPIConfig.Instance.Server.Port;

  FServer.CorsConfig.AllowHeaders := TAPIConfig.Instance.Cors.AllowHeaders;
  FServer.CorsConfig.AllowOrigin := TAPIConfig.Instance.Cors.AllowOrigin;

  TAPIJWTPayload.CheckSecretIsConfigured;

  TTFireDACConnectionPool.Instance.Config.Enabled := True;

  TTSqlServerConnection.RegisterConnection(
    TAPIConfig.Instance.Database.ConnectionName,
    TAPIConfig.Instance.Database.Server,
    TAPIConfig.Instance.Database.Username,
    TAPIConfig.Instance.Database.Password,
    TAPIConfig.Instance.Database.DatabaseName);

  RegisterLogWriter;
  RegisterAuthentication;
  RegisterControllers;
end;

procedure TAPIHttp.RegisterLogWriter;
begin
  FServer.RegisterLogWriter<TAPILogWriter>(
    TTHttpLogParameters.Create(2, 10000, 65536));

  FServer.OnRedactContent :=
    function(ARequest: TTHttpRequest; AContent: String): String
    begin
      result := AContent;
      if ARequest.ControllerID.Uri.ToLower().Contains('logon') then
        result := '<redacted>';
    end;
end;

procedure TAPIHttp.RegisterAuthentication;
begin
  FServer.RegisterAuthentication<TAPIAuthentication>();
end;

procedure TAPIHttp.RegisterControllers;
begin
  FServer.RegisterController<TAPILogonController>();
  FServer.RegisterController<TAPIReadWriteController<TAPICompany>>('/company');
  FServer.RegisterController<TAPIReadWriteController<TAPIEmployee>>('/employee');
end;

procedure TAPIHttp.Start;
begin
  FServer.Start;
end;

procedure TAPIHttp.Stop;
begin
  FServer.Stop;
end;

function TAPIHttp.GetPort: Word;
begin
  result := FServer.Port;
end;

function TAPIHttp.GetStarted: Boolean;
begin
  result := FServer.Started;
end;

end.

