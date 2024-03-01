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

{ TTFireDACConnectionClass }

  TTFireDACConnectionClass = class of TTFireDACConnection;

{ TTTenantConnection }

  TTTenantConnection = class abstract
  strict protected
    FConfig: TTTenantConfig;

    function GetConnectionClass: TTFireDACConnectionClass; virtual; abstract;
    procedure RegisterConnection; virtual; abstract;
  public
    constructor Create(const AConfig: TTTenantConfig); virtual;

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
  RegisterConnection;
end;

function TTTenantConnection.CreateConnection: TTConnection;
begin
  result := GetConnectionClass().Create(FConfig.ConnectionName);
end;

end.
