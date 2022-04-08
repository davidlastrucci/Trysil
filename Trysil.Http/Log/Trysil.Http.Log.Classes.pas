(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Log.Classes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,

  Trysil.Http.Log.Types;

type

{ TTHttpLogQueue }

  TTHttpLogQueue = class
  strict private
    FCriticalSection: TCriticalSection;
    FQueue: TQueue<TTHttpLogQueueValue>;

    function GetIsEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Enqueue(const ARequest: TTHttpLogRequest); overload;
    procedure Enqueue(const AResponse: TTHttpLogResponse); overload;

    function Dequeue: TTHttpLogQueueValue;

    property IsEmpty: Boolean read GetIsEmpty;
  end;

implementation

{ TTHttpLogQueue }

constructor TTHttpLogQueue.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
  FQueue := TQueue<TTHttpLogQueueValue>.Create;
end;

destructor TTHttpLogQueue.Destroy;
begin
  FQueue.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTHttpLogQueue.Enqueue(const ARequest: TTHttpLogRequest);
begin
  FCriticalSection.Enter;
  try
    FQueue.Enqueue(TTHttpLogQueueValue.Create(ARequest));
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TTHttpLogQueue.Enqueue(const AResponse: TTHttpLogResponse);
begin
  FCriticalSection.Enter;
  try
    FQueue.Enqueue(TTHttpLogQueueValue.Create(AResponse));
  finally
    FCriticalSection.Leave;
  end;
end;

function TTHttpLogQueue.Dequeue: TTHttpLogQueueValue;
begin
  FCriticalSection.Enter;
  try
    result := FQueue.Dequeue;
  finally
    FCriticalSection.Leave;
  end;
end;

function TTHttpLogQueue.GetIsEmpty: Boolean;
begin
  result := (FQueue.Count = 0);
end;

end.
