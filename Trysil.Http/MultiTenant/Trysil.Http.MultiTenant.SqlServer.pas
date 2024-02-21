(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.MultiTenant.SqlServer;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.SqlServer,

  Trysil.Http.MultiTenant.Connection;

type

{ TTSqlServerTenantConnection }

  TTSqlServerTenantConnection = class(TTTenantConnection)
  strict protected
    function GetConnectionClass: TTFireDACConnectionClass; override;
    procedure RegisterConnection; override;
  end;

implementation

{ TTSqlServerTenantConnection }

function TTSqlServerTenantConnection.GetConnectionClass: TTFireDACConnectionClass;
begin
  result := TTSqlServerConnection;
end;

procedure TTSqlServerTenantConnection.RegisterConnection;
begin
  if FConfig.Username.IsEmpty and FConfig.Password.IsEmpty then
    TTSqlServerConnection.RegisterConnection(
      FConfig.ConnectionName, FConfig.Server, FConfig.DatabaseName)
  else
    TTSqlServerConnection.RegisterConnection(
      FConfig.ConnectionName,
      FConfig.Server,
      FConfig.Username,
      FConfig.Password,
      FConfig.DatabaseName);
end;

end.

