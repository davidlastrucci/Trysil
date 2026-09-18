(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.JSon;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Rtti,
  Trysil.Generics.Collections,
  Trysil.Context,
  Trysil.Data,
  Trysil.Lazy,
  Trysil.JSon.Context,
  Trysil.JSon.Types,
  Trysil.JSon.Serializer.Classes,
  Trysil.JSon.Sqids,
  Trysil.JSon.Exceptions,
  Trysil.Http.Context,
  Trysil.Http.Exceptions,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractJSonTests }

  TTAbstractJSonTests = class(TTAbstractBaseTests)
  strict private
    function PropertyFlag(
      const AJSon: String;
      const AName: String;
      const AFlag: String): Boolean;
  strict protected
    FJSonContext: TTJSonContext;
    FCreatedEntities: TObjectList<TObject>;

    procedure CheckStillDeleted(const AID: TTPrimaryKey);
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;

    [Test]
    procedure EntityToJSonReturnsNonEmptyJson;

    [Test]
    procedure EntityFromJSonRoundTrip;

    [Test]
    procedure APutOnASoftDeletedEntityDoesNotResurrectIt;

    [Test]
    procedure ADeleteOfAMissingRowIsNotFound;

    [Test]
    procedure EntityFromJSonPopulatesLazyList;

    [Test]
    procedure EntityFromJSonEmptyArrayDoesNotReloadFromDB;

    [Test]
    procedure EntityFromJSonOnALoadedEntityReloadsTheLazyMember;

    [Test]
    procedure EntityFromJSonRoundTripsLazyReferenceIdWithSqids;

    [Test]
    procedure InsertRefusesABodyThatCarriesNoKey;

    [Test]
    procedure SaveOnABodyThatNamesARowIsAnUpdate;

    [Test]
    procedure SaveIsNotAvailableOnAnHttpContext;

    [Test]
    procedure EntityFromJSonWithoutTheKeyIsAcceptedWithSqids;

    [Test]
    procedure ADateIsSerializedWithoutATimeZone;

    [Test]
    procedure ATimeIsSerializedWithoutADate;

    [Test]
    procedure ATimeDoesNotFollowTheMachineSeparator;

    [Test]
    procedure DatasetToJSonHandlesLargeIntegersAndDecimals;

    [Test]
    procedure DatasetToJSonDoesNotHtmlEncodeItsStrings;

    [Test]
    procedure EntityToJSonMaxLevelsZeroEmitsOnlyLazyId;

    [Test]
    procedure EntityToJSonMaxLevelsZeroDoesNotLoadLazy;

    [Test]
    procedure EntityToJSonMaxLevelsOneEmitsRelatedEntity;

    [Test]
    procedure EntityToJSonMaxLevelsOneBoundsDetailDepth;

    [Test]
    procedure EntityToJSonMaxLevelsZeroOmitsDetails;

    [Test]
    procedure ListToJSonReturnsValidArray;

    [Test]
    procedure ListFromJSonRoundTrip;

    [Test]
    procedure ListFromJSonDoesNotDrawSequenceIdsPerItem;

    [Test]
    procedure ListFromJSonRefusesAnItemThatIsNotAnObject;

    [Test]
    procedure ADetailItemThatIsNotAnObjectLeavesTheDetail;

    [Test]
    procedure ABodyTheDeserializerCannotReadIsTheCallersFault;

    [Test]
    procedure ALazyIdIsReadUnderTheKeyItIsWrittenWith;

    [Test]
    procedure MetadataToJSonNamesTheEntity;

    [Test]
    procedure MetadataToJSonDeclaresTheDirectionOfAColumn;

    [Test]
    procedure MetadataToJSonOmitsAHiddenKeyAndVersion;

    [Test]
    procedure MetadataToJSonStillNamesAKeyTheBodyOnlyWrites;

    [Test]
    procedure ABodyThatIsNotAnObjectIsRefused;

    [Test]
    procedure MetadataToJSonDescribesAJoinEntity;

    [Test]
    procedure MetadataToJSonOnAnEntityWithoutAVersionColumn;

    [Test]
    procedure DatasetToJSonContainsData;

    [Test]
    procedure IdentityMapNotSupported;

    { Directional JSon attributes }

    [Test]
    procedure IgnoreSerializeColumnIsNotInJSon;

    [Test]
    procedure IgnoreDeserializeColumnIsNotReadFromJSon;

    { Change tracking is not writable from JSon }

    [Test]
    procedure ChangeTrackingIsNotReadFromJSon;

    [Test]
    procedure UpdateDoesNotOverwriteCreatedBy;

    [Test]
    procedure DeserializeOnLoadedEntityKeepsOtherColumns;
  end;

implementation

{ TTAbstractJSonTests }

procedure TTAbstractJSonTests.Setup;
begin
  ClearTables;
  FJSonContext := TTJSonContext.Create(Connection);
  FContext := FJSonContext;
  FCreatedEntities := TObjectList<TObject>.Create(True);
end;

procedure TTAbstractJSonTests.TearDown;
begin
  FCreatedEntities.Free;
  inherited TearDown;
  FJSonContext := nil;
end;

procedure TTAbstractJSonTests.EntityToJSonReturnsNonEmptyJson;
var
  LCustomer: TTestCustomer;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Acme Corp';
  LCustomer.Email := 'acme@example.com';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LJson := FJSonContext.EntityToJSon<TTestCustomer>(LCustomer, LConfig);
  Assert.IsNotEmpty(LJson, 'EntityToJSon must return non-empty JSON');
  Assert.IsTrue(LJson.Contains('Acme Corp'),
    'JSON must contain customer name');
end;

procedure TTAbstractJSonTests.EntityFromJSonRoundTrip;
var
  LCustomer: TTestCustomer;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LRestored: TTestCustomer;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Acme Corp';
  LCustomer.Email := 'acme@example.com';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LJson := FJSonContext.EntityToJSon<TTestCustomer>(LCustomer, LConfig);
  LRestored := FJSonContext.EntityFromJSon<TTestCustomer>(LJson);
  FCreatedEntities.Add(LRestored);
  Assert.AreEqual('Acme Corp', LRestored.Name);
  Assert.AreEqual('acme@example.com', LRestored.Email);
end;

procedure TTAbstractJSonTests.APutOnASoftDeletedEntityDoesNotResurrectIt;
var
  LConfig: TTJSonSerializerConfig;
  LTask: TTestTask;
  LDeleted: TTestTask;
  LFromJSon: TTestTask;
  LID: TTPrimaryKey;
  LRaised: Boolean;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LTask := FJSonContext.CreateEntity<TTestTask>();
  FCreatedEntities.Add(LTask);
  LTask.Title := 'Recoverable';
  FJSonContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FJSonContext.Delete<TTestTask>(LTask);

  LDeleted := FJSonContext.Get<TTestTask>(LID, True);
  FCreatedEntities.Add(LDeleted);
  LFromJSon := FJSonContext.EntityFromJSon<TTestTask>(
    FJSonContext.EntityToJSon<TTestTask>(LDeleted, LConfig));
  FCreatedEntities.Add(LFromJSon);
  Assert.IsTrue(
    LFromJSon.DeletedAt.IsNull,
    'Precondition: a body cannot carry DeletedAt, so the entity has none');

  LFromJSon.Title := 'Resurrected';
  LRaised := False;
  try
    FJSonContext.Update<TTestTask>(LFromJSon);
  except
    on E: ETConcurrentUpdateException do
      LRaised := True;
  end;

  Assert.IsTrue(
    LRaised, 'An update must not reach a row that is soft deleted');
  CheckStillDeleted(LID);
end;

procedure TTAbstractJSonTests.CheckStillDeleted(const AID: TTPrimaryKey);
var
  LReloaded: TTestTask;
begin
  Assert.IsFalse(
    FJSonContext.TryGet<TTestTask>(AID, LReloaded),
    'A refused update must leave the row soft deleted');

  LReloaded := FJSonContext.Get<TTestTask>(AID, True);
  FCreatedEntities.Add(LReloaded);
  Assert.AreEqual(
    'Recoverable',
    LReloaded.Title,
    'A refused update must not have written the new title either');
end;

procedure TTAbstractJSonTests.EntityFromJSonPopulatesLazyList;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedCustomer: TTestLazyCustomer;
  LJson: String;
  LRestored: TTestLazyCustomer;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, True);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'LazyParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 20.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedCustomer := FJSonContext.Get<TTestLazyCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LLoadedCustomer);
  Assert.AreEqual<Integer>(2, LLoadedCustomer.Orders.Count,
    'Precondition: lazy list must load the two related orders');

  LJson := FJSonContext.EntityToJSon<TTestLazyCustomer>(
    LLoadedCustomer, LConfig);

  Connection.Execute('DELETE FROM Orders');

  LRestored := FJSonContext.EntityFromJSon<TTestLazyCustomer>(LJson);
  FCreatedEntities.Add(LRestored);
  Assert.AreEqual<Integer>(2, LRestored.Orders.Count,
    'Lazy list must be populated from the JSON array, not reloaded from DB');
end;

procedure TTAbstractJSonTests.EntityFromJSonEmptyArrayDoesNotReloadFromDB;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedCustomer: TTestLazyCustomer;
  LJson: String;
  LRestored: TTestLazyCustomer;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, True);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'EmptyParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LLoadedCustomer := FJSonContext.Get<TTestLazyCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LLoadedCustomer);
  Assert.AreEqual<Integer>(0, LLoadedCustomer.Orders.Count,
    'Precondition: customer must start with no related orders');

  LJson := FJSonContext.EntityToJSon<TTestLazyCustomer>(
    LLoadedCustomer, LConfig);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 20.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LRestored := FJSonContext.EntityFromJSon<TTestLazyCustomer>(LJson);
  FCreatedEntities.Add(LRestored);
  Assert.AreEqual<Integer>(0, LRestored.Orders.Count,
    'Empty JSON array must leave the lazy list empty and valid, not reload from DB');
end;

procedure TTAbstractJSonTests.ADateIsSerializedWithoutATimeZone;
var
  LSerializer: TTJSonAbstractSerializer;
  LJSon: TJSonValue;
begin
  LSerializer := TTJSonSerializers.Instance.GetInstance(TypeInfo(TDate));
  LJSon := LSerializer.ToJSon(TTValue.From<TDate>(EncodeDate(2026, 3, 5)));
  try
    Assert.AreEqual(
      '2026-03-05',
      LJSon.Value,
      'A pure date has no time zone to convert. It used to go through ' +
      'ToUniversalTime like a TDateTime, so east of Greenwich it came out ' +
      'as the previous day at 23:00Z');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.ATimeIsSerializedWithoutADate;
var
  LSerializer: TTJSonAbstractSerializer;
  LJSon: TJSonValue;
begin
  LSerializer := TTJSonSerializers.Instance.GetInstance(TypeInfo(TTime));
  LJSon := LSerializer.ToJSon(TTValue.From<TTime>(EncodeTime(10, 30, 0, 0)));
  try
    Assert.AreEqual(
      '10:30:00',
      LJSon.Value,
      'And a time of day carries no date to shift');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.ATimeDoesNotFollowTheMachineSeparator;
var
  LSeparator: Char;
  LSerializer: TTJSonAbstractSerializer;
  LJSon: TJSonValue;
begin
  LSeparator := FormatSettings.TimeSeparator;
  try
    FormatSettings.TimeSeparator := '.';
    LSerializer := TTJSonSerializers.Instance.GetInstance(TypeInfo(TTime));
    LJSon := LSerializer.ToJSon(
      TTValue.From<TTime>(EncodeTime(10, 30, 0, 0)));
    try
      Assert.AreEqual(
        '10:30:00',
        LJSon.Value,
        'In a FormatDateTime mask the colon is not a literal: it is the '
        + 'token the RTL replaces with FormatSettings.TimeSeparator. On a '
        + 'machine set to fi-FI, nb-NO or da-DK the time went out as '
        + '10.30.00, and that string comes back neither through the '
        + 'invariant TryStrToTime of the deserializer nor through its ISO '
        + 'fallback: EConvertError, which is not an ETJSonException, so a '
        + '500 on a value this library had just written itself');
    finally
      LJSon.Free;
    end;
  finally
    FormatSettings.TimeSeparator := LSeparator;
  end;
end;

procedure TTAbstractJSonTests.DatasetToJSonDoesNotHtmlEncodeItsStrings;
var
  LCustomer: TTestCustomer;
  LDataset: TDataset;
  LJSon: String;
begin
  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Rossi & Figli';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LDataset := FJSonContext.CreateDataset(Format(
    'SELECT Name FROM Customers WHERE ID = %d', [LCustomer.ID]));
  try
    LJSon := FJSonContext.DatasetToJSon(LDataset);
  finally
    LDataset.Free;
  end;

  Assert.IsTrue(
    LJSon.Contains('Rossi & Figli'),
    'The value used to be HTML encoded on its way into the JSON, so a name ' +
    'came out of a RawSelect endpoint as Rossi &amp; Figli while the same ' +
    'name from an entity endpoint came out intact');
  Assert.IsFalse(
    LJSon.Contains('&amp;'),
    'TJSonString already escapes what JSON requires: an HTML encode on top ' +
    'of it protects nothing and changes the data');
end;

procedure TTAbstractJSonTests.DatasetToJSonHandlesLargeIntegersAndDecimals;
var
  LEntity: TTestAllTypes;
  LDataset: TDataset;
  LJSon: String;
begin
  LEntity := FJSonContext.CreateEntity<TTestAllTypes>();
  FCreatedEntities.Add(LEntity);
  LEntity.LargeNumber := Int64(9000000000);
  LEntity.Price := 1234.5678;
  FJSonContext.Insert<TTestAllTypes>(LEntity);

  LDataset := FJSonContext.CreateDataset(Format(
    'SELECT LargeNumber, Price FROM AllTypes WHERE ID = %d', [LEntity.ID]));
  try
    LJSon := FJSonContext.DatasetToJSon(LDataset);
  finally
    LDataset.Free;
  end;

  Assert.IsTrue(
    LJSon.Contains('9000000000'),
    'A BIGINT column had no branch of its own and fell into the else, so ' +
    'any RawSelect carrying one answered 500');
  Assert.IsTrue(
    LJSon.Contains('1234'),
    'And so did every decimal read as ftFMTBcd - which is what a ' +
    'SUM(CAST(x AS DECIMAL)) comes back as');
end;

procedure TTAbstractJSonTests.InsertRefusesABodyThatCarriesNoKey;
var
  LRestored: TTestCustomer;
  LRaised: Boolean;
begin
  LRestored := FJSonContext.EntityFromJSon<TTestCustomer>(
    '{"name":"NoKey","email":"nokey@example.com"}');
  FCreatedEntities.Add(LRestored);

  LRaised := False;
  try
    FJSonContext.Insert<TTestCustomer>(LRestored);
  except
    on E: ETException do
      LRaised := True;
  end;

  Assert.IsTrue(
    LRaised,
    'A body with no id leaves the entity at key zero, and the insert ' +
    'used to write a row with ID = 0 and say nothing. The controller has ' +
    'to call SetSequenceID, and now it is told when it forgets');
end;

procedure TTAbstractJSonTests.SaveOnABodyThatNamesARowIsAnUpdate;
var
  LConfig: TTJSonSerializerConfig;
  LCustomer: TTestCustomer;
  LRestored: TTestCustomer;
  LReloaded: TTestCustomer;
  LJSon: String;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);
  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Before';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LJSon := FJSonContext.EntityToJSon<TTestCustomer>(LCustomer, LConfig);
  LRestored := FJSonContext.EntityFromJSon<TTestCustomer>(LJSon);
  FCreatedEntities.Add(LRestored);
  LRestored.Name := 'After';

  FJSonContext.Save<TTestCustomer>(LRestored);

  LReloaded := FJSonContext.Get<TTestCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LReloaded);
  Assert.AreEqual(
    'After',
    LReloaded.Name,
    'An entity filled from a body was registered as new under key zero, ' +
    'together with every other deserialized entity of its type. The ' +
    'context did not give it its identity, so it is not one of the ' +
    'entities the context is tracking, and a body that names a row means ' +
    'an update');
end;

procedure TTAbstractJSonTests.SaveIsNotAvailableOnAnHttpContext;
var
  LContext: TTHttpContext;
  LCustomer: TTestCustomer;
  LRaised: Boolean;
begin
  LRaised := False;
  LContext := TTHttpContext.Create(Connection);
  try
    LCustomer := LContext.CreateEntity<TTestCustomer>();
    try
      LCustomer.Name := 'Whatever';
      try
        LContext.Save<TTestCustomer>(LCustomer);
      except
        on E: ETHttpServerException do
          LRaised := True;
      end;
    finally
      LContext.FreeEntity<TTestCustomer>(LCustomer);
    end;
  finally
    LContext.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'Save decides between an insert and an update from what the context ' +
    'created and has not written yet, and a context that lives one ' +
    'request has no such history. Whether the request is a create or an ' +
    'update is in the request, and the controller says so with Insert ' +
    'or Update');
end;

procedure TTAbstractJSonTests.EntityFromJSonWithoutTheKeyIsAcceptedWithSqids;
var
  LRestored: TTestCustomer;
begin
  TTJSonSqids.Instance.UseSqids := True;
  try
    LRestored := FJSonContext.EntityFromJSon<TTestCustomer>(
      '{"name":"NoKey","email":"nokey@example.com"}');
    FCreatedEntities.Add(LRestored);

    Assert.AreEqual(
      'NoKey',
      LRestored.Name,
      'With Sqids on, the primary key went to the sqids branch whether or ' +
      'not the body carried it, and decoding the empty string raised: a ' +
      'body written by hand without the key answered 500');
    Assert.AreEqual<TTPrimaryKey>(
      0,
      LRestored.ID,
      'A key that is not in the body leaves the entity with none, which is ' +
      'what every other column does');
  finally
    TTJSonSqids.Instance.UseSqids := False;
  end;
end;

procedure TTAbstractJSonTests.EntityFromJSonOnALoadedEntityReloadsTheLazyMember;
var
  LFirst: TTestCustomer;
  LSecond: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedOrder: TTestLazyOrder;
  LJSon: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(0, False);

  LFirst := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LFirst);
  LFirst.Name := 'First parent';
  FJSonContext.Insert<TTestCustomer>(LFirst);

  LSecond := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LSecond);
  LSecond.Name := 'Second parent';
  FJSonContext.Insert<TTestCustomer>(LSecond);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LFirst.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedOrder := FJSonContext.Get<TTestLazyOrder>(LOrder.ID);
  FCreatedEntities.Add(LLoadedOrder);
  Assert.AreEqual<Integer>(
    LFirst.ID,
    LLoadedOrder.Customer.Entity.ID,
    'Precondition: the lazy member is loaded and holds the first parent');

  LJSon := FJSonContext.EntityToJSonObject<TTestLazyOrder>(
    LLoadedOrder, LConfig);
  try
    LJSon.RemovePair('customerID').Free;
    LJSon.AddPair('customerID', TJSonNumber.Create(LSecond.ID));
    FJSonContext.EntityFromJSonObject<TTestLazyOrder>(LJSon, LLoadedOrder);
  finally
    LJSon.Free;
  end;

  Assert.AreEqual<Integer>(
    LSecond.ID,
    LLoadedOrder.Customer.Entity.ID,
    'A key written by the deserializer goes through the property, so the ' +
    'entity in the cache is released and the relation reloads. It used to ' +
    'write the field: the key changed and the old master stayed');
end;

procedure TTAbstractJSonTests.EntityFromJSonRoundTripsLazyReferenceIdWithSqids;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedOrder: TTestLazyOrder;
  LJson: String;
  LRestored: TTestLazyOrder;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  TTJSonSqids.Instance.UseSqids := True;
  try
    LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
    FCreatedEntities.Add(LCustomer);
    LCustomer.Name := 'SqidsParent';
    FJSonContext.Insert<TTestCustomer>(LCustomer);

    LOrder := FJSonContext.CreateEntity<TTestOrder>();
    FCreatedEntities.Add(LOrder);
    LOrder.CustomerID := LCustomer.ID;
    LOrder.Amount := 33.0;
    FJSonContext.Insert<TTestOrder>(LOrder);

    LLoadedOrder := FJSonContext.Get<TTestLazyOrder>(LOrder.ID);
    FCreatedEntities.Add(LLoadedOrder);
    Assert.AreEqual<Integer>(LCustomer.ID, LLoadedOrder.Customer.ID,
      'Precondition: lazy reference must carry the customer FK');

    LJson := FJSonContext.EntityToJSon<TTestLazyOrder>(LLoadedOrder, LConfig);

    LRestored := FJSonContext.EntityFromJSon<TTestLazyOrder>(LJson);
    FCreatedEntities.Add(LRestored);
    Assert.AreEqual<Integer>(LCustomer.ID, LRestored.Customer.ID,
      'Lazy reference FK must survive the Sqids encode/decode round-trip');
  finally
    TTJSonSqids.Instance.UseSqids := False;
  end;
end;

procedure TTAbstractJSonTests.EntityToJSonMaxLevelsZeroEmitsOnlyLazyId;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedOrder: TTestLazyOrder;
  LJSon: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(0, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'LevelParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedOrder := FJSonContext.Get<TTestLazyOrder>(LOrder.ID);
  FCreatedEntities.Add(LLoadedOrder);

  LJSon := FJSonContext.EntityToJSonObject<TTestLazyOrder>(
    LLoadedOrder, LConfig);
  try
    Assert.IsTrue(
      LJSon.GetValue('customerID') <> nil,
      'The foreign key must still be emitted when MaxLevels is zero');
    Assert.IsTrue(
      LJSon.GetValue('customer') = nil,
      'The related entity must not be emitted when MaxLevels is zero');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.EntityToJSonMaxLevelsZeroDoesNotLoadLazy;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedOrder: TTestLazyOrder;
  LJSon: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(0, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'LevelParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedOrder := FJSonContext.Get<TTestLazyOrder>(LOrder.ID);
  FCreatedEntities.Add(LLoadedOrder);
  Assert.IsFalse(
    LLoadedOrder.Customer.IsLoaded,
    'Precondition: a freshly read entity must not have loaded the lazy');

  LJSon := FJSonContext.EntityToJSonObject<TTestLazyOrder>(
    LLoadedOrder, LConfig);
  try
    Assert.IsFalse(
      LLoadedOrder.Customer.IsLoaded,
      'Serializing at level zero must not resolve the lazy reference');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.EntityToJSonMaxLevelsOneEmitsRelatedEntity;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedOrder: TTestLazyOrder;
  LJSon: TJSonObject;
  LNested: TJSonValue;
begin
  LConfig := TTJSonSerializerConfig.Create(1, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'LevelParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedOrder := FJSonContext.Get<TTestLazyOrder>(LOrder.ID);
  FCreatedEntities.Add(LLoadedOrder);

  LJSon := FJSonContext.EntityToJSonObject<TTestLazyOrder>(
    LLoadedOrder, LConfig);
  try
    Assert.IsTrue(
      LJSon.GetValue('customerID') <> nil,
      'The foreign key must be emitted when MaxLevels is one');

    LNested := LJSon.GetValue('customer');
    Assert.IsTrue(
      LNested is TJSonObject,
      'The related entity must be emitted when MaxLevels is one');
    Assert.AreEqual(
      'LevelParent', TJSonObject(LNested).GetValue<String>('name'));

    Assert.IsTrue(
      LLoadedOrder.Customer.IsLoaded,
      'Serializing at level one must resolve the lazy reference');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.EntityToJSonMaxLevelsOneBoundsDetailDepth;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedCustomer: TTestLazyCustomer;
  LJSon: TJSonObject;
  LOrders: TJSonValue;
  LDetail: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(1, True);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'DetailParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedCustomer := FJSonContext.Get<TTestLazyCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LLoadedCustomer);
  Assert.AreEqual<Integer>(1, LLoadedCustomer.Orders.Count,
    'Precondition: the lazy list must load the related order');

  LJSon := FJSonContext.EntityToJSonObject<TTestLazyCustomer>(
    LLoadedCustomer, LConfig);
  try
    LOrders := LJSon.GetValue('orders');
    Assert.IsTrue(
      LOrders is TJSonArray,
      'The detail collection must be emitted when MaxLevels is one');
    Assert.AreEqual<Integer>(1, TJSonArray(LOrders).Count);

    LDetail := TJSonArray(LOrders).Items[0] as TJSonObject;
    Assert.IsTrue(
      LDetail.GetValue('customerID') <> nil,
      'The detail must still carry its foreign key');
    Assert.IsTrue(
      LDetail.GetValue('customer') = nil,
      'MaxLevels must bound what hangs below a detail, not restart at it');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.EntityToJSonMaxLevelsZeroOmitsDetails;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoadedCustomer: TTestLazyCustomer;
  LJSon: TJSonObject;
begin
  LConfig := TTJSonSerializerConfig.Create(0, True);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'DetailParent';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoadedCustomer := FJSonContext.Get<TTestLazyCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LLoadedCustomer);
  Assert.AreEqual<Integer>(1, LLoadedCustomer.Orders.Count,
    'Precondition: there must be a detail available to omit');

  LJSon := FJSonContext.EntityToJSonObject<TTestLazyCustomer>(
    LLoadedCustomer, LConfig);
  try
    Assert.IsTrue(
      LJSon.GetValue('name') <> nil,
      'The entity own columns must still be emitted at level zero');
    Assert.IsTrue(
      LJSon.GetValue('orders') = nil,
      'Level zero allows nothing below the entity, details included');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.ListToJSonReturnsValidArray;
var
  LCustomer: TTestCustomer;
  LList: TTObjectList<TTestCustomer>;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
  LArray: TJSonValue;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Alpha';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Beta';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LList := TTObjectList<TTestCustomer>.Create(True);
  try
    FJSonContext.SelectAll<TTestCustomer>(LList);
    LJson := FJSonContext.ListToJSon<TTestCustomer>(LList, LConfig);
  finally
    LList.Free;
  end;

  LArray := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LArray is TJSonArray, 'ListToJSon must return a JSON array');
    Assert.AreEqual<Integer>(2, TJSonArray(LArray).Count);
  finally
    LArray.Free;
  end;
end;

procedure TTAbstractJSonTests.ListFromJSonRoundTrip;
var
  LCustomer: TTestCustomer;
  LOriginalList: TTObjectList<TTestCustomer>;
  LRestoredList: TTObjectList<TTestCustomer>;
  LConfig: TTJSonSerializerConfig;
  LJson: String;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Alpha';
  LCustomer.Email := 'alpha@example.com';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Beta';
  LCustomer.Email := 'beta@example.com';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOriginalList := TTObjectList<TTestCustomer>.Create(True);
  try
    FJSonContext.SelectAll<TTestCustomer>(LOriginalList);
    LJson := FJSonContext.ListToJSon<TTestCustomer>(LOriginalList, LConfig);
  finally
    LOriginalList.Free;
  end;

  LRestoredList := TTObjectList<TTestCustomer>.Create(True);
  try
    FJSonContext.ListFromJSon<TTestCustomer>(LJson, LRestoredList);
    Assert.AreEqual<Integer>(2, LRestoredList.Count);
    Assert.AreEqual('Alpha', LRestoredList[0].Name);
    Assert.AreEqual('Beta', LRestoredList[1].Name);
  finally
    LRestoredList.Free;
  end;
end;

procedure TTAbstractJSonTests.ListFromJSonDoesNotDrawSequenceIdsPerItem;
var
  LList: TTObjectList<TTestCustomer>;
  LIndex: Integer;
begin
  LList := TTObjectList<TTestCustomer>.Create(True);
  try
    FJSonContext.ListFromJSon<TTestCustomer>(
      '[{"name":"A"},{"name":"B"},{"name":"C"}]', LList);
    Assert.AreEqual<Integer>(3, LList.Count);

    for LIndex := 0 to LList.Count - 1 do
      Assert.AreEqual<TTPrimaryKey>(0, LList[LIndex].ID,
        'Deserializing must not draw a sequence id: the JSon carries the id');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJSonTests.ListFromJSonRefusesAnItemThatIsNotAnObject;
var
  LList: TTObjectList<TTestCustomer>;
  LRaised: Boolean;
  LDropped: Boolean;
  LCount: Integer;
begin
  LRaised := False;
  LDropped := False;

  LList := TTObjectList<TTestCustomer>.Create(True);
  try
    try
      FJSonContext.ListFromJSon<TTestCustomer>('[1, 2, 3]', LList);
    except
      on E: ETJSonException do
        LRaised := True;
    end;

    try
      FJSonContext.ListFromJSon<TTestCustomer>(
        '[{"name":"A"}, 5, {"name":"B"}]', LList);
    except
      on E: ETJSonException do
        LDropped := True;
    end;
    LCount := LList.Count;
  finally
    LList.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'A body of [1, 2, 3] produced an empty list and no error at all: the '
    + 'four entity doors are closed and the list doors were not, so the '
    + 'caller was told 200 over nothing');
  Assert.IsTrue(
    LDropped,
    'and an array with one item that is not an object lost that item in '
    + 'silence. A body the deserializer cannot read is refused, not '
    + 'ignored - which is what the message beside it has said since it was '
    + 'written');
  Assert.AreEqual<Integer>(
    0,
    LCount,
    'and it is refused before anything is added: a check made inside the '
    + 'loop would have added A and then raised');
end;

procedure TTAbstractJSonTests.ABodyTheDeserializerCannotReadIsTheCallersFault;
var
  LWrongType: String;
  LBroken: String;
begin
  LWrongType := String.Empty;
  try
    FCreatedEntities.Add(
      FJSonContext.EntityFromJSon<TTestCustomer>('{"id":"abc"}'));
  except
    on E: ETJSonException do
      LWrongType := E.Message;
  end;

  LBroken := String.Empty;
  try
    FCreatedEntities.Add(
      FJSonContext.EntityFromJSon<TTestCustomer>('{"name":'));
  except
    on E: ETJSonException do
      LBroken := E.Message;
  end;

  Assert.IsTrue(
    LWrongType.Contains('"id"'),
    'A value the RTL cannot convert raised EJSONException or EConvertError, '
    + 'neither of them an ETJSonException, and the listener answered 500: '
    + 'the client was told the server was broken when the body was, which '
    + 'is the case the changelog says the 400 closed. The message names '
    + 'the field');
  Assert.IsFalse(
    LBroken.IsEmpty,
    'and JSON that does not parse, handed to the overloads that take a '
    + 'string, is refused the same way');
end;

procedure TTAbstractJSonTests.ALazyIdIsReadUnderTheKeyItIsWrittenWith;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LConfig: TTJSonSerializerConfig;
  LLoaded: TTestDoubleFLazyOrder;
  LJSon: String;
  LRestored: TTestDoubleFLazyOrder;
begin
  LConfig := TTJSonSerializerConfig.Create(0, False);

  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'DoubleF';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 12.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoaded := FJSonContext.Get<TTestDoubleFLazyOrder>(LOrder.ID);
  FCreatedEntities.Add(LLoaded);
  LJSon := FJSonContext.EntityToJSon<TTestDoubleFLazyOrder>(LLoaded, LConfig);

  LRestored := FJSonContext.EntityFromJSon<TTestDoubleFLazyOrder>(LJSon);
  FCreatedEntities.Add(LRestored);

  Assert.IsTrue(
    LJSon.Contains('"fCustomerID"'),
    'Precondition: FFCustomer is published as fCustomer, and its id as '
    + 'fCustomerID');
  Assert.AreEqual<Integer>(
    LCustomer.ID,
    LRestored.Customer.ID,
    'The deserializer used to fold the name a second time when it read the '
    + 'id, and a second fold of fCustomer strips the f again: it looked for '
    + 'customerID and ignored the id the client sent back under the key it '
    + 'had received. No member of the model had the shape F, F and a '
    + 'capital, so putting the second fold back left the suite green');
end;

procedure TTAbstractJSonTests.ADetailItemThatIsNotAnObjectLeavesTheDetail;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LLoaded: TTestLazyCustomer;
  LMessage: String;
begin
  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'DetailRefused';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FJSonContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FJSonContext.Insert<TTestOrder>(LOrder);

  LLoaded := FJSonContext.Get<TTestLazyCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LLoaded);
  Assert.AreEqual<Integer>(
    1,
    LLoaded.Orders.Count,
    'Precondition: the lazy list loads the one related order');

  LMessage := String.Empty;
  try
    FJSonContext.EntityFromJSon<TTestLazyCustomer>(
      '{"orders":[1]}', LLoaded);
  except
    on E: ETJSonException do
      LMessage := E.Message;
  end;

  Assert.IsTrue(
    LMessage.Contains('orders'),
    'An item of a detail array that is not an object is refused, naming '
    + 'the array: it used to be skipped, so {"orders":[1]} emptied the '
    + 'detail and answered 200');
  Assert.AreEqual<Integer>(
    1,
    LLoaded.Orders.Count,
    'and the check runs before PrepareList empties the list, so the '
    + 'refused body leaves the detail as it was');
end;

procedure TTAbstractJSonTests.MetadataToJSonNamesTheEntity;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestCustomer>();
  Assert.IsNotEmpty(LJson, 'MetadataToJSon must return non-empty JSON');
  Assert.IsTrue(
    LJson.Contains('"entity":"TestCustomer"'),
    'The payload names what it describes by the class, which is stable ' +
    'across a schema refactor, and no longer by the table, which was the ' +
    'one line in it that spoke of the database');
  Assert.IsTrue(
    LJson.Contains('"properties"'),
    'And the array holds mapped members reported with their JSON name, ' +
    'never the columns behind them, so it is called what it is');
end;

function TTAbstractJSonTests.PropertyFlag(
  const AJSon: String;
  const AName: String;
  const AFlag: String): Boolean;
var
  LRoot: TJSonValue;
  LItem: TJSonValue;
begin
  result := True;
  LRoot := TJSonObject.ParseJSONValue(AJSon);
  try
    for LItem in TJSonObject(LRoot).GetValue<TJSonArray>('properties') do
      if TJSonObject(LItem).GetValue<String>('name') = AName then
      begin
        result := TJSonObject(LItem).GetValue<Boolean>(AFlag, True);
        Break;
      end;
  finally
    LRoot.Free;
  end;
end;

procedure TTAbstractJSonTests.MetadataToJSonDeclaresTheDirectionOfAColumn;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestAsymmetricCustomer>();
  Assert.IsFalse(
    PropertyFlag(LJson, 'name', 'readable'),
    'A member the body may write and no response returns is part of the ' +
    'contract too - a password taken on create is the case from the ' +
    'manual - and it is described for the one direction it has');
  Assert.IsTrue(
    PropertyFlag(LJson, 'name', 'writable'),
    'and it keeps the direction it does have');
  Assert.IsFalse(
    PropertyFlag(LJson, 'email', 'writable'),
    'The other way round for a member that is returned and never read ' +
    'from the body');
  Assert.IsTrue(
    PropertyFlag(LJson, 'email', 'readable'),
    'and that one is readable. Asked of the whole document instead of the ' +
    'column, these four would not notice the two pairs being swapped');
end;

procedure TTAbstractJSonTests.DatasetToJSonContainsData;
var
  LCustomer: TTestCustomer;
  LDataset: TDataset;
  LJson: String;
begin
  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Acme Corp';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LDataset := FJSonContext.CreateDataset('SELECT * FROM Customers');
  try
    LJson := FJSonContext.DatasetToJSon(LDataset);
  finally
    LDataset.Free;
  end;

  Assert.IsNotEmpty(LJson, 'DatasetToJSon must return non-empty JSON');
  Assert.IsTrue(LJson.Contains('Acme Corp'),
    'Dataset JSON must contain customer name');
end;

procedure TTAbstractJSonTests.IdentityMapNotSupported;
var
  LContext: TTJSonContext;
  LRaised: Boolean;
begin
  LRaised := False;
  try
    LContext := TTJSonContext.Create(Connection, True);
    LContext.Free;
  except
    on E: ETJSonException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised,
    'TTJSonContext must raise when IdentityMap is True');
end;

{ Directional JSon attributes }

procedure TTAbstractJSonTests.IgnoreSerializeColumnIsNotInJSon;
var
  LCustomer: TTestAsymmetricCustomer;
  LConfig: TTJSonSerializerConfig;
  LJSon: String;
begin
  LConfig := TTJSonSerializerConfig.Create(-1, False);

  LCustomer := FJSonContext.CreateEntity<TTestAsymmetricCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'HiddenOnOutput';
  LCustomer.Email := 'visible@example.com';

  LJSon := FJSonContext.EntityToJSon<TTestAsymmetricCustomer>(
    LCustomer, LConfig);

  Assert.IsFalse(LJSon.Contains('HiddenOnOutput'),
    'TJSonIgnoreSerialize column must not be serialized');
  Assert.IsTrue(LJSon.Contains('visible@example.com'),
    'a column without TJSonIgnoreSerialize must still be serialized');
end;

procedure TTAbstractJSonTests.IgnoreDeserializeColumnIsNotReadFromJSon;
var
  LCustomer: TTestAsymmetricCustomer;
begin
  LCustomer := FJSonContext.EntityFromJSon<TTestAsymmetricCustomer>(
    '{"name": "FromBody", "email": "injected@example.com"}');
  FCreatedEntities.Add(LCustomer);

  Assert.AreEqual<String>('FromBody', LCustomer.Name,
    'a column without TJSonIgnoreDeserialize must be read from JSon');
  Assert.AreEqual<String>(String.Empty, LCustomer.Email,
    'TJSonIgnoreDeserialize column must not be read from JSon');
end;

{ Change tracking is not writable from JSon }

procedure TTAbstractJSonTests.ChangeTrackingIsNotReadFromJSon;
var
  LUser: TTestTrackedUser;
begin
  LUser := FJSonContext.EntityFromJSon<TTestTrackedUser>(
    '{"name": "Mallory", "createdBy": "forged"}');
  FCreatedEntities.Add(LUser);

  Assert.AreEqual<String>('Mallory', LUser.Name,
    'a plain column must be read from JSon');
  Assert.AreEqual<String>(String.Empty, LUser.CreatedBy,
    'change tracking columns must not be read from JSon');
end;

procedure TTAbstractJSonTests.UpdateDoesNotOverwriteCreatedBy;
var
  LUser: TTestTrackedUser;
  LFromJSon: TTestTrackedUser;
  LReloaded: TTestTrackedUser;
begin
  FJSonContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'alice';
    end;

  LUser := FJSonContext.CreateEntity<TTestTrackedUser>();
  FCreatedEntities.Add(LUser);
  LUser.Name := 'Original';
  FJSonContext.Insert<TTestTrackedUser>(LUser);

  LFromJSon := FJSonContext.EntityFromJSon<TTestTrackedUser>(Format(
    '{"id": %d, "name": "Renamed", "version": %d, "createdBy": "forged"}',
    [LUser.ID, LUser.Version]));
  FCreatedEntities.Add(LFromJSon);
  FJSonContext.Update<TTestTrackedUser>(LFromJSon);

  LReloaded := FJSonContext.Get<TTestTrackedUser>(LUser.ID);
  FCreatedEntities.Add(LReloaded);
  Assert.AreEqual<String>('Renamed', LReloaded.Name,
    'a plain column must be updated from JSon');
  Assert.AreEqual<String>('alice', LReloaded.CreatedBy,
    'Update must not overwrite CreatedBy with the value from JSon');
end;

procedure TTAbstractJSonTests.DeserializeOnLoadedEntityKeepsOtherColumns;
var
  LCustomer: TTestCustomer;
  LLoaded: TTestCustomer;
  LReloaded: TTestCustomer;
begin
  LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(LCustomer);
  LCustomer.Name := 'Original';
  LCustomer.Email := 'keep@example.com';
  FJSonContext.Insert<TTestCustomer>(LCustomer);

  LLoaded := FJSonContext.Get<TTestCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LLoaded);
  FJSonContext.EntityFromJSon<TTestCustomer>('{"name": "Renamed"}', LLoaded);

  Assert.AreEqual<String>('Renamed', LLoaded.Name,
    'the column present in JSon must be applied to the loaded entity');
  Assert.AreEqual<String>('keep@example.com', LLoaded.Email,
    'a plain column absent from JSon must keep its loaded value');

  FJSonContext.Update<TTestCustomer>(LLoaded);

  LReloaded := FJSonContext.Get<TTestCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LReloaded);
  Assert.AreEqual<String>('Renamed', LReloaded.Name,
    'the update must persist the column present in JSon');
  Assert.AreEqual<String>('keep@example.com', LReloaded.Email,
    'the update must not blank a plain column absent from JSon');
end;

procedure TTAbstractJSonTests.ADeleteOfAMissingRowIsNotFound;
var
  LContext: TTHttpContext;
  LRaised: Boolean;
begin
  LRaised := False;
  LContext := TTHttpContext.Create(Connection);
  try
    try
      LContext.Delete<TTestTask>(999999, 1);
    except
      on E: ETHttpNotFound do
        LRaised := True;
    end;
  finally
    LContext.Free;
  end;

  Assert.IsTrue(LRaised,
    'A row that is not there is not a concurrency conflict: 409 tells the ' +
    'client to reload and retry, and reloading will never produce it');
end;

procedure TTAbstractJSonTests.MetadataToJSonOmitsAHiddenKeyAndVersion;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestHiddenKeyCustomer>();
  Assert.IsTrue(
    LJson.Contains('"name":"name"'),
    'Precondition: a member that is serialized must be described');
  Assert.IsFalse(
    LJson.Contains('primaryKey'),
    'The filter that keeps a hidden member out of the properties was not ' +
    'applied to the two keys written above them, so a key an entity keeps ' +
    'out of every response was still named at the top of its own metadata');
  Assert.IsFalse(
    LJson.Contains('versionColumn'),
    'And the same for the version column');
end;

procedure TTAbstractJSonTests.MetadataToJSonOnAnEntityWithoutAVersionColumn;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestSimpleItem>();
  Assert.IsTrue(
    LJson.Contains('"name":"name"'),
    'A version column is optional - it is what TTUpdateMode.KeyOnly is ' +
    'for - and the metadata dereferenced it without asking whether it was ' +
    'there, so describing such an entity was an access violation');
  Assert.IsFalse(
    LJson.Contains('versionColumn'),
    'And there is nothing to name');
end;

procedure TTAbstractJSonTests.MetadataToJSonStillNamesAKeyTheBodyOnlyWrites;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestWriteOnlyKeyCustomer>();
  Assert.IsTrue(
    LJson.Contains('"readable":false'),
    'Precondition: the key is described, for the one direction it has');
  Assert.IsTrue(
    LJson.Contains('primaryKey'),
    'The array below asks whether a column is serialized or deserialized, ' +
    'and the two pairs above it asked only the first: a key the body may ' +
    'write appeared among the properties and stopped being named as the ' +
    'key, so a client knew the field and not what it was');
end;

procedure TTAbstractJSonTests.ABodyThatIsNotAnObjectIsRefused;
var
  LJSon: TJSonValue;
  LCustomer: TTestCustomer;
  LRaised: Boolean;
begin
  LJSon := TJSonObject.ParseJSONValue('[]');
  try
    LRaised := False;
    LCustomer := nil;
    try
      LCustomer := FJSonContext.EntityFromJSonObject<TTestCustomer>(LJSon);
    except
      on E: ETJSonException do
        LRaised := True;
    end;
    if Assigned(LCustomer) then
      FJSonContext.FreeEntity<TTestCustomer>(LCustomer);

    Assert.IsTrue(
      LRaised,
      'A body of [] is read for every column with GetValue, which answers ' +
      'nil on a root that is not an object, so a create built an entity ' +
      'with every field at its default and inserted it, and answered 200');

    LCustomer := FJSonContext.CreateEntity<TTestCustomer>();
    try
      LRaised := False;
      try
        FJSonContext.EntityFromJSonObject<TTestCustomer>(LJSon, LCustomer);
      except
        on E: ETJSonException do
          LRaised := True;
      end;

      Assert.IsTrue(
        LRaised,
        'and on the update path it is worse: no field is written, no error ' +
        'is raised, and the caller believes it has saved');
    finally
      FJSonContext.FreeEntity<TTestCustomer>(LCustomer);
    end;
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractJSonTests.MetadataToJSonDescribesAJoinEntity;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestOrderReport>();
  Assert.IsTrue(
    LJson.Contains('"name":"customerName"'),
    'The metadata of a join entity are keyed on the output alias of each ' +
    'column, and the description looked them up by the bare name: every ' +
    'lookup missed, so the contract of a join entity was an empty array');
  Assert.IsTrue(
    LJson.Contains('"name":"amount"'),
    'and the columns of the FROM table are keyed on an alias as well');
end;

end.
