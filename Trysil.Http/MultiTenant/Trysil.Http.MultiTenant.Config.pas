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
  System.Classes;

type

{ TTTenantConfig }

  TTTenantConfig = class abstract
  strict protected
    FName: String;

    function GetConnectionName: String; virtual; abstract;
    function GetServer: String; virtual; abstract;
    function GetPort: Integer; virtual; abstract;
    function GetUsername: String; virtual; abstract;
    function GetPassword: String; virtual; abstract;
    function GetDatabaseName: String; virtual; abstract;
  public
    constructor Create(const AName: String); virtual;

    property ConnectionName: String read GetConnectionName;
    property Server: String read GetServer;
    property Port: Integer read GetPort;
    property Username: String read GetUsername;
    property Password: String read GetPassword;
    property DatabaseName: String read GetDatabaseName;
  end;

implementation

{ TTTenantConfig }

constructor TTTenantConfig.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
end;

end.
