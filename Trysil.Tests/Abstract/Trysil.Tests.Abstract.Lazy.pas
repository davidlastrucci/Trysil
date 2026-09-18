(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Lazy;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Context,
  Trysil.Events,
  Trysil.Session,
  Trysil.Lazy,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTestLazyOldEntityEvent }

  TTestLazyOldEntityEvent = class(TTEvent<TTestLazyOrder>)
  public
    function ReadOldEntity: TTestLazyOrder;
  end;

{ TTAbstractLazyTests }

  TTAbstractLazyTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure LazyEntityLoadsOnFirstAccess;

    [Test]
    procedure LazyEntityChangeIdReloads;

    [Test]
    procedure LazyListLoadsRelatedEntities;

    [Test]
    procedure LazyListIsEmptyWhenNoRelated;

    [Test]
    procedure LazyEntityResolvesSoftDeletedMaster;

    [Test]
    procedure DisposingAnEntityReleasesItsLazyMembers;

    [Test]
    procedure DisposingACloneReleasesItsLazyMembers;

    [Test]
    procedure ALazyReferenceReleasesWhatItLoaded;

    [Test]
    procedure ASessionReleasesTheLazyMembersOfItsClones;

    [Test]
    procedure ADetailThatDoesNotMapTheKeyStillLoads;

    [Test]
    procedure ADetailEntityThatMapsAJoinIsRefused;

    [Test]
    procedure AnEventReleasesItsOldEntityTheSameWay;

    [Test]
    procedure ANilAssignedBeforeLoadingClearsTheRelation;
  end;

implementation

{ TTestLazyOldEntityEvent }

function TTestLazyOldEntityEvent.ReadOldEntity: TTestLazyOrder;
begin
  result := OldEntity;
end;

{ TTAbstractLazyTests }

procedure TTAbstractLazyTests.LazyEntityLoadsOnFirstAccess;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoadedOrder: TTestLazyOrder;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'LazyTarget';
  LCustomer.Email := 'lazy@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 99.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoadedOrder := LFreshContext.Get<TTestLazyOrder>(LOrder.ID);
    Assert.AreEqual('LazyTarget', LLoadedOrder.Customer.Entity.Name,
      'Lazy entity must load related customer on first access');
    Assert.AreEqual('lazy@example.com', LLoadedOrder.Customer.Entity.Email);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.LazyEntityChangeIdReloads;
var
  LCustomerA: TTestCustomer;
  LCustomerB: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoadedOrder: TTestLazyOrder;
begin
  LCustomerA := FContext.CreateEntity<TTestCustomer>();
  LCustomerA.Name := 'First';
  FContext.Insert<TTestCustomer>(LCustomerA);

  LCustomerB := FContext.CreateEntity<TTestCustomer>();
  LCustomerB.Name := 'Second';
  FContext.Insert<TTestCustomer>(LCustomerB);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoadedOrder := LFreshContext.Get<TTestLazyOrder>(LOrder.ID);
    Assert.AreEqual('First', LLoadedOrder.Customer.Entity.Name);

    LLoadedOrder.Customer.ID := LCustomerB.ID;
    Assert.AreEqual('Second', LLoadedOrder.Customer.Entity.Name,
      'Changing lazy ID must reload with new entity');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.LazyListLoadsRelatedEntities;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoadedCustomer: TTestLazyCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'ParentCust';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 20.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoadedCustomer := LFreshContext.Get<TTestLazyCustomer>(LCustomer.ID);
    Assert.AreEqual<Integer>(2, LLoadedCustomer.Orders.Count,
      'Lazy list must load all related orders');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.LazyListIsEmptyWhenNoRelated;
var
  LCustomer: TTestCustomer;
  LFreshContext: TTContext;
  LLoadedCustomer: TTestLazyCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'NoOrders';
  FContext.Insert<TTestCustomer>(LCustomer);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoadedCustomer := LFreshContext.Get<TTestLazyCustomer>(LCustomer.ID);
    Assert.AreEqual<Integer>(0, LLoadedCustomer.Orders.Count,
      'Lazy list must return empty list when no related entities exist');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.LazyEntityResolvesSoftDeletedMaster;
var
  LCustomer: TTestSoftCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoadedOrder: TTestSoftLazyOrder;
  LCustomerID: TTPrimaryKey;
begin
  LCustomer := FContext.CreateEntity<TTestSoftCustomer>();
  LCustomer.Name := 'Ghost';
  LCustomer.Email := 'ghost@example.com';
  FContext.Insert<TTestSoftCustomer>(LCustomer);
  LCustomerID := LCustomer.ID;

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 42.0;
  FContext.Insert<TTestOrder>(LOrder);

  FContext.Delete<TTestSoftCustomer>(LCustomer);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoadedOrder := LFreshContext.Get<TTestSoftLazyOrder>(LOrder.ID);
    Assert.IsNotNull(LLoadedOrder.Customer.Entity,
      'Lazy reference must resolve a soft-deleted master');
    Assert.AreEqual('Ghost', LLoadedOrder.Customer.Entity.Name);

    Assert.IsNull(LFreshContext.Get<TTestSoftCustomer>(LCustomerID),
      'A direct Get must still exclude the soft-deleted master');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.DisposingAnEntityReleasesItsLazyMembers;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LList: TTList<TTestLazyOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'LazyOwner';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection, False);
  try
    LList := LFreshContext.CreateEntityList<TTestLazyOrder>();
    try
      LFreshContext.SelectAll<TTestLazyOrder>(LList);
      Assert.AreEqual<Integer>(1, LFreshContext.LazyOwnerCount,
        'A materialized entity must own its lazy members');
    finally
      LList.Free;
    end;

    Assert.AreEqual<Integer>(0, LFreshContext.LazyOwnerCount,
      'Disposing the entity must release its lazy members');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.DisposingACloneReleasesItsLazyMembers;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoaded: TTestLazyOrder;
  LClone: TTestLazyOrder;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'CloneOwner';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 20.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection, False);
  try
    LLoaded := LFreshContext.Get<TTestLazyOrder>(LOrder.ID);
    try
      LClone := LFreshContext.CloneEntity<TTestLazyOrder>(LLoaded);
      Assert.AreEqual<Integer>(2, LFreshContext.LazyOwnerCount,
        'A clone must own its own lazy members');
      LFreshContext.FreeEntity<TTestLazyOrder>(LClone);

      Assert.AreEqual<Integer>(1, LFreshContext.LazyOwnerCount,
        'Disposing the clone must release only its own lazy members');
    finally
      LFreshContext.FreeEntity<TTestLazyOrder>(LLoaded);
    end;

    Assert.AreEqual<Integer>(0, LFreshContext.LazyOwnerCount,
      'Disposing the entity must release its lazy members');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.ASessionReleasesTheLazyMembersOfItsClones;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LList: TTList<TTestLazyOrder>;
  LSession: TTSession<TTestLazyOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'SessionOwner';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 40.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection, False);
  try
    LList := LFreshContext.CreateEntityList<TTestLazyOrder>();
    try
      LFreshContext.SelectAll<TTestLazyOrder>(LList);
      LSession := LFreshContext.CreateSession<TTestLazyOrder>(LList);
      try
        Assert.AreEqual<Integer>(2, LFreshContext.LazyOwnerCount,
          'Precondition: a session clones every entity of the list, and a ' +
          'clone owns its own lazy members');
      finally
        LSession.Free;
      end;

      Assert.AreEqual<Integer>(1, LFreshContext.LazyOwnerCount,
        'The session released its clones with a bare Free, so the lazy ' +
        'members of every clone stayed behind under an address nobody ' +
        'holds: one per lazy member per row, on each open');
    finally
      LList.Free;
    end;
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.ALazyReferenceReleasesWhatItLoaded;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LChained: TTestChainedOrder;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'ChainOwner';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 30.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection, False);
  try
    LChained := LFreshContext.Get<TTestChainedOrder>(LOrder.ID);
    Assert.IsNotNull(
      LChained.Customer.Entity,
      'Precondition: the reference must resolve');
    Assert.AreEqual<Integer>(
      2,
      LFreshContext.LazyOwnerCount,
      'Precondition: the order owns its reference and the customer it ' +
      'loaded owns its own detail list');

    LFreshContext.FreeEntity<TTestChainedOrder>(LChained);

    Assert.AreEqual<Integer>(
      0,
      LFreshContext.LazyOwnerCount,
      'A lazy reference owns the entity it loaded, so freeing the order ' +
      'must release the customer through the disposal path and not with a ' +
      'bare Free: a bare Free leaves the customer''s own lazy members ' +
      'behind, keyed on an address nobody holds');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.ADetailThatDoesNotMapTheKeyStillLoads;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoaded: TTestBareDetailCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'BareDetail';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 30.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoaded := LFreshContext.Get<TTestBareDetailCustomer>(LCustomer.ID);
    Assert.AreEqual<Integer>(
      1,
      LLoaded.Orders.Count,
      'The detail entity does not map the column [TDetailColumn] names, ' +
      'which is what the cookbook shows, and the collection has to load ' +
      'anyway. What this pins is that shape, not the quoting of the ' +
      'fallback: CustomerID is an ordinary identifier and the test tables ' +
      'are created unquoted, so the bare name and the quoted name reach ' +
      'the same object on all seven engines. Telling them apart needs a ' +
      'detail column whose name has to be quoted, and the model has none');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.ADetailEntityThatMapsAJoinIsRefused;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoaded: TTestJoinDetailCustomer;
  LCount: Integer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'JoinDetail';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 40.0;
  FContext.Insert<TTestOrder>(LOrder);

  LCount := -1;
  LRaised := False;
  LFreshContext := TTContext.Create(Connection);
  try
    LLoaded := LFreshContext.Get<TTestJoinDetailCustomer>(LCustomer.ID);
    try
      LCount := LLoaded.Orders.Count;
    except
      on E: ETException do
        LRaised := True;
    end;
  finally
    LFreshContext.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'The metadata of a join entity are keyed on the output alias of each ' +
    'column, so the name the attribute carries never matches one and the ' +
    'reference would reach the engine unqualified: it has never worked, ' +
    'and now it says so');
  Assert.AreEqual<Integer>(
    -1, LCount, 'And the access must not come back with a list');
end;

procedure TTAbstractLazyTests.AnEventReleasesItsOldEntityTheSameWay;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLoaded: TTestLazyOrder;
  LEvent: TTestLazyOldEntityEvent;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'EventOwner';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 30.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection, False);
  try
    LLoaded := LFreshContext.Get<TTestLazyOrder>(LOrder.ID);
    try
      LEvent := TTestLazyOldEntityEvent.Create(LFreshContext, LLoaded);
      try
        LEvent.ReadOldEntity;
        Assert.AreEqual<Integer>(
          2,
          LFreshContext.LazyOwnerCount,
          'Precondition: the old entity is a clone, and a clone owns its ' +
          'own lazy members');
      finally
        LEvent.Free;
      end;

      Assert.AreEqual<Integer>(
        1,
        LFreshContext.LazyOwnerCount,
        'An event releases the clone it loaded the same way every other ' +
        'holder of a clone does: a bare Free left its lazy members alive ' +
        'and keyed on an address nobody holds, and every Update on an ' +
        'entity with an event and a lazy member left one behind');
    finally
      LFreshContext.FreeEntity<TTestLazyOrder>(LLoaded);
    end;
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractLazyTests.ANilAssignedBeforeLoadingClearsTheRelation;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFreshContext: TTContext;
  LLazyOrder: TTestLazyOrder;
  LReloaded: TTestOrder;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Detached';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 5.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFreshContext := TTContext.Create(Connection, False);
  try
    LLazyOrder := LFreshContext.Get<TTestLazyOrder>(LOrder.ID);
    try
      LLazyOrder.Customer.Entity := nil;
      LFreshContext.Update<TTestLazyOrder>(LLazyOrder);
    finally
      LFreshContext.FreeEntity<TTestLazyOrder>(LLazyOrder);
    end;

    LReloaded := LFreshContext.Get<TTestOrder>(LOrder.ID);
    try
      Assert.AreEqual<Integer>(
        0,
        LReloaded.CustomerID,
        'Assigning nil to a lazy member that has not loaded has to clear ' +
        'the relation: the update wrote the old foreign key back');
    finally
      LFreshContext.FreeEntity<TTestOrder>(LReloaded);
    end;
  finally
    LFreshContext.Free;
  end;
end;

end.
