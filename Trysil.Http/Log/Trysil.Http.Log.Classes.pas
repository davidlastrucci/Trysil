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
    FDiscarded: TDictionary<String, Integer>;

    function CanEnqueue: Boolean;
    procedure Discard(const AHost: String);
    function GetIsEmpty: Boolean;
  public
    constructor Create(const ACapacity: Integer);
    destructor Destroy; override;

    procedure Enqueue(const ARequest: TTHttpLogRequest); overload;
    procedure Enqueue(const AResponse: TTHttpLogResponse); overload;

    function Dequeue: TTHttpLogQueueValue;
    function TakeDiscarded: TArray<TTHttpLogDiscarded>;

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
  FDiscarded := TDictionary<String, Integer>.Create;
end;

destructor TTHttpLogQueue.Destroy;
begin
  FDiscarded.Free;
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
      Discard(ARequest.Host);
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
      Discard(AResponse.Host);
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

function TTHttpLogQueue.TakeDiscarded: TArray<TTHttpLogDiscarded>;
var
  LPair: TPair<String, Integer>;
  LIndex: Integer;
begin
  FCriticalSection.Enter;
  try
    SetLength(result, FDiscarded.Count);
    LIndex := 0;
    for LPair in FDiscarded do
    begin
      result[LIndex] := TTHttpLogDiscarded.Create(
        LPair.Key, LPair.Value);
      Inc(LIndex);
    end;
    FDiscarded.Clear;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TTHttpLogQueue.Discard(const AHost: String);
var
  LKey: String;
  LCount: Integer;
begin
  LKey := AHost.ToLower();
  if not FDiscarded.TryGetValue(LKey, LCount) then
    LCount := 0;
  FDiscarded.AddOrSetValue(LKey, LCount + 1);
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
