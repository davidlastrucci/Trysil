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

{ TTLoggerItemID }

  TTLoggerItemID = record
  strict private
    FConnectionID: String;
    FThreadID: TThreadID;
  public
    constructor Create(const AConnectionID: String);

    property ConnectionID: String read FConnectionID;
    property ThreadID: TThreadID read FThreadID;
  end;

{ TTLoggerItem }

  TTLoggerItem = record
  strict private
    FID: TTLoggerItemID;
    FEvent: TTLoggerEvent;
    FValues: TArray<String>;
  public
    constructor Create(
      const AConnectionID: String;
      const AEvent: TTLoggerEvent); overload;
    constructor Create(
      const AConnectionID: String;
      const AEvent: TTLoggerEvent;
      const AValue: String); overload;
    constructor Create(
      const AConnectionID: String;
      const AEvent: TTLoggerEvent;
      const AValues: TArray<String>); overload;

    property ID: TTLoggerItemID read FID;
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

{ TTLoggerMethod }

  TTLoggerMethod = procedure(const AItem: TTLoggerItem) of object;

{ TTLoggerThread }

  TTLoggerThread = class abstract(TThread)
  strict private
    FLoggerMethods: TDictionary<TTLoggerEvent, TTLoggerMethod>;
    FQueue: TTLoggerQueue;
    FEvent: TEvent;

    procedure Log(const AItem: TTLoggerItem);
    procedure DrainQueue;

    procedure SetTerminated;

    procedure InternalLogStartTransaction(const AItem: TTLoggerItem);
    procedure InternalLogCommit(const AItem: TTLoggerItem);
    procedure InternalLogRollback(const AItem: TTLoggerItem);
    procedure InternalLogParameter(const AItem: TTLoggerItem);
    procedure InternalLogSyntax(const AItem: TTLoggerItem);
    procedure InternalLogCommand(const AItem: TTLoggerItem);
    procedure InternalLogError(const AItem: TTLoggerItem);
  strict protected
    procedure LogStartTransaction(const AID: TTLoggerItemID); virtual; abstract;
    procedure LogCommit(const AID: TTLoggerItemID); virtual; abstract;
    procedure LogRollback(const AID: TTLoggerItemID); virtual; abstract;
    procedure LogParameter(
      const AID: TTLoggerItemID;
      const AName: String;
      const AValue: String); virtual; abstract;
    procedure LogSyntax(
      const AID: TTLoggerItemID; const ASyntax: String); virtual; abstract;
    procedure LogCommand(
      const AID: TTLoggerItemID; const ASyntax: String); virtual; abstract;
    procedure LogError(
      const AID: TTLoggerItemID; const AMessage: String); virtual; abstract;

    procedure RegisterMethods;
    procedure Execute; override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure BeforeDestruction; override;

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
    FEnabled: Boolean;

    procedure Log(const AItem: TTLoggerItem);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LogStartTransaction(const AConnectionID: String);
    procedure LogCommit(const AConnectionID: String);
    procedure LogRollback(const AConnectionID: String);
    procedure LogParameter(
      const AConnectionID: String;
      const AName: String;
      const AValue: String);
    procedure LogSyntax(const AConnectionID: String; const ASyntax: String);
    procedure LogCommand(const AConnectionID: String; const ASyntax: String);
    procedure LogError(const AConnectionID: String; const AMessage: String);

    procedure RegisterLogger<T: TTLoggerThread>(); overload;
    procedure RegisterLogger<T: TTLoggerThread>(
      const AThreadPoolSize: Integer); overload;

    property Enabled: Boolean read FEnabled;

    class property Instance: TTLogger read FInstance;
  end;

implementation

{ TTLoggerItemID }

constructor TTLoggerItemID.Create(const AConnectionID: String);
begin
  FConnectionID := AConnectionID;
  FThreadID := TThread.Current.ThreadID;
end;

{ TTLoggerItem }

constructor TTLoggerItem.Create(
  const AConnectionID: String; const AEvent: TTLoggerEvent);
begin
  Create(AConnectionID, AEvent, []);
end;

constructor TTLoggerItem.Create(
  const AConnectionID: String;
  const AEvent: TTLoggerEvent;
  const AValue: String);
begin
  Create(AConnectionID, AEvent, [AValue]);
end;

constructor TTLoggerItem.Create(
  const AConnectionID: String;
  const AEvent: TTLoggerEvent;
  const AValues: TArray<String>);
begin
  FID := TTLoggerItemID.Create(AConnectionID);
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
    FCriticalSection.Release;
  end;
end;

function TTLoggerQueue.Dequeue: TTLoggerItem;
begin
  FCriticalSection.Acquire;
  try
    result := FQueue.Dequeue;
  finally
    FCriticalSection.Release;
  end;
end;

function TTLoggerQueue.GetIsEmpty: Boolean;
begin
  FCriticalSection.Acquire;
  try
    result := (FQueue.Count = 0);
  finally
    FCriticalSection.Release;
  end;
end;

{ TTLoggerThread }

constructor TTLoggerThread.Create;
begin
  inherited Create;
  FLoggerMethods := TDictionary<TTLoggerEvent, TTLoggerMethod>.Create;
  FQueue := TTLoggerQueue.Create;
  FEvent := TEvent.Create;
  RegisterMethods;
end;

destructor TTLoggerThread.Destroy;
begin
  FEvent.Free;
  FQueue.Free;
  FLoggerMethods.Free;
  inherited Destroy;
end;

procedure TTLoggerThread.BeforeDestruction;
begin
  SetTerminated();
  inherited BeforeDestruction;
end;

procedure TTLoggerThread.AddLog(const AItem: TTLoggerItem);
begin
  FQueue.Enqueue(AItem);
  FEvent.SetEvent;
end;

procedure TTLoggerThread.RegisterMethods;
begin
  FLoggerMethods.Add(TTLoggerEvent.StartTransaction, InternalLogStartTransaction);
  FLoggerMethods.Add(TTLoggerEvent.Commit, InternalLogCommit);
  FLoggerMethods.Add(TTLoggerEvent.Rollback, InternalLogRollback);
  FLoggerMethods.Add(TTLoggerEvent.Parameter, InternalLogParameter);
  FLoggerMethods.Add(TTLoggerEvent.Syntax, InternalLogSyntax);
  FLoggerMethods.Add(TTLoggerEvent.Command, InternalLogCommand);
  FLoggerMethods.Add(TTLoggerEvent.Error, InternalLogError);
end;

procedure TTLoggerThread.Execute;
const
  Timeout: Cardinal = 5000;
begin
  while not Terminated do
  begin
    FEvent.ResetEvent;
    DrainQueue();

    if not Terminated then
      FEvent.WaitFor(Timeout);
  end;
end;

procedure TTLoggerThread.InternalLogStartTransaction(const AItem: TTLoggerItem);
begin
  LogStartTransaction(AItem.ID);
end;

procedure TTLoggerThread.InternalLogCommit(const AItem: TTLoggerItem);
begin
  LogCommit(AItem.ID);
end;

procedure TTLoggerThread.InternalLogRollback(const AItem: TTLoggerItem);
begin
  LogRollback(AItem.ID);
end;

procedure TTLoggerThread.InternalLogParameter(const AItem: TTLoggerItem);
begin
  LogParameter(AItem.ID, AItem.Values[0], AItem.Values[1]);
end;

procedure TTLoggerThread.InternalLogSyntax(const AItem: TTLoggerItem);
begin
  LogSyntax(AItem.ID, AItem.Values[0]);
end;

procedure TTLoggerThread.InternalLogCommand(const AItem: TTLoggerItem);
begin
  LogCommand(AItem.ID, AItem.Values[0]);
end;

procedure TTLoggerThread.InternalLogError(const AItem: TTLoggerItem);
begin
  LogError(AItem.ID, AItem.Values[0]);
end;

procedure TTLoggerThread.Log(const AItem: TTLoggerItem);
var
  LLoggerMethod: TTLoggerMethod;
begin
  if FLoggerMethods.TryGetValue(AItem.Event, LLoggerMethod) then
    LLoggerMethod(AItem);
end;

procedure TTLoggerThread.DrainQueue;
begin
  while not FQueue.IsEmpty do
  try
    Log(FQueue.Dequeue);
  except
    // Thread should not crash in case of exception
  end;
end;

procedure TTLoggerThread.SetTerminated;
begin
  FreeOnTerminate := False;
  Terminate();
  FEvent.SetEvent;
  if Suspended then
    Suspended := False;
  WaitFor();
  DrainQueue();
end;

{ TTLogger }

class constructor TTLogger.ClassCreate;
begin
  FInstance := TTLogger.Create;
end;

class destructor TTLogger.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTLogger.Create;
begin
  inherited Create;
  FThreads := TTLoggerThreads.Create;
  FEnabled := False;
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
  if FEnabled then
  begin
    LThread := FThreads.Next;
    if Assigned(LThread) then
      LThread.AddLog(AItem);
  end;
end;

procedure TTLogger.LogStartTransaction(const AConnectionID: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(AConnectionID, TTLoggerEvent.StartTransaction));
end;

procedure TTLogger.LogCommit(const AConnectionID: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(AConnectionID, TTLoggerEvent.Commit));
end;

procedure TTLogger.LogRollback(const AConnectionID: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(AConnectionID, TTLoggerEvent.Rollback));
end;

procedure TTLogger.LogParameter(
  const AConnectionID: String; const AName: String; const AValue: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(
      AConnectionID, TTLoggerEvent.Parameter, [AName, AValue]));
end;

procedure TTLogger.LogSyntax(const AConnectionID: String; const ASyntax: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(AConnectionID, TTLoggerEvent.Syntax, ASyntax));
end;

procedure TTLogger.LogCommand(const AConnectionID: String; const ASyntax: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(AConnectionID, TTLoggerEvent.Command, ASyntax));
end;

procedure TTLogger.LogError(
  const AConnectionID: String; const AMessage: String);
begin
  if FEnabled then
    Log(TTLoggerItem.Create(AConnectionID, TTLoggerEvent.Error, AMessage));
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
  FEnabled := True;
end;

end.
