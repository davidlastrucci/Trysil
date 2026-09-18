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
  System.Classes,
  System.Generics.Collections,
  DUnitX.TestFramework,

  IdCustomHTTPServer,

  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Exceptions;

type

{ TTHttpUriTests }

  [TestFixture]
  TTHttpUriTests = class
  public
    [Test]
    procedure AnUnsupportedMethodIsNotAllowedRatherThanAServerError;

    [Test]
    procedure AnUnsupportedMethodStillHasAName;

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
    procedure UriPartsWildcardExtractsEveryParam;

    [Test]
    procedure UriPartsLeavesNoParamsBehindOnAFailedMatch;

    [Test]
    procedure ControllerIdEqualsSameMethodAndUri;

    [Test]
    procedure ControllerIdDifferentMethodNotEqual;

    [Test]
    procedure TaskIDIsUniqueWithinTheSameThread;

    [Test]
    procedure TaskIDDoesNotDiscloseTheClock;

    [Test]
    procedure HeaderLookupIsCaseInsensitive;

    [Test]
    procedure HeaderLookupFoldsANameCarryingACapitalI;

    [Test]
    procedure ParameterLookupStaysCaseSensitive;
  end;

implementation

{ TTHttpUriTests }

procedure TTHttpUriTests.AnUnsupportedMethodIsNotAllowedRatherThanAServerError;
var
  LControllerID: TTHttpControllerID;
  LStatusCode: Integer;
begin
  LControllerID := TTHttpControllerID.Create(
    '/health', THttpCommandType.hcHEAD);

  LStatusCode := 0;
  try
    LControllerID.MethodType;
  except
    on E: ETHttpException do
      LStatusCode := E.StatusCode;
  end;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.MethodNotAllowed,
    LStatusCode,
    'A HEAD request is a method the route does not allow, not a server fault');
end;

procedure TTHttpUriTests.AnUnsupportedMethodStillHasAName;
var
  LControllerID: TTHttpControllerID;
begin
  LControllerID := TTHttpControllerID.Create(
    '/health', THttpCommandType.hcHEAD);

  Assert.AreEqual(
    'HEAD',
    LControllerID.Method,
    'The log entry must be writable for a method the router refuses');
end;

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

procedure TTHttpUriTests.UriPartsWildcardExtractsEveryParam;
var
  LPattern: TTHttpUriParts;
  LActual: TTHttpUriParts;
  LParams: TList<Integer>;
begin
  LPattern := TTHttpUriParts.Create('/api/orders/?/rows/?');
  LActual := TTHttpUriParts.Create('/api/orders/7/rows/3');
  LParams := TList<Integer>.Create;
  try
    Assert.IsTrue(LPattern.Equals(LActual, LParams));
    Assert.AreEqual<Integer>(
      2,
      LParams.Count,
      'Both placeholders carry a parameter, and with Sqids on only the ' +
      'first of them used to be decoded, so a valid id in second position ' +
      'matched nothing and the route answered 404');
    Assert.AreEqual<Integer>(7, LParams[0]);
    Assert.AreEqual<Integer>(3, LParams[1]);
  finally
    LParams.Free;
  end;
end;

procedure TTHttpUriTests.UriPartsLeavesNoParamsBehindOnAFailedMatch;
var
  LPattern: TTHttpUriParts;
  LActual: TTHttpUriParts;
  LParams: TList<Integer>;
begin
  LPattern := TTHttpUriParts.Create('/api/orders/?/rows');
  LActual := TTHttpUriParts.Create('/api/orders/7/items');
  LParams := TList<Integer>.Create;
  try
    Assert.IsFalse(LPattern.Equals(LActual, LParams));
    Assert.AreEqual<Integer>(
      0,
      LParams.Count,
      'The first placeholder matched and added a parameter, then the last ' +
      'segment did not: the list used to come back holding that parameter, ' +
      'and a request that fell through to a wildcard route was invoked ' +
      'with an argument nobody expected');
  finally
    LParams.Free;
  end;
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

procedure TTHttpUriTests.TaskIDIsUniqueWithinTheSameThread;
var
  LIDs: TList<String>;
  LIndex: Integer;
  LValue: String;
  LIsDuplicated: Boolean;
begin
  LIsDuplicated := False;
  LIDs := TList<String>.Create;
  try
    for LIndex := 1 to 1000 do
    begin
      LValue := TTHttpTaskID.NewID.ToString();
      if LIDs.Contains(LValue) then
        LIsDuplicated := True;
      LIDs.Add(LValue);
    end;
  finally
    LIDs.Free;
  end;

  Assert.IsFalse(
    LIsDuplicated,
    'Two tasks served by the same thread must not share an identifier');
end;

procedure TTHttpUriTests.TaskIDDoesNotDiscloseTheClock;
var
  LValue: String;
begin
  LValue := TTHttpTaskID.NewID.ToString();

  Assert.AreEqual<Integer>(32, LValue.Length);
  Assert.IsFalse(
    LValue.Contains(FormatDateTime('yyyymmdd', Now())),
    'The task identifier must not carry the server clock');
end;

procedure TTHttpUriTests.HeaderLookupIsCaseInsensitive;
var
  LHeaders: TTHttpHeaders;
  LStrings: TStringList;
begin
  LHeaders := TTHttpHeaders.Create;
  try
    LStrings := TStringList.Create;
    try
      LStrings.Add('authorization=Bearer token');
      LHeaders.AddStrings(LStrings);
    finally
      LStrings.Free;
    end;

    Assert.AreEqual(
      'Bearer token',
      LHeaders.Value['Authorization'],
      'Header names are case insensitive, and HTTP/2 sends them lower case');
  finally
    LHeaders.Free;
  end;
end;

procedure TTHttpUriTests.HeaderLookupFoldsANameCarryingACapitalI;
var
  LHeaders: TTHttpHeaders;
  LStrings: TStringList;
begin
  LHeaders := TTHttpHeaders.Create;
  try
    LStrings := TStringList.Create;
    try
      LStrings.Add('X-Api-Key=k-123');
      LHeaders.AddStrings(LStrings);
    finally
      LStrings.Free;
    end;

    Assert.AreEqual(
      'k-123',
      LHeaders.Value['X-API-KEY'],
      'This dictionary is one of the two the release re-keyed on ' +
      'TTIdentifier.Comparer, and no test reached it: the only ' +
      'case-insensitive header test used Authorization, a name with no ' +
      'capital I, so the fold that the whole locale sweep is about was ' +
      'never exercised here. GetValue goes straight to the dictionary, ' +
      'with no fallback to save it if the key does not land');
  finally
    LHeaders.Free;
  end;
end;

procedure TTHttpUriTests.ParameterLookupStaysCaseSensitive;
var
  LParameters: TTHttpParameters;
  LStrings: TStringList;
begin
  LParameters := TTHttpParameters.Create;
  try
    LStrings := TStringList.Create;
    try
      LStrings.Add('id=42');
      LParameters.AddStrings(LStrings);
    finally
      LStrings.Free;
    end;

    Assert.AreEqual('42', LParameters.Value['id']);
    Assert.AreEqual(
      String.Empty,
      LParameters.Value['ID'],
      'Query parameter names are case sensitive: only headers are not');
  finally
    LParameters.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpUriTests);

end.
