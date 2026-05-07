(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.AllTypes;

interface

uses
  System.SysUtils,
  System.DateUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Generics.Collections,
  Trysil.Filter,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractAllTypesTests }

  TTAbstractAllTypesTests = class(TTAbstractBaseTests)
  strict protected
    procedure ClearTables; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;

    [Test]
    procedure InsertAndGetRoundTripsAllNonNullableFields;

    [Test]
    procedure InsertAndGetRoundTripsAllNullableFields;

    [Test]
    procedure NullableFieldsDefaultToNull;

    [Test]
    procedure UpdateRewritesAllValues;

    [Test]
    procedure DeleteRemovesRow;

    [Test]
    procedure SelectAllReturnsMultipleRows;
  end;

implementation

const
  GUID_ONE: TGUID = '{11111111-1111-1111-1111-111111111111}';
  GUID_TWO: TGUID = '{22222222-2222-2222-2222-222222222222}';

{ TTAbstractAllTypesTests }

procedure TTAbstractAllTypesTests.ClearTables;
begin
  inherited;
  Connection.Execute('DELETE FROM AllTypes');
end;

procedure TTAbstractAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTAbstractAllTypesTests.TearDown;
begin
  inherited;
end;

procedure TTAbstractAllTypesTests.InsertAndGetRoundTripsAllNonNullableFields;
var
  LEntity: TTestAllTypes;
  LLoaded: TTestAllTypes;
  LExpectedDate: TDateTime;
  LExpectedPayload: TBytes;
begin
  LExpectedDate := EncodeDateTime(2024, 7, 15, 10, 30, 0, 0);
  LExpectedPayload := TBytes.Create($DE, $AD, $BE, $EF);

  LEntity := FContext.CreateEntity<TTestAllTypes>();
  LEntity.LargeNumber := Int64(9000000000);
  LEntity.IsActive := True;
  LEntity.BirthDate := LExpectedDate;
  LEntity.UniqueID := GUID_ONE;
  LEntity.Payload := LExpectedPayload;
  FContext.Insert<TTestAllTypes>(LEntity);

  LLoaded := FContext.Get<TTestAllTypes>(LEntity.ID);
  Assert.AreEqual<Int64>(Int64(9000000000), LLoaded.LargeNumber);
  Assert.IsTrue(LLoaded.IsActive);
  Assert.AreEqual(LExpectedDate, LLoaded.BirthDate);
  Assert.IsTrue(IsEqualGUID(GUID_ONE, LLoaded.UniqueID));
  Assert.AreEqual<Integer>(Length(LExpectedPayload), Length(LLoaded.Payload));
  Assert.AreEqual<Byte>($DE, LLoaded.Payload[0]);
  Assert.AreEqual<Byte>($EF, LLoaded.Payload[3]);
end;

procedure TTAbstractAllTypesTests.InsertAndGetRoundTripsAllNullableFields;
var
  LEntity: TTestAllTypes;
  LLoaded: TTestAllTypes;
  LExpectedDate: TDateTime;
  LExpectedPayload: TBytes;
begin
  LExpectedDate := EncodeDateTime(1999, 12, 31, 23, 59, 59, 0);
  LExpectedPayload := TBytes.Create($CA, $FE);

  LEntity := FContext.CreateEntity<TTestAllTypes>();
  LEntity.LargeNumber := 1;
  LEntity.IsActive := False;
  LEntity.BirthDate := Now;
  LEntity.UniqueID := GUID_ONE;
  LEntity.Payload := TBytes.Create($01);
  LEntity.OptLargeNumber := TTNullable<Int64>.Create(Int64(-500));
  LEntity.OptIsActive := TTNullable<Boolean>.Create(True);
  LEntity.OptBirthDate := TTNullable<TDateTime>.Create(LExpectedDate);
  LEntity.OptUniqueID := TTNullable<TGuid>.Create(GUID_TWO);
  LEntity.OptPayload := TTNullable<TBytes>.Create(LExpectedPayload);
  FContext.Insert<TTestAllTypes>(LEntity);

  LLoaded := FContext.Get<TTestAllTypes>(LEntity.ID);
  Assert.IsFalse(LLoaded.OptLargeNumber.IsNull);
  Assert.AreEqual<Int64>(Int64(-500), LLoaded.OptLargeNumber.GetValueOrDefault);
  Assert.IsFalse(LLoaded.OptIsActive.IsNull);
  Assert.IsTrue(LLoaded.OptIsActive.GetValueOrDefault);
  Assert.IsFalse(LLoaded.OptBirthDate.IsNull);
  Assert.AreEqual(LExpectedDate, LLoaded.OptBirthDate.GetValueOrDefault);
  Assert.IsFalse(LLoaded.OptUniqueID.IsNull);
  Assert.IsTrue(IsEqualGUID(GUID_TWO, LLoaded.OptUniqueID.GetValueOrDefault));
  Assert.IsFalse(LLoaded.OptPayload.IsNull);
  Assert.AreEqual<Integer>(2, Length(LLoaded.OptPayload.GetValueOrDefault));
end;

procedure TTAbstractAllTypesTests.NullableFieldsDefaultToNull;
var
  LEntity: TTestAllTypes;
  LLoaded: TTestAllTypes;
begin
  LEntity := FContext.CreateEntity<TTestAllTypes>();
  LEntity.LargeNumber := 0;
  LEntity.IsActive := False;
  LEntity.BirthDate := Now;
  LEntity.UniqueID := GUID_ONE;
  LEntity.Payload := TBytes.Create($00);
  FContext.Insert<TTestAllTypes>(LEntity);

  LLoaded := FContext.Get<TTestAllTypes>(LEntity.ID);
  Assert.IsTrue(LLoaded.OptLargeNumber.IsNull,
    'OptLargeNumber must be null when not assigned');
  Assert.IsTrue(LLoaded.OptIsActive.IsNull);
  Assert.IsTrue(LLoaded.OptBirthDate.IsNull);
  Assert.IsTrue(LLoaded.OptUniqueID.IsNull);
  Assert.IsTrue(LLoaded.OptPayload.IsNull);
end;

procedure TTAbstractAllTypesTests.UpdateRewritesAllValues;
var
  LEntity: TTestAllTypes;
  LLoaded: TTestAllTypes;
  LInitialDate: TDateTime;
  LUpdatedDate: TDateTime;
begin
  LInitialDate := EncodeDateTime(2000, 1, 1, 0, 0, 0, 0);
  LUpdatedDate := EncodeDateTime(2020, 6, 15, 12, 0, 0, 0);

  LEntity := FContext.CreateEntity<TTestAllTypes>();
  LEntity.LargeNumber := 1;
  LEntity.IsActive := False;
  LEntity.BirthDate := LInitialDate;
  LEntity.UniqueID := GUID_ONE;
  LEntity.Payload := TBytes.Create($01);
  FContext.Insert<TTestAllTypes>(LEntity);

  LEntity.LargeNumber := Int64(42);
  LEntity.IsActive := True;
  LEntity.BirthDate := LUpdatedDate;
  LEntity.UniqueID := GUID_TWO;
  LEntity.Payload := TBytes.Create($FF, $00);
  FContext.Update<TTestAllTypes>(LEntity);

  LLoaded := FContext.Get<TTestAllTypes>(LEntity.ID);
  Assert.AreEqual<Int64>(Int64(42), LLoaded.LargeNumber);
  Assert.IsTrue(LLoaded.IsActive);
  Assert.AreEqual(LUpdatedDate, LLoaded.BirthDate);
  Assert.AreEqual(GUID_TWO.ToString, LLoaded.UniqueID.ToString);
  Assert.AreEqual<Integer>(2, Length(LLoaded.Payload));
end;

procedure TTAbstractAllTypesTests.DeleteRemovesRow;
var
  LEntity: TTestAllTypes;
  LCount: Integer;
begin
  LEntity := FContext.CreateEntity<TTestAllTypes>();
  LEntity.LargeNumber := 1;
  LEntity.IsActive := True;
  LEntity.BirthDate := Now;
  LEntity.UniqueID := GUID_ONE;
  LEntity.Payload := TBytes.Create($01);
  FContext.Insert<TTestAllTypes>(LEntity);

  FContext.Delete<TTestAllTypes>(LEntity);

  LCount := FContext.SelectCount<TTestAllTypes>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount);
end;

procedure TTAbstractAllTypesTests.SelectAllReturnsMultipleRows;
var
  LEntity: TTestAllTypes;
  LIndex: Integer;
  LList: TTList<TTestAllTypes>;
begin
  for LIndex := 1 to 3 do
  begin
    LEntity := FContext.CreateEntity<TTestAllTypes>();
    LEntity.LargeNumber := Int64(LIndex);
    LEntity.IsActive := (LIndex mod 2 = 0);
    LEntity.BirthDate := Now;
    LEntity.UniqueID := GUID_ONE;
    LEntity.Payload := TBytes.Create(Byte(LIndex));
    FContext.Insert<TTestAllTypes>(LEntity);
  end;

  LList := TTList<TTestAllTypes>.Create;
  try
    FContext.SelectAll<TTestAllTypes>(LList);
    Assert.AreEqual<Integer>(3, LList.Count);
  finally
    LList.Free;
  end;
end;

end.
