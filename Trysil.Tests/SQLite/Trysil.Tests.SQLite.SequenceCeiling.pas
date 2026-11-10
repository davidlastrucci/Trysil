(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.SequenceCeiling;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Context,
  Trysil.Exceptions,
  Trysil.Data,
  Trysil.Data.FireDAC.SQLite,
  Trysil.Generics.Collections,

  Trysil.Tests.Model,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteSequenceCeilingTests }

  [TestFixture]
  TTSQLiteSequenceCeilingTests = class
  strict private
    FConnection: TTConnection;
    FContext: TTContext;

    procedure ClearTable;
    procedure InsertRowWithID(const AID: Int64);
    procedure CheckTheCacheStopsThere;
    function CreateFreshConnection: TTConnection;
    procedure CheckTheDeletedIDIsNotReused(const AConnection: TTConnection);
    procedure CheckTheNextIDIsNew(const AContext: TTContext);
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure ASequenceAboveThePrimaryKeyRangeRaises;

    [Test]
    procedure TheCeilingIsInclusiveAndSoIsTheCache;

    [Test]
    procedure AnIDStillInTheIdentityMapIsNotHandedOutAgain;
  end;

implementation

{ TTSQLiteSequenceCeilingTests }

procedure TTSQLiteSequenceCeilingTests.Setup;
begin
  FConnection := TTSQLiteTestConnection.Connection;
  ClearTable;
  FContext := TTContext.Create(FConnection, False);
end;

procedure TTSQLiteSequenceCeilingTests.TearDown;
begin
  FContext.Free;
  ClearTable;
end;

procedure TTSQLiteSequenceCeilingTests.ClearTable;
begin
  FConnection.Execute('DELETE FROM SequenceCeiling');
end;

procedure TTSQLiteSequenceCeilingTests.InsertRowWithID(const AID: Int64);
begin
  FConnection.Execute(Format(
    'INSERT INTO SequenceCeiling (ID, Name) VALUES (%d, %s)', [
      AID,
      QuotedStr('SequenceCeiling')]));
end;

procedure TTSQLiteSequenceCeilingTests.ASequenceAboveThePrimaryKeyRangeRaises;
var
  LRaised: Boolean;
  LItem: TTestSequenceCeiling;
begin
  LRaised := False;
  LItem := nil;
  InsertRowWithID(High(TTPrimaryKey));
  try
    try
      LItem := FContext.CreateEntity<TTestSequenceCeiling>();
    except
      on E: ETException do
        LRaised := True;
    end;
  finally
    if Assigned(LItem) then
      LItem.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'The next sequence value is 2147483648, which does not fit a primary ' +
    'key: it must raise instead of coming back truncated to -2147483648');
end;

procedure TTSQLiteSequenceCeilingTests.TheCeilingIsInclusiveAndSoIsTheCache;
var
  LItem: TTestSequenceCeiling;
begin
  InsertRowWithID(High(TTPrimaryKey) - 1);
  LItem := FContext.CreateEntity<TTestSequenceCeiling>();
  try
    Assert.AreEqual<TTPrimaryKey>(
      High(TTPrimaryKey),
      LItem.ID,
      'The ceiling is inclusive: the last value a primary key can hold is ' +
      'still a valid identifier');

    CheckTheCacheStopsThere;
  finally
    LItem.Free;
  end;
end;

procedure TTSQLiteSequenceCeilingTests.CheckTheCacheStopsThere;
var
  LRaised: Boolean;
  LItem: TTestSequenceCeiling;
begin
  LRaised := False;
  LItem := nil;
  try
    try
      LItem := FContext.CreateEntity<TTestSequenceCeiling>();
    except
      on E: ETException do
        LRaised := True;
    end;
  finally
    if Assigned(LItem) then
      LItem.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'SQLite keeps a cache of the last value it handed out, and that branch ' +
    'is the one that answers here, not the inherited method the guard was ' +
    'written in: it added one to an Int32 with nothing to stop it');
end;

function TTSQLiteSequenceCeilingTests.CreateFreshConnection: TTConnection;
var
  LName: String;
begin
  LName := Format('SequenceSeed%s', [TGUID.NewGuid.ToString()]);
  TTSQLiteConnection.RegisterConnection(
    LName, TTSQLiteTestConnection.DatabaseFile);
  result := TTSQLiteConnection.Create(LName);
end;

procedure TTSQLiteSequenceCeilingTests.CheckTheNextIDIsNew(
  const AContext: TTContext);
var
  LRaised: Boolean;
  LItem: TTestSequenceCeiling;
begin
  LRaised := False;
  LItem := nil;
  try
    LItem := AContext.CreateEntity<TTestSequenceCeiling>();
  except
    on E: ETException do
      LRaised := True;
  end;

  Assert.IsFalse(
    LRaised,
    'The deleted row is gone from the table but its entity is still in ' +
    'the identity map: handing its ID out again collides with it');
  Assert.AreEqual<TTPrimaryKey>(4, LItem.ID);
end;

procedure TTSQLiteSequenceCeilingTests.CheckTheDeletedIDIsNotReused(
  const AConnection: TTConnection);
var
  LContext: TTContext;
  LList: TTList<TTestSequenceCeiling>;
begin
  LContext := TTContext.Create(AConnection, True);
  try
    LList := LContext.CreateEntityList<TTestSequenceCeiling>();
    try
      LContext.SelectAll<TTestSequenceCeiling>(LList);
      FConnection.Execute('DELETE FROM SequenceCeiling WHERE ID = 3');
      CheckTheNextIDIsNew(LContext);
    finally
      LList.Free;
    end;
  finally
    LContext.Free;
  end;
end;

procedure TTSQLiteSequenceCeilingTests.
  AnIDStillInTheIdentityMapIsNotHandedOutAgain;
var
  LConnection: TTConnection;
begin
  InsertRowWithID(1);
  InsertRowWithID(2);
  InsertRowWithID(3);
  LConnection := CreateFreshConnection;
  try
    CheckTheDeletedIDIsNotReused(LConnection);
  finally
    LConnection.Free;
  end;
end;

end.
