(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Log.Threading;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Trysil.LoadBalancing,

  Trysil.Http.Rtti,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Classes,
  Trysil.Http.Log.Writer;

type

{ TTHttpLogThread }

  TTHttpLogThread = class(TThread)
  strict private
    const DiscardedFlushInterval: Cardinal = 5000;
    const WaitInterval: Cardinal = 20000;
  strict private
    FRttiLogWriter: TTHttpRttiLogWriter;
    FQueue: TTHttpLogQueue;
    FEvent: TEvent;

    procedure WriteDiscarded(const AWriter: TTHttpLogAbstractWriter);
    procedure WriteValue(
      const AWriter: TTHttpLogAbstractWriter;
      const AValue: TTHttpLogQueueValue);
    procedure ProcessQueue(const AWriter: TTHttpLogAbstractWriter);
  strict protected
    procedure Execute; override;
  public
    constructor Create(
      const ARttiLogWriter: TTHttpRttiLogWriter;
      const AQueueCapacity: Integer);
    destructor Destroy; override;

    procedure BeforeDestruction; override;

    procedure Add(const ARequest: TTHttpLogRequest); overload;
    procedure Add(const AResponse: TTHttpLogResponse); overload;
    procedure Add(const AError: TTHttpLogError); overload;
  end;

{ TTHttpLogThreads }

  TTHttpLogThreads = class(TTRoundRobin<TTHttpLogThread>);

implementation

{ TTHttpLogThread }

constructor TTHttpLogThread.Create(
  const ARttiLogWriter: TTHttpRttiLogWriter;
  const AQueueCapacity: Integer);
begin
  inherited Create(False);
  FRttiLogWriter := ARttiLogWriter;
  FQueue := TTHttpLogQueue.Create(AQueueCapacity);
  FEvent := TEvent.Create;
  FreeOnTerminate := False;
end;

destructor TTHttpLogThread.Destroy;
begin
  FEvent.Free;
  FQueue.Free;
  inherited Destroy;
end;

procedure TTHttpLogThread.BeforeDestruction;
begin
  Terminate;
  FEvent.SetEvent;
  WaitFor;
  inherited BeforeDestruction;
end;

procedure TTHttpLogThread.WriteDiscarded(
  const AWriter: TTHttpLogAbstractWriter);
var
  LDiscarded: TArray<TTHttpLogDiscarded>;
  LIndex: Integer;
begin
  LDiscarded := FQueue.TakeDiscarded;
  for LIndex := Low(LDiscarded) to High(LDiscarded) do
    try
      AWriter.WriteDiscarded(LDiscarded[LIndex]);
    except
      // Thread should not crash in case of exception
    end;
end;

procedure TTHttpLogThread.Add(const ARequest: TTHttpLogRequest);
begin
  FQueue.Enqueue(ARequest);
  FEvent.SetEvent;
end;

procedure TTHttpLogThread.Add(const AResponse: TTHttpLogResponse);
begin
  FQueue.Enqueue(AResponse);
  FEvent.SetEvent;
end;

procedure TTHttpLogThread.Add(const AError: TTHttpLogError);
begin
  FQueue.Enqueue(AError);
  FEvent.SetEvent;
end;

procedure TTHttpLogThread.WriteValue(
  const AWriter: TTHttpLogAbstractWriter;
  const AValue: TTHttpLogQueueValue);
begin
  try
    case AValue.QueueType of
      TTHttpLogQueueType.Request: AWriter.WriteRequest(AValue.Request);
      TTHttpLogQueueType.Response: AWriter.WriteResponse(AValue.Response);
      TTHttpLogQueueType.Error: AWriter.WriteError(AValue.Error);
    end;
  except
    // Thread should not crash in case of exception
  end;
end;

procedure TTHttpLogThread.ProcessQueue(
  const AWriter: TTHttpLogAbstractWriter);
var
  LNextFlush: UInt64;
begin
  LNextFlush := TThread.GetTickCount64 + DiscardedFlushInterval;
  while not FQueue.IsEmpty do
  begin
    WriteValue(AWriter, FQueue.Dequeue);
    if TThread.GetTickCount64 >= LNextFlush then
    begin
      WriteDiscarded(AWriter);
      LNextFlush := TThread.GetTickCount64 + DiscardedFlushInterval;
    end;
  end;
  WriteDiscarded(AWriter);
end;

procedure TTHttpLogThread.Execute;
var
  LWriter: TTHttpLogAbstractWriter;
begin
  LWriter := FRttiLogWriter.CreateLogWriter;
  try
    while not Terminated do
    begin
      FEvent.ResetEvent;
      ProcessQueue(LWriter);

      if not Terminated then
        FEvent.WaitFor(WaitInterval);
    end;
  finally
    LWriter.Free;
  end;
end;

end.
