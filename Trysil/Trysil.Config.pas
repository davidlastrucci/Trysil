(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Config;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TTConfigPooling }

  TTConfigPooling = class
  strict private
    const DefaultEnabled: Boolean = True;
    const DefaultMaximumItems: Integer = 50;
    const DefaultCleanupTimeout: Integer = 30000;
    const DefaultExpireTimeout: Integer = 90000;
  strict private
    FEnabled: Boolean;
    FMaximumItems: Integer;
    FCleanupTimeout: Integer;
    FExpireTimeout: Integer;
  public
    constructor Create;

    property Enabled: Boolean read FEnabled write FEnabled;
    property MaximumItems: Integer read FMaximumItems write FMaximumItems;
    property CleanupTimeout: Integer read FCleanupTimeout write FCleanupTimeout;
    property ExpireTimeout: Integer read FExpireTimeout write FExpireTimeout;
  end;

{ TTConfig }

  TTConfig = class
  strict private
    class var FInstance: TTConfig;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FPooling: TTConfigPooling;
  public
    constructor Create;
    destructor Destroy; override;

    property Pooling: TTConfigPooling read FPooling;

    class property Instance: TTConfig read FInstance;
  end;

implementation

{ TTConfigPooling }

constructor TTConfigPooling.Create;
begin
  inherited Create;
  FEnabled := DefaultEnabled;
  FMaximumItems := DefaultMaximumItems;
  FCleanupTimeout := DefaultCleanupTimeout;
  FExpireTimeout := DefaultExpireTimeout;
end;

{ TTConfig }

class constructor TTConfig.ClassCreate;
begin
  FInstance := TTConfig.Create;
end;

class destructor TTConfig.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTConfig.Create;
begin
  inherited Create;
  FPooling := TTConfigPooling.Create;
end;

destructor TTConfig.Destroy;
begin
  FPooling.Free;
  inherited Destroy;
end;

end.
