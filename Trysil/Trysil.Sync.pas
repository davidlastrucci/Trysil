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
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Acquire;
    procedure Release;
  end;

{ TTMultiReadExclusiveWriteLock }

  TTMultiReadExclusiveWriteLock = class
  strict private
    FLock: TMultiReadExclusiveWriteSynchronizer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginRead;
    procedure EndRead;
    procedure BeginWrite;
    procedure EndWrite;
  end;

implementation

{ TTCriticalSection }

constructor TTCriticalSection.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TTCriticalSection.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

procedure TTCriticalSection.Acquire;
begin
  FLock.Acquire;
end;

procedure TTCriticalSection.Release;
begin
  FLock.Release;
end;

{ TTMultiReadExclusiveWriteLock }

constructor TTMultiReadExclusiveWriteLock.Create;
begin
  inherited Create;
  FLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TTMultiReadExclusiveWriteLock.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

procedure TTMultiReadExclusiveWriteLock.BeginRead;
begin
  FLock.BeginRead;
end;

procedure TTMultiReadExclusiveWriteLock.EndRead;
begin
  FLock.EndRead;
end;

procedure TTMultiReadExclusiveWriteLock.BeginWrite;
begin
  FLock.BeginWrite;
end;

procedure TTMultiReadExclusiveWriteLock.EndWrite;
begin
  FLock.EndWrite;
end;

end.
