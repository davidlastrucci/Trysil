(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.CommitFailure;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Context,
  Trysil.Exceptions,
  Trysil.Data,
  Trysil.Transaction,
  Trysil.Data.FireDAC.SQLite,

  Trysil.Tests.Model;

type

{ TTestFailingCommitConnection }

  TTestFailingCommitConnection = class(TTSQLiteConnection)
  strict private
    FFailCommit: Boolean;
  strict protected
    procedure InternalCommitTransaction; override;
  public
    property FailCommit: Boolean read FFailCommit write FFailCommit;
  end;

{ TTestRollbackCounter }

  TTestRollbackCounter = class(TTTransactionObserver)
  strict private
    FRollbacks: Integer;
  protected
    procedure TransactionStarted; override;
    procedure TransactionCommitted; override;
    procedure TransactionRolledback; override;
  public
    property Rollbacks: Integer read FRollbacks;
  end;

{ TTSQLiteCommitFailureTests }

  [TestFixture]
  TTSQLiteCommitFailureTests = class
  strict private
    FConnection: TTestFailingCommitConnection;
    FContext: TTContext;
    FCommitFailed: Boolean;

    function InsertInFailingTransaction: TTestCustomer;
    function FindCustomer(const AID: TTPrimaryKey): TTestCustomer;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AFailedCommitLeavesTheEntityNew;

    [Test]
    procedure AFailedCommitOnTheConnectionRollsBack;

    [Test]
    procedure AFailedCommitNotifiesOneRollback;

    [Test]
    procedure AFailedCommitLeavesNothingToUndo;

  end;

implementation

{ TTestFailingCommitConnection }

procedure TTestFailingCommitConnection.InternalCommitTransaction;
begin
  if FFailCommit then
    raise ETException.Create('Commit failed on purpose');
  inherited InternalCommitTransaction;
end;

{ TTestRollbackCounter }

procedure TTestRollbackCounter.TransactionStarted;
begin
end;

procedure TTestRollbackCounter.TransactionCommitted;
begin
end;

procedure TTestRollbackCounter.TransactionRolledback;
begin
  Inc(FRollbacks);
end;

{ TTSQLiteCommitFailureTests }

procedure TTSQLiteCommitFailureTests.Setup;
begin
  FCommitFailed := False;
  FConnection := TTestFailingCommitConnection.Create('TrysilTests');
  FConnection.Execute('DELETE FROM Customers');
  FContext := TTContext.Create(FConnection, False);
end;

procedure TTSQLiteCommitFailureTests.TearDown;
begin
  FContext.Free;
  FConnection.Execute('DELETE FROM Customers');
  FConnection.Free;
end;

function TTSQLiteCommitFailureTests.FindCustomer(
  const AID: TTPrimaryKey): TTestCustomer;
begin
  result := FContext.Get<TTestCustomer>(AID);
end;

function TTSQLiteCommitFailureTests.InsertInFailingTransaction: TTestCustomer;
var
  LCustomer: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'CommitFailure';
  LCustomer.Email := 'commit.failure@example.com';

  FConnection.FailCommit := True;
  try
    try
      FContext.RunInTransaction(
        procedure
        begin
          FContext.Insert<TTestCustomer>(LCustomer);
        end);
    except
      on E: ETException do
        FCommitFailed := True;
    end;
  finally
    FConnection.FailCommit := False;
  end;

  result := LCustomer;
end;

procedure TTSQLiteCommitFailureTests.AFailedCommitLeavesTheEntityNew;
var
  LCustomer: TTestCustomer;
  LFound: TTestCustomer;
begin
  LCustomer := InsertInFailingTransaction;
  try
    Assert.IsTrue(
      FCommitFailed,
      'Precondition: the commit must have failed. Swallowing the ' +
      'exception without looking at it would hide the very thing this ' +
      'test is about');

    LFound := FindCustomer(LCustomer.ID);
    try
      Assert.IsFalse(
        Assigned(LFound),
        'Precondition: the failed commit must leave no row behind');
    finally
      if Assigned(LFound) then
        LFound.Free;
    end;

    FContext.Save<TTestCustomer>(LCustomer);

    LFound := FindCustomer(LCustomer.ID);
    try
      Assert.IsTrue(
        Assigned(LFound),
        'After a failed commit the entity is new again, so Save inserts it');
      Assert.AreEqual('CommitFailure', LFound.Name);
    finally
      if Assigned(LFound) then
        LFound.Free;
    end;
  finally
    LCustomer.Free;
  end;
end;

procedure TTSQLiteCommitFailureTests.AFailedCommitOnTheConnectionRollsBack;
var
  LRaised: Boolean;
begin
  LRaised := False;
  FConnection.StartTransaction;
  FConnection.FailCommit := True;
  try
    try
      FConnection.CommitTransaction;
    except
      LRaised := True;
    end;
  finally
    FConnection.FailCommit := False;
  end;

  Assert.IsTrue(LRaised, 'Precondition: the commit must fail');
  Assert.IsFalse(
    FConnection.InTransaction,
    'A failed commit must not leave the physical transaction open');
end;

procedure TTSQLiteCommitFailureTests.AFailedCommitNotifiesOneRollback;
var
  LCounter: TTestRollbackCounter;
  LCustomer: TTestCustomer;
begin
  LCounter := TTestRollbackCounter.Create;
  try
    FConnection.AddTransactionObserver(LCounter);
    try
      LCustomer := InsertInFailingTransaction;
      try
        Assert.AreEqual<Integer>(
          1,
          LCounter.Rollbacks,
          'A failed commit must notify one rollback, not two');
      finally
        LCustomer.Free;
      end;
    finally
      FConnection.RemoveTransactionObserver(LCounter);
    end;
  finally
    LCounter.Free;
  end;
end;

procedure TTSQLiteCommitFailureTests.AFailedCommitLeavesNothingToUndo;
var
  LTransaction: TTTransaction;
  LCommitRaised: Boolean;
  LRollbackRaised: Boolean;
begin
  LCommitRaised := False;
  LRollbackRaised := False;
  LTransaction := TTTransaction.Create(
    FConnection, TTTransactionMode.RollbackOnDestroy);
  try
    FConnection.FailCommit := True;
    try
      try
        LTransaction.Commit;
      except
        on E: ETException do
          LCommitRaised := True;
      end;
    finally
      FConnection.FailCommit := False;
    end;

    try
      LTransaction.Rollback;
    except
      on E: ETException do
        LRollbackRaised := True;
    end;
  finally
    LTransaction.Free;
  end;

  Assert.IsTrue(LCommitRaised, 'Precondition: the commit must fail');
  Assert.IsFalse(
    LRollbackRaised,
    'A failed commit has already rolled back: the transaction has nothing ' +
    'left to undo, and its destructor used to try again and log a failure ' +
    'that never happened');
end;

end.
