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
  strict private
    function DeletedByOf(const AID: TTPrimaryKey): String;
  public
    [Test]
    procedure InsertPopulatesCreatedAtAndCreatedBy;

    [Test]
    procedure InsertWithoutOnGetCurrentUserLeavesCreatedByEmpty;

    [Test]
    procedure UpdatePopulatesUpdatedAtAndUpdatedBy;

    [Test]
    procedure AFailedUpdateLeavesNoAuditInMemory;

    [Test]
    procedure ChangeTrackingFieldsPersistAfterReload;

    [Test]
    procedure ReloadedEmptyCreatedByIsEmptyString;

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
    procedure UpdateDoesNotReachASoftDeletedRow;

    [Test]
    procedure UndeleteRestoresSoftDeletedEntity;

    [Test]
    procedure UndeleteDoesNotWriteTheWholeRow;

    [Test]
    procedure UndeleteWritesTheUpdateAudit;

    [Test]
    procedure UndeleteClearsDeletedByOnTheRow;

    [Test]
    procedure UpdateLeavesTheDeleteAuditAlone;

    [Test]
    procedure UndeleteKeepsTheEntityInSyncWithTheRow;

    [Test]
    procedure ASecondDeleteKeepsTheFirstAudit;

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
  Assert.IsTrue(
    (LUser.CreatedAt.Value >= LBefore) and (LUser.CreatedAt.Value <= Now),
    'CreatedAt must sit between the moment before the insert and the ' +
    'moment after it. The old bound was Now - 1, a whole day, with no ' +
    'upper bound at all: a stamp from last week would have passed');
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

procedure TTAbstractChangeTrackingTests.AFailedUpdateLeavesNoAuditInMemory;
var
  LUser: TTestTrackedUser;
  LRaised: Boolean;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'editor';
    end;

  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'Dave';
  FContext.Insert<TTestTrackedUser>(LUser);

  Connection.Execute(Format(
    'UPDATE TrackedUsers SET VersionID = VersionID + 10 WHERE ID = %d',
    [LUser.ID]));

  LUser.Name := 'Dave (renamed)';
  LRaised := False;
  try
    FContext.Update<TTestTrackedUser>(LUser);
  except
    on E: ETConcurrentUpdateException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised, 'The stale version must make the update fail');
  Assert.IsTrue(
    LUser.UpdatedAt.IsNull,
    'The audit is written to the entity before the command runs, so a ' +
    'failed update used to leave a timestamp in memory that no row ' +
    'carries: the caller then persisted it on the next attempt');
  Assert.AreEqual(
    String.Empty,
    LUser.UpdatedBy,
    'UpdatedBy is written in the same place as UpdatedAt and must be ' +
    'rolled back with it');
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

procedure TTAbstractChangeTrackingTests.ReloadedEmptyCreatedByIsEmptyString;
var
  LUser: TTestTrackedUser;
  LInsertedID: TTPrimaryKey;
  LFreshContext: TTContext;
  LReloaded: TTestTrackedUser;
begin
  LUser := FContext.CreateEntity<TTestTrackedUser>();
  LUser.Name := 'Anonymous';
  FContext.Insert<TTestTrackedUser>(LUser);
  LInsertedID := LUser.ID;

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestTrackedUser>(LInsertedID);

    Assert.IsFalse(LReloaded.CreatedAt.IsNull,
      'CreatedAt must persist even without OnGetCurrentUser');
    Assert.AreEqual(String.Empty, LReloaded.CreatedBy,
      'An empty CreatedBy must read back as an empty string, including ' +
      'where the engine stores the empty string as NULL');
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
    Assert.IsTrue(LFreshContext.TryGet<TTestTask>(LID, True, LLoaded),
      'TryGet with IncludeDeleted must find a soft-deleted entity');
    Assert.AreEqual('TryRecoverable', LLoaded.Title);
  finally
    LFreshContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UpdateDoesNotReachASoftDeletedRow;
var
  LTask: TTestTask;
  LID: TTPrimaryKey;
  LRaised: Boolean;
  LFreshContext: TTContext;
  LReloaded: TTestTask;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Original';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  LTask.Title := 'Edited';
  LRaised := False;
  try
    FContext.Update<TTestTask>(LTask);
  except
    on E: ETConcurrentUpdateException do
      LRaised := True;
  end;

  Assert.IsTrue(
    LRaised,
    'The soft delete left the entity carrying the version the row now ' +
    'has, so the key and version of the WHERE match: what must keep the ' +
    'update away from a deleted row is the DeletedAt IS NULL guard, and ' +
    'this is the only test that puts it in the way');

  LFreshContext := TTContext.Create(Connection);
  try
    LReloaded := LFreshContext.Get<TTestTask>(LID, True);
    Assert.AreEqual(
      'Original',
      LReloaded.Title,
      'A refused update must leave the row as the delete left it');
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

procedure TTAbstractChangeTrackingTests.UndeleteDoesNotWriteTheWholeRow;
var
  LTask: TTestTask;
  LID: TTPrimaryKey;
  LVerifyContext: TTContext;
  LReloaded: TTestTask;
begin
  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Original';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  LTask.Title := 'Edited while deleted';
  FContext.Undelete<TTestTask>(LTask);

  LVerifyContext := TTContext.Create(Connection);
  try
    LReloaded := LVerifyContext.Get<TTestTask>(LID);
    Assert.AreEqual(
      'Original',
      LReloaded.Title,
      'Undelete must clear the delete columns, not write the whole row');
  finally
    LVerifyContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UndeleteWritesTheUpdateAudit;
var
  LTask: TTestTask;
  LID: TTPrimaryKey;
  LVerifyContext: TTContext;
  LReloaded: TTestTask;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'restorer';
    end;

  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'ToRestore';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  FContext.Undelete<TTestTask>(LTask);

  LVerifyContext := TTContext.Create(Connection);
  try
    LReloaded := LVerifyContext.Get<TTestTask>(LID);
    Assert.IsFalse(LReloaded.UpdatedAt.IsNull,
      'Undelete must write UpdatedAt to the database');
    Assert.AreEqual('restorer', LReloaded.UpdatedBy,
      'Undelete must write UpdatedBy to the database');
  finally
    LVerifyContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UndeleteClearsDeletedByOnTheRow;
var
  LTask: TTestTask;
  LID: TTPrimaryKey;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'deleter';
    end;

  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'ToRestore';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;

  FContext.Delete<TTestTask>(LTask);
  Assert.AreEqual('deleter', DeletedByOf(LID),
    'Precondition: the soft delete stamps DeletedBy on the row');

  FContext.Undelete<TTestTask>(LTask);
  Assert.AreEqual(String.Empty, DeletedByOf(LID),
    'Undelete writes DeletedBy as the literal empty string, which one ' +
    'engine stores as NULL: it must read back empty either way');
end;

procedure TTAbstractChangeTrackingTests.UpdateLeavesTheDeleteAuditAlone;
var
  LTask: TTestTask;
  LID: TTPrimaryKey;
  LContext: TTContext;
  LReloaded: TTestTask;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'deleter';
    end;

  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'Original';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  Connection.Execute(Format(
    'UPDATE Tasks SET DeletedAt = NULL WHERE ID = %d', [LID]));

  LTask.Title := 'Edited';
  FContext.Update<TTestTask>(LTask);

  LContext := TTContext.Create(Connection);
  try
    LReloaded := LContext.Get<TTestTask>(LID);
    Assert.AreEqual('Edited', LReloaded.Title,
      'Precondition: the row is reachable again and the update landed');
    Assert.IsTrue(LReloaded.DeletedAt.IsNull,
      'An update must not write the delete columns back from the entity, ' +
      'which still carries them in memory');
    Assert.AreEqual('deleter', LReloaded.DeletedBy,
      'And it must not blank the one the delete wrote either');
  finally
    LContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.UndeleteKeepsTheEntityInSyncWithTheRow;
var
  LTask: TTestTask;
  LRaised: Boolean;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'restorer';
    end;

  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'ToRestore';
  FContext.Insert<TTestTask>(LTask);
  FContext.Delete<TTestTask>(LTask);
  FContext.Undelete<TTestTask>(LTask);

  Assert.IsFalse(LTask.UpdatedAt.IsNull,
    'Undelete stamps the update audit on the entity as well as the row');
  Assert.AreEqual('restorer', LTask.UpdatedBy);

  LRaised := False;
  LTask.Title := 'Renamed';
  try
    FContext.Update<TTestTask>(LTask);
  except
    on E: ETConcurrentUpdateException do
      LRaised := True;
  end;

  Assert.IsFalse(LRaised,
    'The in-memory version must have been incremented with the row, or ' +
    'the next update on the same instance is refused');
end;

function TTAbstractChangeTrackingTests.DeletedByOf(
  const AID: TTPrimaryKey): String;
var
  LContext: TTContext;
begin
  LContext := TTContext.Create(Connection);
  try
    result := LContext.Get<TTestTask>(AID, True).DeletedBy;
  finally
    LContext.Free;
  end;
end;

procedure TTAbstractChangeTrackingTests.ASecondDeleteKeepsTheFirstAudit;
var
  LTask: TTestTask;
  LID: TTPrimaryKey;
  LContext: TTContext;
  LRaised: Boolean;
begin
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'first';
    end;

  LTask := FContext.CreateEntity<TTestTask>();
  LTask.Title := 'ToDelete';
  FContext.Insert<TTestTask>(LTask);
  LID := LTask.ID;
  FContext.Delete<TTestTask>(LTask);

  LRaised := False;
  LContext := TTContext.Create(Connection);
  try
    LContext.OnGetCurrentUser :=
      function: String
      begin
        result := 'second';
      end;
    try
      LContext.Delete<TTestTask>(LContext.Get<TTestTask>(LID, True));
    except
      on E: ETConcurrentUpdateException do
        LRaised := True;
    end;
  finally
    LContext.Free;
  end;

  Assert.IsTrue(LRaised,
    'A row that is already deleted is not in the state the caller thinks');
  Assert.AreEqual('first', DeletedByOf(LID),
    'The audit of the original delete must survive a second delete');
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
