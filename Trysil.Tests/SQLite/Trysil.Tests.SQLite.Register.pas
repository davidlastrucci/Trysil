(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Register;

interface

type

{ TTSQLiteTestRegister }

  TTSQLiteTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.SQLite.Connection,
  Trysil.Tests.SQLite.Crud,
  Trysil.Tests.SQLite.ChangeTracking,
  Trysil.Tests.SQLite.IdentityMap,
  Trysil.Tests.SQLite.Validation,
  Trysil.Tests.SQLite.Join,
  Trysil.Tests.SQLite.Session,
  Trysil.Tests.SQLite.Transaction,
  Trysil.Tests.SQLite.Lazy,
  Trysil.Tests.SQLite.Events,
  Trysil.Tests.SQLite.Relation,
  Trysil.Tests.SQLite.ContextApi,
  Trysil.Tests.SQLite.UpdateMode,
  Trysil.Tests.SQLite.JSon,
  Trysil.Tests.SQLite.AllTypes,
  Trysil.Tests.SQLite.AllTypesJSon,
  Trysil.Tests.SQLite.NullablePrimitives,
  Trysil.Tests.SQLite.NullablePrimitivesJSon,
  Trysil.Tests.SQLite.CommitFailure,
  Trysil.Tests.SQLite.SequenceCeiling,
  Trysil.Tests.SQLite.HttpFilter,
  Trysil.Tests.SQLite.JSonReentrance,
  Trysil.Tests.SQLite.SqlSyntax;

{ TTSQLiteTestRegister }

class procedure TTSQLiteTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('SQLite') then
  begin
    TTSQLiteTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTSQLiteSqlSyntaxTests);
    TDUnitX.RegisterTestFixture(TTSQLiteCrudTests);
    TDUnitX.RegisterTestFixture(TTSQLiteChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTSQLiteIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTSQLiteValidationTests);
    TDUnitX.RegisterTestFixture(TTSQLiteJoinTests);
    TDUnitX.RegisterTestFixture(TTSQLiteSessionTests);
    TDUnitX.RegisterTestFixture(TTSQLiteTransactionTests);
    TDUnitX.RegisterTestFixture(TTSQLiteCommitFailureTests);
    TDUnitX.RegisterTestFixture(TTSQLiteSequenceCeilingTests);
    TDUnitX.RegisterTestFixture(TTSQLiteHttpFilterTests);
    TDUnitX.RegisterTestFixture(TTSQLiteJSonReentranceTests);
    TDUnitX.RegisterTestFixture(TTSQLiteLazyTests);
    TDUnitX.RegisterTestFixture(TTSQLiteEventsTests);
    TDUnitX.RegisterTestFixture(TTSQLiteRelationTests);
    TDUnitX.RegisterTestFixture(TTSQLiteContextApiTests);
    TDUnitX.RegisterTestFixture(TTSQLiteUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTSQLiteJSonTests);
    TDUnitX.RegisterTestFixture(TTSQLiteAllTypesTests);
    TDUnitX.RegisterTestFixture(TTSQLiteAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTSQLiteNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTSQLiteNullablePrimitivesJSonTests);
  end;
end;

class procedure TTSQLiteTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('SQLite') then
    TTSQLiteTestConnection.Finalize;
end;

end.
