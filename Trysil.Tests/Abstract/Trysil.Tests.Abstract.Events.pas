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
  Trysil.Exceptions,
  Trysil.Context,
  Trysil.Events.Factory,
  Trysil.Events,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTestRegisteredEvents }

  TTestRegisteredEvents = class(
    TTEntityEvents<TTestRegisteredEventCustomer>)
  strict private
    function OldEntityState(const AOperation: String): String;
  strict protected
    procedure BeforeInsert; override;
    procedure AfterInsert; override;
    procedure BeforeUpdate; override;
    procedure AfterUpdate; override;
    procedure BeforeDelete; override;
    procedure AfterDelete; override;
  end;

{ TTestConflictEvents }

  TTestConflictEvents = class(TTEntityEvents<TTestConflictEventCustomer>);

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

    [Test]
    procedure RegisteredEventsFireAllEventsInOrder;

    [Test]
    procedure RegisteredEventsOldEntityIsNilOnInsert;

    [Test]
    procedure RegisteredEventsAreInherited;

    [Test]
    procedure RegisteringEventsTwiceRaises;

    [Test]
    procedure RegisteringANilEventClassRaises;

    [Test]
    procedure AttributeAndRegistrationTogetherRaise;
  end;

implementation

{ TTestRegisteredEvents }

function TTestRegisteredEvents.OldEntityState(
  const AOperation: String): String;
begin
  result := Format('%s:%s', [
    AOperation, BoolToStr(Assigned(OldEntity), True)]);
end;

procedure TTestRegisteredEvents.BeforeInsert;
begin
  Entity.AppendEvent('BI');
  Entity.AppendOldEntity(OldEntityState('I'));
end;

procedure TTestRegisteredEvents.AfterInsert;
begin
  Entity.AppendEvent('AI');
end;

procedure TTestRegisteredEvents.BeforeUpdate;
begin
  Entity.AppendEvent('BU');
  Entity.AppendOldEntity(OldEntityState('U'));
end;

procedure TTestRegisteredEvents.AfterUpdate;
begin
  Entity.AppendEvent('AU');
end;

procedure TTestRegisteredEvents.BeforeDelete;
begin
  Entity.AppendEvent('BD');
end;

procedure TTestRegisteredEvents.AfterDelete;
begin
  Entity.AppendEvent('AD');
end;

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

procedure TTAbstractEventsTests.RegisteredEventsFireAllEventsInOrder;
var
  LCustomer: TTestRegisteredEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestRegisteredEventCustomer>();
  LCustomer.Name := 'Registered';
  FContext.Insert<TTestRegisteredEventCustomer>(LCustomer);

  LCustomer.Name := 'Changed';
  FContext.Update<TTestRegisteredEventCustomer>(LCustomer);

  FContext.Delete<TTestRegisteredEventCustomer>(LCustomer);

  Assert.AreEqual('BI;AI;BU;AU;BD;AD;', LCustomer.EventLog,
    'Registered events must fire all 6 events in order');
end;

procedure TTAbstractEventsTests.RegisteredEventsOldEntityIsNilOnInsert;
var
  LCustomer: TTestRegisteredEventCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestRegisteredEventCustomer>();
  LCustomer.Name := 'OldEntity';
  FContext.Insert<TTestRegisteredEventCustomer>(LCustomer);

  LCustomer.Name := 'Changed';
  FContext.Update<TTestRegisteredEventCustomer>(LCustomer);

  Assert.AreEqual('I:False;U:True;', LCustomer.OldEntityLog,
    'OldEntity must be nil on insert and assigned on update');
end;

procedure TTAbstractEventsTests.RegisteredEventsAreInherited;
var
  LCustomer: TTestRegisteredDerivedCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestRegisteredDerivedCustomer>();
  LCustomer.Name := 'Derived';
  FContext.Insert<TTestRegisteredDerivedCustomer>(LCustomer);

  LCustomer.Name := 'Changed';
  FContext.Update<TTestRegisteredDerivedCustomer>(LCustomer);

  Assert.AreEqual('BI;AI;BU;AU;', LCustomer.EventLog,
    'A derived entity must fire the events registered for its ancestor');
end;

procedure TTAbstractEventsTests.RegisteringEventsTwiceRaises;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTEventRegistration.RegisterEvents<
      TTestRegisteredEventCustomer, TTestRegisteredEvents>;
  except
    on ETException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Registering the events of an entity twice must raise');
end;

procedure TTAbstractEventsTests.RegisteringANilEventClassRaises;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTEventRegistry.Instance.RegisterEvents(TypeInfo(TTestCustomer), nil);
  except
    on ETException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised, 'Registering a nil event class must raise');
end;

procedure TTAbstractEventsTests.AttributeAndRegistrationTogetherRaise;
var
  LCustomer: TTestConflictEventCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestConflictEventCustomer>();
  LCustomer.Name := 'Conflict';
  LRaised := False;
  try
    FContext.Insert<TTestConflictEventCustomer>(LCustomer);
  except
    on ETException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'An event attribute and a registration together must raise');
end;

initialization
  TTEventRegistration.RegisterEvents<
    TTestRegisteredEventCustomer, TTestRegisteredEvents>;
  TTEventRegistration.RegisterEvents<
    TTestConflictEventCustomer, TTestConflictEvents>;

end.
