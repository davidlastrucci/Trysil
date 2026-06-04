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
  Trysil.Generics.Collections,
  Trysil.Context,
  Trysil.Data,
  Trysil.JSon.Context,
  Trysil.JSon.Types,
  Trysil.JSon.Exceptions,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractJSonTests }

  TTAbstractJSonTests = class(TTAbstractBaseTests)
  strict protected
    FJSonContext: TTJSonContext;
    FCreatedEntities: TObjectList<TObject>;
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
    procedure EntityFromJSonPopulatesLazyList;

    [Test]
    procedure EntityFromJSonEmptyArrayDoesNotReloadFromDB;

    [Test]
    procedure ListToJSonReturnsValidArray;

    [Test]
    procedure ListFromJSonRoundTrip;

    [Test]
    procedure MetadataToJSonContainsTableName;

    [Test]
    procedure DatasetToJSonContainsData;

    [Test]
    procedure IdentityMapNotSupported;
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

procedure TTAbstractJSonTests.MetadataToJSonContainsTableName;
var
  LJson: String;
begin
  LJson := FJSonContext.MetadataToJSon<TTestCustomer>();
  Assert.IsNotEmpty(LJson, 'MetadataToJSon must return non-empty JSON');
  Assert.IsTrue(LJson.Contains('Customers'),
    'Metadata JSON must contain table name');
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

end.
