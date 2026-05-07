(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Transaction;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Generics.Collections,
  Trysil.Filter,
  Trysil.Context,
  Trysil.Transaction,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractTransactionTests }

  TTAbstractTransactionTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure TransactionAutoCommitsOnFree;

    [Test]
    procedure TransactionRollbackRevertsInsert;

    [Test]
    procedure TransactionRollbackRevertsUpdate;

    [Test]
    procedure TransactionNestedDoesNotDoubleStart;
  end;

implementation

{ TTAbstractTransactionTests }

procedure TTAbstractTransactionTests.TransactionAutoCommitsOnFree;
var
  LCustomer: TTestCustomer;
  LFreshContext: TTContext;
  LCount: Integer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'AutoCommit';
  FContext.Insert<TTestCustomer>(LCustomer);

  FContext.Free;
  FContext := nil;

  LFreshContext := TTContext.Create(Connection);
  try
    LCount := LFreshContext.SelectCount<TTestCustomer>(TTFilter.Empty);
    Assert.AreEqual<Integer>(1, LCount,
      'Insert inside auto-committed transaction must persist');
  finally
    LFreshContext.Free;
  end;

  FContext := TTContext.Create(Connection);
end;

procedure TTAbstractTransactionTests.TransactionRollbackRevertsInsert;
var
  LTransaction: TTTransaction;
  LCustomer: TTestCustomer;
  LCount: Integer;
begin
  LTransaction := FContext.CreateTransaction;
  try
    LCustomer := FContext.CreateEntity<TTestCustomer>();
    LCustomer.Name := 'RolledBack';
    FContext.Insert<TTestCustomer>(LCustomer);

    LTransaction.Rollback;
  finally
    LTransaction.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'Rollback must revert the insert');
end;

procedure TTAbstractTransactionTests.TransactionRollbackRevertsUpdate;
var
  LCustomer: TTestCustomer;
  LTransaction: TTTransaction;
  LFreshContext: TTContext;
  LReloaded: TTestCustomer;
  LInsertedID: TTPrimaryKey;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'BeforeRollback';
  FContext.Insert<TTestCustomer>(LCustomer);
  LInsertedID := LCustomer.ID;

  LTransaction := FContext.CreateTransaction;
  try
    LCustomer.Name := 'DuringTransaction';
    FContext.Update<TTestCustomer>(LCustomer);

    LTransaction.Rollback;
  finally
    LTransaction.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestCustomer>(LInsertedID);
    Assert.AreEqual('BeforeRollback', LReloaded.Name,
      'Rollback must revert the update');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractTransactionTests.TransactionNestedDoesNotDoubleStart;
var
  LOuterTransaction: TTTransaction;
  LInnerTransaction: TTTransaction;
  LCustomer: TTestCustomer;
  LCount: Integer;
begin
  LOuterTransaction := FContext.CreateTransaction;
  try
    LInnerTransaction := FContext.CreateTransaction;
    try
      LCustomer := FContext.CreateEntity<TTestCustomer>();
      LCustomer.Name := 'Nested';
      FContext.Insert<TTestCustomer>(LCustomer);
    finally
      LInnerTransaction.Free;
    end;

    LOuterTransaction.Rollback;
  finally
    LOuterTransaction.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'Outer rollback must revert even when inner transaction was freed');
end;

end.
