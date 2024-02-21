(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.MultiTenant.SQLite;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.SQLite,

  Trysil.Http.MultiTenant.Connection;

type

{ TTSQLiteTenantConnection }

  TTSQLiteTenantConnection = class(TTTenantConnection)
  strict protected
    function GetConnectionClass: TTFireDACConnectionClass; override;
    procedure RegisterConnection; override;
  end;

implementation

{ TTSQLiteTenantConnection }

function TTSQLiteTenantConnection.GetConnectionClass: TTFireDACConnectionClass;
begin
  result := TTSQLiteConnection;
end;

procedure TTSQLiteTenantConnection.RegisterConnection;
begin
  if FConfig.Username.IsEmpty and FConfig.Password.IsEmpty then
    TTSQLiteConnection.RegisterConnection(
      FConfig.ConnectionName, FConfig.DatabaseName)
  else
    TTSQLiteConnection.RegisterConnection(
      FConfig.ConnectionName,
      FConfig.Username,
      FConfig.Password,
      FConfig.DatabaseName);
end;

end.

