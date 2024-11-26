(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.MultiTenant.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Data.FireDAC;

type

{ TTTenantConfig }

  TTTenantConfig = class abstract
  strict protected
    FName: String;

    function GetConnectionName: String; virtual; abstract;
    function GetParameters: TTFireDACConnectionParameters; virtual; abstract;
  public
    constructor Create(const AName: String); virtual;

    property ConnectionName: String read GetConnectionName;
    property Parameters: TTFireDACConnectionParameters read GetParameters;
  end;

implementation

{ TTTenantConfig }

constructor TTTenantConfig.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
end;

end.
