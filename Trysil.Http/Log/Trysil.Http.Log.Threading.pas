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
  System.Generics.Collections,
  System.SyncObjs,
  System.Threading,
  Trysil.LoadBalancing,

  Trysil.Http.Rtti,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Classes,
  Trysil.Http.Log.Writer;

type

{ TTHttpLogThread }

  TTHttpLogThread = class(TThread)
  strict private
    FRttiLogWriter: TTHttpRttiLogWriter;
    FQueue: TTHttpLogQueue;
    FEvent: TEvent;
  strict protected
    procedure Execute; override;
  public
    constructor Create(const ARttiLogWriter: TTHttpRttiLogWriter);
    destructor Destroy; override;

    procedure BeforeDestruction; override;

    procedure Add(const ARequest: TTHttpLogRequest); overload;
    procedure Add(const AResponse: TTHttpLogResponse); overload;
  end;

{ TTHttpLogThreads }

  TTHttpLogThreads = class(TTRoundRobin<TTHttpLogThread>);

implementation

{ TTHttpLogThread }

constructor TTHttpLogThread.Create(const ARttiLogWriter: TTHttpRttiLogWriter);
begin
  inherited Create(False);
  FRttiLogWriter := ARttiLogWriter;
  FQueue := TTHttpLogQueue.Create;
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
  FEvent.SetEvent;
  Terminate;
  WaitFor;
  inherited BeforeDestruction;
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

procedure TTHttpLogThread.Execute;
var
  LWriter: TTHttpLogAbstractWriter;
  LValue: TTHttpLogQueueValue;
begin
  LWriter := FRttiLogWriter.CreateLogWriter;
  try
    while not Terminated do
    begin
      while not FQueue.IsEmpty do
      begin
        LValue := FQueue.Dequeue;
        try
          case LValue.QueueType of
            TTHttpLogQueueType.Request: LWriter.WriteRequest(LValue.Request);
            TTHttpLogQueueType.Response: LWriter.WriteResponse(LValue.Response);
          end;
        except
          // Thread should not crash in case of exception
        end;
      end;

      if not Terminated then
      begin
        FEvent.ResetEvent;
        FEvent.WaitFor(20000);
      end;
    end;
  finally
    LWriter.Free;
  end;
end;

end.
