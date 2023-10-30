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

{ TTTransaction }

  TTTransaction = class
  strict private
    FConnection: TTConnection;
    FLocalTransaction: Boolean;

    procedure Start;
    procedure Commit;
  public
    constructor Create(const AConnection: TTConnection);

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Rollback;
  end;

implementation

{ TTTransaction }

constructor TTTransaction.Create(const AConnection: TTConnection);
begin
  inherited Create;
  FConnection := AConnection;
  FLocalTransaction := False;
end;

procedure TTTransaction.AfterConstruction;
begin
  inherited AfterConstruction;
  Start;
end;

procedure TTTransaction.BeforeDestruction;
begin
  Commit;
  inherited BeforeDestruction;
end;

procedure TTTransaction.Start;
begin
  FLocalTransaction :=
    FConnection.SupportTransaction and (not FConnection.InTransaction);
  if FLocalTransaction then
    FConnection.StartTransaction;
end;

procedure TTTransaction.Commit;
begin
  if FLocalTransaction then
  begin
    if not FConnection.InTransaction then
      raise ETException.Create(SNotValidTransaction);
    FConnection.CommitTransaction;
  end;
end;

procedure TTTransaction.Rollback;
begin
  if FLocalTransaction then
  begin
    if not FConnection.InTransaction then
      raise ETException.Create(SNotValidTransaction);
    FLocalTransaction := False;
    FConnection.RollbackTransaction;
  end;
end;

end.
