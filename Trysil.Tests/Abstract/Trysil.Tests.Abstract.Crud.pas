(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Crud;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Filter,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractCrudTests }

  TTAbstractCrudTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure SelectAllOnEmptyTableReturnsEmptyList;

    [Test]
    procedure InsertAssignsGeneratedId;

    [Test]
    procedure InsertThenGetReturnsSameValues;

    [Test]
    procedure SelectAllReturnsAllInsertedRows;

    [Test]
    procedure SelectCountMatchesRowCount;

    [Test]
    procedure UpdateChangesColumnAndIncrementsVersion;

    [Test]
    procedure HardDeleteRemovesRow;

    [Test]
    procedure SoftDeleteKeepsRowButExcludesItFromSelectAll;

    [Test]
    procedure IncludeDeletedReturnsSoftDeletedRows;

    [Test]
    procedure FilterBuilderFiltersBySingleCondition;

    [Test]
    procedure PagingLimitsResultCount;

    [Test]
    procedure UpdateWithStaleVersionRaisesConcurrentUpdateException;

    [Test]
    procedure DeleteWithStaleVersionRaisesConcurrentUpdateException;

    { ApplyAll }

    [Test]
    procedure ApplyAllExecutesAllOperationsInTransaction;

    [Test]
    procedure ApplyAllRollsBackOnFailure;

    { Save / SaveAll }

    [Test]
    procedure SaveInsertsNewEntity;

    [Test]
    procedure SaveUpdatesExistingEntity;

    [Test]
    procedure SaveAllMixedInsertAndUpdate;

    { TryGet }

    [Test]
    procedure TryGetReturnsTrueWhenFound;

    [Test]
    procedure TryGetReturnsFalseWhenNotFound;

    { Refresh / OldEntity }

    [Test]
    procedure RefreshReloadsEntityFromDatabase;

    [Test]
    procedure OldEntityReturnsPersistedState;

    { WhereClause }

    [Test]
    procedure WhereClauseFiltersSelectAll;

    [Test]
    procedure WhereClauseFiltersSelectCount;

    { FilterBuilder advanced }

    [Test]
    procedure FilterAndWhereNarrowsResults;

    [Test]
    procedure FilterOrWhereWidensResults;

    [Test]
    procedure FilterNotEqualExcludesMatch;

    [Test]
    procedure FilterGreaterReturnsAboveThreshold;

    [Test]
    procedure FilterLessReturnsBelowThreshold;

    [Test]
    procedure FilterGreaterOrEqualIncludesBoundary;

    [Test]
    procedure FilterLessOrEqualIncludesBoundary;

    [Test]
    procedure FilterLikeMatchesPattern;

    [Test]
    procedure FilterNotLikeExcludesPattern;

    [Test]
    procedure FilterIsNullReturnsNullRows;

    [Test]
    procedure FilterIsNotNullExcludesNullRows;

    [Test]
    procedure FilterOrderByDescReversesSortOrder;

    { Concurrent update }

    [Test]
    procedure ConcurrentUpdateWithTwoContextsRaisesOnSecond;

    { FilterBuilder And/Or combination }

    [Test]
    procedure FilterAndOrCombinationRespectsOperatorPrecedence;
  end;

implementation

{ TTAbstractCrudTests }

procedure TTAbstractCrudTests.SelectAllOnEmptyTableReturnsEmptyList;
var
  LList: TTList<TTestCustomer>;
begin
  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    Assert.AreEqual<Integer>(0, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.InsertAssignsGeneratedId;
var
  LCustomer: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alice';
  LCustomer.Email := 'alice@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);
  Assert.IsTrue(LCustomer.ID > 0, 'ID should be assigned after insert');
end;

procedure TTAbstractCrudTests.InsertThenGetReturnsSameValues;
var
  LInserted: TTestCustomer;
  LLoaded: TTestCustomer;
begin
  LInserted := FContext.CreateEntity<TTestCustomer>();
  LInserted.Name := 'Bob';
  LInserted.Email := 'bob@example.com';
  FContext.Insert<TTestCustomer>(LInserted);

  LLoaded := FContext.Get<TTestCustomer>(LInserted.ID);
  Assert.IsNotNull(LLoaded);
  Assert.AreEqual('Bob', LLoaded.Name);
  Assert.AreEqual('bob@example.com', LLoaded.Email);
end;

procedure TTAbstractCrudTests.SelectAllReturnsAllInsertedRows;
var
  LFirst: TTestCustomer;
  LSecond: TTestCustomer;
  LThird: TTestCustomer;
  LList: TTList<TTestCustomer>;
begin
  LFirst := FContext.CreateEntity<TTestCustomer>();
  LFirst.Name := 'One';
  FContext.Insert<TTestCustomer>(LFirst);

  LSecond := FContext.CreateEntity<TTestCustomer>();
  LSecond.Name := 'Two';
  FContext.Insert<TTestCustomer>(LSecond);

  LThird := FContext.CreateEntity<TTestCustomer>();
  LThird.Name := 'Three';
  FContext.Insert<TTestCustomer>(LThird);

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    Assert.AreEqual<Integer>(3, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.SelectCountMatchesRowCount;
var
  LCustomer: TTestCustomer;
  LIndex: Integer;
  LCount: Integer;
begin
  for LIndex := 1 to 5 do
  begin
    LCustomer := FContext.CreateEntity<TTestCustomer>();
    LCustomer.Name := Format('User%d', [LIndex]);
    FContext.Insert<TTestCustomer>(LCustomer);
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(5, LCount);
end;

procedure TTAbstractCrudTests.UpdateChangesColumnAndIncrementsVersion;
var
  LCustomer: TTestCustomer;
  LInitialVersion: TTVersion;
  LLoaded: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);
  LInitialVersion := LCustomer.Version;

  LCustomer.Name := 'Modified';
  FContext.Update<TTestCustomer>(LCustomer);

  Assert.IsTrue(
    LCustomer.Version > LInitialVersion,
    'Version should be incremented after update');

  LLoaded := FContext.Get<TTestCustomer>(LCustomer.ID);
  Assert.AreEqual('Modified', LLoaded.Name);
end;

procedure TTAbstractCrudTests.HardDeleteRemovesRow;
var
  LCustomer: TTestCustomer;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'ToDelete';
  FContext.Insert<TTestCustomer>(LCustomer);

  FContext.Delete<TTestCustomer>(LCustomer);

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.SelectAll<TTestCustomer>(LList);
    Assert.AreEqual<Integer>(0, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.SoftDeleteKeepsRowButExcludesItFromSelectAll;
var
  LTask: TTestTask;
  LList: TTList<TTestTask>;
  LRawCount: Integer;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Design soft delete test';
  FContext.Insert<TTestTask>(LTask);

  FContext.Delete<TTestTask>(LTask);

  LList := TTList<TTestTask>.Create;
  try
    FContext.SelectAll<TTestTask>(LList);
    Assert.AreEqual<Integer>(0, LList.Count,
      'SelectAll should exclude soft-deleted rows');
  finally
    LList.Free;
  end;

  LRawCount := FContext.SelectCount<TTestTask>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LRawCount,
    'Count without IncludeDeleted should also exclude soft-deleted');
end;

procedure TTAbstractCrudTests.IncludeDeletedReturnsSoftDeletedRows;
var
  LTask: TTestTask;
  LBuilder: TTFilterBuilder<TTestTask>;
  LFilter: TTFilter;
  LList: TTList<TTestTask>;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Soft-deleted task';
  FContext.Insert<TTestTask>(LTask);
  FContext.Delete<TTestTask>(LTask);

  LBuilder := FContext.CreateFilterBuilder<TTestTask>();
  try
    LFilter := LBuilder.IncludeDeleted.Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestTask>.Create;
  try
    FContext.Select<TTestTask>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Soft-deleted task', LList[0].Title);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterBuilderFiltersBySingleCondition;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.Where('Name').Equal('Beta').Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Beta', LList[0].Name);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.PagingLimitsResultCount;
var
  LCustomer: TTestCustomer;
  LIndex: Integer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  for LIndex := 1 to 10 do
  begin
    LCustomer := FContext.CreateEntity<TTestCustomer>();
    LCustomer.Name := Format('User%.2d', [LIndex]);
    FContext.Insert<TTestCustomer>(LCustomer);
  end;

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.OrderByAsc('ID').Limit(3).Offset(0).Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(3, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.UpdateWithStaleVersionRaisesConcurrentUpdateException;
var
  LCustomer: TTestCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);

  Connection.Execute(Format(
    'UPDATE Customers SET VersionID = VersionID + 5 WHERE ID = %d;',
    [LCustomer.ID]));

  LCustomer.Name := 'StaleUpdate';
  LRaised := False;
  try
    FContext.Update<TTestCustomer>(LCustomer);
  except
    on E: ETConcurrentUpdateException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Update with stale version must raise ETConcurrentUpdateException');
end;

procedure TTAbstractCrudTests.DeleteWithStaleVersionRaisesConcurrentUpdateException;
var
  LCustomer: TTestCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'ToDeleteStale';
  FContext.Insert<TTestCustomer>(LCustomer);

  Connection.Execute(Format(
    'UPDATE Customers SET VersionID = VersionID + 7 WHERE ID = %d;',
    [LCustomer.ID]));

  LRaised := False;
  try
    FContext.Delete<TTestCustomer>(LCustomer);
  except
    on E: ETConcurrentUpdateException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Delete with stale version must raise ETConcurrentUpdateException');
end;

{ ApplyAll }

procedure TTAbstractCrudTests.ApplyAllExecutesAllOperationsInTransaction;
var
  LExisting: TTestCustomer;
  LInsertList: TTList<TTestCustomer>;
  LUpdateList: TTList<TTestCustomer>;
  LDeleteList: TTList<TTestCustomer>;
  LNewCustomer: TTestCustomer;
  LFreshContext: TTContext;
  LResult: TTList<TTestCustomer>;
begin
  LExisting := FContext.CreateEntity<TTestCustomer>();
  LExisting.Name := 'ToUpdate';
  FContext.Insert<TTestCustomer>(LExisting);

  LInsertList := TTList<TTestCustomer>.Create;
  LUpdateList := TTList<TTestCustomer>.Create;
  LDeleteList := TTList<TTestCustomer>.Create;
  try
    LNewCustomer := FContext.CreateEntity<TTestCustomer>();
    LNewCustomer.Name := 'Inserted';
    LInsertList.Add(LNewCustomer);

    LExisting.Name := 'Updated';
    LUpdateList.Add(LExisting);

    FContext.ApplyAll<TTestCustomer>(
      LInsertList, LUpdateList, LDeleteList);
  finally
    LDeleteList.Free;
    LUpdateList.Free;
    LInsertList.Free;
  end;

  LFreshContext := TTContext.Create(Connection);
  try
    Lresult := TTList<TTestCustomer>.Create;
    try
      LFreshContext.SelectAll<TTestCustomer>(LResult);
      Assert.AreEqual<Integer>(2, LResult.Count);
    finally
      LResult.Free;
    end;
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractCrudTests.ApplyAllRollsBackOnFailure;
var
  LGood: TTestCustomer;
  LBad: TTestCustomer;
  LInsertList: TTList<TTestCustomer>;
  LUpdateList: TTList<TTestCustomer>;
  LDeleteList: TTList<TTestCustomer>;
  LRaised: Boolean;
  LCount: Integer;
begin
  LGood := FContext.CreateEntity<TTestCustomer>();
  LGood.Name := 'Good';
  FContext.Insert<TTestCustomer>(LGood);

  LInsertList := TTList<TTestCustomer>.Create;
  LUpdateList := TTList<TTestCustomer>.Create;
  LDeleteList := TTList<TTestCustomer>.Create;
  try
    LBad := FContext.CreateEntity<TTestCustomer>();
    LBad.Name := 'NewRow';
    LInsertList.Add(LBad);

    Connection.Execute(Format(
      'UPDATE Customers SET VersionID = VersionID + 10 WHERE ID = %d;',
      [LGood.ID]));
    LGood.Name := 'StaleUpdate';
    LUpdateList.Add(LGood);

    LRaised := False;
    try
      FContext.ApplyAll<TTestCustomer>(
        LInsertList, LUpdateList, LDeleteList);
    except
      on E: Exception do
        LRaised := True;
    end;

    Assert.IsTrue(LRaised, 'ApplyAll must raise on stale update');
  finally
    LDeleteList.Free;
    LUpdateList.Free;
    LInsertList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(1, LCount,
    'Rollback must revert the insert from ApplyAll');
end;

{ Save / SaveAll }

procedure TTAbstractCrudTests.SaveInsertsNewEntity;
var
  LCustomer: TTestCustomer;
  LCount: Integer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'SavedNew';
  FContext.Save<TTestCustomer>(LCustomer);

  Assert.IsTrue(LCustomer.ID > 0, 'Save must assign ID for new entity');
  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(1, LCount);
end;

procedure TTAbstractCrudTests.SaveUpdatesExistingEntity;
var
  LCustomer: TTestCustomer;
  LFreshContext: TTContext;
  LReloaded: TTestCustomer;
  LInsertedID: TTPrimaryKey;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);
  LInsertedID := LCustomer.ID;

  LCustomer.Name := 'SavedUpdate';
  FContext.Save<TTestCustomer>(LCustomer);

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestCustomer>(LInsertedID);
    Assert.AreEqual('SavedUpdate', LReloaded.Name);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractCrudTests.SaveAllMixedInsertAndUpdate;
var
  LExisting: TTestCustomer;
  LNew: TTestCustomer;
  LList: TTList<TTestCustomer>;
  LCount: Integer;
begin
  LExisting := FContext.CreateEntity<TTestCustomer>();
  LExisting.Name := 'Existing';
  FContext.Insert<TTestCustomer>(LExisting);

  LNew := FContext.CreateEntity<TTestCustomer>();
  LNew.Name := 'New';

  LExisting.Name := 'ExistingUpdated';

  LList := TTList<TTestCustomer>.Create;
  try
    LList.Add(LExisting);
    LList.Add(LNew);
    FContext.SaveAll<TTestCustomer>(LList);
  finally
    LList.Free;
  end;

  LCount := FContext.SelectCount<TTestCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(2, LCount);
end;

{ TryGet }

procedure TTAbstractCrudTests.TryGetReturnsTrueWhenFound;
var
  LCustomer: TTestCustomer;
  LFound: TTestCustomer;
  LResult: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Findable';
  FContext.Insert<TTestCustomer>(LCustomer);

  Lresult := FContext.TryGet<TTestCustomer>(LCustomer.ID, LFound);
  Assert.IsTrue(LResult);
  Assert.IsNotNull(LFound);
  Assert.AreEqual('Findable', LFound.Name);
end;

procedure TTAbstractCrudTests.TryGetReturnsFalseWhenNotFound;
var
  LFound: TTestCustomer;
  LResult: Boolean;
begin
  Lresult := FContext.TryGet<TTestCustomer>(99999, LFound);
  Assert.IsFalse(LResult);
  Assert.IsNull(LFound);
end;

{ Refresh / OldEntity }

procedure TTAbstractCrudTests.RefreshReloadsEntityFromDatabase;
var
  LCustomer: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);

  Connection.Execute(Format(
    'UPDATE Customers SET Name = ''ChangedBehindTheScenes'' WHERE ID = %d;',
    [LCustomer.ID]));

  FContext.Refresh<TTestCustomer>(LCustomer);
  Assert.AreEqual('ChangedBehindTheScenes', LCustomer.Name,
    'Refresh must reload entity from database');
end;

procedure TTAbstractCrudTests.OldEntityReturnsPersistedState;
var
  LCustomer: TTestCustomer;
  LOld: TTestCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Persisted';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer.Name := 'ModifiedInMemory';

  LOld := FContext.OldEntity<TTestCustomer>(LCustomer);
  try
    Assert.AreEqual('Persisted', LOld.Name,
      'OldEntity must return the persisted state, not in-memory changes');
    Assert.AreEqual(LCustomer.ID, LOld.ID);
  finally
    LOld.Free;
  end;
end;

{ WhereClause }

procedure TTAbstractCrudTests.WhereClauseFiltersSelectAll;
var
  LList: TTList<TTestActiveCustomer>;
begin
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (1, ''WithEmail'', ''a@b.com'', 0);');
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (2, ''NoEmail'', NULL, 0);');
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (3, ''AlsoWithEmail'', ''c@d.com'', 0);');

  LList := TTList<TTestActiveCustomer>.Create;
  try
    FContext.SelectAll<TTestActiveCustomer>(LList);
    Assert.AreEqual<Integer>(2, LList.Count,
      'WhereClause must filter out rows where Email IS NULL');
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.WhereClauseFiltersSelectCount;
var
  LCount: Integer;
begin
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (1, ''WithEmail'', ''x@y.com'', 0);');
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (2, ''NoEmail'', NULL, 0);');

  LCount := FContext.SelectCount<TTestActiveCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(1, LCount,
    'SelectCount with WhereClause must exclude filtered rows');
end;

{ FilterBuilder advanced }

procedure TTAbstractCrudTests.FilterAndWhereNarrowsResults;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alice';
  LCustomer.Email := 'alice@test.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Bob';
  LCustomer.Email := 'bob@test.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alice';
  LCustomer.Email := 'alice2@test.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder
      .Where('Name').Equal('Alice')
      .AndWhere('Email').Equal('alice2@test.com')
      .Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('alice2@test.com', LList[0].Email);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterOrWhereWidensResults;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alice';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Bob';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Carol';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder
      .Where('Name').Equal('Alice')
      .OrWhere('Name').Equal('Carol')
      .Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(2, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterNotEqualExcludesMatch;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Keep';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Exclude';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.Where('Name').NotEqual('Exclude').Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Keep', LList[0].Name);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterGreaterReturnsAboveThreshold;
var
  LOrder: TTestOrder;
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestOrder>;
  LFilter: TTFilter;
  LList: TTList<TTestOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Cust';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 100.0;
  FContext.Insert<TTestOrder>(LOrder);

  LBuilder := FContext.CreateFilterBuilder<TTestOrder>();
  try
    LFilter := LBuilder.Where('Amount').Greater(50.0).Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestOrder>.Create;
  try
    FContext.Select<TTestOrder>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterLessReturnsBelowThreshold;
var
  LOrder: TTestOrder;
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestOrder>;
  LFilter: TTFilter;
  LList: TTList<TTestOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Cust';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LBuilder := FContext.CreateFilterBuilder<TTestOrder>();
  try
    LFilter := LBuilder.Where('Amount').Less(50.0).Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestOrder>.Create;
  try
    FContext.Select<TTestOrder>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterGreaterOrEqualIncludesBoundary;
var
  LOrder: TTestOrder;
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestOrder>;
  LFilter: TTFilter;
  LList: TTList<TTestOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Cust';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LBuilder := FContext.CreateFilterBuilder<TTestOrder>();
  try
    LFilter := LBuilder.Where('Amount').GreaterOrEqual(50.0).Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestOrder>.Create;
  try
    FContext.Select<TTestOrder>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterLessOrEqualIncludesBoundary;
var
  LOrder: TTestOrder;
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestOrder>;
  LFilter: TTFilter;
  LList: TTList<TTestOrder>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Cust';
  FContext.Insert<TTestCustomer>(LCustomer);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 10.0;
  FContext.Insert<TTestOrder>(LOrder);

  LOrder := FContext.CreateEntity<TTestOrder>();
  LOrder.CustomerID := LCustomer.ID;
  LOrder.Amount := 50.0;
  FContext.Insert<TTestOrder>(LOrder);

  LBuilder := FContext.CreateFilterBuilder<TTestOrder>();
  try
    LFilter := LBuilder.Where('Amount').LessOrEqual(10.0).Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestOrder>.Create;
  try
    FContext.Select<TTestOrder>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterLikeMatchesPattern;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'AlphaPlus';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.Where('Name').Like('Alpha%').Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(2, LList.Count);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterNotLikeExcludesPattern;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.Where('Name').NotLike('Alpha%').Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('Beta', LList[0].Name);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterIsNullReturnsNullRows;
var
  LList: TTList<TTestCustomer>;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
begin
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (1, ''WithEmail'', ''a@b.com'', 0);');
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (2, ''NoEmail'', NULL, 0);');

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.Where('Email').IsNull.Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('NoEmail', LList[0].Name);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterIsNotNullExcludesNullRows;
var
  LList: TTList<TTestCustomer>;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
begin
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (1, ''WithEmail'', ''a@b.com'', 0);');
  Connection.Execute(
    'INSERT INTO Customers (ID, Name, Email, VersionID) ' +
    'VALUES (2, ''NoEmail'', NULL, 0);');

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.Where('Email').IsNotNull.Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(1, LList.Count);
    Assert.AreEqual('WithEmail', LList[0].Name);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterOrderByDescReversesSortOrder;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alpha';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Charlie';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Bravo';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder.OrderByDesc('Name').Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(3, LList.Count);
    Assert.AreEqual('Charlie', LList[0].Name);
    Assert.AreEqual('Bravo', LList[1].Name);
    Assert.AreEqual('Alpha', LList[2].Name);
  finally
    LList.Free;
  end;
end;

procedure TTAbstractCrudTests.ConcurrentUpdateWithTwoContextsRaisesOnSecond;
var
  LCustomer: TTestCustomer;
  LContext2: TTContext;
  LList: TTList<TTestCustomer>;
  LCustomer2: TTestCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Original';
  FContext.Insert<TTestCustomer>(LCustomer);

  LContext2 := TTContext.Create(Connection);
  try
    LList := TTList<TTestCustomer>.Create;
    try
      LContext2.SelectAll<TTestCustomer>(LList);
      LCustomer2 := LList[0];

      LCustomer.Name := 'Updated by first';
      FContext.Update<TTestCustomer>(LCustomer);

      LCustomer2.Name := 'Updated by second';
      LRaised := False;
      try
        LContext2.Update<TTestCustomer>(LCustomer2);
      except
        on E: Exception do
          LRaised := True;
      end;
      Assert.IsTrue(LRaised,
        'Second context update must fail due to stale version');
    finally
      LList.Free;
    end;
  finally
    LContext2.Free;
  end;
end;

procedure TTAbstractCrudTests.FilterAndOrCombinationRespectsOperatorPrecedence;
var
  LCustomer: TTestCustomer;
  LBuilder: TTFilterBuilder<TTestCustomer>;
  LFilter: TTFilter;
  LList: TTList<TTestCustomer>;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Alpha';
  LCustomer.Email := 'alpha@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Beta';
  FContext.Insert<TTestCustomer>(LCustomer);

  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'Gamma';
  LCustomer.Email := 'gamma@example.com';
  FContext.Insert<TTestCustomer>(LCustomer);

  LBuilder := FContext.CreateFilterBuilder<TTestCustomer>();
  try
    LFilter := LBuilder
      .Where('Name').Equal('Beta')
      .OrWhere('Name').Equal('Gamma')
      .AndWhere('Email').IsNotNull
      .Build;
  finally
    LBuilder.Free;
  end;

  LList := TTList<TTestCustomer>.Create;
  try
    FContext.Select<TTestCustomer>(LList, LFilter);
    Assert.AreEqual<Integer>(2, LList.Count,
      'AND must bind tighter than OR: Beta (any) + Gamma (with email)');
  finally
    LList.Free;
  end;
end;

end.
