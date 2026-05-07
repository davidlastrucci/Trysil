(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Log;

interface

uses
  System.SysUtils,
  System.JSON,
  DUnitX.TestFramework,

  Trysil.Http.Log.Types;

type

{ TTHttpLogTests }

  [TestFixture]
  TTHttpLogTests = class
  public
    [Test]
    procedure LogActionToJSonContainsFields;

    [Test]
    procedure LogActionPreservesTaskIdAndAction;
  end;

implementation

{ TTHttpLogTests }

procedure TTHttpLogTests.LogActionToJSonContainsFields;
var
  LAction: TTHttpLogAction;
  LJson: String;
  LObj: TJSonValue;
begin
  LAction := TTHttpLogAction.Create('task-001', 'TestAction');
  LJson := LAction.ToJSon;

  LObj := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LObj is TJSonObject,
      'LogAction.ToJSon must return a JSON object');
    Assert.AreEqual('task-001',
      TJSonObject(LObj).GetValue<String>('TaskID'));
    Assert.AreEqual('TestAction',
      TJSonObject(LObj).GetValue<String>('Action'));
    Assert.IsTrue(
      TJSonObject(LObj).GetValue('DateTime') <> nil,
      'LogAction JSON must contain DateTime');
  finally
    LObj.Free;
  end;
end;

procedure TTHttpLogTests.LogActionPreservesTaskIdAndAction;
var
  LAction: TTHttpLogAction;
begin
  LAction := TTHttpLogAction.Create('task-002', 'ProcessRequest');
  Assert.AreEqual('task-002', LAction.TaskID);
  Assert.AreEqual('ProcessRequest', LAction.Action);
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpLogTests);

end.
