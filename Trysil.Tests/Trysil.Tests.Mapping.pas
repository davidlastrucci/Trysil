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
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Classes,
  Trysil.Attributes,
  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.JSon.Attributes;

type

{ TTestNoTable }

  TTestNoTable = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;
  public
    property ID: TTPrimaryKey read FID;
  end;

{ TTestNoColumns }

  [TTable('Empty')]
  TTestNoColumns = class
  strict private
    FSomething: String;
  public
    property Something: String read FSomething write FSomething;
  end;

{ TTestNoPrimaryKey }

  [TTable('Keyless')]
  TTestNoPrimaryKey = class
  strict private
    [TColumn('Name')]
    FName: String;
  public
    property Name: String read FName write FName;
  end;

{ TTestKeyIsVersion }

  [TTable('Broken')]
  TTestKeyIsVersion = class
  strict private
    [TPrimaryKey]
    [TVersionColumn]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
  end;

{ TTestTrackedPrimaryKey }

  [TTable('Broken')]
  TTestTrackedPrimaryKey = class
  strict private
    [TPrimaryKey]
    [TCreatedBy]
    [TColumn('ID')]
    FID: String;

    [TColumn('Name')]
    FName: String;
  public
    property ID: String read FID;
    property Name: String read FName write FName;
  end;

{ TTestColumnAndDetailColumn }

  [TTable('Broken')]
  TTestColumnAndDetailColumn = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Lines')]
    [TDetailColumn('ID', 'HeaderID')]
    FLines: String;
  public
    property ID: TTPrimaryKey read FID;
    property Lines: String read FLines write FLines;
  end;

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

{ TTestDirectionalRecord }

  [TTable('Records')]
  TTestDirectionalRecord = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Plain')]
    FPlain: String;

    [TColumn('OutOnly')]
    [TJSonIgnoreDeserialize]
    FOutOnly: String;

    [TColumn('InOnly')]
    [TJSonIgnoreSerialize]
    FInOnly: String;
  public
    property ID: TTPrimaryKey read FID;
    property Plain: String read FPlain write FPlain;
    property OutOnly: String read FOutOnly write FOutOnly;
    property InOnly: String read FInOnly write FInOnly;
  end;

{ TTestParameterFilteredRecord }

  [TTable('Records')]
  [TWhereClause('Active = :Active AND Role = :Role')]
  [TWhereClauseParameter('Active', True)]
  [TWhereClauseParameter('Role', 'admin')]
  TTestParameterFilteredRecord = class
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

{ TTestUnpairedDeletedBy }

  [TTable('Unpaired')]
  TTestUnpairedDeletedBy = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TDeletedBy]
    [TColumn('DeletedBy')]
    FDeletedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property DeletedBy: String read FDeletedBy;
  end;

{ TTestLoneTrackingColumns }

  [TTable('LoneTracking')]
  TTestLoneTrackingColumns = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TDeletedAt]
    [TColumn('DeletedAt')]
    FDeletedAt: TTNullable<TDateTime>;

    [TCreatedBy]
    [TColumn('CreatedBy')]
    FCreatedBy: String;

    [TUpdatedBy]
    [TColumn('UpdatedBy')]
    FUpdatedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
    property CreatedBy: String read FCreatedBy;
    property UpdatedBy: String read FUpdatedBy;
  end;

{ TTestTwoMembersOneColumn }

  [TTable('TwoMembers')]
  TTestTwoMembersOneColumn = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TUpdatedAt]
    [TColumn('Stamp')]
    FUpdatedAt: TTNullable<TDateTime>;

    [TDeletedAt]
    [TColumn('Stamp')]
    FDeletedAt: TTNullable<TDateTime>;
  public
    property ID: TTPrimaryKey read FID;
    property UpdatedAt: TTNullable<TDateTime> read FUpdatedAt;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
  end;

{ TTestDoubleTrackedColumn }

  [TTable('DoubleTracked')]
  TTestDoubleTrackedColumn = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TUpdatedAt]
    [TDeletedAt]
    [TColumn('Stamp')]
    FStamp: TTNullable<TDateTime>;
  public
    property ID: TTPrimaryKey read FID;
    property Stamp: TTNullable<TDateTime> read FStamp;
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

{ TTestLongAliasReport - JOIN whose aliases exceed the shortest limit }

  [TTable('Documenti')]
  [TJoin(TJoinKind.Inner, 'DocumentiRighe', 'ID', 'DocumentoID')]
  TTestLongAliasReport = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('DocumentiRighe', 'PrezzoUnitarioNetto')]
    FPrezzoNetto: Double;

    [TColumn('DocumentiRighe', 'PrezzoUnitarioLordo')]
    FPrezzoLordo: Double;

    [TColumn('DocumentiRighe', 'Qta')]
    FQta: Double;
  public
    property ID: TTPrimaryKey read FID;
    property PrezzoNetto: Double read FPrezzoNetto;
    property PrezzoLordo: Double read FPrezzoLordo;
    property Qta: Double read FQta;
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
    function AliasOf(
      const ATableMap: TTTableMap;
      const AColumnName: String): String;
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
    procedure WhereClauseParametersAreStoredOnTableMap;

    [Test]
    procedure IsChangeTrackingIsFalseForPlainColumn;

    [Test]
    procedure IsChangeTrackingIsTrueForCreatedBy;

    [Test]
    procedure DirectionalJSonAttributesAreFoundOnTheirColumns;

    [Test]
    procedure CreatedAtAndByAreMappedInChangeTracking;

    [Test]
    procedure UpdatedAtAndByAreMappedInChangeTracking;

    [Test]
    procedure DeletedAtAndByAreMappedInChangeTracking;

    [Test]
    procedure DeletedByWithoutDeletedAtRaises;

    [Test]
    procedure AColumnWithTwoTrackingAttributesRaises;

    [Test]
    procedure LoneTrackingColumnsAreAccepted;

    [Test]
    procedure TwoMembersOnOneTrackedColumnRaise;

    [Test]
    procedure AColumnThatIsKeyAndVersionRaises;

    [Test]
    procedure ATrackedPrimaryKeyRaises;

    [Test]
    procedure AMemberThatIsColumnAndDetailColumnRaises;

    [Test]
    procedure JoinEntityReportsHasJoinsTrue;

    [Test]
    procedure JoinEntityContainsDeclaredJoin;

    [Test]
    procedure JoinEntityColumnLookupNameUsesAlias;

    [Test]
    procedure ALongJoinAliasIsBoundedAndStaysUnique;

    [Test]
    procedure ALongJoinAliasFoldsBeforeItHashes;

    [Test]
    procedure AJoinAliasIsMeasuredInBytes;

    [Test]
    procedure AShortJoinAliasIsLeftAlone;

    [Test]
    procedure SelfJoinEntityHasTwoDistinctAliases;

    [Test]
    procedure LoadReturnsSameInstanceForSameType;
  end;

{ TTestMappingMetadataProvider }

  TTestMappingMetadataProvider = class(TTMetadataProvider)
  strict protected
    function GetConnectionName: String; override;
  public
    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;
  end;

{ TTMetadataTests }

  [TestFixture]
  TTMetadataTests = class
  strict private
    FProvider: TTestMappingMetadataProvider;
    FMetadata: TTMetadata;

    function MessageOfLoad<T: class>: String;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AnEntityWithoutATableIsRefused;

    [Test]
    procedure AnEntityWithoutColumnsIsRefused;

    [Test]
    procedure AnEntityWithoutAPrimaryKeyIsRefused;
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

procedure TTMapperTests.WhereClauseParametersAreStoredOnTableMap;
var
  LMap: TTTableMap;
  LParameter: TTWhereParameterMap;
  LNames: String;
  LCount: Integer;
begin
  LMap := TTMapper.Instance.Load<TTestParameterFilteredRecord>();
  LCount := 0;
  LNames := String.Empty;
  for LParameter in LMap.WhereParameters do
  begin
    Inc(LCount);
    LNames := Format('%s[%s]', [LNames, LParameter.Name]);
  end;

  Assert.AreEqual<Integer>(2, LCount,
    Format('WhereClauseParameter attributes must reach the table map, ' +
      'found: %s', [LNames]));
end;

procedure TTMapperTests.IsChangeTrackingIsFalseForPlainColumn;
var
  LMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LFound: Boolean;
begin
  LMap := TTMapper.Instance.Load<TTestTrackedUser>();
  LFound := False;
  for LColumnMap in LMap.Columns do
    if LColumnMap.Member.Name = 'FName' then
    begin
      LFound := True;
      Assert.IsFalse(LMap.Columns.IsChangeTracking(LColumnMap),
        'a plain column must not be reported as change tracking');
    end;

  Assert.IsTrue(LFound, 'Precondition: FName column must be mapped');
end;

procedure TTMapperTests.IsChangeTrackingIsTrueForCreatedBy;
var
  LMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LFound: Boolean;
begin
  LMap := TTMapper.Instance.Load<TTestTrackedUser>();
  LFound := False;
  for LColumnMap in LMap.Columns do
    if LColumnMap.Member.Name = 'FCreatedBy' then
    begin
      LFound := True;
      Assert.IsTrue(LMap.Columns.IsChangeTracking(LColumnMap),
        'CreatedBy must be reported as change tracking');
    end;

  Assert.IsTrue(LFound, 'Precondition: FCreatedBy column must be mapped');
end;

procedure TTMapperTests.DirectionalJSonAttributesAreFoundOnTheirColumns;
var
  LMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LChecked: Integer;
begin
  LMap := TTMapper.Instance.Load<TTestDirectionalRecord>();
  LChecked := 0;
  for LColumnMap in LMap.Columns do
  begin
    if LColumnMap.Member.Name = 'FPlain' then
    begin
      Inc(LChecked);
      Assert.IsFalse(
        Assigned(
          LColumnMap.Member.GetAttribute<TJSonIgnoreSerializeAttribute>()),
        'a plain column must not report TJSonIgnoreSerialize');
      Assert.IsFalse(
        Assigned(
          LColumnMap.Member.GetAttribute<TJSonIgnoreDeserializeAttribute>()),
        'a plain column must not report TJSonIgnoreDeserialize');
    end
    else if LColumnMap.Member.Name = 'FOutOnly' then
    begin
      Inc(LChecked);
      Assert.IsTrue(
        Assigned(
          LColumnMap.Member.GetAttribute<TJSonIgnoreDeserializeAttribute>()),
        'TJSonIgnoreDeserialize must be found on the column carrying it');
      Assert.IsFalse(
        Assigned(
          LColumnMap.Member.GetAttribute<TJSonIgnoreSerializeAttribute>()),
        'the two directional attributes must not be confused');
    end
    else if LColumnMap.Member.Name = 'FInOnly' then
    begin
      Inc(LChecked);
      Assert.IsTrue(
        Assigned(
          LColumnMap.Member.GetAttribute<TJSonIgnoreSerializeAttribute>()),
        'TJSonIgnoreSerialize must be found on the column carrying it');
    end;
  end;

  Assert.AreEqual<Integer>(3, LChecked,
    'Precondition: the three columns must be mapped');
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

procedure TTMapperTests.DeletedByWithoutDeletedAtRaises;
var
  LMessage: String;
begin
  LMessage := String.Empty;
  try
    TTMapper.Instance.Load<TTestUnpairedDeletedBy>();
  except
    on E: ETException do
      LMessage := E.Message;
  end;

  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SDeletedByWithoutDeletedAt),
      ['DeletedBy']),
    LMessage,
    'A [TDeletedBy] without [TDeletedAt] must be refused at mapping time, ' +
    'and for that reason rather than any other mapping failure');
end;

procedure TTMapperTests.TwoMembersOnOneTrackedColumnRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTMapper.Instance.Load<TTestTwoMembersOneColumn>();
  except
    on E: ETException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Two members mapped on one column produce two distinct column maps, ' +
    'so comparing them by reference misses the case that actually emits ' +
    'the same column twice in the same SET list');
end;

procedure TTMapperTests.LoneTrackingColumnsAreAccepted;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestLoneTrackingColumns>();

  Assert.IsNotNull(LMap.Columns.DeletedChangeTracking.ChangedAt,
    'A [TDeletedAt] on its own is a soft delete with no user recorded');
  Assert.IsNull(LMap.Columns.DeletedChangeTracking.ChangedBy);
  Assert.IsNotNull(LMap.Columns.CreatedChangeTracking.ChangedBy,
    'A lone [TCreatedBy] is written by Insert and must keep mapping');
  Assert.IsNotNull(LMap.Columns.UpdatedChangeTracking.ChangedBy,
    'A lone [TUpdatedBy] is written by Update and must keep mapping');
end;

procedure TTMapperTests.AColumnWithTwoTrackingAttributesRaises;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTMapper.Instance.Load<TTestDoubleTrackedColumn>();
  except
    on E: ETException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'One column in two change tracking maps is emitted twice in the same ' +
    'SET list, with two values that contradict each other');
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

function TTMapperTests.AliasOf(
  const ATableMap: TTTableMap; const AColumnName: String): String;
var
  LColumn: TTColumnMap;
begin
  result := String.Empty;
  for LColumn in ATableMap.Columns do
    if SameText(LColumn.Name, AColumnName) then
      result := LColumn.AliasName;
end;

procedure TTMapperTests.ALongJoinAliasFoldsBeforeItHashes;
var
  LLower: String;
  LUpper: String;
begin
  LLower := TTIdentifier.JoinAliasName(
    'documentirighe', 'PrezzoUnitarioNetto');
  LUpper := TTIdentifier.JoinAliasName(
    'DocumentiRighe', 'PrezzoUnitarioNetto');

  Assert.AreEqual<Integer>(
    30, LLower.Length, 'Precondition: the alias is cut and hashed');
  Assert.IsTrue(
    TTIdentifier.Same(LLower, LUpper),
    'Every lookup that consumes a join alias compares without regard to ' +
    'case, and the cut hashed the name in the case it was written: above ' +
    'thirty characters two spellings of one column produced two different ' +
    'suffixes, and the query that named one was refused as an unknown ' +
    'column - on a name the writer considers correct');
end;

procedure TTMapperTests.AJoinAliasIsMeasuredInBytes;
var
  LColumn: String;
  LAlias: String;
begin
  LColumn := Format('Quantit%sResidua', [Char($00E0)]);
  LAlias := TTIdentifier.JoinAliasName('DocumentiRighe', LColumn);

  Assert.AreEqual<Integer>(
    30,
    Format('DocumentiRighe_%s', [LColumn]).Length,
    'Precondition: the alias is thirty characters, one of them accented');
  Assert.IsTrue(
    TEncoding.UTF8.GetByteCount(LAlias) <= 30,
    'Oracle up to 12.1 counts bytes, and an accented letter is two in '
    + 'AL32UTF8: thirty characters are thirty-one bytes, and a guard that '
    + 'measured Length let the alias through to ORA-00972');
  Assert.IsTrue(
    LAlias.StartsWith('DocumentiRighe_Quantit_'),
    'The head is cut in bytes too, on a character boundary: the accented '
    + 'letter would take the prefix to twenty-four bytes, so it goes');
end;

procedure TTMapperTests.ALongJoinAliasIsBoundedAndStaysUnique;
var
  LMap: TTTableMap;
  LNetto: String;
  LLordo: String;
begin
  LMap := TTMapper.Instance.Load<TTestLongAliasReport>();
  LNetto := AliasOf(LMap, 'PrezzoUnitarioNetto');
  LLordo := AliasOf(LMap, 'PrezzoUnitarioLordo');

  Assert.IsTrue(
    LNetto.Length <= 30,
    'DocumentiRighe_PrezzoUnitarioNetto is 34 characters, and Oracle up ' +
    'to 12.1 takes 30 while Firebird up to 3.0 and InterBase take 31: ' +
    'the same mapping worked on SQL Server and was refused there, with ' +
    'nothing to say so until you ran it');
  Assert.IsTrue(
    LNetto.StartsWith('DocumentiRighe_PrezzoUn'),
    'What is kept is the readable head, so the alias can still be ' +
    'recognised in a query that is being read');
  Assert.AreNotEqual(
    LNetto,
    LLordo,
    'Netto and Lordo share the first 23 characters, so truncation alone ' +
    'would have made them the same column twice in one select list: the ' +
    'hash is taken over the whole name');
end;

procedure TTMapperTests.AShortJoinAliasIsLeftAlone;
var
  LMap: TTTableMap;
begin
  LMap := TTMapper.Instance.Load<TTestLongAliasReport>();

  Assert.AreEqual(
    'DocumentiRighe_Qta',
    AliasOf(LMap, 'Qta'),
    'An alias that fits is untouched, so nothing changes for a mapping ' +
    'that works today');
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

procedure TTMapperTests.AColumnThatIsKeyAndVersionRaises;
var
  LMessage: String;
begin
  LMessage := String.Empty;
  try
    TTMapper.Instance.Load<TTestKeyIsVersion>();
  except
    on E: ETException do
      LMessage := E.Message;
  end;

  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SPrimaryKeyIsVersionColumn), ['ID']),
    LMessage,
    'An update on that mapping reads SET ID = ID + 1 WHERE ID = :ID, ' +
    'which moves the key of the row it is identifying by');
end;

procedure TTMapperTests.ATrackedPrimaryKeyRaises;
var
  LMessage: String;
begin
  LMessage := String.Empty;
  try
    TTMapper.Instance.Load<TTestTrackedPrimaryKey>();
  except
    on E: ETException do
      LMessage := E.Message;
  end;

  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SKeyColumnWithChangeTracking), [
        'ID', 'primary key']),
    LMessage,
    'Change tracking columns are written by the framework, and the key ' +
    'is not the framework''s to move: the duplicate check only ever ' +
    'compared the six tracking slots with one another');
end;

procedure TTMapperTests.AMemberThatIsColumnAndDetailColumnRaises;
var
  LMessage: String;
begin
  LMessage := String.Empty;
  try
    TTMapper.Instance.Load<TTestColumnAndDetailColumn>();
  except
    on E: ETException do
      LMessage := E.Message;
  end;

  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SColumnAndDetailColumn), ['FLines']),
    LMessage,
    'One maps a value of this row and the other a collection of another ' +
    'table: which one won used to depend on the order the attributes ' +
    'were written in');
end;

{ TTestMappingMetadataProvider }

function TTestMappingMetadataProvider.GetConnectionName: String;
begin
  result := 'Test';
end;

procedure TTestMappingMetadataProvider.GetMetadata(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LColumn: TTColumnMap;
begin
  for LColumn in ATableMap.Columns do
    ATableMetadata.Columns.Add(
      LColumn.LookupName,
      LColumn.SqlReference,
      TTColumnType.Create(ftString, 255, 0),
      LColumn);
end;

{ TTMetadataTests }

procedure TTMetadataTests.Setup;
begin
  FProvider := TTestMappingMetadataProvider.Create;
  FMetadata := TTMetadata.Create(FProvider);
end;

procedure TTMetadataTests.TearDown;
begin
  FMetadata.Free;
  FProvider.Free;
end;

function TTMetadataTests.MessageOfLoad<T>: String;
begin
  result := String.Empty;
  try
    FMetadata.Load<T>();
  except
    on E: ETException do
      result := E.Message;
  end;
end;

procedure TTMetadataTests.AnEntityWithoutATableIsRefused;
begin
  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SNotValidTableName), ['TTestNoTable']),
    MessageOfLoad<TTestNoTable>,
    'A query on it would read "FROM " and fail in the driver, with the ' +
    'driver''s words and not ours');
end;

procedure TTMetadataTests.AnEntityWithoutColumnsIsRefused;
begin
  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SNoMappedColumns), ['TTestNoColumns']),
    MessageOfLoad<TTestNoColumns>,
    'TTColumnsMap.Empty existed and nothing ever asked it');
end;

procedure TTMetadataTests.AnEntityWithoutAPrimaryKeyIsRefused;
begin
  Assert.AreEqual(
    TTLanguage.Instance.Translate(SNotDefinedPrimaryKey),
    MessageOfLoad<TTestNoPrimaryKey>,
    'It used to be an access violation on ATableMap.PrimaryKey.Name, ' +
    'while the provider had a clean message for the same case. A DTO ' +
    'without a key stays valid, because RawSelect does not come here');
end;

initialization
  TDUnitX.RegisterTestFixture(TTMapperTests);
  TDUnitX.RegisterTestFixture(TTMetadataTests);

end.
