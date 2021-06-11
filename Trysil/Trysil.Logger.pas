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

{ TTLoggerEvent }

  TTLoggerEvent = (
    StartTransaction,
    Commit,
    Rollback,
    Parameter,
    Syntax,
    Error);

{ TTLoggerItem }

  TTLoggerItem = record
  strict private
    FEvent: TTLoggerEvent;
    FMessage: String;
  public
    constructor Create(
      const AEvent: TTLoggerEvent; const AMessage: String);

    property Event: TTLoggerEvent read FEvent;
    property Message: String read FMessage;
  end;

{ TTLoggerQueue }

  TTLoggerQueue = class
  strict private
    FCriticalSection: TTCriticalSection;
    FQueue: TQueue<TTLoggerItem>;

    function GetIsEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Enqueue(const AValue: TTLoggerItem);
    function Dequeue: TTLoggerItem;

    property IsEmpty: Boolean read GetIsEmpty;
  end;

{ TTLoggerThread }

  TTLoggerThread = class abstract(TThread)
  strict private
    FQueue: TTLoggerQueue;
    FEvent: TEvent;

    procedure SetTerminated;
  strict protected
    procedure Log(const AItem: TTLoggerItem); virtual; abstract;

    procedure Execute; override;
  public
  	constructor Create;
    destructor Destroy; override;

    procedure AddLog(const AItem: TTLoggerItem);
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

    procedure Log(const AItem: TTLoggerItem);

    procedure SetLoggerClass(const AValue: TTLoggerThreadClass);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LogStartTransaction;
    procedure LogCommit;
    procedure LogRollback;
    procedure LogParameter(const AName: String; const AValue: String);
    procedure LogSyntax(const ASyntax: String);

    property LoggerClass: TTLoggerThreadClass
      read FLoggerClass write SetLoggerClass;

    class property Instance: TTLogger read FInstance;
  end;

implementation

{ TTLoggerItem }

constructor TTLoggerItem.Create(
  const AEvent: TTLoggerEvent; const AMessage: String);
begin
  FEvent := AEvent;
  FMessage := AMessage;
end;

{ TTLoggerQueue }

constructor TTLoggerQueue.Create;
begin
  inherited Create;
  FCriticalSection := TTCriticalSection.Create;
  FQueue := TQueue<TTLoggerItem>.Create;
end;

destructor TTLoggerQueue.Destroy;
begin
  FQueue.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTLoggerQueue.Enqueue(const AValue: TTLoggerItem);
begin
  FCriticalSection.Acquire;
  try
    FQueue.Enqueue(AValue);
  finally
    FCriticalSection.Leave;
  end;
end;

function TTLoggerQueue.Dequeue: TTLoggerItem;
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

procedure TTLoggerThread.AddLog(const AItem: TTLoggerItem);
begin
  FQueue.Enqueue(AItem);
  FEvent.SetEvent;
end;

procedure TTLoggerThread.Execute;
const
  Timeout: Cardinal = 5000;
begin
  while not Terminated do
  begin
    while not FQueue.IsEmpty do
    begin
      try
        Log(FQueue.Dequeue);
      except
        on E: Exception do
          Log(TTLoggerItem.Create(TTLoggerEvent.Error, E.Message));
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

procedure TTLogger.Log(const AItem: TTLoggerItem);
begin
  if Assigned(FThread) then
    FThread.AddLog(AItem);
end;

procedure TTLogger.LogStartTransaction;
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.StartTransaction, String.Empty));
end;

procedure TTLogger.LogCommit;
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Commit, String.Empty));
end;

procedure TTLogger.LogRollback;
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Rollback, String.Empty));
end;

procedure TTLogger.LogParameter(const AName: String; const AValue: String);
begin
  Log(TTLoggerItem.Create(
    TTLoggerEvent.Parameter, Format(':%0:s="%1:s"', [AName, AValue])));
end;

procedure TTLogger.LogSyntax(const ASyntax: String);
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Syntax, ASyntax));
end;

procedure TTLogger.SetLoggerClass(const AValue: TTLoggerThreadClass);
begin
  if FLoggerClass <> AValue then
  begin
    if Assigned(FThread) then
      FThread.Free;
    FLoggerClass := AValue;
    FThread := FLoggerClass.Create;
  end;
end;

end.
