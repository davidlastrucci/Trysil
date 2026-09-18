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

    procedure AddColumn(
      const ATableMap: TTTableMap;
      const AColumnName: String;
      const ADataType: TFieldType;
      const ADataSize: Integer);
    function CreateWhereJSon(
      const AColumnName: String;
      const ACondition: String;
      const AValue: String): TJSonObject;
    function CreateOrderByJSon(
      const AColumnName: String; const ADirection: String): TJSonObject;
    function CreateSecretMetadata: TTTableMetadata;
    function SecretMetadataHasColumn(
      const AColumnName: String): Boolean;
    function CreateJoinMetadata: TTTableMetadata;
    function CreateNamesMetadata: TTTableMetadata;
    procedure AddColumnWithoutMember(const AMetadata: TTTableMetadata);
    function NamesWhere(
      const AColumnName: String;
      const ACondition: String): String;
    function NamesOrderBy(const AColumnName: String): String;
    function TryBuildSecretFilter(const AColumnName: String): Boolean;
    function SecretFilterRefusal(const AColumnName: String): String;
    function TryBuildWhere(const AJSon: TJSonObject): Boolean;
    function TryBuildOrderBy(const AJSon: TJSonObject): Boolean;
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
    procedure WhereEmitsTheCanonicalCondition;

    [Test]
    procedure OrderByEmitsTheCanonicalDirection;

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
    procedure WhereRejectsAColumnTheResponsesNeverReturn;

    [Test]
    procedure WhereRejectsAColumnHiddenByAnAttributeOfTheHost;

    [Test]
    procedure AGuardedColumnAnswersLikeOneThatDoesNotExist;

    [Test]
    procedure WhereAcceptsFilterableColumn;

    [Test]
    procedure WhereRefusesAValueOfTheWrongShape;

    [Test]
    procedure OrderByRefusesADirectionOfTheWrongShape;

    [Test]
    procedure AWhereOnAJoinedColumnQualifiesItWithTheAlias;

    [Test]
    procedure AWhereOnAJoinedColumnAcceptsThePublishedName;

    [Test]
    procedure AWhereOnAnOwnColumnStaysUnqualified;

    [Test]
    procedure AHiddenColumnIsRefusedUnderItsJSonNameToo;

    [Test]
    procedure AHiddenColumnNameIsNotPassedOnToAnotherMember;

    [Test]
    procedure ALazyMemberIsFilteredByItsPublishedName;

    [Test]
    procedure AnOrderByAcceptsTheJSonName;

    [Test]
    procedure AnEmptyColumnNameIsRefused;

    [Test]
    procedure ARefusalNamesTheColumnTheClientSent;
  end;

implementation

{ TTHttpFilterTests }

procedure TTHttpFilterTests.AddColumn(
  const ATableMap: TTTableMap;
  const AColumnName: String;
  const ADataType: TFieldType;
  const ADataSize: Integer);
begin
  FTableMetadata.Columns.Add(
    AColumnName,
    AColumnName,
    TTColumnType.Create(ADataType, ADataSize, 0),
    ATableMap.Columns.Find(AColumnName));
end;

procedure TTHttpFilterTests.Setup;
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<TTestCustomer>();
  FTableMetadata := TTTableMetadata.Create(LTableMap);
  AddColumn(LTableMap, 'ID', TFieldType.ftInteger, 0);
  AddColumn(LTableMap, 'Name', TFieldType.ftString, 100);
  AddColumn(LTableMap, 'Email', TFieldType.ftString, 255);
  AddColumn(LTableMap, 'VersionID', TFieldType.ftInteger, 0);
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

procedure TTHttpFilterTests.AWhereOnAJoinedColumnQualifiesItWithTheAlias;
var
  LMetadata: TTTableMetadata;
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  LMetadata := CreateJoinMetadata;
  try
    LJSon := CreateWhereJSon('Customers_Name', '=', 'Acme');
    try
      LWhere := TTHttpFilterWhere.Create(LJSon, LMetadata, 0);

      Assert.AreEqual(
        'Customers.Name = :p0',
        LWhere.ToString,
        'For an entity with a join the metadata are keyed by the output ' +
        'alias, and the filter put that alias straight into the WHERE: ' +
        'no engine resolves a select list alias there, so every filter ' +
        'on a join entity was invalid SQL');
    finally
      LJSon.Free;
    end;
  finally
    LMetadata.Free;
  end;
end;

procedure TTHttpFilterTests.AWhereOnAJoinedColumnAcceptsThePublishedName;
var
  LMetadata: TTTableMetadata;
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  LMetadata := CreateJoinMetadata;
  try
    LJSon := CreateWhereJSon('customerName', '=', 'Acme');
    try
      LWhere := TTHttpFilterWhere.Create(LJSon, LMetadata, 0);

      Assert.AreEqual(
        'Customers.Name = :p0',
        LWhere.ToString,
        'MetadataToJSon publishes the column as customerName, which is the '
        + 'name the data come out under, while the metadata are keyed by '
        + 'the output alias Customers_Name. A client that built its filter '
        + 'from the payload sent a name the gate refused, so on a join '
        + 'entity every where and every orderBy answered 400 while the '
        + 'payload marked nothing as not filterable');
    finally
      LJSon.Free;
    end;
  finally
    LMetadata.Free;
  end;
end;

procedure TTHttpFilterTests.AWhereOnAnOwnColumnStaysUnqualified;
var
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  LJSon := CreateWhereJSon('Name', '=', 'Acme');
  try
    LWhere := TTHttpFilterWhere.Create(LJSon, FTableMetadata, 0);

    Assert.AreEqual(
      'Name = :p0',
      LWhere.ToString,
      'An entity without joins has nothing to qualify, and the reference ' +
      'stays the bare column it always was');
  finally
    LJSon.Free;
  end;
end;

function TTHttpFilterTests.CreateJoinMetadata: TTTableMetadata;
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
begin
  LTableMap := TTMapper.Instance.Load<TTestOrderReport>();
  result := TTTableMetadata.Create(LTableMap);
  try
    for LColumnMap in LTableMap.Columns do
      result.Columns.Add(
        LColumnMap.LookupName,
        LColumnMap.SqlReference,
        TTColumnType.Create(TFieldType.ftString, 100, 0),
        LColumnMap);
  except
    result.Free;
    raise;
  end;
end;

function TTHttpFilterTests.CreateNamesMetadata: TTTableMetadata;
var
  LTableMap: TTTableMap;
  LColumn: TTColumnMap;
  LType: TFieldType;
begin
  LTableMap := TTMapper.Instance.Load<TTestFilterNames>();
  result := TTTableMetadata.Create(LTableMap);
  try
    for LColumn in LTableMap.Columns do
    begin
      LType := TFieldType.ftInteger;
      if LColumn.Member.RttiType.TypeKind in [tkString, tkUString] then
        LType := TFieldType.ftString;
      result.Columns.Add(
        LColumn.Name,
        LColumn.SqlReference,
        TTColumnType.Create(LType, 100, 0),
        LColumn);
    end;
    AddColumnWithoutMember(result);
  except
    result.Free;
    raise;
  end;
end;

procedure TTHttpFilterTests.AddColumnWithoutMember(
  const AMetadata: TTTableMetadata);
var
  LColumn: TTColumnMap;
begin
  LColumn := TTColumnMap.Create('NO_MEMBER');
  try
    AMetadata.Columns.Add(
      LColumn.Name,
      LColumn.SqlReference,
      TTColumnType.Create(TFieldType.ftInteger, 100, 0),
      LColumn);
  finally
    LColumn.Free;
  end;
end;

function TTHttpFilterTests.NamesWhere(
  const AColumnName: String;
  const ACondition: String): String;
var
  LMetadata: TTTableMetadata;
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  LMetadata := CreateNamesMetadata;
  try
    LJSon := CreateWhereJSon(AColumnName, ACondition, '1');
    try
      try
        LWhere := TTHttpFilterWhere.Create(LJSon, LMetadata, 0);
        result := LWhere.ToString;
      except
        on E: ETHttpBadRequest do
          result := Format('400: %s', [E.Message]);
      end;
    finally
      LJSon.Free;
    end;
  finally
    LMetadata.Free;
  end;
end;

function TTHttpFilterTests.NamesOrderBy(const AColumnName: String): String;
var
  LMetadata: TTTableMetadata;
  LJSon: TJSonObject;
  LOrderBy: TTHttpFilterOrderBy;
begin
  LMetadata := CreateNamesMetadata;
  try
    LJSon := CreateOrderByJSon(AColumnName, 'ASC');
    try
      try
        LOrderBy := TTHttpFilterOrderBy.Create(LJSon, LMetadata);
        result := LOrderBy.ToString;
      except
        on E: ETHttpBadRequest do
          result := Format('400: %s', [E.Message]);
      end;
    finally
      LJSon.Free;
    end;
  finally
    LMetadata.Free;
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
      result.Columns.Add(
        LColumn.Name,
        LColumn.SqlReference,
        TTColumnType.Create(TFieldType.ftString, 100, 0),
        LColumn);
  except
    result.Free;
    raise;
  end;
end;

function TTHttpFilterTests.SecretMetadataHasColumn(
  const AColumnName: String): Boolean;
var
  LMetadata: TTTableMetadata;
begin
  LMetadata := CreateSecretMetadata;
  try
    result := Assigned(LMetadata.Columns.Find(AColumnName));
  finally
    LMetadata.Free;
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

function TTHttpFilterTests.SecretFilterRefusal(
  const AColumnName: String): String;
var
  LMetadata: TTTableMetadata;
  LJSon: TJSonObject;
  LWhere: TTHttpFilterWhere;
begin
  result := String.Empty;
  LMetadata := CreateSecretMetadata;
  try
    LJSon := CreateWhereJSon(AColumnName, '=', 'x');
    try
      try
        LWhere := TTHttpFilterWhere.Create(LJSon, LMetadata, 0);
        LWhere.ToString;
      except
        on E: ETHttpBadRequest do
          result := E.Message;
      end;
    finally
      LJSon.Free;
    end;
  finally
    LMetadata.Free;
  end;
end;

function TTHttpFilterTests.TryBuildWhere(
  const AJSon: TJSonObject): Boolean;
var
  LWhere: TTHttpFilterWhere;
begin
  result := True;
  try
    LWhere := TTHttpFilterWhere.Create(AJSon, FTableMetadata, 0);
    LWhere.ToString;
  except
    on E: ETHttpBadRequest do
      result := False;
  end;
end;

function TTHttpFilterTests.TryBuildOrderBy(
  const AJSon: TJSonObject): Boolean;
var
  LOrderBy: TTHttpFilterOrderBy;
begin
  result := True;
  try
    LOrderBy := TTHttpFilterOrderBy.Create(AJSon, FTableMetadata);
    LOrderBy.ToString;
  except
    on E: ETHttpBadRequest do
      result := False;
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

procedure TTHttpFilterTests.WhereEmitsTheCanonicalCondition;
var
  LFilter: TTFilter;
begin
  Assert.IsTrue(TryBuildFilter('Name', 'like', '%Acme%', LFilter));
  Assert.AreEqual(
    'Name LIKE :p0',
    LFilter.Where,
    'The SQL must carry the allowlist constant, not the client string');
end;

procedure TTHttpFilterTests.OrderByEmitsTheCanonicalDirection;
var
  LArray: TJSonArray;
  LList: TTHttpFilterOrderByList;
begin
  LArray := TJSonArray.Create;
  try
    LArray.AddElement(CreateOrderByJSon('name', 'desc'));

    LList := TTHttpFilterOrderByList.Create(LArray, FTableMetadata);
    Assert.AreEqual(
      'Name DESC',
      LList.ToString,
      'The direction must be the allowlist constant, not what arrived');
  finally
    LArray.Free;
  end;
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

procedure TTHttpFilterTests.WhereRejectsAColumnTheResponsesNeverReturn;
begin
  Assert.IsTrue(
    TryBuildSecretFilter('Name'),
    'Precondition: an ordinary column is filterable');
  Assert.IsTrue(
    SecretMetadataHasColumn('Token'),
    'Precondition: Token is a mapped column. Without this the assertion '
    + 'below is satisfied by a column that is simply not there - and the '
    + 'refusal for a hidden column is textually identical to the refusal '
    + 'for an unknown one, as the test two below proves. Rename the column '
    + 'or drop the attribute and the test stays green');
  Assert.IsFalse(
    TryBuildSecretFilter('Token'),
    'A column no response ever returns must not be filterable either, and ' +
    'nobody marked this one [TNotFilterable]: LIKE plus the row count of ' +
    'the answer reads it one character at a time, which is exactly what ' +
    'hiding it was for');
end;

procedure TTHttpFilterTests.WhereRejectsAColumnHiddenByAnAttributeOfTheHost;
begin
  Assert.IsTrue(
    SecretMetadataHasColumn('Segreto'),
    'Precondition: Segreto is a mapped column, so the refusal below is '
    + 'about the attribute and not about a name nobody knows');
  Assert.IsFalse(
    TryBuildSecretFilter('Segreto'),
    'Every attribute lookup in this library is polymorphic, because an ' +
    'attribute is an ordinary class and an application may derive from ' +
    'one. The gate compares names, so a column hidden by a descendant of ' +
    '[TJSonIgnoreSerialize] was hidden from the payload and still ' +
    'filterable: the payload said no and the server said yes');
end;

procedure TTHttpFilterTests.AGuardedColumnAnswersLikeOneThatDoesNotExist;
var
  LGuarded: String;
  LUnknown: String;
begin
  LGuarded := SecretFilterRefusal('Password');
  LUnknown := SecretFilterRefusal('ThisColumnDoesNotExist');

  Assert.IsNotEmpty(LGuarded, 'Precondition: both are refused');
  Assert.AreEqual(
    LGuarded.Replace('Password', String.Empty, [rfReplaceAll]),
    LUnknown.Replace('ThisColumnDoesNotExist', String.Empty, [rfReplaceAll]),
    'The two refusals used to be different messages, so a caller who could ' +
    'read one route could enumerate the [TNotFilterable] columns of the ' +
    'entity by asking: the ones the host marked precisely because they ' +
    'must not be probed. It is not a leak of data, it is the map of where ' +
    'they are');
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

procedure TTHttpFilterTests.WhereRefusesAValueOfTheWrongShape;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('columnName', 'Name');
    LJSon.AddPair('condition', '=');
    LJSon.AddPair('value', TJSonObject.Create);

    Assert.IsFalse(
      TryBuildWhere(LJSon),
      'An object where the value goes was a 500 on Delphi 11 and an empty ' +
      'string on Delphi 13, so the same filter matched nothing instead of ' +
      'saying it was malformed');
  finally
    LJSon.Free;
  end;
end;

procedure TTHttpFilterTests.OrderByRefusesADirectionOfTheWrongShape;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('columnName', 'Name');
    LJSon.AddPair('direction', TJSonArray.Create);

    Assert.IsFalse(
      TryBuildOrderBy(LJSon), 'The ordering is read the same way');
  finally
    LJSon.Free;
  end;
end;

procedure TTHttpFilterTests.AHiddenColumnIsRefusedUnderItsJSonNameToo;
begin
  Assert.AreEqual(
    'DESCR = :p0',
    NamesWhere('descrizione', '='),
    'Precondition: a visible column is reached by its JSON name');
  Assert.IsTrue(
    NamesWhere('noteInterne', '=').StartsWith('400'),
    'NOTE_INT is hidden from the responses and its JSON name is not its '
    + 'column name, so only the second pass of the lookup finds it. Every '
    + 'hidden column of the suite had a JSON name equal to its column name, '
    + 'and a lookup that checked the flags on the first pass alone stayed '
    + 'green');
  Assert.IsTrue(
    NamesWhere('NOTE_INT', '=').StartsWith('400'),
    'and under its column name');
end;

procedure TTHttpFilterTests.AHiddenColumnNameIsNotPassedOnToAnotherMember;
begin
  Assert.IsTrue(
    NamesWhere('clienteID', '=').StartsWith('400'),
    'clienteID is the name, case aside, of the hidden column ClienteID, '
    + 'and also the JSON name of the visible column IDCliente. The column '
    + 'name is tried first and its refusal is the answer. Passing the name '
    + 'on to the other member would move a filter written for one column '
    + 'onto another with a 200 and nothing said: in 1.0.0, which checked '
    + 'nothing, this name filtered on ClienteID');
end;

procedure TTHttpFilterTests.ALazyMemberIsFilteredByItsPublishedName;
begin
  Assert.AreEqual(
    'CUST_REF = :p0',
    NamesWhere('customerID', '='),
    'A lazy member is published as its name plus ID, which is neither the '
    + 'member nor the column');
end;

procedure TTHttpFilterTests.AnOrderByAcceptsTheJSonName;
begin
  Assert.IsTrue(
    NamesOrderBy('descrizione').StartsWith('DESCR '),
    'orderBy goes through the same lookup as where');
end;

procedure TTHttpFilterTests.AnEmptyColumnNameIsRefused;
begin
  Assert.IsTrue(
    NamesWhere(String.Empty, '=').StartsWith('400'),
    'A missing columnName reads as an empty string, and a column with no '
    + 'member has an empty JSON name: the two used to match. The metadata '
    + 'of this fixture carry such a column, NO_MEMBER; without it every '
    + 'JSON name was set, and the test stayed green with the guard gone');
end;

procedure TTHttpFilterTests.ARefusalNamesTheColumnTheClientSent;
var
  LRefusal: String;
begin
  LRefusal := NamesWhere('customerID', 'LIKE');

  Assert.IsTrue(
    LRefusal.StartsWith('400'), 'Precondition: LIKE on a number');
  Assert.IsTrue(
    LRefusal.Contains('customerID'),
    'The refusal repeats the name the client sent');
  Assert.IsFalse(
    LRefusal.Contains('CUST_REF'),
    'and not the database name behind it, which the payload stopped '
    + 'publishing in this release');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpFilterTests);

end.
