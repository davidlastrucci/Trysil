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
  Trysil.Attributes,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Filter,
  Trysil.Filter.Expression,
  Trysil.Exceptions;

type

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

{ TTestFakeMetadataProvider }

  TTestFakeMetadataProvider = class(TTMetadataProvider)
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
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure EmptyBuilderProducesEmptyFilter;

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
    procedure ExpressionIsNullEmitsIsNullWithoutParameter;

    [Test]
    procedure OrderByDescPropertySetsOrderByWithDescSuffix;

    [Test]
    procedure ExpressionUnknownColumnRaisesETException;

    [Test]
    procedure AliasedPropertyQualifiesWhereAndParameter;

    [Test]
    procedure OrderByDescAliasedPropertyQualifiesColumn;
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
    ATableMetadata.Columns.Add(LColumn.Name, ftString, 255);
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

procedure TTFilterBuilderTests.OrderByDescAliasedPropertyQualifiesColumn;
var
  LProperty: TTProperty;
  LBuilder: TTFilterBuilder<TTestFilterItem>;
  LFilter: TTFilter;
begin
  LProperty := TTProperty.Create('Customers', 'Name');
  LBuilder := NewBuilder;
  try
    LBuilder.OrderByDesc(LProperty);
    LFilter := LBuilder.Build;
    Assert.AreEqual('Customers.Name DESC', LFilter.Paging.OrderBy);
  finally
    LBuilder.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTFilterBuilderTests);

end.
