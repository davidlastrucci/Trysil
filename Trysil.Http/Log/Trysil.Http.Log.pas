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
    FLogThreads: TTHttpLogThreads;
    FRttiLogWriter: TTHttpRttiLogWriter;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterWriter(
      const ALogWriter: TTHttpRttiLogWriter;
      const ALogThreadPoolSize: Integer);

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
  FLogThreads := TTHttpLogThreads.Create;
  FRttiLogWriter := nil;
end;

destructor TTHttpLog.Destroy;
begin
  FLogThreads.Free;
  inherited Destroy;
end;

procedure TTHttpLog.RegisterWriter(
  const ALogWriter: TTHttpRttiLogWriter; const ALogThreadPoolSize: Integer);
begin
  FRttiLogWriter := ALogWriter;
  FLogThreads.CreateItems(
    function: TTHttpLogThread
    begin
      result := TTHttpLogThread.Create(ALogWriter);
    end,
    ALogThreadPoolSize);
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
var
  LLogThread: TTHttpLogThread;
begin
  LLogThread := FLogThreads.Next;
  if Assigned(LLogThread) then
    LLogThread.Add(TTHttpLogRequest.Create(ARequest));
end;

procedure TTHttpLog.LogResponse(
  const AUser: TTHttpUser; const AResponse: TTHttpResponse);
var
  LLogThread: TTHttpLogThread;
begin
  LLogThread := FLogThreads.Next;
  if Assigned(LLogThread) then
    LLogThread.Add(TTHttpLogResponse.Create(AUser, AResponse));
end;

end.
