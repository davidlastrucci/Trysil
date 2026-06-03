(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.ChangeTracking;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Context,
  Trysil.Data,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractChangeTrackingTests }

  TTAbstractChangeTrackingTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure InsertPopulatesCreatedAtAndCreatedBy;

    [Test]
    procedure InsertWithoutOnGetCurrentUserLeavesCreatedByEmpty;

    [Test]
    procedure UpdatePopulatesUpdatedAtAndUpdatedBy;

    [Test]
    procedure ChangeTrackingFieldsPersistAfterReload;

    [Test]
    procedure SoftDeletePopulatesDeletedAtAndDeletedBy;

    [Test]
    procedure SoftDeleteIncrementsInMemoryVersion;

    [Test]
    procedure GetExcludesSoftDeletedByDefault;

    [Test]
    procedure GetWithIncludeDeletedReturnsSoftDeletedEntity;

    [Test]
    procedure TryGetWithIncludeDeletedReturnsSoftDeletedEntity;

    [Test]
    procedure UndeleteRestoresSoftDeletedEntity;

    [Test]
    procedure UndeleteAllRestoresSoftDeletedEntities;

    [Test]
    procedure UndeleteOnEntityWithoutSoftDeleteRaises;

    [Test]
    procedure NullableFieldPersistsNullThroughDb;

    [Test]
    procedure NullableFieldPersistsValueThroughDb;
  end;

implementation

{ TTAbstractChangeTrackingTests }

procedure TTAbstractChangeTrackingTests.InsertPopulatesCreatedAtAndCreatedBy;
var
  LBefore: TDateTime;
  LUser: TTestTrackedUser;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'tester';
    end;

  LBefore := Now;
  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'Alice';
  FContext.Insert<TTestTrackedUser>(LUser);

  Assert.IsFalse(LUser.CreatedAt.IsNull, 'CreatedAt must be populated on insert');
  Assert.IsTrue(LUser.CreatedAt.Value >= LBefore - 1,
    'CreatedAt must be close to current time');
  Assert.AreEqual('tester', LUser.CreatedBy);
  Assert.IsTrue(LUser.UpdatedAt.IsNull, 'UpdatedAt must remain null after insert');
  Assert.AreEqual(String.Empty, LUser.UpdatedBy);
end;

procedure TTAbstractChangeTrackingTests.InsertWithoutOnGetCurrentUserLeavesCreatedByEmpty;
var
  LUser: TTestTrackedUser;
begin
  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'Anonymous';
  FContext.Insert<TTestTrackedUser>(LUser);

  Assert.IsFalse(LUser.CreatedAt.IsNull,
    'CreatedAt must be populated even without OnGetCurrentUser');
  Assert.AreEqual(String.Empty, LUser.CreatedBy);
end;

procedure TTAbstractChangeTrackingTests.UpdatePopulatesUpdatedAtAndUpdatedBy;
var
  LUser: TTestTrackedUser;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'editor';
    end;

  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'Bob';
  FContext.Insert<TTestTrackedUser>(LUser);

  LUser.Name := 'Bob (renamed)';
  FContext.Update<TTestTrackedUser>(LUser);

  Assert.IsFalse(LUser.UpdatedAt.IsNull, 'UpdatedAt must be populated on update');
  Assert.AreEqual('editor', LUser.UpdatedBy);
end;

procedure TTAbstractChangeTrackingTests.ChangeTrackingFieldsPersistAfterReload;
var
  LFreshContext: TTContext;
  LInsertedID: TTPrimaryKey;
  LUser: TTestTrackedUser;
  LReloaded: TTestTrackedUser;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'persisted-user';
    end;

  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'Carol';
  FContext.Insert<TTestTrackedUser>(LUser);
  LInsertedID := LUser.ID;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestTrackedUser>(LInsertedID);
    Assert.IsFalse(LReloaded.CreatedAt.IsNull,
      'CreatedAt must persist to database');
    Assert.AreEqual('persisted-user', LReloaded.CreatedBy);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.SoftDeletePopulatesDeletedAtAndDeletedBy;
var
  LTask: TTestTask;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'deleter';
    end;

  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'To soft-delete';
  FContext.Insert<TTestTask>(LTask);

  FContext.Delete<TTestTask>(LTask);

  Assert.IsFalse(LTask.DeletedAt.IsNull,
    'Soft delete must populate DeletedAt');
  Assert.AreEqual('deleter', LTask.DeletedBy);
end;

procedure TTAbstractChangeTrackingTests.SoftDeleteIncrementsInMemoryVersion;
var
  LTask: TTestTask;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'VersionCheck';
  FContext.Insert<TTestTask>(LTask);

  FContext.Delete<TTestTask>(LTask);

  Assert.AreEqual<TTVersion>(1, LTask.Version,
    'Soft delete must increment the in-memory version');
end;

procedure TTAbstractChangeTrackingTests.GetExcludesSoftDeletedByDefault;
var
  LTask: TTestTask;
  LFreshContext: TTContext;
  LID: TTPrimaryKey;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Hidden';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  LFreshContext := TTContext.Create(Connection);
  try
    Assert.IsNull(LFreshContext.Get<TTestTask>(LID),
      'Get must exclude soft-deleted entities by default');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.GetWithIncludeDeletedReturnsSoftDeletedEntity;
var
  LTask: TTestTask;
  LFreshContext: TTContext;
  LLoaded: TTestTask;
  LID: TTPrimaryKey;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Recoverable';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  LFreshContext := TTContext.Create(Connection);
  try
    LLoaded := LFreshContext.Get<TTestTask>(LID, True);
    Assert.IsNotNull(LLoaded,
      'Get with IncludeDeleted must return a soft-deleted entity');
    Assert.AreEqual('Recoverable', LLoaded.Title);
    Assert.IsFalse(LLoaded.DeletedAt.IsNull,
      'Soft-deleted entity must carry a DeletedAt value');
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.TryGetWithIncludeDeletedReturnsSoftDeletedEntity;
var
  LTask: TTestTask;
  LFreshContext: TTContext;
  LLoaded: TTestTask;
  LID: TTPrimaryKey;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'TryRecoverable';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  LFreshContext := TTContext.Create(Connection);
  try
    Assert.IsFalse(LFreshContext.TryGet<TTestTask>(LID, LLoaded),
      'TryGet without IncludeDeleted must not find a soft-deleted entity');
    Assert.IsTrue(LFreshContext.TryGet<TTestTask>(LID, LLoaded, True),
      'TryGet with IncludeDeleted must find a soft-deleted entity');
    Assert.AreEqual('TryRecoverable', LLoaded.Title);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UndeleteRestoresSoftDeletedEntity;
var
  LTask: TTestTask;
  LVerifyContext: TTContext;
  LID: TTPrimaryKey;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'ToRestore';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;

  FContext.Delete<TTestTask>(LTask);
  FContext.Undelete<TTestTask>(LTask);

  Assert.IsTrue(LTask.DeletedAt.IsNull,
    'Undelete must clear DeletedAt');
  Assert.AreEqual(String.Empty, LTask.DeletedBy,
    'Undelete must clear DeletedBy');

  LVerifyContext := TTContext.Create(Connection);
  try
    Assert.IsNotNull(LVerifyContext.Get<TTestTask>(LID),
      'An undeleted entity must be visible to a default Get again');
  finally
    LVerifyContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UndeleteAllRestoresSoftDeletedEntities;
var
  LFirst: TTestTask;
  LSecond: TTestTask;
  LList: TTList<TTestTask>;
  LVerifyContext: TTContext;
  LFirstID: TTPrimaryKey;
  LSecondID: TTPrimaryKey;
begin
  LFirst := FContext.CreateEntity<TTestTask>();
  LFirst.Title := 'First';
  FContext.Insert<TTestTask>(LFirst);
  LFirstID := LFirst.ID;
  FContext.Delete<TTestTask>(LFirst);

  LSecond := FContext.CreateEntity<TTestTask>();
  LSecond.Title := 'Second';
  FContext.Insert<TTestTask>(LSecond);
  LSecondID := LSecond.ID;
  FContext.Delete<TTestTask>(LSecond);

  LList := TTList<TTestTask>.Create;
  try
    LList.Add(LFirst);
    LList.Add(LSecond);
    FContext.UndeleteAll<TTestTask>(LList);
  finally
    LList.Free;
  end;

  LVerifyContext := TTContext.Create(Connection);
  try
    Assert.IsNotNull(LVerifyContext.Get<TTestTask>(LFirstID),
      'UndeleteAll must restore the first entity');
    Assert.IsNotNull(LVerifyContext.Get<TTestTask>(LSecondID),
      'UndeleteAll must restore the second entity');
  finally
    LVerifyContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UndeleteOnEntityWithoutSoftDeleteRaises;
var
  LCustomer: TTestCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomer>();
  LCustomer.Name := 'NoSoftDelete';
  FContext.Insert<TTestCustomer>(LCustomer);

  LRaised := False;
  try
    FContext.Undelete<TTestCustomer>(LCustomer);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised,
    'Undelete on an entity without a DeletedAt column must raise ETException');
end;

procedure TTAbstractChangeTrackingTests.NullableFieldPersistsNullThroughDb;
var
  LUser: TTestTrackedUser;
  LContext2: TTContext;
  LList: TTList<TTestTrackedUser>;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'tester';
    end;

  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'TestUser';
  FContext.Insert<TTestTrackedUser>(LUser);

  LContext2 := TTContext.Create(Connection);
  try
    LList := TTList<TTestTrackedUser>.Create;
    try
      LContext2.SelectAll<TTestTrackedUser>(LList);
      Assert.AreEqual<Integer>(1, LList.Count);
      Assert.IsTrue(LList[0].UpdatedAt.IsNull,
        'UpdatedAt must be null after insert without update');
    finally
      LList.Free;
    end;
  finally
    LContext2.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.NullableFieldPersistsValueThroughDb;
var
  LUser: TTestTrackedUser;
  LContext2: TTContext;
  LList: TTList<TTestTrackedUser>;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'tester';
    end;

  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'TestUser';
  FContext.Insert<TTestTrackedUser>(LUser);

  LUser.Name := 'Updated';
  FContext.Update<TTestTrackedUser>(LUser);

  LContext2 := TTContext.Create(Connection);
  try
    LList := TTList<TTestTrackedUser>.Create;
    try
      LContext2.SelectAll<TTestTrackedUser>(LList);
      Assert.AreEqual<Integer>(1, LList.Count);
      Assert.IsFalse(LList[0].UpdatedAt.IsNull,
        'UpdatedAt must have a value after update');
    finally
      LList.Free;
    end;
  finally
    LContext2.Free;
  end;
end;

end.
