(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.ContextApi;

interface

uses
  System.SysUtils,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Consts,
  Trysil.Metadata,
  Trysil.Generics.Collections,
  Trysil.Context,
  Trysil.Exceptions,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractContextApiTests }

  TTAbstractContextApiTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure CreateDatasetReturnsOpenDataset;

    [Test]
    procedure CreateDatasetReturnsCorrectColumnValues;

    [Test]
    procedure CreateDatasetOnEmptyTableReturnsNoRows;

    [Test]
    procedure CloneEntityCopiesAllFields;

    [Test]
    procedure CloneEntityIsIndependentInstance;

    [Test]
    procedure GetMetadataReturnsTableName;

    [Test]
    procedure GetMetadataReturnsPrimaryKey;

    [Test]
    procedure GetMetadataReturnsColumns;

    [Test]
    procedure DatabaseVersionIsNotEmpty;

    { Context lifetime on a shared connection }

    [Test]
    procedure DestroyClearsTransactionObserver;

    [Test]
    procedure TwoContextsOnTheSameConnectionAreBothNotified;

    [Test]
    procedure AnEntityWithoutAKeyIsRefusedByTheFramework;

    [Test]
    procedure AColumnNameThatCannotBeAParameterIsRefused;
  end;

implementation

{ TTAbstractContextApiTests }

procedure TTAbstractContextApiTests.CreateDatasetReturnsOpenDataset;
var
  LCustomer: TTestCustomer;
  LDataset: TDataset;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Acme Corp';
  LCustomer.Email := 'acme@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LDataset := FContext.CreateDataset('SELECT * FROM Customers');
  try
    Assert.IsTrue(LDataset.Active, 'Dataset must be open');
    Assert.IsFalse(LDataset.Eof, 'Dataset must contain at least one row');
  finally
    LDataset.Free;
  end;
end;

procedure TTAbstractContextApiTests.CreateDatasetReturnsCorrectColumnValues;
var
  LCustomer: TTestCustomer;
  LDataset: TDataset;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Acme Corp';
  LCustomer.Email := 'acme@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LDataset := FContext.CreateDataset(
    'SELECT Name, Email FROM Customers');
  try
    Assert.AreEqual('Acme Corp',
      LDataset.FieldByName('Name').AsString);
    Assert.AreEqual('acme@example.com',
      LDataset.FieldByName('Email').AsString);
  finally
    LDataset.Free;
  end;
end;

procedure TTAbstractContextApiTests.CreateDatasetOnEmptyTableReturnsNoRows;
var
  LDataset: TDataset;
begin
  LDataset := FContext.CreateDataset('SELECT * FROM Customers');
  try
    Assert.IsTrue(LDataset.Active, 'Dataset must be open');
    Assert.IsTrue(LDataset.Eof, 'Dataset must be empty');
  finally
    LDataset.Free;
  end;
end;

procedure TTAbstractContextApiTests.CloneEntityCopiesAllFields;
var
  LCustomer: TTestCustomer;
  LClone: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  LCustomer.Email := 'orig@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LClone := FContext.CloneEntity<TTestCustomer>(LCustomer);
  try
    Assert.AreEqual<TTPrimaryKey>(LCustomer.ID, LClone.ID);
    Assert.AreEqual('Original', LClone.Name);
    Assert.AreEqual('orig@example.com', LClone.Email);
  finally
    LClone.Free;
  end;
end;

procedure TTAbstractContextApiTests.CloneEntityIsIndependentInstance;
var
  LCustomer: TTestCustomer;
  LClone: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);

  LClone := FContext.CloneEntity<TTestCustomer>(LCustomer);
  try
    Assert.AreNotSame(LCustomer, LClone,
      'Clone must be a different object instance');
    LCustomer.Name := 'Modified';
    Assert.AreEqual('Original', LClone.Name,
      'Modifying original must not affect clone');
  finally
    LClone.Free;
  end;
end;

procedure TTAbstractContextApiTests.GetMetadataReturnsTableName;
var
  LMetadata: TTTableMetadata;
begin
  LMetadata := FContext.GetMetadata<TTestCustomer>();
  Assert.AreEqual('Customers', LMetadata.TableName);
end;

procedure TTAbstractContextApiTests.GetMetadataReturnsPrimaryKey;
var
  LMetadata: TTTableMetadata;
begin
  LMetadata := FContext.GetMetadata<TTestCustomer>();
  Assert.AreEqual('ID', LMetadata.PrimaryKey);
end;

procedure TTAbstractContextApiTests.GetMetadataReturnsColumns;
var
  LMetadata: TTTableMetadata;
begin
  LMetadata := FContext.GetMetadata<TTestCustomer>();
  Assert.IsFalse(LMetadata.Columns.Empty,
    'Columns must not be empty');

  Assert.IsNotNull(LMetadata.Columns.Find('Name'),
    'Columns must contain "Name"');
  Assert.IsNotNull(LMetadata.Columns.Find('Email'),
    'Columns must contain "Email"');
end;

procedure TTAbstractContextApiTests.DatabaseVersionIsNotEmpty;
var
  LVersion: String;
begin
  LVersion := Connection.DatabaseVersion;
  Assert.IsFalse(LVersion.IsEmpty, 'Database version must not be empty');
end;

{ Context lifetime on a shared connection }

procedure TTAbstractContextApiTests.DestroyClearsTransactionObserver;
var
  LBefore: Integer;
  LContext: TTContext;
begin
  LBefore := Connection.TransactionObserverCount;
  LContext := TTContext.Create(Connection);
  try
    Assert.IsTrue(
      Connection.TransactionObserverCount > LBefore,
      'Precondition: a context registers itself on the connection');
  finally
    LContext.Free;
  end;

  Assert.AreEqual<Integer>(
    LBefore,
    Connection.TransactionObserverCount,
    'Destroying a context must unregister every observer it installed. ' +
    'The count is compared with the one taken before, not with zero: the ' +
    'connection is shared by every fixture, so an absolute number would ' +
    'be asserting that nobody else is alive');
end;

procedure
  TTAbstractContextApiTests.TwoContextsOnTheSameConnectionAreBothNotified;
var
  LContext: TTContext;
  LOneContext: Integer;
begin
  LOneContext := Connection.TransactionObserverCount;

  LContext := TTContext.Create(Connection);
  try
    Assert.AreEqual<Integer>(
      LOneContext * 2,
      Connection.TransactionObserverCount,
      'A second context does not displace the first one: it registers as ' +
      'many observers again');
  finally
    LContext.Free;
  end;

  Assert.AreEqual<Integer>(
    LOneContext,
    Connection.TransactionObserverCount,
    'Destroying the second context leaves the first one registered');
end;

procedure TTAbstractContextApiTests.AnEntityWithoutAKeyIsRefusedByTheFramework;
var
  LCustomer: TTestCustomer;
  LList: TTList<TTestNoKeyCustomer>;
  LMessage: String;
  LRaised: Boolean;
begin
  LMessage := String.Empty;
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'NoKey';
  FContext.Insert<TTestCustomer>(LCustomer);

  LList := TTList<TTestNoKeyCustomer>.Create;
  try
    LRaised := False;
    try
      FContext.SelectAll<TTestNoKeyCustomer>(LList);
    except
      on E: ETException do
      begin
        LRaised := True;
        LMessage := E.Message;
      end;
    end;

    Assert.IsTrue(LRaised, 'Precondition: it must be refused');
    Assert.AreEqual(
      TTLanguage.Instance.Translate(SNotDefinedPrimaryKey),
      LMessage,
      'and refused by the framework, with the message it has for that ' +
      'case, not by the engine: Trysil wraps a driver error in an ' +
      'ETException too, so catching the type alone proves nothing about ' +
      'where the refusal came from');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractContextApiTests.AColumnNameThatCannotBeAParameterIsRefused;
var
  LName: String;
  LRaised: Boolean;
begin
  Assert.AreEqual(
    'Nome_Cliente',
    Connection.GetParameterName('Nome Cliente'),
    'Precondition: a space becomes an underscore, and nothing else moves');

  LRaised := False;
  try
    LName := Connection.GetParameterName('Cli]enti');
  except
    on E: ETException do
      LRaised := True;
  end;

  Assert.IsTrue(
    LRaised,
    'The parameter scanner of the driver ends the name at the first ' +
    'character outside its alphabet, so the value is looked up under a ' +
    'name that is not in the statement and is never bound: the column ' +
    'reads and does not write, on every engine');
end;

end.
