(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.MultiTenant.Connection;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Data,
  Trysil.Data.FireDAC,

  Trysil.Http.MultiTenant.Config;

type

{ TTTenantConnection }

  TTTenantConnection = class
  strict protected
    FConfig: TTTenantConfig;
  public
    constructor Create(const AConfig: TTTenantConfig);

    procedure AfterConstruction; override;

    function CreateConnection: TTConnection;
  end;

implementation

{ TTTenantConnection }

constructor TTTenantConnection.Create(const AConfig: TTTenantConfig);
begin
  inherited Create;
  FConfig := AConfig;
end;

procedure TTTenantConnection.AfterConstruction;
begin
  inherited AfterConstruction;
  TTFireDACConnectionFactory.Instance.RegisterConnection(
    FConfig.ConnectionName, FConfig.Parameters);
end;

function TTTenantConnection.CreateConnection: TTConnection;
begin
  result := TTFireDACConnectionFactory.Instance.CreateConnection(
    FConfig.ConnectionName);
end;

end.
