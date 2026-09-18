(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Join;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Filter,
  Trysil.Context,
  Trysil.Lazy,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractJoinTests }

  TTAbstractJoinTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure JoinSelectAllPopulatesJoinedFields;

    [Test]
    procedure JoinSelectAllReturnsMultipleRows;

    [Test]
    procedure JoinSelectWithFilterReturnsMatchingRows;

    [Test]
    procedure JoinInsertRaisesException;

    [Test]
    procedure JoinUpdateRaisesException;

    [Test]
    procedure JoinDeleteRaisesException;

    [Test]
    procedure JoinIdentityMapIsSkipped;

    [Test]
    procedure JoinGetByKeyQualifiesTheKey;

    [Test]
    procedure LeftJoinReturnsRowWithNullJoinedFields;

    [Test]
    procedure LeftJoinReturnsBothMatchedAndUnmatchedRows;

    [Test]
    procedure ChainJoinPopulatesAllJoinedFields;

    [Test]
    procedure ChainJoinExcludesRowsWhenChainBreaks;

    [Test]
    procedure RawSelectMapsColumnsToDto;

    [Test]
    procedure RawSelectWithGroupByReturnsAggregation;

    [Test]
    procedure RawSelectOnEmptyResultReturnsEmptyList;

    [Test]
    procedure RawSelectWithHavingFiltersAggregation;

    [Test]
    procedure RawSelectWithSubqueryReturnsResults;

    [Test]
    procedure AJoinListOwnsWhatTheIdentityMapDoesNot;

    [Test]
    procedure AJoinEntityCreatedByHandIsFreedOnce;

    [Test]
    procedure ALazyOnAJoinEntityKeepsACloneOfItsOwn;
  end;

implementation

{ TTAbstractJoinTests }

procedure TTAbstractJoinTests.JoinSelectAllPopulatesJoinedFields;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestOrderReport>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Acme Corp';
  LCustomer.Email := 'acme@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 100.50;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestOrderReport>.Create(True);
  try
    FContext.SelectAll<TTestOrderReport>(LList);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Acme Corp', LList[0].CustomerName);
    Assert.AreEqual('acme@example.com', LList[0].CustomerEmail);
    Assert.IsTrue(Abs(LList[0].Amount - 100.50) < 0.01,
      'Amount must match inserted value');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinSelectAllReturnsMultipleRows;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestOrderReport>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Customer A';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 20.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestOrderReport>.Create(True);
  try
    FContext.SelectAll<TTestOrderReport>(LList);
    Assert.AreEqual<Integer>(2, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinSelectWithFilterReturnsMatchingRows;
var
  LCustomerA: TTestCustomer;
  LCustomerB: TTestCustomer;
  LOrder: TTestOrder;
  LFilter: TTFilter;
  LList: TTObjectList<TTestOrderReport>;
begin
  LCustomerA := FContext.CreateEntity<TTestCustomer>();
  LCustomerA.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomerA);

  LCustomerB := FContext.CreateEntity<TTestCustomer>();
  LCustomerB.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomerB);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerB.ID;
  LOrder.Amount := 75.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFilter := TTFilter.Create(
    Format('Orders.CustomerID = %d', [LCustomerA.ID]));

  LList := TTObjectList<TTestOrderReport>.Create(True);
  try
    FContext.Select<TTestOrderReport>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Alpha', LList[0].CustomerName);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinInsertRaisesException;
var
  LReport: TTestOrderReport;
  LRaised: Boolean;
begin
  LReport := TTestOrderReport.Create;
  try
    LRaised := False;
    try
      FContext.Insert<TTestOrderReport>(LReport);
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised,
      'Insert on a join entity must raise ETException');
  finally
    LReport.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinUpdateRaisesException;
var
  LReport: TTestOrderReport;
  LRaised: Boolean;
begin
  LReport := TTestOrderReport.Create;
  try
    LRaised := False;
    try
      FContext.Update<TTestOrderReport>(LReport);
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised,
      'Update on a join entity must raise ETException');
  finally
    LReport.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinDeleteRaisesException;
var
  LReport: TTestOrderReport;
  LRaised: Boolean;
begin
  LReport := TTestOrderReport.Create;
  try
    LRaised := False;
    try
      FContext.Delete<TTestOrderReport>(LReport);
    except
      on E: ETException do
        LRaised := True;
    end;
    Assert.IsTrue(LRaised,
      'Delete on a join entity must raise ETException');
  finally
    LReport.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinIdentityMapIsSkipped;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LFirstList: TTObjectList<TTestOrderReport>;
  LSecondList: TTObjectList<TTestOrderReport>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'UniqueCustomer';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 42.0;
  FContext.Insert<TTestOrder>(LOrder);

  LFirstList := TTObjectList<TTestOrderReport>.Create(True);
  try
    FContext.SelectAll<TTestOrderReport>(LFirstList);
    Assert.AreEqual<Integer>(1, LFirstList.Count);

    LSecondList := TTObjectList<TTestOrderReport>.Create(True);
    try
      FContext.SelectAll<TTestOrderReport>(LSecondList);
      Assert.AreEqual<Integer>(1, LSecondList.Count);
      Assert.AreNotSame(LFirstList[0], LSecondList[0],
        'Join entities must not be cached in identity map');
    finally
      LSecondList.Free;
    end;
  finally
    LFirstList.Free;
  end;
end;

procedure TTAbstractJoinTests.LeftJoinReturnsRowWithNullJoinedFields;
var
  LOrder: TTestOrder;
  LList: TTObjectList<TTestLeftJoinOrderReport>;
begin
  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := 999;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestLeftJoinOrderReport>.Create(True);
  try
    FContext.SelectAll<TTestLeftJoinOrderReport>(LList);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('', LList[0].CustomerName,
      'LEFT JOIN with no match must return empty string');
    Assert.IsTrue(Abs(LList[0].Amount - 50.0) < 0.01,
      'Amount must match inserted value');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.LeftJoinReturnsBothMatchedAndUnmatchedRows;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestLeftJoinOrderReport>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Acme Corp';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := 999;
  LOrder.Amount := 200.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestLeftJoinOrderReport>.Create(True);
  try
    FContext.SelectAll<TTestLeftJoinOrderReport>(LList);
    Assert.AreEqual<Integer>(2, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.ChainJoinPopulatesAllJoinedFields;
var
  LCountry: TTestCountry;
  LCustomer: TTestCustomerWithCountry;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestChainJoinOrder>;
begin
  LCountry := FContext.CreateEntity<TTestCountry>();
  LCountry.Name := 'Italy';
  FContext.Insert<TTestCountry>(LCountry);

  LCustomer := FContext.CreateEntity<TTestCustomerWithCountry>();
  LCustomer.Name := 'Acme Corp';
  LCustomer.CountryID := LCountry.ID;
  FContext.Insert<TTestCustomerWithCountry>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 150.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestChainJoinOrder>.Create(True);
  try
    FContext.SelectAll<TTestChainJoinOrder>(LList);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Acme Corp', LList[0].CustomerName);
    Assert.AreEqual('Italy', LList[0].CountryName);
    Assert.IsTrue(Abs(LList[0].Amount - 150.0) < 0.01,
      'Amount must match inserted value');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.ChainJoinExcludesRowsWhenChainBreaks;
var
  LCountry: TTestCountry;
  LCustomerWithCountry: TTestCustomerWithCountry;
  LCustomerNoCountry: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestChainJoinOrder>;
begin
  LCountry := FContext.CreateEntity<TTestCountry>();
  LCountry.Name := 'Italy';
  FContext.Insert<TTestCountry>(LCountry);

  LCustomerWithCountry := FContext.CreateEntity<TTestCustomerWithCountry>();
  LCustomerWithCountry.Name := 'Acme Corp';
  LCustomerWithCountry.CountryID := LCountry.ID;
  FContext.Insert<TTestCustomerWithCountry>(LCustomerWithCountry);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerWithCountry.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LCustomerNoCountry := FContext.CreateEntity<TTestCustomer>();
  LCustomerNoCountry.Name := 'Beta Inc';
  FContext.Insert<TTestCustomer>(LCustomerNoCountry);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerNoCountry.ID;
  LOrder.Amount := 200.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestChainJoinOrder>.Create(True);
  try
    FContext.SelectAll<TTestChainJoinOrder>(LList);
    Assert.AreEqual<Integer>(1, LList.Count,
      'Only the order with a complete chain must be returned');
    Assert.AreEqual('Acme Corp', LList[0].CustomerName);
    Assert.AreEqual('Italy', LList[0].CountryName);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.RawSelectMapsColumnsToDto;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestOrderSummary>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'RawCorp';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 200.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestOrderSummary>.Create(True);
  try
    FContext.RawSelect<TTestOrderSummary>(
      'SELECT c.Name AS CustomerName, ' +
      'COUNT(o.ID) AS OrderCount, ' +
      'SUM(o.Amount) AS TotalAmount ' +
      'FROM Orders o ' +
      'INNER JOIN Customers c ON o.CustomerID = c.ID ' +
      'GROUP BY c.Name',
      LList);

    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('RawCorp', LList[0].CustomerName);
    Assert.AreEqual<Integer>(1, LList[0].OrderCount);
    Assert.IsTrue(Abs(LList[0].TotalAmount - 200.0) < 0.01,
      'TotalAmount must match');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.RawSelectWithGroupByReturnsAggregation;
var
  LCustomerA: TTestCustomer;
  LCustomerB: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestOrderSummary>;
begin
  LCustomerA := FContext.CreateEntity<TTestCustomer>();
  LCustomerA.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomerA);

  LCustomerB := FContext.CreateEntity<TTestCustomer>();
  LCustomerB.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomerB);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 30.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerB.ID;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestOrderSummary>.Create(True);
  try
    FContext.RawSelect<TTestOrderSummary>(
      'SELECT c.Name AS CustomerName, ' +
      'COUNT(o.ID) AS OrderCount, ' +
      'SUM(o.Amount) AS TotalAmount ' +
      'FROM Orders o ' +
      'INNER JOIN Customers c ON o.CustomerID = c.ID ' +
      'GROUP BY c.Name ' +
      'ORDER BY c.Name',
      LList);

    Assert.AreEqual<Integer>(2, LList.Count);

    Assert.AreEqual('Alpha', LList[0].CustomerName);
    Assert.AreEqual<Integer>(2, LList[0].OrderCount);
    Assert.IsTrue(Abs(LList[0].TotalAmount - 40.0) < 0.01,
      'Alpha total must be 40');

    Assert.AreEqual('Beta', LList[1].CustomerName);
    Assert.AreEqual<Integer>(1, LList[1].OrderCount);
    Assert.IsTrue(Abs(LList[1].TotalAmount - 50.0) < 0.01,
      'Beta total must be 50');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.RawSelectOnEmptyResultReturnsEmptyList;
var
  LList: TTObjectList<TTestOrderSummary>;
begin
  LList := TTObjectList<TTestOrderSummary>.Create(True);
  try
    FContext.RawSelect<TTestOrderSummary>(
      'SELECT c.Name AS CustomerName, ' +
      'COUNT(o.ID) AS OrderCount, ' +
      'SUM(o.Amount) AS TotalAmount ' +
      'FROM Orders o ' +
      'INNER JOIN Customers c ON o.CustomerID = c.ID ' +
      'GROUP BY c.Name',
      LList);

    Assert.AreEqual<Integer>(0, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.RawSelectWithHavingFiltersAggregation;
var
  LCustomerA: TTestCustomer;
  LCustomerB: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestOrderSummary>;
begin
  LCustomerA := FContext.CreateEntity<TTestCustomer>();
  LCustomerA.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomerA);

  LCustomerB := FContext.CreateEntity<TTestCustomer>();
  LCustomerB.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomerB);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 20.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerB.ID;
  LOrder.Amount := 5.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestOrderSummary>.Create(True);
  try
    FContext.RawSelect<TTestOrderSummary>(
      'SELECT c.Name AS CustomerName, ' +
      'COUNT(o.ID) AS OrderCount, ' +
      'SUM(o.Amount) AS TotalAmount ' +
      'FROM Orders o ' +
      'INNER JOIN Customers c ON o.CustomerID = c.ID ' +
      'GROUP BY c.Name ' +
      'HAVING COUNT(o.ID) > 1',
      LList);

    Assert.AreEqual<Integer>(1, LList.Count,
      'HAVING must filter out customers with only 1 order');
    Assert.AreEqual('Alpha', LList[0].CustomerName);
    Assert.AreEqual<Integer>(2, LList[0].OrderCount);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.RawSelectWithSubqueryReturnsResults;
var
  LCustomerA: TTestCustomer;
  LCustomerB: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTObjectList<TTestOrderSummary>;
begin
  LCustomerA := FContext.CreateEntity<TTestCustomer>();
  LCustomerA.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomerA);

  LCustomerB := FContext.CreateEntity<TTestCustomer>();
  LCustomerB.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomerB);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomerA.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := TTObjectList<TTestOrderSummary>.Create(True);
  try
    FContext.RawSelect<TTestOrderSummary>(
      'SELECT c.Name AS CustomerName, ' +
      '0 AS OrderCount, ' +
      '0.0 AS TotalAmount ' +
      'FROM Customers c ' +
      'WHERE c.ID IN (SELECT o.CustomerID FROM Orders o)',
      LList);

    Assert.AreEqual<Integer>(1, LList.Count,
      'Subquery must return only customers with orders');
    Assert.AreEqual('Alpha', LList[0].CustomerName);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractJoinTests.JoinGetByKeyQualifiesTheKey;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LReport: TTestOrderReport;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Ambiguous';
  LCustomer.Email := 'ambiguous@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 12.5;
  FContext.Insert<TTestOrder>(LOrder);

  LReport := FContext.Get<TTestOrderReport>(LOrder.ID);
  try
    Assert.IsNotNull(
      LReport,
      'Both joined tables have an ID, so a WHERE that names the key without ' +
      'its table is ambiguous on every engine. Writes on a join entity are ' +
      'refused by CheckReadWrite, reads by key were not');
    Assert.AreEqual('Ambiguous', LReport.CustomerName);
  finally
    FContext.FreeEntity<TTestOrderReport>(LReport);
  end;
end;

procedure TTAbstractJoinTests.AJoinListOwnsWhatTheIdentityMapDoesNot;
var
  LCustomer: TTestCustomer;
  LOrder: TTestOrder;
  LList: TTList<TTestOwnedOrderReport>;
  LCount: Integer;
begin
  Assert.IsTrue(
    FContext.UseIdentityMap,
    'Precondition: the identity map is on, which is what TTContext.Create ' +
    'gives you when you do not ask');

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'OwnedByTheList';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 7.0;
  FContext.Insert<TTestOrder>(LOrder);

  LList := FContext.CreateEntityList<TTestOwnedOrderReport>();
  try
    FContext.SelectAll<TTestOwnedOrderReport>(LList);
    LCount := LList.Count;
    Assert.AreEqual<Integer>(1, LCount, 'Precondition: the join returns a row');
    TTestOwnedOrderReport.ResetDestroyedCount;
  finally
    LList.Free;
  end;

  Assert.AreEqual<Integer>(
    LCount,
    TTestOwnedOrderReport.DestroyedCount,
    'The identity map never registers a join entity, so the list that ' +
    'carries it has to own it: with the map on nobody was freeing these');
end;

procedure TTAbstractJoinTests.AJoinEntityCreatedByHandIsFreedOnce;
var
  LContext: TTContext;
  LReport: TTestOwnedOrderReport;
begin
  LContext := TTContext.Create(Connection);
  try
    Assert.IsTrue(
      LContext.UseIdentityMap,
      'Precondition: the identity map is on, which is the default');

    LReport := LContext.CreateEntity<TTestOwnedOrderReport>();
    TTestOwnedOrderReport.ResetDestroyedCount;
    LContext.FreeEntity<TTestOwnedOrderReport>(LReport);

    Assert.AreEqual<Integer>(
      1,
      TTestOwnedOrderReport.DestroyedCount,
      'FreeEntity owns a join entity, because the map never registers one');
  finally
    LContext.Free;
  end;

  Assert.AreEqual<Integer>(
    1,
    TTestOwnedOrderReport.DestroyedCount,
    'and the context must not release it a second time: CreateEntity was ' +
    'the one registration that did not ask about joins, so the map held ' +
    'what the caller had already been told to free');
end;

procedure TTAbstractJoinTests.ALazyOnAJoinEntityKeepsACloneOfItsOwn;
var
  LContext: TTContext;
  LReport: TTestOwnedOrderReport;
  LLazy: TTLazy<TTestOwnedOrderReport>;
  LSame: Boolean;
begin
  LContext := TTContext.Create(Connection);
  try
    LReport := LContext.CreateEntity<TTestOwnedOrderReport>();
    LLazy := TTLazy<TTestOwnedOrderReport>.Create(LContext, 'ID');
    try
      LLazy.Entity := LReport;
      LSame := LLazy.Entity = LReport;
    finally
      LLazy.Free;
    end;

    if not LSame then
      LContext.FreeEntity<TTestOwnedOrderReport>(LReport);

    Assert.IsFalse(
      LSame,
      'A lazy reference keeps the instance it was given only when the ' +
      'identity map owns it, and the map never registers a join entity: ' +
      'keeping it meant the lazy released, on its own destruction, an ' +
      'object the caller had made and still held');
  finally
    LContext.Free;
  end;
end;

end.
