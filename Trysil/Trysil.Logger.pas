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

  Trysil.Sync,
  Trysil.LoadBalancing;

type

{$SCOPEDENUMS ON}

{ TTLoggerEvent }

  TTLoggerEvent = (
    StartTransaction,
    Commit,
    Rollback,
    Parameter,
    Syntax,
    Command,
    Error);

{ TTLoggerItem }

  TTLoggerItem = record
  strict private
    FEvent: TTLoggerEvent;
    FValues: TArray<String>;
  public
    constructor Create(
      const AEvent: TTLoggerEvent); overload;
    constructor Create(
      const AEvent: TTLoggerEvent; const AValue: String); overload;
    constructor Create(
      const AEvent: TTLoggerEvent; const AValues: TArray<String>); overload;

    property Event: TTLoggerEvent read FEvent;
    property Values: TArray<String> read FValues;
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

    procedure Log(const AItem: TTLoggerItem);

    procedure SetTerminated;
  strict protected
    procedure LogStartTransaction; virtual; abstract;
    procedure LogCommit; virtual; abstract;
    procedure LogRollback; virtual; abstract;
    procedure LogParameter(
      const AName: String; const AValue: String); virtual; abstract;
    procedure LogSyntax(const ASyntax: String); virtual; abstract;
    procedure LogCommand(const ASyntax: String); virtual; abstract;
    procedure LogError(const AMessage: String); virtual; abstract;

    procedure Execute; override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddLog(const AItem: TTLoggerItem);
  end;

{ TTLoggerThreads }

  TTLoggerThreads = class(TTRoundRobin<TTLoggerThread>);

{ TTLogger }

  TTLogger = class
  strict private
    class var FInstance: TTLogger;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    const DefaultThreadPoolSize: Integer = 1;
  strict private
    FThreads: TTLoggerThreads;

    procedure Log(const AItem: TTLoggerItem);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LogStartTransaction;
    procedure LogCommit;
    procedure LogRollback;
    procedure LogParameter(const AName: String; const AValue: String);
    procedure LogSyntax(const ASyntax: String);
    procedure LogCommand(const ASyntax: String);

    procedure RegisterLogger<T: TTLoggerThread>(); overload;
    procedure RegisterLogger<T: TTLoggerThread>(
      const AThreadPoolSize: Integer); overload;

    class property Instance: TTLogger read FInstance;
  end;

implementation

{ TTLoggerItem }

constructor TTLoggerItem.Create(const AEvent: TTLoggerEvent);
begin
  Create(AEvent, []);
end;

constructor TTLoggerItem.Create(
  const AEvent: TTLoggerEvent; const AValue: String);
begin
  Create(AEvent, [AValue]);
end;

constructor TTLoggerItem.Create(
  const AEvent: TTLoggerEvent; const AValues: TArray<String>);
begin
  FEvent := AEvent;
  FValues := Copy(AValues, Low(AValues), Length(AValues));
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
  while (not Terminated) or (not FQueue.IsEmpty) do
  begin
    while not FQueue.IsEmpty do
    begin
      try
        Log(FQueue.Dequeue);
      except
        on E: Exception do
        begin
          try
            Log(TTLoggerItem.Create(TTLoggerEvent.Error, E.Message));
          except
            // Thread should not crash in case of exception
          end;
        end;
      end;
    end;

    if not Terminated then
    begin
      FEvent.ResetEvent;
      FEvent.WaitFor(Timeout);
    end;
  end;
end;

procedure TTLoggerThread.Log(const AItem: TTLoggerItem);
begin
  case AItem.Event of
    TTLoggerEvent.StartTransaction: LogStartTransaction;
    TTLoggerEvent.Commit: LogCommit;
    TTLoggerEvent.Rollback: LogRollback;
    TTLoggerEvent.Parameter: LogParameter(AItem.Values[0], AItem.Values[1]);
    TTLoggerEvent.Syntax: LogSyntax(AItem.Values[0]);
    TTLoggerEvent.Command: LogCommand(AItem.Values[0]);
    TTLoggerEvent.Error: LogError(AItem.Values[0]);
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
  FThreads := TTLoggerThreads.Create;
end;

destructor TTLogger.Destroy;
begin
  FThreads.Free;
  inherited Destroy;
end;

procedure TTLogger.Log(const AItem: TTLoggerItem);
var
  LThread: TTLoggerThread;
begin
  LThread := FThreads.Next;
  if Assigned(LThread) then
    LThread.AddLog(AItem);
end;

procedure TTLogger.LogStartTransaction;
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.StartTransaction));
end;

procedure TTLogger.LogCommit;
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Commit));
end;

procedure TTLogger.LogRollback;
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Rollback));
end;

procedure TTLogger.LogParameter(const AName: String; const AValue: String);
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Parameter, [AName, AValue]));
end;

procedure TTLogger.LogSyntax(const ASyntax: String);
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Syntax, ASyntax));
end;

procedure TTLogger.LogCommand(const ASyntax: String);
begin
  Log(TTLoggerItem.Create(TTLoggerEvent.Command, ASyntax));
end;

procedure TTLogger.RegisterLogger<T>;
begin
  RegisterLogger<T>(DefaultThreadPoolSize);
end;

procedure TTLogger.RegisterLogger<T>(const AThreadPoolSize: Integer);
begin
  FThreads.CreateItems(
    function: TTLoggerThread
    begin
      result := T.Create;
    end,
    AThreadPoolSize);
end;

end.
