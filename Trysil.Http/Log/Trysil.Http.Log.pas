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

  Trysil.Http.Classes,
  Trysil.Http.Rtti,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Writer,
  Trysil.Http.Log.Threading;

type

{ TTHttpLog }

  TTHttpLog = class
  strict private
    FLogThreads: TTHttpLogThreads;
    FRttiLogWriter: TTHttpRttiLogWriter;
    FParameters: TTHttpLogParameters;
    FOnCanLog: TFunc<TTHttpRequest, Boolean>;
    FOnRedactContent: TFunc<TTHttpRequest, String, String>;

    function CanLog(const ARequest: TTHttpRequest): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterWriter(
      const ALogWriter: TTHttpRttiLogWriter;
      const AParameters: TTHttpLogParameters);

    procedure LogAction(const ATaskID: String; const AAction: String);
    procedure LogError(
      const ARequest: TTHttpRequest; const AException: Exception);
    procedure LogRequest(const ARequest: TTHttpRequest);
    procedure LogResponse(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);

    property OnCanLog: TFunc<TTHttpRequest, Boolean>
      read FOnCanLog write FOnCanLog;
    property OnRedactContent: TFunc<TTHttpRequest, String, String>
      read FOnRedactContent write FOnRedactContent;
  end;

implementation

{ TTHttpLog }

constructor TTHttpLog.Create;
begin
  inherited Create;
  FLogThreads := TTHttpLogThreads.Create;
  FRttiLogWriter := nil;
  FParameters := TTHttpLogParameters.Create(0, 0);
  FOnCanLog := nil;
  FOnRedactContent := nil;
end;

destructor TTHttpLog.Destroy;
begin
  FLogThreads.Free;
  inherited Destroy;
end;

procedure TTHttpLog.RegisterWriter(
  const ALogWriter: TTHttpRttiLogWriter;
  const AParameters: TTHttpLogParameters);
var
  LQueueCapacity: Integer;
begin
  FRttiLogWriter := ALogWriter;
  FParameters := AParameters;
  if Assigned(FRttiLogWriter) then
  begin
    LQueueCapacity := AParameters.QueueCapacity;
    FLogThreads.CreateItems(
      function: TTHttpLogThread
      begin
        result := TTHttpLogThread.Create(ALogWriter, LQueueCapacity);
      end,
      AParameters.ThreadPoolSize);
  end;
end;

procedure TTHttpLog.LogAction(const ATaskID: String; const AAction: String);
var
  LWriter: TTHttpLogAbstractWriter;
begin
  try
    if Assigned(FRttiLogWriter) then
    begin
      LWriter := FRttiLogWriter.CreateLogWriter;
      try
        LWriter.WriteAction(TTHttpLogAction.Create(ATaskID, AAction));
      finally
        LWriter.Free;
      end;
    end;
  except
    // Logging must not break the operation being logged
  end;
end;

procedure TTHttpLog.LogError(
  const ARequest: TTHttpRequest; const AException: Exception);
var
  LLogThread: TTHttpLogThread;
begin
  try
    if Assigned(FRttiLogWriter) then
    begin
      LLogThread := FLogThreads.Next;
      if Assigned(LLogThread) then
        LLogThread.Add(TTHttpLogError.Create(ARequest, AException));
    end;
  except
    // Logging must not break the operation being logged
  end;
end;

function TTHttpLog.CanLog(const ARequest: TTHttpRequest): Boolean;
begin
  result := Assigned(FRttiLogWriter);
  if result and Assigned(FOnCanLog) then
    result := FOnCanLog(ARequest);
end;

procedure TTHttpLog.LogRequest(const ARequest: TTHttpRequest);
var
  LLogThread: TTHttpLogThread;
begin
  try
    if CanLog(ARequest) then
    begin
      LLogThread := FLogThreads.Next;
      if Assigned(LLogThread) then
        LLogThread.Add(TTHttpLogRequest.Create(
          ARequest, FParameters, FOnRedactContent));
    end;
  except
    // Logging must not break the operation being logged
  end;
end;

procedure TTHttpLog.LogResponse(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
var
  LLogThread: TTHttpLogThread;
begin
  try
    if CanLog(ARequest) then
    begin
      LLogThread := FLogThreads.Next;
      if Assigned(LLogThread) then
        LLogThread.Add(
          TTHttpLogResponse.Create(
            ARequest, AResponse, FParameters, FOnRedactContent));
    end;
  except
    // Logging must not break the operation being logged
  end;
end;

end.
