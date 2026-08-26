(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Transaction;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Data;

type

{$SCOPEDENUMS ON}

  TTTransactionMode = (CommitOnDestroy, RollbackOnDestroy);

{ TTTransaction }

  TTTransaction = class
  strict private
    FConnection: TTConnection;
    FTransactionMode: TTTransactionMode;
    FLocalTransaction: Boolean;

    procedure Start;
    procedure Stop;

    procedure SilentRollback;
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATransactionMode: TTTransactionMode);

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Commit;
    procedure Rollback;

    class procedure Run(
      const AConnection: TTConnection; const AProc: TProc);
  end;

implementation

{ TTTransaction }

constructor TTTransaction.Create(
  const AConnection: TTConnection; const ATransactionMode: TTTransactionMode);
begin
  inherited Create;
  FConnection := AConnection;
  FTransactionMode := ATransactionMode;

  FLocalTransaction := False;
end;

procedure TTTransaction.AfterConstruction;
begin
  inherited AfterConstruction;
  Start;
end;

procedure TTTransaction.BeforeDestruction;
begin
  Stop;
  inherited BeforeDestruction;
end;

procedure TTTransaction.Start;
begin
  if (FTransactionMode = TTTransactionMode.RollbackOnDestroy) and
    FConnection.InTransaction then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNestedRollbackNotSupported));

  FLocalTransaction :=
    FConnection.SupportTransaction and (not FConnection.InTransaction);
  if FLocalTransaction then
    FConnection.StartTransaction;
end;

procedure TTTransaction.Stop;
begin
  try
    case FTransactionMode of
      TTTransactionMode.CommitOnDestroy:
        Commit;
      TTTransactionMode.RollbackOnDestroy:
        Rollback;
    end;
  except
    // no exception here
  end;
end;

procedure TTTransaction.SilentRollback;
begin
  try
    FConnection.RollbackTransaction;
  except
  end;
end;

procedure TTTransaction.Commit;
begin
  if FLocalTransaction then
  begin
    if not FConnection.InTransaction then
      raise ETException.Create(
        TTLanguage.Instance.Translate(SNotValidTransaction));

    try
      FConnection.CommitTransaction;
    except
      SilentRollback;
      raise;
    end;

    FLocalTransaction := False;
  end;
end;

class procedure TTTransaction.Run(
  const AConnection: TTConnection; const AProc: TProc);
var
  LTransaction: TTTransaction;
begin
  if not Assigned(AProc) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SProcNotAssigned));

  if AConnection.InTransaction then
    AProc()
  else
  begin
    LTransaction := TTTransaction.Create(
      AConnection, TTTransactionMode.RollbackOnDestroy);
    try
      AProc();

      LTransaction.Commit;
    finally
      LTransaction.Free;
    end;
  end;
end;

procedure TTTransaction.Rollback;
begin
  if FLocalTransaction then
  begin
    if not FConnection.InTransaction then
      raise ETException.Create(
        TTLanguage.Instance.Translate(SNotValidTransaction));
    FConnection.RollbackTransaction;
    FLocalTransaction := False;
  end;
end;

end.

