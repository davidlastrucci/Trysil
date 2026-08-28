(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Log.Classes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,

  Trysil.Http.Log.Types;

type

{ TTHttpLogQueue }

  TTHttpLogQueue = class
  strict private
    FCriticalSection: TCriticalSection;
    FQueue: TQueue<TTHttpLogQueueValue>;
    FCapacity: Integer;
    FDiscarded: Integer;

    function CanEnqueue: Boolean;
    function GetIsEmpty: Boolean;
  public
    constructor Create(const ACapacity: Integer);
    destructor Destroy; override;

    procedure Enqueue(const ARequest: TTHttpLogRequest); overload;
    procedure Enqueue(const AResponse: TTHttpLogResponse); overload;

    function Dequeue: TTHttpLogQueueValue;
    function TakeDiscarded: Integer;

    property IsEmpty: Boolean read GetIsEmpty;
  end;

implementation

{ TTHttpLogQueue }

constructor TTHttpLogQueue.Create(const ACapacity: Integer);
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
  FQueue := TQueue<TTHttpLogQueueValue>.Create;
  FCapacity := ACapacity;
  FDiscarded := 0;
end;

destructor TTHttpLogQueue.Destroy;
begin
  FQueue.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTHttpLogQueue.Enqueue(const ARequest: TTHttpLogRequest);
begin
  FCriticalSection.Enter;
  try
    if CanEnqueue then
      FQueue.Enqueue(TTHttpLogQueueValue.Create(ARequest))
    else
      Inc(FDiscarded);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TTHttpLogQueue.Enqueue(const AResponse: TTHttpLogResponse);
begin
  FCriticalSection.Enter;
  try
    if CanEnqueue then
      FQueue.Enqueue(TTHttpLogQueueValue.Create(AResponse))
    else
      Inc(FDiscarded);
  finally
    FCriticalSection.Leave;
  end;
end;

function TTHttpLogQueue.Dequeue: TTHttpLogQueueValue;
begin
  FCriticalSection.Enter;
  try
    result := FQueue.Dequeue;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTHttpLogQueue.TakeDiscarded: Integer;
begin
  FCriticalSection.Enter;
  try
    result := FDiscarded;
    FDiscarded := 0;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTHttpLogQueue.CanEnqueue: Boolean;
begin
  result := (FCapacity < 0) or (FQueue.Count < FCapacity);
end;

function TTHttpLogQueue.GetIsEmpty: Boolean;
begin
  FCriticalSection.Enter;
  try
    result := (FQueue.Count = 0);
  finally
    FCriticalSection.Leave;
  end;
end;

end.
