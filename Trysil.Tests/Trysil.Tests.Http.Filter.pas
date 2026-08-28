(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Filter;

interface

uses
  System.SysUtils,
  System.JSon,
  System.TypInfo,
  System.Rtti,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Filter,

  Trysil.Http.Filter,
  Trysil.Http.Exceptions,

  Trysil.Tests.Model;

type

{ TTHttpFilterTests }

  [TestFixture]
  TTHttpFilterTests = class
  strict private
    FTableMetadata: TTTableMetadata;

    function CreateWhereJSon(
      const AColumnName: String;
      const ACondition: String;
      const AValue: String): TJSonObject;
    function CreateOrderByJSon(
      const AColumnName: String; const ADirection: String): TJSonObject;
    function CreateSecretMetadata: TTTableMetadata;
    function TryBuildSecretFilter(const AColumnName: String): Boolean;
    function TryBuildFilter(
      const AColumnName: String;
      const ACondition: String;
      const AValue: String;
      out AFilter: TTFilter): Boolean;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure WhereEmitsPlaceholderInsteadOfValue;

    [Test]
    procedure WhereBindsStringValueAsParameter;

    [Test]
    procedure WhereBindsIntegerValueAsInteger;

    [Test]
    procedure WhereRejectsValueNotValidForColumn;

    [Test]
    procedure WhereRejectsUnknownColumn;

    [Test]
    procedure WhereRejectsUnknownCondition;

    [Test]
    procedure WhereRejectsLikeOnNonStringColumn;

    [Test]
    procedure WhereAcceptsLikeOnStringColumn;

    [Test]
    procedure WhereListNumbersParametersByIndex;

    [Test]
    procedure WhereListRejectsNonObjectItem;

    [Test]
    procedure WhereUsesTheCanonicalColumnName;

    [Test]
    procedure WhereListRejectsTooManyConditions;

    [Test]
    procedure OrderByUsesTheCanonicalColumnName;

    [Test]
    procedure OrderByListRejectsNonObjectItem;

    [Test]
    procedure OrderByListRejectsTooManyColumns;

    [Test]
    procedure ParametersCapTheLimit;

    [Test]
    procedure ParametersAllowAnUnlimitedLimit;

    [Test]
    procedure ParametersTreatZeroAsTheDefault;

    [Test]
    procedure WhereRejectsNotFilterableColumn;

    [Test]
    procedure WhereAcceptsFilterableColumn;
  end;

implementation

{ TTHttpFilterTests }

procedure TTHttpFilterTests.Setup;
begin
  FTableMetadata := TTTableMetadata.Create(
    TTMapper.Instance.Load<TTestCustomer>());
  FTableMetadata.Columns.Add('ID', TFieldType.ftInteger, 0);
  FTableMetadata.Columns.Add('Name', TFieldType.ftString, 100);
  FTableMetadata.Columns.Add('Email', TFieldType.ftString, 255);
  FTableMetadata.Columns.Add('VersionID', TFieldType.ftInteger, 0);
end;

procedure TTHttpFilterTests.TearDown;
begin
  FTableMetadata.Free;
end;

function TTHttpFilterTests.CreateWhereJSon(
  const AColumnName: String;
  const ACondition: String;
  const AValue: String): TJSonObject;
begin
  result := TJSonObject.Create;
  try
    result.AddPair('columnName', AColumnName);
    result.AddPair('condition', ACondition);
    result.AddPair('value', AValue);
  except
    result.Free;
    raise;
  end;
end;

function TTHttpFilterTests.CreateOrderByJSon(
  const AColumnName: String; const ADirection: String): TJSonObject;
begin
  result := TJSonObject.Create;
  try
    result.AddPair('columnName', AColumnName);
    result.AddPair('direction', ADirection);
  except
    result.Free;
    raise;
  end;
end;

function TTHttpFilterTests.CreateSecretMetadata: TTTableMetadata;
var
  LTableMap: TTTableMap;
  LColumn: TTColumnMap;
begin
  LTableMap := TTMapper.Instance.Load<TTestSecret>();
  result := TTTableMetadata.Create(LTableMap);
  try
    for LColumn in LTableMap.Columns do
      result.Columns.Add(LColumn.Name, TFieldType.ftString, 100, LColumn);
  except
    result.Free;
    raise;
  end;
end;

function TTHttpFilterTests.TryBuildSecretFilter(
  const AColumnName: String): Boolean;
var
  LMetadata: TTTableMetadata;
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  result := True;
  LMetadata := CreateSecretMetadata;
  try
    LJSon := CreateWhereJSon(AColumnName, '=', 'x');
    try
      try
        LWhere := TTHttpFilterWhere.Create(LJSon, LMetadata, 0);
        LWhere.ToString;
      except
        on E: ETHttpBadRequest do
          result := False;
      end;
    finally
      LJSon.Free;
    end;
  finally
    LMetadata.Free;
  end;
end;

function TTHttpFilterTests.TryBuildFilter(
  const AColumnName: String;
  const ACondition: String;
  const AValue: String;
  out AFilter: TTFilter): Boolean;
var
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  result := True;
  AFilter := TTFilter.Create(String.Empty);
  LJSon := CreateWhereJSon(AColumnName, ACondition, AValue);
  try
    try
      LWhere := TTHttpFilterWhere.Create(LJSon, FTableMetadata, 0);
      AFilter.Where := LWhere.ToString;
      LWhere.AddParameter(AFilter);
    except
      on E: ETHttpBadRequest do
        result := False;
    end;
  finally
    LJSon.Free;
  end;
end;

procedure TTHttpFilterTests.WhereEmitsPlaceholderInsteadOfValue;
var
  LFilter: TTFilter;
begin
  Assert.IsTrue(TryBuildFilter('Name', '=', 'Acme', LFilter));
  Assert.AreEqual('Name = :p0', LFilter.Where);
  Assert.IsFalse(
    LFilter.Where.Contains('Acme'),
    'The value must never reach the SQL text');
end;

procedure TTHttpFilterTests.WhereBindsStringValueAsParameter;
var
  LFilter: TTFilter;
begin
  Assert.IsTrue(TryBuildFilter('Name', '=', 'Acme', LFilter));
  Assert.AreEqual<Integer>(1, Length(LFilter.Parameters));
  Assert.AreEqual('p0', LFilter.Parameters[0].Name);
  Assert.IsTrue(
    LFilter.Parameters[0].DataType = TFieldType.ftString,
    'The parameter must carry the column data type');
  Assert.AreEqual<Integer>(100, LFilter.Parameters[0].Size);
  Assert.AreEqual('Acme', LFilter.Parameters[0].Value.AsType<String>());
end;

procedure TTHttpFilterTests.WhereBindsIntegerValueAsInteger;
var
  LFilter: TTFilter;
begin
  Assert.IsTrue(TryBuildFilter('ID', '>=', '42', LFilter));
  Assert.AreEqual<Integer>(1, Length(LFilter.Parameters));
  Assert.IsTrue(
    LFilter.Parameters[0].Value.TypeInfo = TypeInfo(Integer),
    'A numeric column must bind a typed value, not a string');
  Assert.AreEqual<Integer>(42, LFilter.Parameters[0].Value.AsType<Integer>());
end;

procedure TTHttpFilterTests.WhereRejectsValueNotValidForColumn;
var
  LFilter: TTFilter;
begin
  Assert.IsFalse(
    TryBuildFilter('ID', '=', 'abc', LFilter),
    'A value that does not match the column type must be a bad request');
end;

procedure TTHttpFilterTests.WhereRejectsUnknownColumn;
var
  LFilter: TTFilter;
begin
  Assert.IsFalse(
    TryBuildFilter('DropTable', '=', 'x', LFilter),
    'A column outside the table metadata must be a bad request');
end;

procedure TTHttpFilterTests.WhereRejectsUnknownCondition;
var
  LFilter: TTFilter;
begin
  Assert.IsFalse(
    TryBuildFilter('Name', 'DROP', 'x', LFilter),
    'A condition outside the closed list must be a bad request');
end;

procedure TTHttpFilterTests.WhereRejectsLikeOnNonStringColumn;
var
  LFilter: TTFilter;
begin
  Assert.IsFalse(
    TryBuildFilter('ID', 'LIKE', '1', LFilter),
    'LIKE on a non string column must be a bad request');
end;

procedure TTHttpFilterTests.WhereAcceptsLikeOnStringColumn;
var
  LFilter: TTFilter;
begin
  Assert.IsTrue(TryBuildFilter('Name', 'LIKE', '%Acme%', LFilter));
  Assert.AreEqual('Name LIKE :p0', LFilter.Where);
  Assert.AreEqual('%Acme%', LFilter.Parameters[0].Value.AsType<String>());
end;

procedure TTHttpFilterTests.WhereListNumbersParametersByIndex;
var
  LArray: TJSonArray;
  LList: TTHttpFilterWhereList;
  LFilter: TTFilter;
begin
  LFilter := TTFilter.Create(String.Empty);
  LArray := TJSonArray.Create;
  try
    LArray.AddElement(CreateWhereJSon('Name', '=', 'Acme'));
    LArray.AddElement(CreateWhereJSon('ID', '>', '10'));

    LList := TTHttpFilterWhereList.Create(LArray, FTableMetadata);
    LFilter.Where := LList.ToString;
    LList.AddParameters(LFilter);
  finally
    LArray.Free;
  end;

  Assert.AreEqual('Name = :p0 AND ID > :p1', LFilter.Where);
  Assert.AreEqual<Integer>(2, Length(LFilter.Parameters));
  Assert.AreEqual('p0', LFilter.Parameters[0].Name);
  Assert.AreEqual('p1', LFilter.Parameters[1].Name);
  Assert.AreEqual<Integer>(10, LFilter.Parameters[1].Value.AsType<Integer>());
end;

procedure TTHttpFilterTests.WhereListRejectsNonObjectItem;
var
  LArray: TJSonArray;
  LList: TTHttpFilterWhereList;
  LRaised: Boolean;
begin
  LRaised := False;
  LArray := TJSonArray.Create;
  try
    LArray.Add('oops');
    try
      LList := TTHttpFilterWhereList.Create(LArray, FTableMetadata, -1);
      LList.ToString;
    except
      on E: ETHttpBadRequest do
        LRaised := True;
    end;
  finally
    LArray.Free;
  end;

  Assert.IsTrue(
    LRaised, 'A non object item in the where array must be a bad request');
end;

procedure TTHttpFilterTests.WhereUsesTheCanonicalColumnName;
var
  LFilter: TTFilter;
begin
  Assert.IsTrue(TryBuildFilter('name', '=', 'Acme', LFilter));
  Assert.AreEqual(
    'Name = :p0',
    LFilter.Where,
    'The WHERE clause must carry the metadata column name');
end;

procedure TTHttpFilterTests.WhereListRejectsTooManyConditions;
var
  LArray: TJSonArray;
  LList: TTHttpFilterWhereList;
  LRaised: Boolean;
begin
  LRaised := False;
  LArray := TJSonArray.Create;
  try
    LArray.AddElement(CreateWhereJSon('Name', '=', 'Acme'));
    LArray.AddElement(CreateWhereJSon('Email', '=', 'a@b.c'));
    LArray.AddElement(CreateWhereJSon('ID', '>', '10'));
    try
      LList := TTHttpFilterWhereList.Create(LArray, FTableMetadata, 2);
      LList.ToString;
    except
      on E: ETHttpBadRequest do
        LRaised := True;
    end;
  finally
    LArray.Free;
  end;

  Assert.IsTrue(
    LRaised, 'More conditions than the maximum must be a bad request');
end;

procedure TTHttpFilterTests.OrderByUsesTheCanonicalColumnName;
var
  LArray: TJSonArray;
  LList: TTHttpFilterOrderByList;
begin
  LArray := TJSonArray.Create;
  try
    LArray.AddElement(CreateOrderByJSon('name', 'ASC'));

    LList := TTHttpFilterOrderByList.Create(LArray, FTableMetadata);
    Assert.AreEqual(
      'Name ASC',
      LList.ToString,
      'The ORDER BY clause must carry the metadata column name');
  finally
    LArray.Free;
  end;
end;

procedure TTHttpFilterTests.OrderByListRejectsNonObjectItem;
var
  LArray: TJSonArray;
  LList: TTHttpFilterOrderByList;
  LRaised: Boolean;
begin
  LRaised := False;
  LArray := TJSonArray.Create;
  try
    LArray.Add('oops');
    try
      LList := TTHttpFilterOrderByList.Create(LArray, FTableMetadata, -1);
      LList.ToString;
    except
      on E: ETHttpBadRequest do
        LRaised := True;
    end;
  finally
    LArray.Free;
  end;

  Assert.IsTrue(
    LRaised, 'A non object item in the orderBy array must be a bad request');
end;

procedure TTHttpFilterTests.OrderByListRejectsTooManyColumns;
var
  LArray: TJSonArray;
  LList: TTHttpFilterOrderByList;
  LRaised: Boolean;
begin
  LRaised := False;
  LArray := TJSonArray.Create;
  try
    LArray.AddElement(CreateOrderByJSon('Name', 'ASC'));
    LArray.AddElement(CreateOrderByJSon('Email', 'DESC'));
    try
      LList := TTHttpFilterOrderByList.Create(LArray, FTableMetadata, 1);
      LList.ToString;
    except
      on E: ETHttpBadRequest do
        LRaised := True;
    end;
  finally
    LArray.Free;
  end;

  Assert.IsTrue(
    LRaised, 'More order by columns than the maximum must be a bad request');
end;

procedure TTHttpFilterTests.ParametersCapTheLimit;
var
  LParameters: TTHttpFilterParameters;
begin
  LParameters := TTHttpFilterParameters.Create(100, 8, 4);
  Assert.AreEqual<Integer>(
    100,
    LParameters.LimitOrDefault(0),
    'An absent limit must fall back to the maximum');
  Assert.AreEqual<Integer>(
    100,
    LParameters.LimitOrDefault(5000),
    'A limit above the maximum must be capped');
  Assert.AreEqual<Integer>(10, LParameters.LimitOrDefault(10));
  Assert.IsFalse(
    LParameters.IncludeDeleted,
    'Soft deleted rows must be hidden unless the server asks for them');
end;

procedure TTHttpFilterTests.ParametersAllowAnUnlimitedLimit;
var
  LParameters: TTHttpFilterParameters;
begin
  LParameters := TTHttpFilterParameters.Create(-1, -1, -1);
  Assert.AreEqual<Integer>(0, LParameters.LimitOrDefault(0));
  Assert.AreEqual<Integer>(5000, LParameters.LimitOrDefault(5000));
end;

procedure TTHttpFilterTests.WhereRejectsNotFilterableColumn;
begin
  Assert.IsFalse(
    TryBuildSecretFilter('Password'),
    'A [TNotFilterable] column must never be reachable from the filter');
end;

procedure TTHttpFilterTests.WhereAcceptsFilterableColumn;
begin
  Assert.IsTrue(
    TryBuildSecretFilter('Name'),
    'Only the annotated columns are excluded, not the whole entity');
end;

procedure TTHttpFilterTests.ParametersTreatZeroAsTheDefault;
var
  LParameters: TTHttpFilterParameters;
begin
  LParameters := Default(TTHttpFilterParameters);
  Assert.AreEqual<Integer>(
    1000,
    LParameters.LimitOrDefault(0),
    'A zero ceiling must never mean the whole table');
  Assert.AreEqual<Integer>(32, LParameters.MaxWhereConditions);
  Assert.AreEqual<Integer>(8, LParameters.MaxOrderByColumns);
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpFilterTests);

end.
