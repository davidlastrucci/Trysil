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
  Trysil.Exceptions,

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

    [Test]
    procedure TransactionRollbackOnDestroyRevertsWithoutCommit;

    [Test]
    procedure TransactionRollbackOnDestroyCommitPersists;

    [Test]
    procedure TransactionNestedRollbackOnDestroyRaises;

    [Test]
    procedure RunInTransactionCommitsOnSuccess;

    [Test]
    procedure RunInTransactionRollsBackOnException;

    [Test]
    procedure RunInTransactionNestedUsesOuterTransaction;
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
  LTransaction := FContext.CreateTransaction(
    TTTransactionMode.CommitOnDestroy);
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

  LTransaction := FContext.CreateTransaction(
    TTTransactionMode.CommitOnDestroy);
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
  LOuterTransaction := FContext.CreateTransaction(
    TTTransactionMode.CommitOnDestroy);
  try
    LInnerTransaction := FContext.CreateTransaction(
    TTTransactionMode.CommitOnDestroy);
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

procedure TTAbstractTransactionTests.TransactionRollbackOnDestroyRevertsWithoutCommit;
var
  LTransaction: TTTransaction;
  LCustomer: TTestCustomer;
  LCount: Integer;
begin
  LTransaction := FContext.CreateTransaction(
    TTTransactionMode.RollbackOnDestroy);
  try
    LCustomer := FContext.CreateEntity<TTestCustomer>();
    LCustomer.Name := 'NoCommit';
    FContext.Insert<TTestCustomer>(LCustomer);
  finally
    LTransaction.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'RollbackOnDestroy must revert when Commit is not called');
end;

procedure TTAbstractTransactionTests.TransactionRollbackOnDestroyCommitPersists;
var
  LTransaction: TTTransaction;
  LCustomer: TTestCustomer;
  LFreshContext: TTContext;
  LCount: Integer;
begin
  LTransaction := FContext.CreateTransaction(
    TTTransactionMode.RollbackOnDestroy);
  try
    LCustomer := FContext.CreateEntity<TTestCustomer>();
    LCustomer.Name := 'Committed';
    FContext.Insert<TTestCustomer>(LCustomer);

    LTransaction.Commit;
  finally
    LTransaction.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    LCount := LFreshContext.SelectCount<TTestCustomer>(TTFilter.Empty);
    Assert.AreEqual<Integer>(1, LCount,
      'Explicit Commit must persist even with RollbackOnDestroy');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractTransactionTests.TransactionNestedRollbackOnDestroyRaises;
var
  LOuterTransaction: TTTransaction;
begin
  LOuterTransaction := FContext.CreateTransaction(
    TTTransactionMode.CommitOnDestroy);
  try
    Assert.WillRaise(
      procedure
      var
        LInnerTransaction: TTTransaction;
      begin
        LInnerTransaction := FContext.CreateTransaction(
          TTTransactionMode.RollbackOnDestroy);
        LInnerTransaction.Free;
      end,
      ETException,
      'RollbackOnDestroy inside another transaction must raise');

    LOuterTransaction.Rollback;
  finally
    LOuterTransaction.Free;
  end;
end;

procedure TTAbstractTransactionTests.RunInTransactionCommitsOnSuccess;
var
  LFreshContext: TTContext;
  LCount: Integer;
begin
  FContext.RunInTransaction(
    procedure
    var
      LCustomer: TTestCustomer;
    begin
      LCustomer := FContext.CreateEntity<TTestCustomer>();
      LCustomer.Name := 'RunCommitted';
      FContext.Insert<TTestCustomer>(LCustomer);
    end);

  LFreshContext := TTContext.Create(Connection);
  try
    LCount := LFreshContext.SelectCount<TTestCustomer>(TTFilter.Empty);
    Assert.AreEqual<Integer>(1, LCount,
      'RunInTransaction must commit on clean exit');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractTransactionTests.RunInTransactionRollsBackOnException;
var
  LCount: Integer;
begin
  Assert.WillRaise(
    procedure
    begin
      FContext.RunInTransaction(
        procedure
        var
          LCustomer: TTestCustomer;
        begin
          LCustomer := FContext.CreateEntity<TTestCustomer>();
          LCustomer.Name := 'RunFailed';
          FContext.Insert<TTestCustomer>(LCustomer);

          raise ETException.Create('Test failure');
        end);
    end,
    ETException,
    'RunInTransaction must re-raise the exception');

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'RunInTransaction must roll back on exception');
end;

procedure TTAbstractTransactionTests.RunInTransactionNestedUsesOuterTransaction;
var
  LCount: Integer;
begin
  Assert.WillRaise(
    procedure
    begin
      FContext.RunInTransaction(
        procedure
        begin
          FContext.RunInTransaction(
            procedure
            var
              LCustomer: TTestCustomer;
            begin
              LCustomer := FContext.CreateEntity<TTestCustomer>();
              LCustomer.Name := 'RunNested';
              FContext.Insert<TTestCustomer>(LCustomer);
            end);

          raise ETException.Create('Test failure');
        end);
    end,
    ETException);

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'Inner RunInTransaction must join the outer transaction');
end;

end.
