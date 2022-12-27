(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Logger.Types;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,

  Trysil.Sync;

type

{ TTLoggerCreateThread<T> }

  TTLoggerCreateThread<T: class> = reference to function: T;

{ TTLoggerThreads<T> }

  TTLoggerThreads<T: class> = class abstract
  strict private
    FCurrentIndex: Integer;
    FCriticalSection: TTCriticalSection;
    FThreads: TObjectList<T>;

    function GetNextThread: T;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateThreads(
      const AThreadPoolSize: Integer;
      const ACreateThread: TTLoggerCreateThread<T>);

    property NextThread: T read GetNextThread;
  end;

implementation

{ TTLoggerThreads<T> }

constructor TTLoggerThreads<T>.Create;
begin
  FCurrentIndex := 0;
  FCriticalSection := TTCriticalSection.Create;
  FThreads := TObjectList<T>.Create(True);
end;

destructor TTLoggerThreads<T>.Destroy;
begin
  FThreads.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTLoggerThreads<T>.CreateThreads(
  const AThreadPoolSize: Integer; const ACreateThread: TTLoggerCreateThread<T>);
var
  LThreadSize, LIndex: Integer;
  LThread: T;
begin
  FCriticalSection.Acquire;
  try
    if FThreads.Count = 0 then
    begin
      LThreadSize := AThreadPoolSize;
      if LThreadSize < 1 then
        LThreadSize := 1;
      for LIndex := 0 to LThreadSize - 1 do
      begin
        LThread := ACreateThread();
        try
          FThreads.Add(LThread);
        except
          LThread.Free;
          raise;
        end;
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTLoggerThreads<T>.GetNextThread: T;
begin
  result := nil;
  if FThreads.Count > 0 then
  begin
    FCriticalSection.Acquire;
    try
      result := FThreads[FCurrentIndex];
      Inc(FCurrentIndex);
      if FCurrentIndex >= FThreads.Count then
        FCurrentIndex := 0;
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

end.
