(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.HttpFilter;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.JSon,
  DUnitX.TestFramework,

  Trysil.Data,
  Trysil.Filter,
  Trysil.Context,

  Trysil.Http.Filter,
  Trysil.Http.Exceptions,

  Trysil.Tests.Model,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteHttpFilterTests }

  [TestFixture]
  TTSQLiteHttpFilterTests = class
  strict private
    FConnection: TTConnection;
    FContext: TTContext;

    function BuildFrom(const AJSon: TJSonValue): TTHttpFilter<TTestCustomer>;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AnObjectBodyIsAFilter;

    [Test]
    procedure ABodyThatIsNotAnObjectIsRefused;

    [Test]
    procedure NoBodyIsNoFilter;

  end;

implementation

{ TTSQLiteHttpFilterTests }

procedure TTSQLiteHttpFilterTests.Setup;
begin
  FConnection := TTSQLiteTestConnection.Connection;
  FContext := TTContext.Create(FConnection, False);
end;

procedure TTSQLiteHttpFilterTests.TearDown;
begin
  FContext.Free;
end;

function TTSQLiteHttpFilterTests.BuildFrom(
  const AJSon: TJSonValue): TTHttpFilter<TTestCustomer>;
begin
  result := TTHttpFilter<TTestCustomer>.Create(FContext, AJSon);
end;

procedure TTSQLiteHttpFilterTests.AnObjectBodyIsAFilter;
var
  LJSon: TJSonValue;
  LFilter: TTHttpFilter<TTestCustomer>;
begin
  LJSon := TJSonObject.ParseJSONValue('{"limit":10}');
  try
    LFilter := BuildFrom(LJSon);
    Assert.AreEqual<Integer>(
      10,
      LFilter.Filter.Paging.Limit,
      'Precondition: an object body is read as the filter it is');
  finally
    LJSon.Free;
  end;
end;

procedure TTSQLiteHttpFilterTests.ABodyThatIsNotAnObjectIsRefused;
var
  LJSon: TJSonValue;
  LFilter: TTHttpFilter<TTestCustomer>;
  LRaised: Boolean;
begin
  LRaised := False;
  LJSon := TJSonObject.ParseJSONValue('[]');
  try
    try
      LFilter := BuildFrom(LJSon);
    except
      on E: ETHttpBadRequest do
        LRaised := True;
    end;
  finally
    LJSon.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'FindValue on a root that is not an object returns nil, and nil reads ' +
    'as "no condition": a body of [] or 0 or true answered 200 with the ' +
    'whole table, which is the one thing a dropped filter must never do');
end;

procedure TTSQLiteHttpFilterTests.NoBodyIsNoFilter;
var
  LFilter: TTHttpFilter<TTestCustomer>;
begin
  LFilter := BuildFrom(nil);
  Assert.IsTrue(
    LFilter.Filter.Where.IsEmpty,
    'No body is not a malformed body: nil has always meant no filter, and ' +
    'turning it into a 400 would be a different break');
end;

end.
