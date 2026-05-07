(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.NullablePrimitives;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Generics.Collections,
  Trysil.Filter,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractNullablePrimitivesTests }

  TTAbstractNullablePrimitivesTests = class(TTAbstractBaseTests)
  strict protected
    procedure ClearTables; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;

    [Test]
    procedure InsertAndGetRoundTripsAllNullableValues;

    [Test]
    procedure InsertAndGetPreservesNullDefaults;

    [Test]
    procedure UpdateRewritesAllValues;

    [Test]
    procedure UpdateClearsValuesBackToNull;

    [Test]
    procedure DeleteRemovesRow;

    [Test]
    procedure SelectAllReturnsMultipleRows;
  end;

implementation

{ TTAbstractNullablePrimitivesTests }

procedure TTAbstractNullablePrimitivesTests.ClearTables;
begin
  inherited;
  Connection.Execute('DELETE FROM NullablePrimitives');
end;

procedure TTAbstractNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTAbstractNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

procedure TTAbstractNullablePrimitivesTests.InsertAndGetRoundTripsAllNullableValues;
var
  LEntity: TTestNullablePrimitives;
  LLoaded: TTestNullablePrimitives;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  LEntity.Description := TTNullable<String>.Create('Widget');
  LEntity.Quantity := TTNullable<Integer>.Create(42);
  LEntity.Price := TTNullable<Double>.Create(19.95);
  FContext.Insert<TTestNullablePrimitives>(LEntity);

  LLoaded := FContext.Get<TTestNullablePrimitives>(LEntity.ID);
  Assert.IsFalse(LLoaded.Description.IsNull);
  Assert.AreEqual('Widget', LLoaded.Description.GetValueOrDefault);
  Assert.IsFalse(LLoaded.Quantity.IsNull);
  Assert.AreEqual<Integer>(42, LLoaded.Quantity.GetValueOrDefault);
  Assert.IsFalse(LLoaded.Price.IsNull);
  Assert.AreEqual(19.95, LLoaded.Price.GetValueOrDefault, 0.001);
end;

procedure TTAbstractNullablePrimitivesTests.InsertAndGetPreservesNullDefaults;
var
  LEntity: TTestNullablePrimitives;
  LLoaded: TTestNullablePrimitives;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  FContext.Insert<TTestNullablePrimitives>(LEntity);

  LLoaded := FContext.Get<TTestNullablePrimitives>(LEntity.ID);
  Assert.IsTrue(LLoaded.Description.IsNull,
    'Description must be null when not assigned');
  Assert.IsTrue(LLoaded.Quantity.IsNull,
    'Quantity must be null when not assigned');
  Assert.IsTrue(LLoaded.Price.IsNull,
    'Price must be null when not assigned');
end;

procedure TTAbstractNullablePrimitivesTests.UpdateRewritesAllValues;
var
  LEntity: TTestNullablePrimitives;
  LLoaded: TTestNullablePrimitives;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  LEntity.Description := TTNullable<String>.Create('Initial');
  LEntity.Quantity := TTNullable<Integer>.Create(1);
  LEntity.Price := TTNullable<Double>.Create(0.01);
  FContext.Insert<TTestNullablePrimitives>(LEntity);

  LEntity.Description := TTNullable<String>.Create('Updated');
  LEntity.Quantity := TTNullable<Integer>.Create(99);
  LEntity.Price := TTNullable<Double>.Create(123.45);
  FContext.Update<TTestNullablePrimitives>(LEntity);

  LLoaded := FContext.Get<TTestNullablePrimitives>(LEntity.ID);
  Assert.AreEqual('Updated', LLoaded.Description.GetValueOrDefault);
  Assert.AreEqual<Integer>(99, LLoaded.Quantity.GetValueOrDefault);
  Assert.AreEqual(123.45, LLoaded.Price.GetValueOrDefault, 0.001);
end;

procedure TTAbstractNullablePrimitivesTests.UpdateClearsValuesBackToNull;
var
  LEntity: TTestNullablePrimitives;
  LLoaded: TTestNullablePrimitives;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  LEntity.Description := TTNullable<String>.Create('SetValue');
  LEntity.Quantity := TTNullable<Integer>.Create(7);
  LEntity.Price := TTNullable<Double>.Create(3.14);
  FContext.Insert<TTestNullablePrimitives>(LEntity);

  LLoaded := FContext.Get<TTestNullablePrimitives>(LEntity.ID);
  LLoaded.Description := nil;
  LLoaded.Quantity := nil;
  LLoaded.Price := nil;
  FContext.Update<TTestNullablePrimitives>(LLoaded);

  LLoaded := FContext.Get<TTestNullablePrimitives>(LEntity.ID);
  Assert.IsTrue(LLoaded.Description.IsNull);
  Assert.IsTrue(LLoaded.Quantity.IsNull);
  Assert.IsTrue(LLoaded.Price.IsNull);
end;

procedure TTAbstractNullablePrimitivesTests.DeleteRemovesRow;
var
  LEntity: TTestNullablePrimitives;
  LCount: Integer;
begin
  LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
  LEntity.Description := TTNullable<String>.Create('ToDelete');
  FContext.Insert<TTestNullablePrimitives>(LEntity);

  FContext.Delete<TTestNullablePrimitives>(LEntity);

  LCount := FContext.SelectCount<TTestNullablePrimitives>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount);
end;

procedure TTAbstractNullablePrimitivesTests.SelectAllReturnsMultipleRows;
var
  LEntity: TTestNullablePrimitives;
  LIndex: Integer;
  LList: TTList<TTestNullablePrimitives>;
begin
  for LIndex := 1 to 3 do
  begin
    LEntity := FContext.CreateEntity<TTestNullablePrimitives>();
    LEntity.Description := TTNullable<String>.Create(
      Format('Row%d', [LIndex]));
    LEntity.Quantity := TTNullable<Integer>.Create(LIndex * 10);
    LEntity.Price := TTNullable<Double>.Create(LIndex * 1.5);
    FContext.Insert<TTestNullablePrimitives>(LEntity);
  end;

  LList := TTList<TTestNullablePrimitives>.Create;
  try
    FContext.SelectAll<TTestNullablePrimitives>(LList);
    Assert.AreEqual<Integer>(3, LList.Count);
  finally
    LList.Free;
  end;
end;

end.
