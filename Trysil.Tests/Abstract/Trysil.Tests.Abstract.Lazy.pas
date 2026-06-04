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
  Trysil.Generics.Collections,
  Trysil.Context,
  Trysil.Lazy,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

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
  end;

implementation

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

end.
