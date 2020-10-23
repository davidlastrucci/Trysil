(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Sync;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs;

type

{ TTCriticalSection }

  TTCriticalSection = class
  strict private
    FCriticalSection: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Acquire;
    procedure Leave;
  end;

implementation

{ TTCriticalSection }

constructor TTCriticalSection.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TTCriticalSection.Destroy;
begin
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTCriticalSection.Acquire;
begin
  FCriticalSection.Acquire;
end;

procedure TTCriticalSection.Leave;
begin
  FCriticalSection.Leave;
end;

end.
