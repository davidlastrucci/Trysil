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
  FLocalTransaction := not FContext.InTransaction;
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
  if FLocalTransaction then
    FContext.StartTransaction;
end;

procedure TTTransaction.Commit;
begin
  if FLocalTransaction and FContext.InTransaction then
    FContext.CommitTransaction;
end;

procedure TTTransaction.Rollback;
begin
  if FLocalTransaction and FContext.InTransaction  then
    FContext.RollbackTransaction;
end;

end.
