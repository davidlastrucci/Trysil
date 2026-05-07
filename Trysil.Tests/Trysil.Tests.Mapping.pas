(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Mapping;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Attributes,
  Trysil.Mapping;

type

{ TTestSimpleCustomer }

  [TTable('Customers')]
  TTestSimpleCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
  end;

{ TTestVersionedProduct }

  [TTable('Products')]
  [TSequence('ProductsSeq')]
  TTestVersionedProduct = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
  end;

{ TTestFilteredRecord }

  [TTable('Records')]
  [TWhereClause('Active = 1')]
  TTestFilteredRecord = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Label')]
    FLabel: String;
  public
    property ID: TTPrimaryKey read FID;
    property &Label: String read FLabel write FLabel;
  end;

{ TTestTrackedUser }

  [TTable('Users')]
  TTestTrackedUser = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TCreatedAt]
    [TColumn('CreatedAt')]
    FCreatedAt: TTNullable<TDateTime>;

    [TCreatedBy]
    [TColumn('CreatedBy')]
    FCreatedBy: String;

    [TUpdatedAt]
    [TColumn('UpdatedAt')]
    FUpdatedAt: TTNullable<TDateTime>;

    [TUpdatedBy]
    [TColumn('UpdatedBy')]
    FUpdatedBy: String;

    [TDeletedAt]
    [TColumn('DeletedAt')]
    FDeletedAt: TTNullable<TDateTime>;

    [TDeletedBy]
    [TColumn('DeletedBy')]
    FDeletedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property CreatedAt: TTNullable<TDateTime> read FCreatedAt;
    property CreatedBy: String read FCreatedBy;
    property UpdatedAt: TTNullable<TDateTime> read FUpdatedAt;
    property UpdatedBy: String read FUpdatedBy;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
    property DeletedBy: String read FDeletedBy;
  end;

{ TTestOrderReport - single JOIN }

  [TTable('Orders')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  TTestOrderReport = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Amount')]
    FAmount: Double;

    [TColumn('Customers', 'CompanyName')]
    FCustomerName: String;
  public
    property ID: TTPrimaryKey read FID;
    property Amount: Double read FAmount;
    property CustomerName: String read FCustomerName;
  end;

{ TTestSelfJoinEntry - self-JOIN with aliases }

  [TTable('Movements')]
  [TJoin(TJoinKind.Inner, 'Accounts', 'DebitAcc', 'DebitID', 'ID')]
  [TJoin(TJoinKind.Inner, 'Accounts', 'CreditAcc', 'CreditID', 'ID')]
  TTestSelfJoinEntry = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('DebitAcc', 'Description')]
    FDebitDescription: String;

    [TColumn('CreditAcc', 'Description')]
    FCreditDescription: String;
  public
    property ID: TTPrimaryKey read FID;
    property DebitDescription: String read FDebitDescription;
    property CreditDescription: String read FCreditDescription;
  end;

{ TTMapperTests }

  [TestFixture]
  TTMapperTests = class
  strict private
    function CountColumns(const ATableMap: TTTableMap): Integer;
    function CountJoins(const ATableMap: TTTableMap): Integer;
  public
    [Test]
    procedure SimpleEntityMapsTableName;

    [Test]
    procedure SimpleEntityMapsPrimaryKey;

    [Test]
    procedure SimpleEntityMapsAllColumns;

    [Test]
    procedure SimpleEntityHasNoVersionColumn;

    [Test]
    procedure SimpleEntityHasEmptySequenceName;

    [Test]
    procedure SimpleEntityHasNoJoins;

    [Test]
    procedure VersionedEntityMapsVersionColumn;

    [Test]
    procedure VersionedEntityMapsSequenceName;

    [Test]
    procedure WhereClauseIsStoredOnTableMap;

    [Test]
    procedure CreatedAtAndByAreMappedInChangeTracking;

    [Test]
    procedure UpdatedAtAndByAreMappedInChangeTracking;

    [Test]
    procedure DeletedAtAndByAreMappedInChangeTracking;

    [Test]
    procedure JoinEntityReportsHasJoinsTrue;

    [Test]
    procedure JoinEntityContainsDeclaredJoin;

    [Test]
    procedure JoinEntityColumnLookupNameUsesAlias;

    [Test]
    procedure SelfJoinEntityHasTwoDistinctAliases;

    [Test]
    procedure LoadReturnsSameInstanceForSameType;
  end;

implementation

{ TTMapperTests }

function TTMapperTests.CountColumns(const ATableMap: TTTableMap): Integer;
var
  LColumn: TTColumnMap;
begin
  result := 0;
  for LColumn in ATableMap.Columns do
    Inc(result);
end;

function TTMapperTests.CountJoins(const ATableMap: TTTableMap): Integer;
var
  LJoin: TTJoinMap;
begin
  result := 0;
  for LJoin in ATableMap.Joins do
    Inc(result);
end;

procedure TTMapperTests.SimpleEntityMapsTableName;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.AreEqual('Customers', LMap.Name);
end;

procedure TTMapperTests.SimpleEntityMapsPrimaryKey;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.IsNotNull(LMap.PrimaryKey, 'PrimaryKey should be assigned');
  Assert.AreEqual('ID', LMap.PrimaryKey.Name);
end;

procedure TTMapperTests.SimpleEntityMapsAllColumns;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.AreEqual(Integer(3), CountColumns(LMap));
end;

procedure TTMapperTests.SimpleEntityHasNoVersionColumn;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.IsNull(LMap.VersionColumn);
end;

procedure TTMapperTests.SimpleEntityHasEmptySequenceName;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.IsTrue(LMap.SequenceName.IsEmpty);
end;

procedure TTMapperTests.SimpleEntityHasNoJoins;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.IsFalse(LMap.HasJoins);
  Assert.IsTrue(LMap.Joins.IsEmpty);
end;

procedure TTMapperTests.VersionedEntityMapsVersionColumn;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestVersionedProduct>();
  Assert.IsNotNull(LMap.VersionColumn, 'VersionColumn should be assigned');
  Assert.AreEqual('VersionID', LMap.VersionColumn.Name);
end;

procedure TTMapperTests.VersionedEntityMapsSequenceName;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestVersionedProduct>();
  Assert.AreEqual('ProductsSeq', LMap.SequenceName);
end;

procedure TTMapperTests.WhereClauseIsStoredOnTableMap;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestFilteredRecord>();
  Assert.AreEqual('Active = 1', LMap.WhereClause);
end;

procedure TTMapperTests.CreatedAtAndByAreMappedInChangeTracking;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestTrackedUser>();
  Assert.IsNotNull(LMap.Columns.CreatedChangeTracking.ChangedAt);
  Assert.AreEqual('CreatedAt', LMap.Columns.CreatedChangeTracking.ChangedAt.Name);
  Assert.IsNotNull(LMap.Columns.CreatedChangeTracking.ChangedBy);
  Assert.AreEqual('CreatedBy', LMap.Columns.CreatedChangeTracking.ChangedBy.Name);
end;

procedure TTMapperTests.UpdatedAtAndByAreMappedInChangeTracking;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestTrackedUser>();
  Assert.IsNotNull(LMap.Columns.UpdatedChangeTracking.ChangedAt);
  Assert.AreEqual('UpdatedAt', LMap.Columns.UpdatedChangeTracking.ChangedAt.Name);
  Assert.IsNotNull(LMap.Columns.UpdatedChangeTracking.ChangedBy);
  Assert.AreEqual('UpdatedBy', LMap.Columns.UpdatedChangeTracking.ChangedBy.Name);
end;

procedure TTMapperTests.DeletedAtAndByAreMappedInChangeTracking;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestTrackedUser>();
  Assert.IsNotNull(LMap.Columns.DeletedChangeTracking.ChangedAt);
  Assert.AreEqual('DeletedAt', LMap.Columns.DeletedChangeTracking.ChangedAt.Name);
  Assert.IsNotNull(LMap.Columns.DeletedChangeTracking.ChangedBy);
  Assert.AreEqual('DeletedBy', LMap.Columns.DeletedChangeTracking.ChangedBy.Name);
end;

procedure TTMapperTests.JoinEntityReportsHasJoinsTrue;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestOrderReport>();
  Assert.IsTrue(LMap.HasJoins);
  Assert.IsFalse(LMap.Joins.IsEmpty);
end;

procedure TTMapperTests.JoinEntityContainsDeclaredJoin;
var
  LMap: TTTableMap;
  LJoin: TTJoinMap;
  LFound: TTJoinMap;
begin
  LMap := TTMapper.Instance.Load<TTestOrderReport>();
  Assert.AreEqual(Integer(1), CountJoins(LMap));

  LFound := nil;
  for LJoin in LMap.Joins do
    LFound := LJoin;

  Assert.IsNotNull(LFound);
  Assert.AreEqual('Customers', LFound.TableName);
  Assert.AreEqual('Customers', LFound.Alias);
  Assert.AreEqual('CustomerID', LFound.SourceColumnName);
  Assert.AreEqual('ID', LFound.TargetColumnName);
end;

procedure TTMapperTests.JoinEntityColumnLookupNameUsesAlias;
var
  LMap: TTTableMap;
  LColumn: TTColumnMap;
  LCustomerColumn: TTColumnMap;
begin
  LMap := TTMapper.Instance.Load<TTestOrderReport>();
  LCustomerColumn := nil;
  for LColumn in LMap.Columns do
    if SameText(LColumn.Name, 'CompanyName') then
      LCustomerColumn := LColumn;

  Assert.IsNotNull(LCustomerColumn, 'CompanyName column should be mapped');
  Assert.AreEqual('Customers_CompanyName', LCustomerColumn.LookupName);
end;

procedure TTMapperTests.SelfJoinEntityHasTwoDistinctAliases;
var
  LMap: TTTableMap;
  LJoin: TTJoinMap;
  LDebitFound: Boolean;
  LCreditFound: Boolean;
begin
  LMap := TTMapper.Instance.Load<TTestSelfJoinEntry>();
  Assert.AreEqual(Integer(2), CountJoins(LMap));

  LDebitFound := False;
  LCreditFound := False;
  for LJoin in LMap.Joins do
  begin
    Assert.AreEqual('Accounts', LJoin.TableName);
    if SameText(LJoin.Alias, 'DebitAcc') then
      LDebitFound := True
    else if SameText(LJoin.Alias, 'CreditAcc') then
      LCreditFound := True;
  end;

  Assert.IsTrue(LDebitFound, 'DebitAcc alias should be present');
  Assert.IsTrue(LCreditFound, 'CreditAcc alias should be present');
end;

procedure TTMapperTests.LoadReturnsSameInstanceForSameType;
var
  LFirst: TTTableMap;
  LSecond: TTTableMap;
begin
  LFirst := TTMapper.Instance.Load<TTestSimpleCustomer>();
  LSecond := TTMapper.Instance.Load<TTestSimpleCustomer>();
  Assert.AreSame(LFirst, LSecond);
end;

initialization
  TDUnitX.RegisterTestFixture(TTMapperTests);

end.
