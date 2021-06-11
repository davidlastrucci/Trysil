(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Logger;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,

  Trysil.Sync;

type

{ TTLoggerQueue }

  TTLoggerQueue = class
  strict private
    FCriticalSection: TTCriticalSection;
    FQueue: TQueue<String>;

    function GetIsEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Enqueue(const AValue: String);
    function DeQueue: String;

    property IsEmpty: Boolean read GetIsEmpty;
  end;

{ TTLoggerThread }

  TTLoggerThread = class abstract(TThread)
  strict private
    FQueue: TTLoggerQueue;
    FEvent: TEvent;

    procedure SetTerminated;
  strict protected
    procedure Log(const AMessage: String); virtual; abstract;
    procedure LogError(const AMessage: String); virtual; abstract;

    procedure Execute; override;
  public
  	constructor Create;
    destructor Destroy; override;

    procedure AddLog(const AMessage: String);
  end;

  TTLoggerThreadClass = class of TTLoggerThread;

{ TTLogger }

  TTLogger = class
  strict private
    class var FInstance: TTLogger;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FLoggerClass: TTLoggerThreadClass;
    FThread: TTLoggerThread;

    procedure Log(const AValue: String);

    procedure SetLoggerClass(const AValue: TTLoggerThreadClass);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LogParameter(const AName: String; const AValue: String);
    procedure LogSyntax(const ASyntax: String);

    property LoggerClass: TTLoggerThreadClass
      read FLoggerClass write SetLoggerClass;

    class property Instance: TTLogger read FInstance;
  end;

implementation

{ TTLoggerQueue }

constructor TTLoggerQueue.Create;
begin
  inherited Create;
  FCriticalSection := TTCriticalSection.Create;
  FQueue := TQueue<String>.Create;
end;

destructor TTLoggerQueue.Destroy;
begin
  FQueue.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTLoggerQueue.Enqueue(const AValue: String);
begin
  FCriticalSection.Acquire;
  try
    FQueue.Enqueue(AValue);
  finally
    FCriticalSection.Leave;
  end;
end;

function TTLoggerQueue.DeQueue: String;
begin
  FCriticalSection.Acquire;
  try
    result := FQueue.Dequeue;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTLoggerQueue.GetIsEmpty: Boolean;
begin
  FCriticalSection.Acquire;
  try
    result := (FQueue.Count = 0);
  finally
    FCriticalSection.Leave;
  end;
end;

{ TTLoggerThread }

constructor TTLoggerThread.Create;
begin
  inherited Create;
  FQueue := TTLoggerQueue.Create;
  FEvent := TEvent.Create;
end;

destructor TTLoggerThread.Destroy;
begin
  SetTerminated();
  FEvent.Free;
  FQueue.Free;
  inherited Destroy;
end;

procedure TTLoggerThread.AddLog(const AMessage: String);
begin
  FQueue.Enqueue(AMessage);
  FEvent.SetEvent;
end;

procedure TTLoggerThread.Execute;
const
  Timeout: Cardinal = 20000;
begin
  while not Terminated do
  begin
    while not FQueue.IsEmpty do
    begin
      try
        Log(FQueue.Dequeue);
      except
        on E: Exception do
          LogError(E.Message);
      end;
    end;

    if not Terminated then
    begin
      FEvent.ResetEvent;
      FEvent.WaitFor(Timeout);
    end;
  end;
end;

procedure TTLoggerThread.SetTerminated;
begin
  Terminate();
  FEvent.SetEvent;
  WaitFor();
end;

{ TTLogger }

class constructor TTLogger.ClassCreate;
begin
  FInstance := TTLogger.Create;
end;

class destructor TTLogger.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTLogger.Create;
begin
  inherited Create;
  FLoggerClass := nil;
  FThread := nil;
end;

destructor TTLogger.Destroy;
begin
  if Assigned(FThread) then
    FThread.Free;
  inherited Destroy;
end;

procedure TTLogger.Log(const AValue: String);
begin
  if Assigned(FThread) then
    FThread.AddLog(AValue);
end;

procedure TTLogger.LogParameter(const AName: String; const AValue: String);
begin
  Log(Format(':%0:s="%1:s"', [AName, AValue]));
end;

procedure TTLogger.LogSyntax(const ASyntax: String);
begin
  Log(ASyntax);
end;

procedure TTLogger.SetLoggerClass(const AValue: TTLoggerThreadClass);
begin
  if Assigned(FThread) then
    FThread.Free;
  FLoggerClass := AValue;
  FThread := FLoggerClass.Create;
end;

end.
