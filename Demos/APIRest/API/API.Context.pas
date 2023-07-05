(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Context;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SqlServer,
  Trysil.Http.Context,

  API.Config,
  API.Authentication.JWT;

type

{ TAPIContext }

  TAPIContext = class
  strict private
    FConnection: TTConnection;
    FContext: TTHttpContext;
    FPayload: TAPIJWTPayload;
  public
    constructor Create;
    destructor Destroy; override;

    property Context: TTHttpContext read FContext;
    property Payload: TAPIJWTPayload read FPayload;
  end;

implementation

{ TAPIContext }

constructor TAPIContext.Create;
begin
  inherited Create;
  TTFireDACConnectionPool.Instance.Config.Enabled := True;
  FConnection := TTSqlServerConnection.Create(
    TAPIConfig.Instance.Database.ConnectionName);
  FContext := TTHttpContext.Create(FConnection);
  FPayload := TAPIJWTPayload.Create;
end;

destructor TAPIContext.Destroy;
begin
  FPayload.Free;
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;

end.

