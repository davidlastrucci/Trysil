(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.NullablePrimitivesJSon;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Generics.Collections,
  Trysil.JSon.Context,
  Trysil.JSon.Types,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractNullablePrimitivesJSonTests }

  TTAbstractNullablePrimitivesJSonTests = class(TTAbstractBaseTests)
  strict protected
    FJSonContext: TTJSonContext;
    FCreatedEntities: TObjectList<TObject>;

    procedure ClearTables; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;

    [Test]
    procedure EntityToJSonEmitsAllNullableValues;

    [Test]
    procedure EntityToJSonEmitsNullForUnsetFields;

    [Test]
    procedure EntityFromJSonRoundTripsAllNullableValues;

    [Test]
    procedure EntityFromJSonRoundTripsNullFields;

    [Test]
    procedure ListToJSonSerializesAllRows;

    [Test]
    procedure MetadataToJSonExposesAllColumnNames;
  end;

implementation

{ TTAbstractNullablePrimitivesJSonTests }

procedure TTAbstractNullablePrimitivesJSonTests.ClearTables;
begin
  inherited;
  Connection.Execute('DELETE FROM NullablePrimitives');
end;

procedure TTAbstractNullablePrimitivesJSonTests.Setup;
begin
  ClearTables;
  FJSonContext := TTJSonContext.Create(Connection);
  FContext := FJSonContext;
  FCreatedEntities := TObjectList<TObject>.Create(True);
end;

procedure TTAbstractNullablePrimitivesJSonTests.TearDown;
begin
  FCreatedEntities.Free;
  inherited TearDown;
  FJSonContext := nil;
end;

procedure TTAbstractNullablePrimitivesJSonTests.EntityToJSonEmitsAllNullableValues;
var
  LEntity: TTestNullablePrimitives;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LValue: TJSonValue;
  LObj: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestNullablePrimitives>();
  FCreatedEntities.Add(LEntity);
  LEntity.Description := TTNullable<String>.Create('Widget');
  LEntity.Quantity := TTNullable<Integer>.Create(42);
  LEntity.Price := TTNullable<Double>.Create(19.95);
  FJSonContext.Insert<TTestNullablePrimitives>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestNullablePrimitives>(LEntity, LConfig);

  LValue := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LValue is TJSonObject);
    LObj := TJSonObject(LValue);
    Assert.AreEqual('Widget', LObj.GetValue<String>('description'));
    Assert.AreEqual<Integer>(42, LObj.GetValue<Integer>('quantity'));
    Assert.AreEqual(19.95, LObj.GetValue<Double>('price'), 0.001);
  finally
    LValue.Free;
  end;
end;

procedure TTAbstractNullablePrimitivesJSonTests.EntityToJSonEmitsNullForUnsetFields;
var
  LEntity: TTestNullablePrimitives;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LValue: TJSonValue;
  LObj: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestNullablePrimitives>();
  FCreatedEntities.Add(LEntity);
  FJSonContext.Insert<TTestNullablePrimitives>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestNullablePrimitives>(LEntity, LConfig);

  LValue := TJSonObject.ParseJSonValue(LJson);
  try
    LObj := TJSonObject(LValue);
    Assert.IsTrue(LObj.GetValue('description') is TJSonNull);
    Assert.IsTrue(LObj.GetValue('quantity') is TJSonNull);
    Assert.IsTrue(LObj.GetValue('price') is TJSonNull);
  finally
    LValue.Free;
  end;
end;

procedure TTAbstractNullablePrimitivesJSonTests.EntityFromJSonRoundTripsAllNullableValues;
var
  LEntity: TTestNullablePrimitives;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LRestored: TTestNullablePrimitives;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestNullablePrimitives>();
  FCreatedEntities.Add(LEntity);
  LEntity.Description := TTNullable<String>.Create('RoundTrip');
  LEntity.Quantity := TTNullable<Integer>.Create(-7);
  LEntity.Price := TTNullable<Double>.Create(123.456);
  FJSonContext.Insert<TTestNullablePrimitives>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestNullablePrimitives>(LEntity, LConfig);
  LRestored := FJSonContext.EntityFromJSon<TTestNullablePrimitives>(LJson);
  FCreatedEntities.Add(LRestored);

  Assert.IsFalse(LRestored.Description.IsNull);
  Assert.AreEqual('RoundTrip', LRestored.Description.GetValueOrDefault);
  Assert.IsFalse(LRestored.Quantity.IsNull);
  Assert.AreEqual<Integer>(-7, LRestored.Quantity.GetValueOrDefault);
  Assert.IsFalse(LRestored.Price.IsNull);
  Assert.AreEqual(123.456, LRestored.Price.GetValueOrDefault, 0.001);
end;

procedure TTAbstractNullablePrimitivesJSonTests.EntityFromJSonRoundTripsNullFields;
var
  LEntity: TTestNullablePrimitives;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LRestored: TTestNullablePrimitives;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestNullablePrimitives>();
  FCreatedEntities.Add(LEntity);
  FJSonContext.Insert<TTestNullablePrimitives>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestNullablePrimitives>(LEntity, LConfig);
  LRestored := FJSonContext.EntityFromJSon<TTestNullablePrimitives>(LJson);
  FCreatedEntities.Add(LRestored);

  Assert.IsTrue(LRestored.Description.IsNull);
  Assert.IsTrue(LRestored.Quantity.IsNull);
  Assert.IsTrue(LRestored.Price.IsNull);
end;

procedure TTAbstractNullablePrimitivesJSonTests.ListToJSonSerializesAllRows;
var
  LEntity: TTestNullablePrimitives;
  LIndex: Integer;
  LList: TTObjectList<TTestNullablePrimitives>;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LArray: TJSonValue;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  for LIndex := 1 to 3 do
  begin
    LEntity := FJSonContext.CreateEntity<TTestNullablePrimitives>();
    FCreatedEntities.Add(LEntity);
    LEntity.Description := TTNullable<String>.Create(
      Format('Row%d', [LIndex]));
    LEntity.Quantity := TTNullable<Integer>.Create(LIndex * 10);
    LEntity.Price := TTNullable<Double>.Create(LIndex * 1.5);
    FJSonContext.Insert<TTestNullablePrimitives>(LEntity);
  end;

  LList := TTObjectList<TTestNullablePrimitives>.Create(True);
  try
    FJSonContext.SelectAll<TTestNullablePrimitives>(LList);
    LJson := FJSonContext.ListToJSon<TTestNullablePrimitives>(LList, LConfig);
  finally
    LList.Free;
  end;

  LArray := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LArray is TJSonArray);
    Assert.AreEqual<Integer>(3, TJSonArray(LArray).Count);
  finally
    LArray.Free;
  end;
end;

procedure TTAbstractNullablePrimitivesJSonTests.MetadataToJSonExposesAllColumnNames;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestNullablePrimitives>();
  Assert.IsTrue(LJson.Contains('description'));
  Assert.IsTrue(LJson.Contains('quantity'));
  Assert.IsTrue(LJson.Contains('price'));
  Assert.IsTrue(LJson.Contains('NullablePrimitives'),
    'MetadataToJSon must emit the table name');
end;

end.
