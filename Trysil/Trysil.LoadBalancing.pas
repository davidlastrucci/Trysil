(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.LoadBalancing;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,

  Trysil.Sync;

type

{ TTCreateItem<T> }

  TTCreateItem<T: class> = reference to function: T;

{ TTRoundRobin<T> }

  TTRoundRobin<T: class> = class abstract
  strict private
    FIndex: Integer;
    FCriticalSection: TTCriticalSection;
    FItems: TObjectList<T>;

    function GetNext: T;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateItems(
      const ACreateItem: TTCreateItem<T>;
      const APoolSize: Integer);

    property Next: T read GetNext;
  end;

implementation

{ TTRoundRobin<T> }

constructor TTRoundRobin<T>.Create;
begin
  FIndex := -1;
  FCriticalSection := TTCriticalSection.Create;
  FItems := TObjectList<T>.Create(True);
end;

destructor TTRoundRobin<T>.Destroy;
begin
  FItems.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTRoundRobin<T>.CreateItems(
  const ACreateItem: TTCreateItem<T>; const APoolSize: Integer);
var
  LSize, LIndex: Integer;
  LItem: T;
begin
  FCriticalSection.Acquire;
  try
    LSize := APoolSize;
    if LSize < 1 then
      LSize := 1;
    for LIndex := 0 to LSize - 1 do
    begin
      LItem := ACreateItem();
      try
        FItems.Add(LItem);
      except
        LItem.Free;
        raise;
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTRoundRobin<T>.GetNext: T;
begin
  result := nil;
  if FItems.Count > 0 then
  begin
    FCriticalSection.Acquire;
    try
      Inc(FIndex);
      if FIndex >= FItems.Count then
        FIndex := 0;
      result := FItems[FIndex];
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

end.
