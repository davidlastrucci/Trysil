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
  Trysil.Context;

type

{ TTTransaction }

  TTTransaction = class
  strict private
    FContext: TTContext;
    FLocalTransaction: Boolean;

    procedure Start;
    procedure Commit;
  public
    constructor Create(const AContext: TTContext);

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Rollback;
  end;

implementation

{ TTTransaction }

constructor TTTransaction.Create(const AContext: TTContext);
begin
  inherited Create;
  FContext := AContext;
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
  FLocalTransaction := not FContext.InTransaction;
  if FLocalTransaction then
    FContext.StartTransaction;
end;

procedure TTTransaction.Commit;
begin
  if FLocalTransaction then
  begin
    if not FContext.InTransaction then
      raise ETException.Create(SNotValidTransaction);
    FContext.CommitTransaction;
  end;
end;

procedure TTTransaction.Rollback;
begin
  if FLocalTransaction then
  begin
    if not FContext.InTransaction then
      raise ETException.Create(SNotValidTransaction);
    FContext.RollbackTransaction;
  end;
end;

end.
