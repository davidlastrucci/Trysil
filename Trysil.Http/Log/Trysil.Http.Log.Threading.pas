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
  System.Threading,

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
    constructor Create(
      const ARttiLogWriter: TTHttpRttiLogWriter; const AQueue: TTHttpLogQueue);
    destructor Destroy; override;

    procedure Signal;
  end;

implementation

{ TTHttpLogThread }

constructor TTHttpLogThread.Create(
  const ARttiLogWriter: TTHttpRttiLogWriter; const AQueue: TTHttpLogQueue);
begin
  inherited Create(False);
  FRttiLogWriter := ARttiLogWriter;
  FQueue := AQueue;
  FEvent := TEvent.Create;
  FreeOnTerminate := False;
end;

destructor TTHttpLogThread.Destroy;
begin
  FEvent.Free;
  inherited Destroy;
end;

procedure TTHttpLogThread.Execute;
var
  LValue: TTHttpLogQueueValue;
  LWriter: TTHttpLogAbstractWriter;
begin
  while not Terminated do
  begin
    while not FQueue.IsEmpty do
    begin
      LValue := FQueue.Dequeue;
      LWriter := FRttiLogWriter.CreateLogWriter;
      try
        case LValue.QueueType of
          qtRequest: LWriter.WriteRequest(LValue.Request);
          qtResponse: LWriter.WriteResponse(LValue.Response);
        end;
      finally
        LWriter.Free;
      end;
    end;

    if not Terminated then
    begin
      FEvent.ResetEvent;
      FEvent.WaitFor(20000);
    end;
  end;
end;

procedure TTHttpLogThread.Signal;
begin
  FEvent.SetEvent;
end;

end.
