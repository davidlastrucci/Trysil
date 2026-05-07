(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.AllTypesJSon;

interface

uses
  System.SysUtils,
  System.DateUtils,
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

{ TTAbstractAllTypesJSonTests }

  TTAbstractAllTypesJSonTests = class(TTAbstractBaseTests)
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
    procedure EntityToJSonEmitsAllFieldsWithExpectedTypes;

    [Test]
    procedure EntityToJSonEmitsNullForUnsetNullableFields;

    [Test]
    procedure EntityFromJSonRoundTripsAllNonNullableFields;

    [Test]
    procedure EntityFromJSonRoundTripsAllNullableFields;

    [Test]
    procedure EntityToJSonEncodesBlobAsBase64String;

    [Test]
    procedure ListToJSonSerializesAllRows;

    [Test]
    procedure MetadataToJSonExposesAllColumnNames;
  end;

implementation

const
  GUID_SAMPLE: TGUID = '{AABBCCDD-1122-3344-5566-778899AABBCC}';

{ TTAbstractAllTypesJSonTests }

procedure TTAbstractAllTypesJSonTests.ClearTables;
begin
  inherited;
  Connection.Execute('DELETE FROM AllTypes');
end;

procedure TTAbstractAllTypesJSonTests.Setup;
begin
  ClearTables;
  FJSonContext := TTJSonContext.Create(Connection);
  FContext := FJSonContext;
  FCreatedEntities := TObjectList<TObject>.Create(True);
end;

procedure TTAbstractAllTypesJSonTests.TearDown;
begin
  FCreatedEntities.Free;
  inherited TearDown;
  FJSonContext := nil;
end;

procedure TTAbstractAllTypesJSonTests.EntityToJSonEmitsAllFieldsWithExpectedTypes;
var
  LEntity: TTestAllTypes;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LValue: TJSonValue;
  LObj: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
  FCreatedEntities.Add(LEntity);
  LEntity.LargeNumber := Int64(9000000000);
  LEntity.IsActive := True;
  LEntity.BirthDate := EncodeDateTime(2024, 1, 15, 10, 0, 0, 0);
  LEntity.UniqueID := GUID_SAMPLE;
  LEntity.Payload := TBytes.Create($01, $02, $03);
  FJSonContext.Insert<TTestAllTypes>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestAllTypes>(LEntity, LConfig);

  LValue := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LValue is TJSonObject);
    LObj := TJSonObject(LValue);
    Assert.AreEqual<Int64>(
      Int64(9000000000),
      LObj.GetValue<Int64>('largeNumber'));
    Assert.AreEqual<Boolean>(True, LObj.GetValue<Boolean>('isActive'));
    Assert.IsNotNull(LObj.GetValue('birthDate'));
    Assert.IsNotNull(LObj.GetValue('uniqueID'));
    Assert.IsNotNull(LObj.GetValue('payload'));
  finally
    LValue.Free;
  end;
end;

procedure TTAbstractAllTypesJSonTests.EntityToJSonEmitsNullForUnsetNullableFields;
var
  LEntity: TTestAllTypes;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LValue: TJSonValue;
  LObj: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
  FCreatedEntities.Add(LEntity);
  LEntity.LargeNumber := 1;
  LEntity.IsActive := False;
  LEntity.BirthDate := Now;
  LEntity.UniqueID := GUID_SAMPLE;
  LEntity.Payload := TBytes.Create($00);
  FJSonContext.Insert<TTestAllTypes>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestAllTypes>(LEntity, LConfig);

  LValue := TJSonObject.ParseJSonValue(LJson);
  try
    LObj := TJSonObject(LValue);
    Assert.IsTrue(LObj.GetValue('optLargeNumber') is TJSonNull);
    Assert.IsTrue(LObj.GetValue('optIsActive') is TJSonNull);
    Assert.IsTrue(LObj.GetValue('optBirthDate') is TJSonNull);
    Assert.IsTrue(LObj.GetValue('optUniqueID') is TJSonNull);
    Assert.IsTrue(LObj.GetValue('optPayload') is TJSonNull);
  finally
    LValue.Free;
  end;
end;

procedure TTAbstractAllTypesJSonTests.EntityFromJSonRoundTripsAllNonNullableFields;
var
  LEntity: TTestAllTypes;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LRestored: TTestAllTypes;
  LExpectedDate: TDateTime;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);
  LExpectedDate := EncodeDateTime(2024, 1, 15, 10, 0, 0, 0);

  LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
  FCreatedEntities.Add(LEntity);
  LEntity.LargeNumber := Int64(-42);
  LEntity.IsActive := True;
  LEntity.BirthDate := LExpectedDate;
  LEntity.UniqueID := GUID_SAMPLE;
  LEntity.Payload := TBytes.Create($AA, $BB);
  FJSonContext.Insert<TTestAllTypes>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestAllTypes>(LEntity, LConfig);
  LRestored := FJSonContext.EntityFromJSon<TTestAllTypes>(LJson);
  FCreatedEntities.Add(LRestored);

  Assert.AreEqual<Int64>(Int64(-42), LRestored.LargeNumber);
  Assert.IsTrue(LRestored.IsActive);
  Assert.IsTrue(IsEqualGUID(GUID_SAMPLE, LRestored.UniqueID));
  Assert.AreEqual<Integer>(2, Length(LRestored.Payload));
  Assert.AreEqual<Byte>($AA, LRestored.Payload[0]);
  Assert.AreEqual<Byte>($BB, LRestored.Payload[1]);
end;

procedure TTAbstractAllTypesJSonTests.EntityFromJSonRoundTripsAllNullableFields;
var
  LEntity: TTestAllTypes;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LRestored: TTestAllTypes;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
  FCreatedEntities.Add(LEntity);
  LEntity.LargeNumber := 1;
  LEntity.IsActive := False;
  LEntity.BirthDate := Now;
  LEntity.UniqueID := GUID_SAMPLE;
  LEntity.Payload := TBytes.Create($01);
  LEntity.OptLargeNumber := TTNullable<Int64>.Create(Int64(9999999999));
  LEntity.OptIsActive := TTNullable<Boolean>.Create(True);
  LEntity.OptUniqueID := TTNullable<TGuid>.Create(GUID_SAMPLE);
  LEntity.OptPayload := TTNullable<TBytes>.Create(TBytes.Create($FE, $ED));
  FJSonContext.Insert<TTestAllTypes>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestAllTypes>(LEntity, LConfig);
  LRestored := FJSonContext.EntityFromJSon<TTestAllTypes>(LJson);
  FCreatedEntities.Add(LRestored);

  Assert.IsFalse(LRestored.OptLargeNumber.IsNull);
  Assert.AreEqual<Int64>(
    Int64(9999999999), LRestored.OptLargeNumber.GetValueOrDefault);
  Assert.IsFalse(LRestored.OptIsActive.IsNull);
  Assert.IsTrue(LRestored.OptIsActive.GetValueOrDefault);
  Assert.IsFalse(LRestored.OptUniqueID.IsNull);
  Assert.IsTrue(
    IsEqualGUID(GUID_SAMPLE, LRestored.OptUniqueID.GetValueOrDefault));
  Assert.IsFalse(LRestored.OptPayload.IsNull);
  Assert.AreEqual<Integer>(2, Length(LRestored.OptPayload.GetValueOrDefault));
end;

procedure TTAbstractAllTypesJSonTests.EntityToJSonEncodesBlobAsBase64String;
var
  LEntity: TTestAllTypes;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LValue: TJSonValue;
  LPayload: String;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
  FCreatedEntities.Add(LEntity);
  LEntity.LargeNumber := 1;
  LEntity.IsActive := True;
  LEntity.BirthDate := Now;
  LEntity.UniqueID := GUID_SAMPLE;
  LEntity.Payload := TBytes.Create($48, $69);
  FJSonContext.Insert<TTestAllTypes>(LEntity);

  LJson := FJSonContext.EntityToJSon<TTestAllTypes>(LEntity, LConfig);

  LValue := TJSonObject.ParseJSonValue(LJson);
  try
    LPayload := TJSonObject(LValue).GetValue<String>('payload');
    Assert.AreEqual('SGk=', LPayload,
      'Blob must be base64-encoded ("Hi" -> SGk=)');
  finally
    LValue.Free;
  end;
end;

procedure TTAbstractAllTypesJSonTests.ListToJSonSerializesAllRows;
var
  LEntity: TTestAllTypes;
  LIndex: Integer;
  LList: TTObjectList<TTestAllTypes>;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LArray: TJSonValue;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  for LIndex := 1 to 3 do
  begin
    LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
    FCreatedEntities.Add(LEntity);
    LEntity.LargeNumber := Int64(LIndex);
    LEntity.IsActive := (LIndex mod 2 = 0);
    LEntity.BirthDate := Now;
    LEntity.UniqueID := GUID_SAMPLE;
    LEntity.Payload := TBytes.Create(Byte(LIndex));
    FJSonContext.Insert<TTestAllTypes>(LEntity);
  end;

  LList := TTObjectList<TTestAllTypes>.Create(True);
  try
    FJSonContext.SelectAll<TTestAllTypes>(LList);
    LJson := FJSonContext.ListToJSon<TTestAllTypes>(LList, LConfig);
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

procedure TTAbstractAllTypesJSonTests.MetadataToJSonExposesAllColumnNames;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestAllTypes>();
  Assert.IsTrue(LJson.Contains('largeNumber'));
  Assert.IsTrue(LJson.Contains('isActive'));
  Assert.IsTrue(LJson.Contains('uniqueID'));
  Assert.IsTrue(LJson.Contains('payload'));
  Assert.IsTrue(LJson.Contains('AllTypes'),
    'MetadataToJSon must emit the table name');
end;

end.
