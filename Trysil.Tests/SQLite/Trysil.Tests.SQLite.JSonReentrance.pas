(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.JSonReentrance;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.JSon,
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.JSon.Types,
  Trysil.JSon.Context,
  Trysil.JSon.Events,
  Trysil.JSon.Exceptions,

  Trysil.Tests.Model,
  Trysil.Tests.SQLite.Connection;

type

{ TTestReentrantEvent }

  TTestReentrantEvent = class(TTJSonEvent<TTestReentrantCustomer>)
  public
    constructor Create(const AEntity: TTestReentrantCustomer);

    procedure DoAfterSerialized(const AJSon: TJSonObject); override;
  end;

{ TTSQLiteJSonReentranceTests }

  [TestFixture]
  TTSQLiteJSonReentranceTests = class
  strict private
    FConnection: TTConnection;
    FContext: TTJSonContext;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AnEventThatSerializesAgainIsStopped;

  end;

implementation

var
  GContext: TTJSonContext;
  GEntity: TTestReentrantCustomer;

{ TTestReentrantEvent }

constructor TTestReentrantEvent.Create(
  const AEntity: TTestReentrantCustomer);
begin
  inherited Create(AEntity);
end;

procedure TTestReentrantEvent.DoAfterSerialized(const AJSon: TJSonObject);
begin
  if Assigned(GContext) and Assigned(GEntity) then
    GContext.EntityToJSon<TTestReentrantCustomer>(
      GEntity, TTJSonSerializerConfig.Create(-1, False));
end;

{ TTSQLiteJSonReentranceTests }

procedure TTSQLiteJSonReentranceTests.Setup;
begin
  FConnection := TTSQLiteTestConnection.Connection;
  FConnection.Execute('DELETE FROM Customers');
  FContext := TTJSonContext.Create(FConnection, False);
end;

procedure TTSQLiteJSonReentranceTests.TearDown;
begin
  GContext := nil;
  GEntity := nil;
  FContext.Free;
  FConnection.Execute('DELETE FROM Customers');
end;

procedure TTSQLiteJSonReentranceTests.AnEventThatSerializesAgainIsStopped;
var
  LCustomer: TTestReentrantCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestReentrantCustomer>();
  try
    LCustomer.Name := 'Reentrant';
    FContext.Insert<TTestReentrantCustomer>(LCustomer);

    GContext := FContext;
    GEntity := LCustomer;

    LRaised := False;
    try
      FContext.EntityToJSon<TTestReentrantCustomer>(
        LCustomer, TTJSonSerializerConfig.Create(-1, False));
    except
      on E: ETJSonException do
        LRaised := True;
    end;
  finally
    GContext := nil;
    GEntity := nil;
    LCustomer.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'Each call to EntityToJSon starts a depth and a visited set of its ' +
    'own, so neither MaxLevels nor the cycle guard reaches across one: ' +
    'two entities whose events serialize each other used to recur until ' +
    'the stack gave out');
end;

initialization
  TTJSonEventFactory.Instance.RegisterEvent<
    TTestReentrantCustomer, TTestReentrantEvent>();

end.
