(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.HttpEntity;

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
  Trysil.Filter,
  Trysil.Http.Context,
  Trysil.Http.Exceptions,
  Trysil.Http.Filter,
  Trysil.Http.Entity,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractHttpEntityTests }

  TTAbstractHttpEntityTests = class(TTAbstractBaseTests)
  strict private
    FHttpContext: TTHttpContext;
    FCreatedEntities: TObjectList<TObject>;

    function InsertCustomer(const AName: String): TTestCustomer;
    function InsertLazyOrder: TTPrimaryKey;
    function ParseObject(const AJSon: String): TJSonObject;
    function CustomerExists(const AID: TTPrimaryKey): Boolean;
    function CustomerCount: Int64;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;

    [Test]
    procedure GetOfAMissingRowIsNotFound;

    [Test]
    procedure GetReturnsTheEntityAndCallsBeforeSerialize;

    [Test]
    procedure SelectCountsEveryRowAndReturnsOnlyThePage;

    [Test]
    procedure SelectAllHonoursTheLimitGivenToTheConstructor;

    [Test]
    procedure AddEntityFilterRestrictsTheRowsAndTheCount;

    [Test]
    procedure FindEmitsTheRelationAsAnIdOnly;

    [Test]
    procedure GetEmitsTheRelatedEntity;

    [Test]
    procedure InsertTakesTheIdFromTheSequence;

    [Test]
    procedure InsertCallsTheEventsInOrder;

    [Test]
    procedure AFailureInApplyDetailsRollsBackTheInsert;

    [Test]
    procedure UpdatePersistsAndCallsTheEventsInOrder;

    [Test]
    procedure UpdateAnswersWithTheCreationColumnsOfTheRow;

    [Test]
    procedure DeleteWithTheCurrentVersionRemovesTheRow;

    [Test]
    procedure DeleteWithAStaleVersionIsAConflict;

    [Test]
    procedure DeleteOfAMissingRowIsNotFound;

    [Test]
    procedure CreateNewAssignsAnIdWithoutInserting;
  end;

implementation

{ TTAbstractHttpEntityTests }

procedure TTAbstractHttpEntityTests.Setup;
begin
  ClearTables;
  FHttpContext := TTHttpContext.Create(Connection);
  FContext := FHttpContext;
  FCreatedEntities := TObjectList<TObject>.Create(True);
end;

procedure TTAbstractHttpEntityTests.TearDown;
begin
  FCreatedEntities.Free;
  inherited TearDown;
  FHttpContext := nil;
end;

function TTAbstractHttpEntityTests.InsertCustomer(
  const AName: String): TTestCustomer;
begin
  result := FHttpContext.CreateEntity<TTestCustomer>();
  FCreatedEntities.Add(result);
  result.Name := AName;
  result.Email := Format('%s@example.com', [AName.ToLower]);
  FHttpContext.Insert<TTestCustomer>(result);
end;

function TTAbstractHttpEntityTests.InsertLazyOrder: TTPrimaryKey;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
begin
  LCustomer := InsertCustomer('LazyParent');

  LOrder := FHttpContext.CreateEntity<TTestOrder>();
  FCreatedEntities.Add(LOrder);
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FHttpContext.Insert<TTestOrder>(LOrder);
  result := LOrder.ID;
end;

function TTAbstractHttpEntityTests.ParseObject(
  const AJSon: String): TJSonObject;
begin
  result := TJSonObject.ParseJSONValue(AJSon) as TJSonObject;
end;

function TTAbstractHttpEntityTests.CustomerExists(
  const AID: TTPrimaryKey): Boolean;
var
  LCustomer: TTestCustomer;
begin
  result := FHttpContext.TryGet<TTestCustomer>(AID, LCustomer);
  if result then
    FCreatedEntities.Add(LCustomer);
end;

function TTAbstractHttpEntityTests.CustomerCount: Int64;
begin
  result := FHttpContext.SelectCount<TTestCustomer>(TTFilter.Empty);
end;

procedure TTAbstractHttpEntityTests.GetOfAMissingRowIsNotFound;
var
  LReader: TTHttpEntityReader<TTestCustomer>;
  LRaised: Boolean;
begin
  LRaised := False;
  LReader := TTHttpEntityReader<TTestCustomer>.Create(FHttpContext);
  try
    try
      LReader.Get(999999);
    except
      on E: ETHttpNotFound do
        LRaised := True;
    end;
  finally
    LReader.Free;
  end;

  Assert.IsTrue(LRaised, 'A row that is not there must answer 404');
end;

procedure TTAbstractHttpEntityTests.GetReturnsTheEntityAndCallsBeforeSerialize;
var
  LCustomer: TTestCustomer;
  LReader: TTHttpEntityReader<TTestCustomer>;
  LCalls: Integer;
  LJSon: TJSonObject;
begin
  LCustomer := InsertCustomer('Alpha');

  LCalls := 0;
  LReader := TTHttpEntityReader<TTestCustomer>.Create(FHttpContext);
  try
    LReader.OnBeforeSerializeEntity :=
      procedure(const AEntity: TTestCustomer)
      begin
        Inc(LCalls);
      end;
    LJSon := ParseObject(LReader.Get(LCustomer.ID));
  finally
    LReader.Free;
  end;

  try
    Assert.AreEqual('Alpha', LJSon.GetValue<String>('name'));
  finally
    LJSon.Free;
  end;
  Assert.AreEqual<Integer>(1, LCalls,
    'OnBeforeSerializeEntity must run once for the entity it serializes');
end;

procedure TTAbstractHttpEntityTests.SelectCountsEveryRowAndReturnsOnlyThePage;
var
  LFilter: TJSonValue;
  LReader: TTHttpEntityReader<TTestCustomer>;
  LJSon: TJSonObject;
begin
  InsertCustomer('Alpha');
  InsertCustomer('Beta');
  InsertCustomer('Gamma');

  LFilter := TJSonObject.ParseJSONValue(
    '{"limit": 2, "orderBy": [{"columnName": "Name", "direction": "ASC"}]}');
  try
    LReader := TTHttpEntityReader<TTestCustomer>.Create(FHttpContext);
    try
      LJSon := ParseObject(LReader.Select(LFilter));
    finally
      LReader.Free;
    end;
  finally
    LFilter.Free;
  end;

  try
    Assert.AreEqual<Integer>(3, LJSon.GetValue<Integer>('count'),
      'count must report every row the filter matches, not the page');
    Assert.AreEqual<Integer>(2, LJSon.GetValue<TJSonArray>('data').Count,
      'data must carry only the page');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractHttpEntityTests.SelectAllHonoursTheLimitGivenToTheConstructor;
var
  LReader: TTHttpEntityReader<TTestCustomer>;
  LJSon: TJSonObject;
begin
  InsertCustomer('Alpha');
  InsertCustomer('Beta');
  InsertCustomer('Gamma');

  LReader := TTHttpEntityReader<TTestCustomer>.Create(
    FHttpContext, TTHttpFilterParameters.Create(2, 32, 8));
  try
    LJSon := ParseObject(LReader.SelectAll);
  finally
    LReader.Free;
  end;

  try
    Assert.AreEqual<Integer>(3, LJSon.GetValue<Integer>('count'));
    Assert.AreEqual<Integer>(2, LJSon.GetValue<TJSonArray>('data').Count,
      'SelectAll must stop at the MaxLimit given to the constructor');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractHttpEntityTests.AddEntityFilterRestrictsTheRowsAndTheCount;
var
  LBeta: TTestCustomer;
  LReader: TTHttpEntityReader<TTestCustomer>;
  LJSon: TJSonObject;
  LData: TJSonArray;
begin
  InsertCustomer('Alpha');
  LBeta := InsertCustomer('Beta');
  InsertCustomer('Gamma');

  LReader := TTHttpEntityReader<TTestCustomer>.Create(FHttpContext);
  try
    LReader.OnAddEntityFilter :=
      procedure(var AFilter: TTFilter)
      begin
        AFilter.AddWhere('ID = :ownID');
        AFilter.AddParameter('ownID', ftInteger, LBeta.ID);
      end;
    LJSon := ParseObject(LReader.SelectAll);
  finally
    LReader.Free;
  end;

  try
    Assert.AreEqual<Integer>(1, LJSon.GetValue<Integer>('count'),
      'count must go through the same filter as the rows');
    LData := LJSon.GetValue<TJSonArray>('data');
    Assert.AreEqual<Integer>(1, LData.Count);
    Assert.AreEqual('Beta', LData.Items[0].GetValue<String>('name'));
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractHttpEntityTests.FindEmitsTheRelationAsAnIdOnly;
var
  LOrderID: TTPrimaryKey;
  LReader: TTHttpEntityReader<TTestLazyOrder>;
  LJSon: TJSonObject;
begin
  LOrderID := InsertLazyOrder;

  LReader := TTHttpEntityReader<TTestLazyOrder>.Create(FHttpContext);
  try
    LJSon := ParseObject(LReader.Find(LOrderID));
  finally
    LReader.Free;
  end;

  try
    Assert.IsTrue(LJSon.GetValue('customerID') <> nil,
      'Find must still emit the foreign key');
    Assert.IsTrue(LJSon.GetValue('customer') = nil,
      'Find must not emit the related entity');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractHttpEntityTests.GetEmitsTheRelatedEntity;
var
  LOrderID: TTPrimaryKey;
  LReader: TTHttpEntityReader<TTestLazyOrder>;
  LJSon: TJSonObject;
  LNested: TJSonValue;
begin
  LOrderID := InsertLazyOrder;

  LReader := TTHttpEntityReader<TTestLazyOrder>.Create(FHttpContext);
  try
    LJSon := ParseObject(LReader.Get(LOrderID));
  finally
    LReader.Free;
  end;

  try
    LNested := LJSon.GetValue('customer');
    Assert.IsTrue(LNested is TJSonObject,
      'Get must emit the related entity');
    Assert.AreEqual(
      'LazyParent', TJSonObject(LNested).GetValue<String>('name'));
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractHttpEntityTests.InsertTakesTheIdFromTheSequence;
var
  LBody: TJSonValue;
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LJSon: TJSonObject;
  LID: TTPrimaryKey;
begin
  LBody := TJSonObject.ParseJSONValue(
    '{"name": "Alpha", "email": "alpha@example.com"}');
  try
    LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
    try
      LJSon := ParseObject(LWriter.Insert(LBody));
    finally
      LWriter.Free;
    end;
  finally
    LBody.Free;
  end;

  try
    LID := LJSon.GetValue<Integer>('id');
  finally
    LJSon.Free;
  end;

  Assert.IsTrue(LID > 0,
    'A body without an id must get one from the sequence');
  Assert.IsTrue(CustomerExists(LID), 'The inserted row must be there');
end;

procedure TTAbstractHttpEntityTests.InsertCallsTheEventsInOrder;
var
  LEvents: TList<String>;
  LBody: TJSonValue;
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LOrder: String;
begin
  LEvents := TList<String>.Create;
  try
    LBody := TJSonObject.ParseJSONValue(
      '{"name": "Alpha", "email": "alpha@example.com"}');
    try
      LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
      try
        LWriter.OnBeforeInsert :=
          procedure(const AEntity: TTestCustomer)
          begin
            LEvents.Add('BeforeInsert');
          end;
        LWriter.OnApplyDetails :=
          procedure(const AEntity: TTestCustomer)
          begin
            LEvents.Add('ApplyDetails');
          end;
        LWriter.OnAfterInsert :=
          procedure(const AEntity: TTestCustomer)
          begin
            LEvents.Add('AfterInsert');
          end;
        LWriter.Insert(LBody);
      finally
        LWriter.Free;
      end;
    finally
      LBody.Free;
    end;
    LOrder := String.Join(',', LEvents.ToArray);
  finally
    LEvents.Free;
  end;

  Assert.AreEqual('BeforeInsert,ApplyDetails,AfterInsert', LOrder);
end;

procedure TTAbstractHttpEntityTests.AFailureInApplyDetailsRollsBackTheInsert;
var
  LBody: TJSonValue;
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LRaised: Boolean;
begin
  LRaised := False;
  LBody := TJSonObject.ParseJSONValue(
    '{"name": "Alpha", "email": "alpha@example.com"}');
  try
    LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
    try
      LWriter.OnApplyDetails :=
        procedure(const AEntity: TTestCustomer)
        begin
          raise Exception.Create('Details failed');
        end;
      try
        LWriter.Insert(LBody);
      except
        on E: Exception do
          LRaised := True;
      end;
    finally
      LWriter.Free;
    end;
  finally
    LBody.Free;
  end;

  Assert.IsTrue(LRaised, 'The failure in ApplyDetails must reach the caller');
  Assert.AreEqual<Int64>(0, CustomerCount,
    'The master row must be rolled back with its details');
end;

procedure TTAbstractHttpEntityTests.UpdatePersistsAndCallsTheEventsInOrder;
var
  LCustomer: TTestCustomer;
  LEvents: TList<String>;
  LBody: TJSonValue;
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LOrder: String;
  LReloaded: TTestCustomer;
begin
  LCustomer := InsertCustomer('Alpha');

  LEvents := TList<String>.Create;
  try
    LBody := TJSonObject.ParseJSONValue(Format(
      '{"id": %d, "name": "Renamed", "email": "alpha@example.com", ' +
      '"version": %d}', [LCustomer.ID, LCustomer.Version]));
    try
      LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
      try
        LWriter.OnBeforeUpdate :=
          procedure(const AEntity: TTestCustomer)
          begin
            LEvents.Add('BeforeUpdate');
          end;
        LWriter.OnApplyDetails :=
          procedure(const AEntity: TTestCustomer)
          begin
            LEvents.Add('ApplyDetails');
          end;
        LWriter.OnAfterUpdate :=
          procedure(const AEntity: TTestCustomer)
          begin
            LEvents.Add('AfterUpdate');
          end;
        LWriter.Update(LBody);
      finally
        LWriter.Free;
      end;
    finally
      LBody.Free;
    end;
    LOrder := String.Join(',', LEvents.ToArray);
  finally
    LEvents.Free;
  end;

  Assert.AreEqual('BeforeUpdate,ApplyDetails,AfterUpdate', LOrder);

  LReloaded := FHttpContext.Get<TTestCustomer>(LCustomer.ID);
  FCreatedEntities.Add(LReloaded);
  Assert.AreEqual('Renamed', LReloaded.Name);
end;

procedure TTAbstractHttpEntityTests.UpdateAnswersWithTheCreationColumnsOfTheRow;
var
  LUser: TTestTrackedUser;
  LBody: TJSonValue;
  LWriter: TTHttpEntityWriter<TTestTrackedUser>;
  LJSon: TJSonObject;
begin
  FHttpContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'creator';
    end;

  LUser := FHttpContext.CreateEntity<TTestTrackedUser>();
  FCreatedEntities.Add(LUser);
  LUser.Name := 'Alpha';
  FHttpContext.Insert<TTestTrackedUser>(LUser);

  LBody := TJSonObject.ParseJSONValue(Format(
    '{"id": %d, "name": "Renamed", "version": %d}',
    [LUser.ID, LUser.Version]));
  try
    LWriter := TTHttpEntityWriter<TTestTrackedUser>.Create(FHttpContext);
    try
      LJSon := ParseObject(LWriter.Update(LBody));
    finally
      LWriter.Free;
    end;
  finally
    LBody.Free;
  end;

  try
    Assert.AreEqual('creator', LJSon.GetValue<String>('createdBy'),
      'The body does not carry the creation columns: the answer must ' +
      'come from the row, not from the entity built out of the body');
  finally
    LJSon.Free;
  end;
end;

procedure TTAbstractHttpEntityTests.DeleteWithTheCurrentVersionRemovesTheRow;
var
  LCustomer: TTestCustomer;
  LEvents: TList<String>;
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LOrder: String;
begin
  LCustomer := InsertCustomer('Alpha');

  LEvents := TList<String>.Create;
  try
    LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
    try
      LWriter.OnBeforeDelete :=
        procedure(const AEntity: TTestCustomer)
        begin
          LEvents.Add('BeforeDelete');
        end;
      LWriter.OnAfterDelete :=
        procedure(const AEntity: TTestCustomer)
        begin
          LEvents.Add('AfterDelete');
        end;
      LWriter.Delete(LCustomer.ID, LCustomer.Version);
    finally
      LWriter.Free;
    end;
    LOrder := String.Join(',', LEvents.ToArray);
  finally
    LEvents.Free;
  end;

  Assert.AreEqual('BeforeDelete,AfterDelete', LOrder);
  Assert.IsFalse(CustomerExists(LCustomer.ID), 'The row must be gone');
end;

procedure TTAbstractHttpEntityTests.DeleteWithAStaleVersionIsAConflict;
var
  LCustomer: TTestCustomer;
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LRaised: Boolean;
begin
  LCustomer := InsertCustomer('Alpha');

  LRaised := False;
  LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
  try
    try
      LWriter.Delete(LCustomer.ID, LCustomer.Version + 1);
    except
      on E: ETConcurrentUpdateException do
        LRaised := True;
    end;
  finally
    LWriter.Free;
  end;

  Assert.IsTrue(LRaised,
    'A version the row does not have must answer 409');
  Assert.IsTrue(CustomerExists(LCustomer.ID),
    'A refused delete must leave the row where it was');
end;

procedure TTAbstractHttpEntityTests.DeleteOfAMissingRowIsNotFound;
var
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LRaised: Boolean;
begin
  LRaised := False;
  LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
  try
    try
      LWriter.Delete(999999, 1);
    except
      on E: ETHttpNotFound do
        LRaised := True;
    end;
  finally
    LWriter.Free;
  end;

  Assert.IsTrue(LRaised,
    'A row that is not there is not a concurrency conflict: it is a 404');
end;

procedure TTAbstractHttpEntityTests.CreateNewAssignsAnIdWithoutInserting;
var
  LWriter: TTHttpEntityWriter<TTestCustomer>;
  LJSon: TJSonObject;
  LID: TTPrimaryKey;
begin
  LWriter := TTHttpEntityWriter<TTestCustomer>.Create(FHttpContext);
  try
    LJSon := ParseObject(LWriter.CreateNew);
  finally
    LWriter.Free;
  end;

  try
    LID := LJSon.GetValue<Integer>('id');
  finally
    LJSon.Free;
  end;

  Assert.IsTrue(LID > 0, 'CreateNew must hand out an id');
  Assert.AreEqual<Int64>(0, CustomerCount, 'CreateNew must not insert');
end;

end.
