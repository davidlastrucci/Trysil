(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Events;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractEventsTests }

  TTAbstractEventsTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure InsertFiresBeforeAndAfterInsertEvents;

    [Test]
    procedure UpdateFiresBeforeAndAfterUpdateEvents;

    [Test]
    procedure DeleteFiresBeforeAndAfterDeleteEvents;

    [Test]
    procedure FullLifecycleFiresAllEventsInOrder;
  end;

implementation

{ TTAbstractEventsTests }

procedure TTAbstractEventsTests.InsertFiresBeforeAndAfterInsertEvents;
var
  LCustomer: TTestEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestEventCustomer>();
  LCustomer.Name := 'EventTest';
  FContext.Insert<TTestEventCustomer>(LCustomer);

  Assert.AreEqual('BI;AI;', LCustomer.EventLog,
    'Insert must fire BeforeInsert then AfterInsert');
end;

procedure TTAbstractEventsTests.UpdateFiresBeforeAndAfterUpdateEvents;
var
  LCustomer: TTestEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestEventCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestEventCustomer>(LCustomer);

  LCustomer.Name := 'Updated';
  FContext.Update<TTestEventCustomer>(LCustomer);

  Assert.IsTrue(LCustomer.EventLog.Contains('BU;'),
    'Update must fire BeforeUpdate');
  Assert.IsTrue(LCustomer.EventLog.Contains('AU;'),
    'Update must fire AfterUpdate');
end;

procedure TTAbstractEventsTests.DeleteFiresBeforeAndAfterDeleteEvents;
var
  LCustomer: TTestEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestEventCustomer>();
  LCustomer.Name := 'ToDelete';
  FContext.Insert<TTestEventCustomer>(LCustomer);

  FContext.Delete<TTestEventCustomer>(LCustomer);

  Assert.IsTrue(LCustomer.EventLog.Contains('BD;'),
    'Delete must fire BeforeDelete');
  Assert.IsTrue(LCustomer.EventLog.Contains('AD;'),
    'Delete must fire AfterDelete');
end;

procedure TTAbstractEventsTests.FullLifecycleFiresAllEventsInOrder;
var
  LCustomer: TTestEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestEventCustomer>();
  LCustomer.Name := 'Lifecycle';
  FContext.Insert<TTestEventCustomer>(LCustomer);

  LCustomer.Name := 'Changed';
  FContext.Update<TTestEventCustomer>(LCustomer);

  FContext.Delete<TTestEventCustomer>(LCustomer);

  Assert.AreEqual('BI;AI;BU;AU;BD;AD;', LCustomer.EventLog,
    'Full lifecycle must fire all 6 events in order');
end;

end.
