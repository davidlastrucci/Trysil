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

  Trysil.Exceptions,
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
    procedure ConflictHasStatusCode409;

    [Test]
    procedure InternalServerErrorHasStatusCode500;

    [Test]
    procedure ToJSonContainsStatusAndMessage;

    [Test]
    procedure ErrorResponseHidesTheExceptionDetail;

    [Test]
    procedure NestedExceptionIsCapturedAsStrings;

    [Test]
    procedure NestedExceptionIsNotStolen;

    [Test]
    procedure ErrorResponseKeepsTheStatusCode;
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

procedure TTHttpExceptionTests.ConflictHasStatusCode409;
var
  LException: ETHttpConflict;
begin
  LException := ETHttpConflict.Create('conflict');
  try
    Assert.AreEqual<Integer>(409, LException.StatusCode);
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

procedure TTHttpExceptionTests.ErrorResponseHidesTheExceptionDetail;
var
  LJson: String;
  LObj: TJSonValue;
begin
  LJson := TTHttpErrorResponse.ToJSon('task-001');

  LObj := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LObj is TJSonObject, 'ToJSon must return a JSON object');
    Assert.AreEqual<Integer>(
      500, TJSonObject(LObj).GetValue<Integer>('status'));
    Assert.AreEqual(
      'task-001', TJSonObject(LObj).GetValue<String>('taskId'));
    Assert.IsFalse(
      Assigned(TJSonObject(LObj).FindValue('nestedException')),
      'The 500 body must not carry an exception chain');
  finally
    LObj.Free;
  end;
end;

procedure TTHttpExceptionTests.ErrorResponseKeepsTheStatusCode;
var
  LJson: String;
  LObj: TJSonValue;
begin
  LJson := TTHttpErrorResponse.ToJSon(503, 'task-002');

  LObj := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.AreEqual<Integer>(
      503,
      TJSonObject(LObj).GetValue<Integer>('status'),
      'A 5xx other than 500 must keep its own status code');
    Assert.AreEqual(
      'task-002', TJSonObject(LObj).GetValue<String>('taskId'));
  finally
    LObj.Free;
  end;
end;

procedure TTHttpExceptionTests.NestedExceptionIsCapturedAsStrings;
var
  LException: ETHttpBadRequest;
  LClassName: String;
  LMessage: String;
begin
  LClassName := String.Empty;
  LMessage := String.Empty;
  try
    raise ETHttpNotFound.Create('original');
  except
    on E: Exception do
    begin
      LException := ETHttpBadRequest.Create('secondary');
      try
        LClassName := LException.NestedExceptionClassName;
        LMessage := LException.NestedExceptionMessage;
      finally
        LException.Free;
      end;
    end;
  end;

  Assert.AreEqual('ETHttpNotFound', LClassName);
  Assert.AreEqual('original', LMessage);
end;

procedure TTHttpExceptionTests.NestedExceptionIsNotStolen;
var
  LMessage: String;
begin
  LMessage := String.Empty;
  try
    try
      raise ETHttpNotFound.Create('original');
    except
      on E: Exception do
      begin
        try
          raise ETHttpBadRequest.Create('secondary');
        except
          // The nested exception must not take ownership of the outer one
        end;
        raise;
      end;
    end;
  except
    on E: Exception do
      LMessage := E.Message;
  end;

  Assert.AreEqual(
    'original',
    LMessage,
    'A Trysil exception must not free the exception in flight');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpExceptionTests);

end.
