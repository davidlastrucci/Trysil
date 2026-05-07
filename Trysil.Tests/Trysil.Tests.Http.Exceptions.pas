(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Exceptions;

interface

uses
  System.SysUtils,
  System.JSON,
  DUnitX.TestFramework,

  Trysil.Http.Exceptions;

type

{ TTHttpExceptionTests }

  [TestFixture]
  TTHttpExceptionTests = class
  public
    [Test]
    procedure BadRequestHasStatusCode400;

    [Test]
    procedure UnauthorizedHasStatusCode401;

    [Test]
    procedure ForbiddenHasStatusCode403;

    [Test]
    procedure NotFoundHasStatusCode404;

    [Test]
    procedure MethodNotAllowedHasStatusCode405;

    [Test]
    procedure InternalServerErrorHasStatusCode500;

    [Test]
    procedure ToJSonContainsStatusAndMessage;
  end;

implementation

{ TTHttpExceptionTests }

procedure TTHttpExceptionTests.BadRequestHasStatusCode400;
var
  LException: ETHttpBadRequest;
begin
  LException := ETHttpBadRequest.Create('bad request');
  try
    Assert.AreEqual<Integer>(400, LException.StatusCode);
  finally
    LException.Free;
  end;
end;

procedure TTHttpExceptionTests.UnauthorizedHasStatusCode401;
var
  LException: ETHttpUnauthorized;
begin
  LException := ETHttpUnauthorized.Create('unauthorized');
  try
    Assert.AreEqual<Integer>(401, LException.StatusCode);
  finally
    LException.Free;
  end;
end;

procedure TTHttpExceptionTests.ForbiddenHasStatusCode403;
var
  LException: ETHttpForbidden;
begin
  LException := ETHttpForbidden.Create('forbidden');
  try
    Assert.AreEqual<Integer>(403, LException.StatusCode);
  finally
    LException.Free;
  end;
end;

procedure TTHttpExceptionTests.NotFoundHasStatusCode404;
var
  LException: ETHttpNotFound;
begin
  LException := ETHttpNotFound.Create('not found');
  try
    Assert.AreEqual<Integer>(404, LException.StatusCode);
  finally
    LException.Free;
  end;
end;

procedure TTHttpExceptionTests.MethodNotAllowedHasStatusCode405;
var
  LException: ETHttpMethodNotAllowed;
begin
  LException := ETHttpMethodNotAllowed.Create('method not allowed');
  try
    Assert.AreEqual<Integer>(405, LException.StatusCode);
  finally
    LException.Free;
  end;
end;

procedure TTHttpExceptionTests.InternalServerErrorHasStatusCode500;
var
  LException: ETHttpInternalServerError;
begin
  LException := ETHttpInternalServerError.Create('internal error');
  try
    Assert.AreEqual<Integer>(500, LException.StatusCode);
  finally
    LException.Free;
  end;
end;

procedure TTHttpExceptionTests.ToJSonContainsStatusAndMessage;
var
  LException: ETHttpBadRequest;
  LJson: String;
  LObj: TJSonValue;
begin
  LException := ETHttpBadRequest.Create('invalid input');
  try
    LJson := LException.ToJSon;
  finally
    LException.Free;
  end;

  LObj := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LObj is TJSonObject, 'ToJSon must return a JSON object');
    Assert.AreEqual<Integer>(400,
      TJSonObject(LObj).GetValue<Integer>('status'));
    Assert.AreEqual('invalid input',
      TJSonObject(LObj).GetValue<String>('message'));
  finally
    LObj.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpExceptionTests);

end.
