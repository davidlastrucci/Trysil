(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Session;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Filter,
  Trysil.Context,
  Trysil.Session,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractSessionTests }

  TTAbstractSessionTests = class(TTAbstractBaseTests)
  strict protected
    procedure DeleteTables; override;
  public
    [Test]
    procedure SessionEntitiesAreClones;

    [Test]
    procedure SessionApplyChangesInsertsNewEntity;

    [Test]
    procedure SessionApplyChangesUpdatesModifiedEntity;

    [Test]
    procedure SessionApplyChangesDeletesRemovedEntity;

    [Test]
    procedure SessionApplyChangesMixedOperations;

    [Test]
    procedure SessionCannotBeAppliedTwice;

    [Test]
    procedure SessionDeleteInsertedEntityCancelsInsert;

    [Test]
    procedure SessionSaveOnNewEntityActsAsInsert;

    [Test]
    procedure SessionSaveOnClonedEntityActsAsUpdate;

    [Test]
    procedure SessionApplyChangesUpdatesNullableFromNullToValue;

    [Test]
    procedure SessionApplyChangesUpdatesNullableFromValueToNull;

    [Test]
    procedure SessionFromLazyListInvalidatesAfterApply;

    [Test]
    procedure ASessionKeepsApartTwoEntitiesThatCompareEqual;

    [Test]
    procedure AnEntityInsertedByTheSessionIsNoLongerNew;
  end;

implementation

{ TTAbstractSessionTests }

procedure TTAbstractSessionTests.DeleteTables;
begin
  inherited;
  Connection.Execute('DELETE FROM NullablePrimitives');
end;

procedure TTAbstractSessionTests.ASessionKeepsApartTwoEntitiesThatCompareEqual;
var
  LFirst: TTestValueCustomer;
  LSecond: TTestValueCustomer;
  LList: TTList<TTestValueCustomer>;
  LSession: TTSession<TTestValueCustomer>;
begin
  LFirst := FContext.CreateEntity<TTestValueCustomer>();
  LFirst.Name := 'Twin';
  FContext.Insert<TTestValueCustomer>(LFirst);

  LSecond := FContext.CreateEntity<TTestValueCustomer>();
  LSecond.Name := 'Twin';
  FContext.Insert<TTestValueCustomer>(LSecond);

  LList := TTList<TTestValueCustomer>.Create;
  try
    FContext.SelectAll<TTestValueCustomer>(LList);
    Assert.AreEqual<Integer>(2, LList.Count, 'Precondition: two rows');

    LSession := FContext.CreateSession<TTestValueCustomer>(LList);
    try
      Assert.AreEqual<Integer>(
        2,
        LSession.Entities.Count,
        'The session keys three dictionaries on the entity itself, and the ' +
        'default comparer for a class calls the virtual Equals of the ' +
        'object: two rows an application compares by value, which is ' +
        'legitimate, collapsed onto one key');
      Assert.AreEqual<TTPrimaryKey>(
        LSession.Entities[0].ID,
        LSession.GetOriginalEntity(LSession.Entities[0]).ID,
        'And each clone still names the row it was made from');
      Assert.AreEqual<TTPrimaryKey>(
        LSession.Entities[1].ID,
        LSession.GetOriginalEntity(LSession.Entities[1]).ID,
        'And each clone still names the row it was made from');
      Assert.IsFalse(
        LSession.Entities[0].ID = LSession.Entities[1].ID,
        'which is only worth checking because the two are two rows');
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionEntitiesAreClones;
var
  LCustomer: TTestCustomer;
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      Assert.AreEqual<Integer>(1, LSession.Entities.Count);
      Assert.AreNotSame(LList[0], LSession.Entities[0],
        'Session must work on cloned entities, not originals');
      Assert.AreEqual(LList[0].Name, LSession.Entities[0].Name);
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionApplyChangesInsertsNewEntity;
var
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LNewCustomer: TTestCustomer;
  LCount: Integer;
begin
  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LNewCustomer := FContext.CreateEntity<TTestCustomer>();
      LNewCustomer.Name := 'SessionInserted';
      LNewCustomer.Email := 'session@example.com';
      LSession.Insert(LNewCustomer);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(1, LCount);
end;

procedure TTAbstractSessionTests.SessionApplyChangesUpdatesModifiedEntity;
var
  LCustomer: TTestCustomer;
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LFreshContext: TTContext;
  LReloaded: TTestCustomer;
  LInsertedID: TTPrimaryKey;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'BeforeUpdate';
  FContext.Insert<TTestCustomer>(LCustomer);
  LInsertedID := LCustomer.ID;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LSession.Entities[0].Name := 'AfterUpdate';
      LSession.Update(LSession.Entities[0]);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestCustomer>(LInsertedID);
    Assert.AreEqual('AfterUpdate', LReloaded.Name);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionApplyChangesDeletesRemovedEntity;
var
  LCustomer: TTestCustomer;
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LCount: Integer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'ToBeDeleted';
  FContext.Insert<TTestCustomer>(LCustomer);

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LSession.Delete(LSession.Entities[0]);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount);
end;

procedure TTAbstractSessionTests.SessionApplyChangesMixedOperations;
var
  LCustomerA: TTestCustomer;
  LCustomerB: TTestCustomer;
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LNewCustomer: TTestCustomer;
  LFreshContext: TTContext;
  LResult: TTList<TTestCustomer>;
begin
  LCustomerA := FContext.CreateEntity<TTestCustomer>();
  LCustomerA.Name := 'KeepAndUpdate';
  FContext.Insert<TTestCustomer>(LCustomerA);

  LCustomerB := FContext.CreateEntity<TTestCustomer>();
  LCustomerB.Name := 'DeleteMe';
  FContext.Insert<TTestCustomer>(LCustomerB);

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LSession.Entities[0].Name := 'Updated';
      LSession.Update(LSession.Entities[0]);

      LSession.Delete(LSession.Entities[1]);

      LNewCustomer := FContext.CreateEntity<TTestCustomer>();
      LNewCustomer.Name := 'BrandNew';
      LSession.Insert(LNewCustomer);

      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    Lresult := TTList<TTestCustomer>.Create;
    try
      LFreshContext.SelectAll<TTestCustomer>(LResult);
      Assert.AreEqual<Integer>(2, LResult.Count);
    finally
      LResult.Free;
    end;
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionCannotBeAppliedTwice;
var
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LRaised: Boolean;
begin
  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LSession.ApplyChanges;

      LRaised := False;
      try
        LSession.ApplyChanges;
      except
        on E: ETException do
          LRaised := True;
      end;
      Assert.IsTrue(LRaised,
        'ApplyChanges called twice must raise ETException');
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionDeleteInsertedEntityCancelsInsert;
var
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LNewCustomer: TTestCustomer;
  LCount: Integer;
begin
  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LNewCustomer := FContext.CreateEntity<TTestCustomer>();
      LNewCustomer.Name := 'InsertThenDelete';
      LSession.Insert(LNewCustomer);
      LSession.Delete(LNewCustomer);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'Insert followed by Delete in same session must cancel out');
end;

procedure TTAbstractSessionTests.SessionSaveOnNewEntityActsAsInsert;
var
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LNewCustomer: TTestCustomer;
  LCount: Integer;
begin
  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LNewCustomer := FContext.CreateEntity<TTestCustomer>();
      LNewCustomer.Name := 'SavedAsInsert';
      LNewCustomer.Email := 'save-insert@example.com';
      LSession.Save(LNewCustomer);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(1, LCount,
    'Save on a new entity must behave as Insert');
end;

procedure TTAbstractSessionTests.SessionSaveOnClonedEntityActsAsUpdate;
var
  LCustomer: TTestCustomer;
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LFreshContext: TTContext;
  LReloaded: TTestCustomer;
  LInsertedID: TTPrimaryKey;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'BeforeSave';
  FContext.Insert<TTestCustomer>(LCustomer);
  LInsertedID := LCustomer.ID;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LSession.Entities[0].Name := 'AfterSave';
      LSession.Save(LSession.Entities[0]);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestCustomer>(LInsertedID);
    Assert.AreEqual('AfterSave', LReloaded.Name,
      'Save on a cloned (existing) entity must behave as Update');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionApplyChangesUpdatesNullableFromNullToValue;
var
  LEntity: TTestNullablePrimitives;
  LList: TTList<TTestNullablePrimitives>;
  LSession: TTSession<TTestNullablePrimitives>;
  LFreshContext: TTContext;
  LReloaded: TTestNullablePrimitives;
  LID: TTPrimaryKey;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  FContext.Insert<TTestNullablePrimitives>(LEntity);
  LID := LEntity.ID;

  LList := TTList<TTestNullablePrimitives>.Create;
  try
    FContext.SelectAll<TTestNullablePrimitives>(LList);
    LSession := FContext.CreateSession<TTestNullablePrimitives>(LList);
    try
      LSession.Entities[0].Description := TTNullable<String>.Create('Filled');
      LSession.Entities[0].Quantity := TTNullable<Integer>.Create(100);
      LSession.Entities[0].Price := TTNullable<Double>.Create(9.99);
      LSession.Update(LSession.Entities[0]);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestNullablePrimitives>(LID);
    Assert.AreEqual('Filled', LReloaded.Description.GetValueOrDefault);
    Assert.AreEqual<Integer>(100, LReloaded.Quantity.GetValueOrDefault);
    Assert.AreEqual(9.99, LReloaded.Price.GetValueOrDefault, 0.001);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionApplyChangesUpdatesNullableFromValueToNull;
var
  LEntity: TTestNullablePrimitives;
  LList: TTList<TTestNullablePrimitives>;
  LSession: TTSession<TTestNullablePrimitives>;
  LFreshContext: TTContext;
  LReloaded: TTestNullablePrimitives;
  LID: TTPrimaryKey;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  LEntity.Description := TTNullable<String>.Create('Initial');
  LEntity.Quantity := TTNullable<Integer>.Create(7);
  LEntity.Price := TTNullable<Double>.Create(3.14);
  FContext.Insert<TTestNullablePrimitives>(LEntity);
  LID := LEntity.ID;

  LList := TTList<TTestNullablePrimitives>.Create;
  try
    FContext.SelectAll<TTestNullablePrimitives>(LList);
    LSession := FContext.CreateSession<TTestNullablePrimitives>(LList);
    try
      LSession.Entities[0].Description := nil;
      LSession.Entities[0].Quantity := nil;
      LSession.Entities[0].Price := nil;
      LSession.Update(LSession.Entities[0]);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestNullablePrimitives>(LID);
    Assert.IsTrue(LReloaded.Description.IsNull);
    Assert.IsTrue(LReloaded.Quantity.IsNull);
    Assert.IsTrue(LReloaded.Price.IsNull);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractSessionTests.SessionFromLazyListInvalidatesAfterApply;
var
  LCustomer: TTestLazyCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoadedCustomer: TTestLazyCustomer;
  LSession: TTSession<TTestLazyOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestLazyCustomer>();
  LCustomer.Name := 'LazyParent';
  FContext.Insert<TTestLazyCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoadedCustomer := LFreshContext.Get<TTestLazyCustomer>(LCustomer.ID);

    LSession := LFreshContext.CreateSession<TTestLazyOrder>(
      LLoadedCustomer.Orders);
    try
      Assert.AreEqual<Integer>(1, LSession.Entities.Count,
        'Session must clone the entities held by the lazy list');
      LSession.Entities[0].Amount := 99.0;
      LSession.Update(LSession.Entities[0]);
      LSession.ApplyChanges;
    finally
      LSession.Free;
    end;

    Assert.AreEqual<Integer>(1, LLoadedCustomer.Orders.Count);
    Assert.AreEqual(99.0, LLoadedCustomer.Orders[0].Amount, 0.001,
      'Lazy list must reflect the applied change after invalidation');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractSessionTests.AnEntityInsertedByTheSessionIsNoLongerNew;
var
  LList: TTList<TTestCustomer>;
  LSession: TTSession<TTestCustomer>;
  LNewCustomer: TTestCustomer;
  LCount: Int64;
begin
  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    LSession := FContext.CreateSession<TTestCustomer>(LList);
    try
      LNewCustomer := FContext.CreateEntity<TTestCustomer>();
      LNewCustomer.Name := 'InsertedByTheSession';
      LNewCustomer.Email := 'session-insert@example.com';
      LSession.Insert(LNewCustomer);
      LSession.ApplyChanges;

      LNewCustomer.Name := 'ChangedAfterApply';
      FContext.Save<TTestCustomer>(LNewCustomer);
    finally
      LSession.Free;
    end;
  finally
    LList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Int64>(
    1,
    LCount,
    'ApplyChanges wrote the row, so the entity is no longer new: a Save ' +
    'while the session is still alive must update it, not insert it twice');
end;

end.
