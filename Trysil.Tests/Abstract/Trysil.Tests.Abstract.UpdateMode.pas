(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.UpdateMode;

interface

uses
  System.SysUtils,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractUpdateModeTests }

  TTAbstractUpdateModeTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure KeyOnlyInsertAndSelectSucceeds;

    [Test]
    procedure KeyOnlyUpdateSucceeds;

    [Test]
    procedure KeyOnlyUpdateWithUnchangedValuesDoesNotRaise;

    [Test]
    procedure KeyOnlyDeleteSucceeds;

    [Test]
    procedure DefaultModeRaisesWithoutVersionColumn;
  end;

implementation

{ TTAbstractUpdateModeTests }

procedure TTAbstractUpdateModeTests.KeyOnlyInsertAndSelectSucceeds;
var
  LSavedMode: TTUpdateMode;
  LItem: TTestSimpleItem;
  LList: TTList<TTestSimpleItem>;
begin
  LSavedMode := Connection.UpdateMode;
  Connection.UpdateMode := TTUpdateMode.KeyOnly;
  try
    LItem := FContext.CreateEntity<TTestSimpleItem>();
    LItem.Name := 'Test Item';
    FContext.Insert<TTestSimpleItem>(LItem);

    LList := TTList<TTestSimpleItem>.Create;
    try
      FContext.SelectAll<TTestSimpleItem>(LList);
      Assert.AreEqual<Integer>(1, LList.Count);
      Assert.AreEqual('Test Item', LList[0].Name);
    finally
      LList.Free;
    end;
  finally
    Connection.UpdateMode := LSavedMode;
  end;
end;

procedure TTAbstractUpdateModeTests.KeyOnlyUpdateSucceeds;
var
  LSavedMode: TTUpdateMode;
  LItem: TTestSimpleItem;
  LDataset: TDataset;
begin
  LSavedMode := Connection.UpdateMode;
  Connection.UpdateMode := TTUpdateMode.KeyOnly;
  try
    LItem := FContext.CreateEntity<TTestSimpleItem>();
    LItem.Name := 'Original';
    FContext.Insert<TTestSimpleItem>(LItem);

    LItem.Name := 'Updated';
    FContext.Update<TTestSimpleItem>(LItem);

    LDataset := FContext.CreateDataset(
      Format('SELECT Name FROM SimpleItems WHERE ID = %d', [LItem.ID]));
    try
      Assert.AreEqual('Updated', LDataset.Fields[0].AsString);
    finally
      LDataset.Free;
    end;
  finally
    Connection.UpdateMode := LSavedMode;
  end;
end;

procedure
  TTAbstractUpdateModeTests.KeyOnlyUpdateWithUnchangedValuesDoesNotRaise;
var
  LSavedMode: TTUpdateMode;
  LItem: TTestSimpleItem;
  LRaised: Boolean;
begin
  LSavedMode := Connection.UpdateMode;
  Connection.UpdateMode := TTUpdateMode.KeyOnly;
  try
    LItem := FContext.CreateEntity<TTestSimpleItem>();
    LItem.Name := 'Unchanged';
    FContext.Insert<TTestSimpleItem>(LItem);

    LRaised := False;
    try
      FContext.Update<TTestSimpleItem>(LItem);
    except
      on E: ETConcurrentUpdateException do
        LRaised := True;
    end;

    Assert.IsFalse(LRaised,
      'An update that writes the same values must not read as a conflict: ' +
      'the row matched, it simply did not change. Optimistic locking rests ' +
      'entirely on RowsAffected = 0, and one engine counts changed rows ' +
      'rather than matched ones');
  finally
    Connection.UpdateMode := LSavedMode;
  end;
end;

procedure TTAbstractUpdateModeTests.KeyOnlyDeleteSucceeds;
var
  LSavedMode: TTUpdateMode;
  LItem: TTestSimpleItem;
begin
  LSavedMode := Connection.UpdateMode;
  Connection.UpdateMode := TTUpdateMode.KeyOnly;
  try
    LItem := FContext.CreateEntity<TTestSimpleItem>();
    LItem.Name := 'To Delete';
    FContext.Insert<TTestSimpleItem>(LItem);

    FContext.Delete<TTestSimpleItem>(LItem);

    Assert.AreEqual<Integer>(0,
      FContext.SelectCount<TTestSimpleItem>(TTFilter.Empty));
  finally
    Connection.UpdateMode := LSavedMode;
  end;
end;

procedure TTAbstractUpdateModeTests.DefaultModeRaisesWithoutVersionColumn;
var
  LItem: TTestSimpleItem;
  LMessage: String;
begin
  LItem := FContext.CreateEntity<TTestSimpleItem>();
  LMessage := String.Empty;
  try
    FContext.Insert<TTestSimpleItem>(LItem);
  except
    on E: ETException do
      LMessage := E.Message;
  end;
  Assert.IsTrue(
    LMessage.Contains('Version Column'),
    'Insert must raise when the version column is missing in default ' +
    'mode, and say so: ETException is the root of every failure in the ' +
    'framework, so catching it alone would pass on a table name typo too');
end;

end.
