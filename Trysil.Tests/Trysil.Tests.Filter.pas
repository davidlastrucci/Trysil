(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Filter;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Rtti,
  Trysil.Attributes,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Filter,
  Trysil.Filter.Expression,
  Trysil.Exceptions;

type

{ TTestFilterJoinItem - entity with a JOIN, for aliased properties }

  [TTable('Items')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  TTestFilterJoinItem = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Customers', 'Name')]
    FCustomerName: String;
  public
    property ID: TTPrimaryKey read FID;
    property CustomerName: String read FCustomerName;
  end;

{ TTestFilterLongJoinItem - alias and column longer than the limit }

  [TTable('DocumentiRighe')]
  [TJoin(TJoinKind.Inner, 'AnagraficaClienti', 'ClienteID', 'ID')]
  TTestFilterLongJoinItem = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('AnagraficaClienti', 'RagioneSociale')]
    FRagioneSociale: String;
  public
    property ID: TTPrimaryKey read FID;
    property RagioneSociale: String read FRagioneSociale;
  end;

{ TTestFilterItem }

  [TTable('Items')]
  TTestFilterItem = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Code')]
    FCode: String;

    [TColumn('Quantity')]
    FQuantity: Integer;

    [TColumn('Price')]
    FPrice: Double;
  public
    property ID: TTPrimaryKey read FID;
    property Code: String read FCode write FCode;
    property Quantity: Integer read FQuantity write FQuantity;
    property Price: Double read FPrice write FPrice;
  end;

{ TTestFilterMoneyItem }

  [TTable('Payments')]
  TTestFilterMoneyItem = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Amount')]
    FAmount: Currency;

    [TColumn('Reference')]
    FReference: TGuid;
  public
    property ID: TTPrimaryKey read FID;
    property Amount: Currency read FAmount write FAmount;
    property Reference: TGuid read FReference write FReference;
  end;

{ TTestFakeMetadataProvider }

  TTestFakeMetadataProvider = class(TTMetadataProvider)
  strict protected
    function GetConnectionName: String; override;
  public
    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;
  end;

{ TTestQuotedMetadataProvider }

  TTestQuotedMetadataProvider = class(TTMetadataProvider)
  strict protected
    function GetConnectionName: String; override;
  public
    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;
  end;

{ TTFilterBuilderTests }

  [TestFixture]
  TTFilterBuilderTests = class
  strict private
    FProvider: TTestFakeMetadataProvider;
    FMetadata: TTMetadata;

    function NewBuilder: TTFilterBuilder<TTestFilterItem>;
    function NewMoneyBuilder: TTFilterBuilder<TTestFilterMoneyItem>;
    function WhereRaises(const AExpression: TTExpression): Boolean;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure EmptyBuilderProducesEmptyFilter;

    [Test]
    procedure AFilterWithOnlyParametersIsNotEmpty;

    [Test]
    procedure SingleEqualConditionBuildsExpectedWhere;

    [Test]
    procedure SingleEqualConditionProducesOneParameter;

    [Test]
    procedure AndWhereJoinsWithAnd;

    [Test]
    procedure OrWhereJoinsWithOr;

    [Test]
    procedure AllComparisonOperatorsEmitExpectedSymbol;

    [Test]
    procedure LikeEmitsLikeOperator;

    [Test]
    procedure IsNullEmitsIsNullWithoutParameter;

    [Test]
    procedure IsNotNullEmitsIsNotNullWithoutParameter;

    [Test]
    procedure OrderByAscSetsOrderByWithoutSuffix;

    [Test]
    procedure OrderByDescSetsOrderByWithDescSuffix;

    [Test]
    procedure LimitAndOffsetAreCarriedIntoFilterPaging;

    [Test]
    procedure LimitWithoutOffsetPagesFromTheFirstRow;

    [Test]
    procedure OffsetWithoutLimitRaises;

    [Test]
    procedure AZeroStartWithNoLimitDoesNotRaise;

    [Test]
    procedure OrderByOnlyDoesNotPage;

    [Test]
    procedure IncludeDeletedSetsIncludeDeletedFlag;

    [Test]
    procedure UnknownColumnOnWhereRaisesETException;

    [Test]
    procedure ExpressionEqualBuildsExpectedWhere;

    [Test]
    procedure ExpressionGroupedOrAndKeepsParentheses;

    [Test]
    procedure ExpressionMixedWithFluentRenumbersParameters;

    [Test]
    procedure ExpressionNotWrapsGroupWithNot;

    [Test]
    procedure ExpressionBetweenEmitsTwoParameters;

    [Test]
    procedure ExpressionInValuesEmitsParameterList;

    [Test]
    procedure ExpressionInValuesWithNoValuesMatchesNothing;

    [Test]
    procedure OrderByDescMakesEveryColumnOfTheListDescending;

    [Test]
    procedure ACurrencyColumnKeepsItsConversion;

    [Test]
    procedure AGuidColumnKeepsItsConversion;

    [Test]
    procedure AnUnknownColumnIsNamedInTheMessage;

    [Test]
    procedure AnOrderByIsStoredAsTheNameTheMetadataGives;

    [Test]
    procedure ExpressionIsNullEmitsIsNullWithoutParameter;

    [Test]
    procedure OrderByDescPropertySetsOrderByWithDescSuffix;

    [Test]
    procedure ExpressionUnknownColumnRaisesETException;

    [Test]
    procedure AliasedPropertyQualifiesWhereAndParameter;

    [Test]
    procedure OrderByDescAliasedPropertyQualifiesColumn;

    [Test]
    procedure ALongAliasedPropertyNamesTheColumnTheMetadataHas;

    [Test]
    procedure OrderByUnknownColumnRaises;

    [Test]
    procedure OrderByAcceptsSeveralColumns;

    [Test]
    procedure IsNullOnUnknownColumnRaises;

    [Test]
    procedure AnExpressionWithoutParametersChecksItsColumn;
  end;

{ TTFilterQuotingTests }

  [TestFixture]
  TTFilterQuotingTests = class
  strict private
    FProvider: TTestQuotedMetadataProvider;
    FMetadata: TTMetadata;

    function NewBuilder: TTFilterBuilder<TTestFilterItem>;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AConditionCarriesTheReferenceTheMetadataGives;

    [Test]
    procedure AConditionKeepsTheParameterOnThePlainName;

    [Test]
    procedure IsNullCarriesTheReferenceTheMetadataGives;

    [Test]
    procedure AnOrderByCarriesTheReferenceTheMetadataGives;
  end;

implementation

{ TTestFakeMetadataProvider }

function TTestFakeMetadataProvider.GetConnectionName: String;
begin
  result := 'Fake';
end;

procedure TTestFakeMetadataProvider.GetMetadata(
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

{ TTestQuotedMetadataProvider }

function TTestQuotedMetadataProvider.GetConnectionName: String;
begin
  result := 'FakeQuoted';
end;

procedure TTestQuotedMetadataProvider.GetMetadata(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LColumn: TTColumnMap;
begin
  for LColumn in ATableMap.Columns do
    ATableMetadata.Columns.Add(
      LColumn.LookupName,
      Format('[%s]', [LColumn.SqlReference]),
      TTColumnType.Create(ftString, 255, 0),
      LColumn);
end;

{ TTFilterBuilderTests }

procedure TTFilterBuilderTests.Setup;
begin
  FProvider := TTestFakeMetadataProvider.Create;
  FMetadata := TTMetadata.Create(FProvider);
end;

procedure TTFilterBuilderTests.TearDown;
begin
  FMetadata.Free;
  FProvider.Free;
end;

function TTFilterBuilderTests.NewBuilder: TTFilterBuilder<TTestFilterItem>;
begin
  result := TTFilterBuilder<TTestFilterItem>.Create(FMetadata);
end;

function TTFilterBuilderTests.NewMoneyBuilder:
  TTFilterBuilder<TTestFilterMoneyItem>;
begin
  result := TTFilterBuilder<TTestFilterMoneyItem>.Create(FMetadata);
end;

function TTFilterBuilderTests.WhereRaises(
  const AExpression: TTExpression): Boolean;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
begin
  result := False;
  LBuilder := NewBuilder;
  try
    try
      LBuilder.Where(AExpression);
    except
      on E: ETException do
        result := True;
    end;
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionInValuesWithNoValuesMatchesNothing;
var
  LCode: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LBuilder := NewBuilder;
  try
    LBuilder.Where(LCode.InValues([]));
    LFilter := LBuilder.Build;

    Assert.AreEqual(
      '(1 = 0)',
      LFilter.Where,
      'An application filter that resolves to zero ids used to emit ' +
      'IN (), which is a syntax error on every dialect. In the empty ' +
      'set nothing is found, so that is what the clause has to say');
    Assert.AreEqual<Integer>(
      0,
      Length(LFilter.Parameters),
      'And it carries no parameter to bind');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByDescMakesEveryColumnOfTheListDescending;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByDesc('Code, Quantity');
    LFilter := LBuilder.Build;

    Assert.AreEqual(
      'Code DESC, Quantity DESC',
      LFilter.Paging.OrderBy,
      'The suffix used to be appended to the whole list, so only the ' +
      'last column was descending and the first came back ascending ' +
      'without anything saying so');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ACurrencyColumnKeepsItsConversion;
var
  LBuilder: TTFilterBuilder<TTestFilterMoneyItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewMoneyBuilder;
  try
    LBuilder.Where('Amount').Equal(TTValue.From<Currency>(10));
    LFilter := LBuilder.Build;

    Assert.AreEqual<Integer>(
      1, Length(LFilter.Parameters), 'Precondition: one parameter');
    Assert.IsTrue(
      LFilter.Parameters[0].IsCurrency,
      'The builder dropped the flag the HTTP filter carries, so the same ' +
      'condition bound an amount as a plain number through one path and ' +
      'as money through the other');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AGuidColumnKeepsItsConversion;
var
  LBuilder: TTFilterBuilder<TTestFilterMoneyItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewMoneyBuilder;
  try
    LBuilder.Where('Reference').Equal(
      TTValue.From<TGuid>(TGuid.Empty));
    LFilter := LBuilder.Build;

    Assert.AreEqual<Integer>(
      1, Length(LFilter.Parameters), 'Precondition: one parameter');
    Assert.IsTrue(
      LFilter.Parameters[0].IsGuid,
      'And the same for a TGuid column');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AnOrderByIsStoredAsTheNameTheMetadataGives;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByAsc('  code ,  quantity  ');
    LFilter := LBuilder.Build;

    Assert.AreEqual(
      'Code, Quantity',
      LFilter.Paging.OrderBy,
      'The builder validated the text and then stored the text, so what ' +
      'reached the ORDER BY was the caller''s string and not the name ' +
      'the check had resolved. It now stores what it resolved, which is ' +
      'what the HTTP filter has always done');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AnUnknownColumnIsNamedInTheMessage;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LMessage: String;
begin
  LBuilder := NewBuilder;
  try
    LMessage := String.Empty;
    try
      LBuilder.Where('DoesNotExist').Equal('x');
    except
      on E: ETException do
        LMessage := E.Message;
    end;

    Assert.IsTrue(
      LMessage.Contains('DoesNotExist'),
      'The message is what tells the caller which column it got wrong');
    Assert.IsFalse(
      LMessage.Contains('%'),
      'And it used to reach the user with the format placeholder still ' +
      'in it, because the resourcestring was translated and never ' +
      'formatted');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.EmptyBuilderProducesEmptyFilter;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LFilter := LBuilder.Build;
    Assert.IsTrue(LFilter.Where.IsEmpty);
    Assert.AreEqual<Integer>(0, Length(LFilter.Parameters));
    Assert.IsTrue(LFilter.Paging.IsEmpty);
    Assert.IsFalse(LFilter.IncludeDeleted);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AFilterWithOnlyParametersIsNotEmpty;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create(String.Empty);
  Assert.IsTrue(LFilter.IsEmpty, 'Precondition: nothing set yet');

  LFilter.AddParameter('p0', TFieldType.ftInteger, 1);
  Assert.IsFalse(
    LFilter.IsEmpty,
    'A filter carrying parameters is not empty, which is what a ' +
    '[TWhereClause] entity produces');
end;

procedure TTFilterBuilderTests.SingleEqualConditionBuildsExpectedWhere;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('X01');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code = :p0', LFilter.Where);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.SingleEqualConditionProducesOneParameter;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('X01');
    LFilter := LBuilder.Build;
    Assert.AreEqual<Integer>(1, Length(LFilter.Parameters));
    Assert.AreEqual('p0', LFilter.Parameters[0].Name);
    Assert.AreEqual('X01', LFilter.Parameters[0].Value.AsString);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AndWhereJoinsWithAnd;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('A');
    LBuilder.AndWhere('Quantity').Greater(10);
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code = :p0 AND Quantity > :p1', LFilter.Where);
    Assert.AreEqual<Integer>(2, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrWhereJoinsWithOr;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('A');
    LBuilder.OrWhere('Code').Equal('B');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code = :p0 OR Code = :p1', LFilter.Where);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AllComparisonOperatorsEmitExpectedSymbol;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Quantity').NotEqual(1);
    LBuilder.AndWhere('Quantity').Greater(2);
    LBuilder.AndWhere('Quantity').GreaterOrEqual(3);
    LBuilder.AndWhere('Quantity').Less(4);
    LBuilder.AndWhere('Quantity').LessOrEqual(5);
    LFilter := LBuilder.Build;
    Assert.AreEqual(
      'Quantity <> :p0 AND Quantity > :p1 AND Quantity >= :p2 ' +
      'AND Quantity < :p3 AND Quantity <= :p4',
      LFilter.Where);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.LikeEmitsLikeOperator;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Like('AB%');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code LIKE :p0', LFilter.Where);
    Assert.AreEqual('AB%', LFilter.Parameters[0].Value.AsString);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.IsNullEmitsIsNullWithoutParameter;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').IsNull;
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code IS NULL', LFilter.Where);
    Assert.AreEqual<Integer>(0, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.IsNotNullEmitsIsNotNullWithoutParameter;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').IsNotNull;
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code IS NOT NULL', LFilter.Where);
    Assert.AreEqual<Integer>(0, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByAscSetsOrderByWithoutSuffix;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByAsc('Code');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByDescSetsOrderByWithDescSuffix;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByDesc('Code');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code DESC', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.LimitAndOffsetAreCarriedIntoFilterPaging;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Limit(25);
    LBuilder.Offset(50);
    LBuilder.OrderByAsc('ID');
    LFilter := LBuilder.Build;
    Assert.IsTrue(LFilter.Paging.HasPagination);
    Assert.AreEqual(Integer(50), LFilter.Paging.Start);
    Assert.AreEqual(Integer(25), LFilter.Paging.Limit);
    Assert.AreEqual('ID', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.LimitWithoutOffsetPagesFromTheFirstRow;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Limit(25);
    LFilter := LBuilder.Build;
    Assert.IsTrue(
      LFilter.Paging.HasPagination,
      'A limit with no offset must still page');
    Assert.AreEqual(Integer(0), LFilter.Paging.Start);
    Assert.AreEqual(Integer(25), LFilter.Paging.Limit);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OffsetWithoutLimitRaises;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LRaised: Boolean;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Offset(50);

    LRaised := False;
    try
      LBuilder.Build;
    except
      on E: ETException do
        LRaised := True;
    end;

    Assert.IsTrue(
      LRaised,
      'An offset with no limit used to be dropped without a word');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AZeroStartWithNoLimitDoesNotRaise;
var
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create('Active = 1', 0, 0, 'Name ASC');
  Assert.IsFalse(
    LFilter.Paging.HasPagination,
    'Start zero with no limit means no paging, not an offset');
  Assert.AreEqual('Name ASC', LFilter.Paging.OrderBy);
end;

procedure TTFilterBuilderTests.OrderByOnlyDoesNotPage;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByAsc('ID');
    LFilter := LBuilder.Build;
    Assert.IsFalse(LFilter.Paging.HasPagination);
    Assert.AreEqual('ID', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.IncludeDeletedSetsIncludeDeletedFlag;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.IncludeDeleted;
    LFilter := LBuilder.Build;
    Assert.IsTrue(LFilter.IncludeDeleted);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.UnknownColumnOnWhereRaisesETException;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LRaised: Boolean;
begin
  LBuilder := NewBuilder;
  try
    LRaised := False;
    try
      LBuilder.Where('DoesNotExist').Equal('x');
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised, 'Expected ETException on unknown column');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionEqualBuildsExpectedWhere;
var
  LCode: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LBuilder := NewBuilder;
  try
    LBuilder.Where(LCode = 'X01');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code = :p0', LFilter.Where);
    Assert.AreEqual<Integer>(1, Length(LFilter.Parameters));
    Assert.AreEqual('X01', LFilter.Parameters[0].Value.AsString);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionGroupedOrAndKeepsParentheses;
var
  LCode: TTProperty;
  LQuantity: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LQuantity := TTProperty.Create('Quantity');
  LBuilder := NewBuilder;
  try
    LBuilder
      .Where((LCode = 'A') or (LCode = 'B'))
      .AndWhere(LQuantity >= 18);
    LFilter := LBuilder.Build;
    Assert.AreEqual(
      '(Code = :p0 OR Code = :p1) AND Quantity >= :p2', LFilter.Where);
    Assert.AreEqual<Integer>(3, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionMixedWithFluentRenumbersParameters;
var
  LQuantity: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LQuantity := TTProperty.Create('Quantity');
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('A');
    LBuilder.AndWhere(LQuantity > 5);
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code = :p0 AND Quantity > :p1', LFilter.Where);
    Assert.AreEqual<Integer>(2, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionNotWrapsGroupWithNot;
var
  LCode: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LBuilder := NewBuilder;
  try
    LBuilder.Where(not ((LCode = 'A') or (LCode = 'B')));
    LFilter := LBuilder.Build;
    Assert.AreEqual('NOT ((Code = :p0 OR Code = :p1))', LFilter.Where);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionBetweenEmitsTwoParameters;
var
  LQuantity: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LQuantity := TTProperty.Create('Quantity');
  LBuilder := NewBuilder;
  try
    LBuilder.Where(LQuantity.Between(1, 10));
    LFilter := LBuilder.Build;
    Assert.AreEqual('Quantity BETWEEN :p0 AND :p1', LFilter.Where);
    Assert.AreEqual<Integer>(2, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionInValuesEmitsParameterList;
var
  LCode: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LBuilder := NewBuilder;
  try
    LBuilder.Where(LCode.InValues(['A', 'B', 'C']));
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code IN (:p0, :p1, :p2)', LFilter.Where);
    Assert.AreEqual<Integer>(3, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionIsNullEmitsIsNullWithoutParameter;
var
  LCode: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LBuilder := NewBuilder;
  try
    LBuilder.Where(LCode.IsNull);
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code IS NULL', LFilter.Where);
    Assert.AreEqual<Integer>(0, Length(LFilter.Parameters));
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByDescPropertySetsOrderByWithDescSuffix;
var
  LCode: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LCode := TTProperty.Create('Code');
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByDesc(LCode);
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code DESC', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.ExpressionUnknownColumnRaisesETException;
var
  LUnknown: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LRaised: Boolean;
begin
  LUnknown := TTProperty.Create('DoesNotExist');
  LBuilder := NewBuilder;
  try
    LRaised := False;
    try
      LBuilder.Where(LUnknown = 'x');
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised, 'Expected ETException on unknown column');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AliasedPropertyQualifiesWhereAndParameter;
var
  LProperty: TTProperty;
  LExpression: TTExpression;
begin
  LProperty := TTProperty.Create('Customers', 'Name');
  LExpression := LProperty = 'Acme';
  Assert.AreEqual('Customers.Name = ?', LExpression.Sql);
  Assert.AreEqual<Integer>(1, Length(LExpression.Params));
  Assert.AreEqual('Customers_Name', LExpression.Params[0].ColumnName);
end;

procedure TTFilterBuilderTests.ALongAliasedPropertyNamesTheColumnTheMetadataHas;
var
  LProperty: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterLongJoinItem>;
  LFilter: TTFilter;
begin
  LProperty := TTProperty.Create('AnagraficaClienti', 'RagioneSociale');
  LBuilder := TTFilterBuilder<TTestFilterLongJoinItem>.Create(FMetadata);
  try
    LBuilder.Where(LProperty = 'Acme');
    LFilter := LBuilder.Build;
    Assert.AreEqual(
      'AnagraficaClienti.RagioneSociale = :p0',
      LFilter.Where,
      'The mapping cuts an output alias longer than 30 characters, which is ' +
      'the shortest limit of the seven engines, and replaces the tail with ' +
      'a hash. The expression API built the whole name instead, so above ' +
      'that length it named a column the metadata does not have and every ' +
      'expression on it was refused');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByDescAliasedPropertyQualifiesColumn;
var
  LProperty: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterJoinItem>;
  LFilter: TTFilter;
begin
  LProperty := TTProperty.Create('Customers', 'Name');
  LBuilder := TTFilterBuilder<TTestFilterJoinItem>.Create(FMetadata);
  try
    LBuilder.OrderByDesc(LProperty);
    LFilter := LBuilder.Build;
    Assert.AreEqual('Customers.Name DESC', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByUnknownColumnRaises;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LRaised: Boolean;
begin
  LBuilder := NewBuilder;
  try
    LRaised := False;
    try
      LBuilder.OrderByAsc('DoesNotExist');
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised, 'Expected ETException on unknown order by column');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.OrderByAcceptsSeveralColumns;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByAsc('Code, Quantity DESC');
    LFilter := LBuilder.Build;
    Assert.AreEqual('Code, Quantity DESC', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.IsNullOnUnknownColumnRaises;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LRaised: Boolean;
begin
  LBuilder := NewBuilder;
  try
    LRaised := False;
    try
      LBuilder.Where('DoesNotExist').IsNull;
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised, 'Expected ETException on unknown IsNull column');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterBuilderTests.AnExpressionWithoutParametersChecksItsColumn;
var
  LUnknown: TTProperty;
begin
  LUnknown := TTProperty.Create('DoesNotExist');

  Assert.IsTrue(
    WhereRaises(LUnknown.IsNull),
    'The builder checked a column only while binding its parameters, so an '
    + 'expression with none went through unchecked: a misspelled name in '
    + 'IsNull reached the SQL text. The fluent form had been closed and '
    + 'the expression form had not');
  Assert.IsTrue(
    WhereRaises(LUnknown.IsNotNull),
    'IsNotNull has no parameter either');
  Assert.IsTrue(
    WhereRaises(LUnknown.InValues([])),
    'and an empty InValues emits no column at all, which is exactly why '
    + 'its name has to be checked before it disappears');
  Assert.IsTrue(
    WhereRaises((TTProperty.Create('Code') = 'x') or LUnknown.IsNull),
    'The names travel through or with the expression');
  Assert.IsTrue(
    WhereRaises((TTProperty.Create('Code') = 'x') and LUnknown.IsNull),
    'through and');
  Assert.IsTrue(
    WhereRaises(not LUnknown.IsNull),
    'and through not');
end;

{ TTFilterQuotingTests }

procedure TTFilterQuotingTests.Setup;
begin
  FProvider := TTestQuotedMetadataProvider.Create;
  FMetadata := TTMetadata.Create(FProvider);
end;

procedure TTFilterQuotingTests.TearDown;
begin
  FMetadata.Free;
  FProvider.Free;
end;

function TTFilterQuotingTests.NewBuilder: TTFilterBuilder<TTestFilterItem>;
begin
  result := TTFilterBuilder<TTestFilterItem>.Create(FMetadata);
end;

procedure TTFilterQuotingTests.AConditionCarriesTheReferenceTheMetadataGives;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('X01');
    LFilter := LBuilder.Build;
    Assert.AreEqual(
      '[Code] = :p0',
      LFilter.Where,
      'The WHERE clause built by the fluent API must carry the reference ' +
      'the metadata gives, which is the one the driver has quoted');
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterQuotingTests.AConditionKeepsTheParameterOnThePlainName;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').Equal('X01');
    LFilter := LBuilder.Build;
    Assert.AreEqual<Integer>(1, Length(LFilter.Parameters));
    Assert.AreEqual('p0', LFilter.Parameters[0].Name);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterQuotingTests.IsNullCarriesTheReferenceTheMetadataGives;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.Where('Code').IsNull;
    LFilter := LBuilder.Build;
    Assert.AreEqual('[Code] IS NULL', LFilter.Where);
  finally
    LBuilder.Free;
  end;
end;

procedure TTFilterQuotingTests.AnOrderByCarriesTheReferenceTheMetadataGives;
var
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByAsc('Code, Quantity DESC');
    LFilter := LBuilder.Build;
    Assert.AreEqual('[Code], [Quantity] DESC', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTFilterBuilderTests);
  TDUnitX.RegisterTestFixture(TTFilterQuotingTests);

end.
