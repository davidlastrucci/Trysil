(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Log;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes,
  Trysil.Http.Rtti,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Classes,
  Trysil.Http.Log.Writer,
  Trysil.Http.Log.Threading;

type

{ TTHttpLog }

  TTHttpLog = class
  strict private
    FQueue: TTHttpLogQueue;
    FLogThread: TTHttpLogThread;
    FRttiLogWriter: TTHttpRttiLogWriter;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterWriter(const ALogWriter: TTHttpRttiLogWriter);

    procedure LogAction(const ATaskID: String; const AAction: String);
    procedure LogRequest(const ARequest: TTHttpRequest);
    procedure LogResponse(
      const AUser: TTHttpUser; const AResponse: TTHttpResponse);
  end;

implementation

{ TTHttpLog }

constructor TTHttpLog.Create;
begin
  inherited Create;
  FQueue := TTHttpLogQueue.Create;
  FLogThread := nil;
  FRttiLogWriter := nil;
end;

destructor TTHttpLog.Destroy;
begin
  if Assigned(FLogThread) then
  begin
    FLogThread.Signal;
    FLogThread.Terminate;
    FLogThread.WaitFor;
    FLogThread.Free;
  end;
  FQueue.Free;
  inherited Destroy;
end;

procedure TTHttpLog.RegisterWriter;
begin
  FRttiLogWriter := ALogWriter;
end;

procedure TTHttpLog.LogAction(const ATaskID: String; const AAction: String);
var
  LWriter: TTHttpLogAbstractWriter;
begin
  if Assigned(FRttiLogWriter) then
  begin
    LWriter := FRttiLogWriter.CreateLogWriter;
    try
      LWriter.WriteAction(TTHttpLogAction.Create(ATaskID, AAction));
    finally
      LWriter.Free;
    end;
  end;
end;

procedure TTHttpLog.LogRequest(const ARequest: TTHttpRequest);
begin
  if Assigned(FRttiLogWriter) then
  begin
    if not Assigned(FLogThread) then
      FLogThread := TTHttpLogThread.Create(FRttiLogWriter, FQueue);
    FQueue.Enqueue(TTHttpLogRequest.Create(ARequest));
    FLogThread.Signal;
  end;
end;

procedure TTHttpLog.LogResponse(
  const AUser: TTHttpUser; const AResponse: TTHttpResponse);
begin
  if Assigned(FRttiLogWriter) then
  begin
    if not Assigned(FLogThread) then
      FLogThread := TTHttpLogThread.Create(FRttiLogWriter, FQueue);
    FQueue.Enqueue(TTHttpLogResponse.Create(AUser, AResponse));
    FLogThread.Signal;
  end;
end;

end.
