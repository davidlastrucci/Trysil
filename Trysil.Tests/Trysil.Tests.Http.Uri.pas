(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Uri;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DUnitX.TestFramework,

  Trysil.Http.Types;

type

{ TTHttpUriTests }

  [TestFixture]
  TTHttpUriTests = class
  public
    [Test]
    procedure UriPartsParseCorrectly;

    [Test]
    procedure UriPartsEqualsSameUri;

    [Test]
    procedure UriPartsDifferentUriNotEqual;

    [Test]
    procedure UriPartsWildcardMatchesNumber;

    [Test]
    procedure UriPartsWildcardExtractsParam;

    [Test]
    procedure ControllerIdEqualsSameMethodAndUri;

    [Test]
    procedure ControllerIdDifferentMethodNotEqual;
  end;

implementation

{ TTHttpUriTests }

procedure TTHttpUriTests.UriPartsParseCorrectly;
var
  LParts: TTHttpUriParts;
begin
  LParts := TTHttpUriParts.Create('/api/users');
  Assert.AreEqual<Integer>(3, Length(LParts.Parts));
  Assert.AreEqual('api', LParts.Parts[1]);
  Assert.AreEqual('users', LParts.Parts[2]);
end;

procedure TTHttpUriTests.UriPartsEqualsSameUri;
var
  LPartsA: TTHttpUriParts;
  LPartsB: TTHttpUriParts;
begin
  LPartsA := TTHttpUriParts.Create('/api/users');
  LPartsB := TTHttpUriParts.Create('/api/users');
  Assert.IsTrue(LPartsA.Equals(LPartsB, nil));
end;

procedure TTHttpUriTests.UriPartsDifferentUriNotEqual;
var
  LPartsA: TTHttpUriParts;
  LPartsB: TTHttpUriParts;
begin
  LPartsA := TTHttpUriParts.Create('/api/users');
  LPartsB := TTHttpUriParts.Create('/api/orders');
  Assert.IsFalse(LPartsA.Equals(LPartsB, nil));
end;

procedure TTHttpUriTests.UriPartsWildcardMatchesNumber;
var
  LPattern: TTHttpUriParts;
  LActual: TTHttpUriParts;
begin
  LPattern := TTHttpUriParts.Create('/api/users/?');
  LActual := TTHttpUriParts.Create('/api/users/123');
  Assert.IsTrue(LPattern.Equals(LActual, nil),
    'Wildcard ? must match a numeric segment');
end;

procedure TTHttpUriTests.UriPartsWildcardExtractsParam;
var
  LPattern: TTHttpUriParts;
  LActual: TTHttpUriParts;
  LParams: TList<Integer>;
begin
  LPattern := TTHttpUriParts.Create('/api/users/?');
  LActual := TTHttpUriParts.Create('/api/users/42');
  LParams := TList<Integer>.Create;
  try
    Assert.IsTrue(LPattern.Equals(LActual, LParams));
    Assert.AreEqual<Integer>(1, LParams.Count);
    Assert.AreEqual<Integer>(42, LParams[0]);
  finally
    LParams.Free;
  end;
end;

procedure TTHttpUriTests.ControllerIdEqualsSameMethodAndUri;
var
  LIdA: TTHttpControllerID;
  LIdB: TTHttpControllerID;
begin
  LIdA := TTHttpControllerID.Create('/api/users', TTHttpMethodType.GET);
  LIdB := TTHttpControllerID.Create('/api/users', TTHttpMethodType.GET);
  Assert.IsTrue(LIdA.Equals(LIdB));
end;

procedure TTHttpUriTests.ControllerIdDifferentMethodNotEqual;
var
  LIdA: TTHttpControllerID;
  LIdB: TTHttpControllerID;
begin
  LIdA := TTHttpControllerID.Create('/api/users', TTHttpMethodType.GET);
  LIdB := TTHttpControllerID.Create('/api/users', TTHttpMethodType.POST);
  Assert.IsFalse(LIdA.Equals(LIdB));
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpUriTests);

end.
