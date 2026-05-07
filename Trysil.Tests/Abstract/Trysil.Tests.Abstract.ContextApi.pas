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
  Trysil.Metadata,
  Trysil.Context,

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
  LColumn: TTColumnMetadata;
  LFoundName: Boolean;
  LFoundEmail: Boolean;
begin
  LMetadata := FContext.GetMetadata<TTestCustomer>();
  Assert.IsFalse(LMetadata.Columns.Empty,
    'Columns must not be empty');

  LFoundName := False;
  LFoundEmail := False;
  for LColumn in LMetadata.Columns do
  begin
    if LColumn.ColumnName = 'Name' then
      LFoundName := True;
    if LColumn.ColumnName = 'Email' then
      LFoundEmail := True;
  end;

  Assert.IsTrue(LFoundName, 'Columns must contain "Name"');
  Assert.IsTrue(LFoundEmail, 'Columns must contain "Email"');
end;

end.
