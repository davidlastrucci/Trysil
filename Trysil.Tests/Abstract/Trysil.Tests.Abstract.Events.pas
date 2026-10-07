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

    [Test]
    procedure OverrideWithoutAttributeFiresOnce;

    [Test]
    procedure OverrideWithAttributeFiresOnce;

    [Test]
    procedure DistinctMethodsForTheSameEventBothFire;
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

procedure TTAbstractEventsTests.OverrideWithoutAttributeFiresOnce;
var
  LCustomer: TTestOverrideEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestOverrideEventCustomer>();
  LCustomer.Name := 'OverrideTest';
  FContext.Insert<TTestOverrideEventCustomer>(LCustomer);

  Assert.AreEqual('BI-base;BI-override;', LCustomer.EventLog,
    'An overridden event method must fire once');
end;

procedure TTAbstractEventsTests.OverrideWithAttributeFiresOnce;
var
  LCustomer: TTestOverrideAttributeEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestOverrideAttributeEventCustomer>();
  LCustomer.Name := 'OverrideAttributeTest';
  FContext.Insert<TTestOverrideAttributeEventCustomer>(LCustomer);

  Assert.AreEqual('BI-base;BI-override;', LCustomer.EventLog,
    'An overridden event method with the attribute must fire once');
end;

procedure TTAbstractEventsTests.DistinctMethodsForTheSameEventBothFire;
var
  LCustomer: TTestDistinctEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestDistinctEventCustomer>();
  LCustomer.Name := 'DistinctTest';
  FContext.Insert<TTestDistinctEventCustomer>(LCustomer);

  Assert.IsTrue(LCustomer.EventLog.Contains('BI-base;'),
    'The event method of the base class must fire');
  Assert.IsTrue(LCustomer.EventLog.Contains('BI-derived;'),
    'The event method of the derived class must fire');
  Assert.AreEqual<Integer>(
    Length('BI-base;BI-derived;'), Length(LCustomer.EventLog),
    'Each event method must fire once');
end;

end.
