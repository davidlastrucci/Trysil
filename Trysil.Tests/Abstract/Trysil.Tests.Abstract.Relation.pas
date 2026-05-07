(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Relation;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractRelationTests }

  TTAbstractRelationTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure DeleteBlockedByNonCascadeRelation;

    [Test]
    procedure DeleteAllowedWhenNoChildrenExist;

    [Test]
    procedure DeleteAllowedWithCascadeRelation;

    [Test]
    procedure SoftDeleteBypassesRelationCheck;
  end;

implementation

{ TTAbstractRelationTests }

procedure TTAbstractRelationTests.DeleteBlockedByNonCascadeRelation;
var
  LCustomer: TTestCustomerWithRelation;
  LOrder: TTestOrder;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomerWithRelation>();
  LCustomer.Name := 'Acme Corp';
  FContext.Insert<TTestCustomerWithRelation>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LRaised := False;
  try
    FContext.Delete<TTestCustomerWithRelation>(LCustomer);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised,
    'Delete must be blocked when non-cascade related records exist');
end;

procedure TTAbstractRelationTests.DeleteAllowedWhenNoChildrenExist;
var
  LCustomer: TTestCustomerWithRelation;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomerWithRelation>();
  LCustomer.Name := 'Acme Corp';
  FContext.Insert<TTestCustomerWithRelation>(LCustomer);

  LRaised := False;
  try
    FContext.Delete<TTestCustomerWithRelation>(LCustomer);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised,
    'Delete must succeed when no related records exist');
end;

procedure TTAbstractRelationTests.DeleteAllowedWithCascadeRelation;
var
  LCustomer: TTestCustomerWithCascadeRelation;
  LOrder: TTestOrder;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomerWithCascadeRelation>();
  LCustomer.Name := 'Acme Corp';
  FContext.Insert<TTestCustomerWithCascadeRelation>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LRaised := False;
  try
    FContext.Delete<TTestCustomerWithCascadeRelation>(LCustomer);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised,
    'Delete must succeed when relation is cascade');
end;

procedure TTAbstractRelationTests.SoftDeleteBypassesRelationCheck;
var
  LCustomer: TTestSoftDeleteCustomerWithRelation;
  LOrder: TTestOrder;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestSoftDeleteCustomerWithRelation>();
  LCustomer.Name := 'Acme Corp';
  FContext.Insert<TTestSoftDeleteCustomerWithRelation>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LRaised := False;
  try
    FContext.Delete<TTestSoftDeleteCustomerWithRelation>(LCustomer);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised,
    'Soft delete must bypass relation check');
end;

end.
