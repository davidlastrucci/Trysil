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
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestSimpleItem>();
  LRaised := False;
  try
    FContext.Insert<TTestSimpleItem>(LItem);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised,
    'Insert must raise when VersionColumn is missing in default mode');
end;

end.
