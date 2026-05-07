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
