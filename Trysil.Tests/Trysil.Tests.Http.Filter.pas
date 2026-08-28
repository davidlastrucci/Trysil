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
      LList := TTHttpFilterWhereList.Create(LArray, FTableMetadata);
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

initialization
  TDUnitX.RegisterTestFixture(TTHttpFilterTests);

end.
