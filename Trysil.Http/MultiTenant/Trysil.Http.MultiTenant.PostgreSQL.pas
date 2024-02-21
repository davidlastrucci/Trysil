(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.MultiTenant.PostgreSQL;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.PostgreSQL,

  Trysil.Http.MultiTenant.Connection;

type

{ TTPostgreSQLTenantConnection }

  TTPostgreSQLTenantConnection = class(TTTenantConnection)
  strict protected
    function GetConnectionClass: TTFireDACConnectionClass; override;
    procedure RegisterConnection; override;
  end;

implementation

{ TTPostgreSQLTenantConnection }

function TTPostgreSQLTenantConnection.GetConnectionClass: TTFireDACConnectionClass;
begin
  result := TTPostgreSQLConnection;
end;

procedure TTPostgreSQLTenantConnection.RegisterConnection;
begin
  if FConfig.Port = 0 then
    TTPostgreSQLConnection.RegisterConnection(
      FConfig.ConnectionName,
      FConfig.Server,
      FConfig.Username,
      FConfig.Password,
      FConfig.DatabaseName)
  else
    TTPostgreSQLConnection.RegisterConnection(
      FConfig.ConnectionName,
      FConfig.Server,
      FConfig.Port,
      FConfig.Username,
      FConfig.Password,
      FConfig.DatabaseName);
end;

end.
