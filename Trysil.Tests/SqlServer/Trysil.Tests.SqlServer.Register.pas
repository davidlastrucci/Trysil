(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Register;

interface

type

{ TTSqlServerTestRegister }

  TTSqlServerTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.SqlServer.Connection,
  Trysil.Tests.SqlServer.Crud,
  Trysil.Tests.SqlServer.ChangeTracking,
  Trysil.Tests.SqlServer.IdentityMap,
  Trysil.Tests.SqlServer.Validation,
  Trysil.Tests.SqlServer.Join,
  Trysil.Tests.SqlServer.Session,
  Trysil.Tests.SqlServer.Transaction,
  Trysil.Tests.SqlServer.Lazy,
  Trysil.Tests.SqlServer.Events,
  Trysil.Tests.SqlServer.Relation,
  Trysil.Tests.SqlServer.ContextApi,
  Trysil.Tests.SqlServer.UpdateMode,
  Trysil.Tests.SqlServer.JSon,
  Trysil.Tests.SqlServer.AllTypes,
  Trysil.Tests.SqlServer.AllTypesJSon,
  Trysil.Tests.SqlServer.NullablePrimitives,
  Trysil.Tests.SqlServer.NullablePrimitivesJSon;

{ TTSqlServerTestRegister }

class procedure TTSqlServerTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('SqlServer') then
  begin
    TTSqlServerTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTSqlServerCrudTests);
    TDUnitX.RegisterTestFixture(TTSqlServerChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTSqlServerIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTSqlServerValidationTests);
    TDUnitX.RegisterTestFixture(TTSqlServerJoinTests);
    TDUnitX.RegisterTestFixture(TTSqlServerSessionTests);
    TDUnitX.RegisterTestFixture(TTSqlServerTransactionTests);
    TDUnitX.RegisterTestFixture(TTSqlServerLazyTests);
    TDUnitX.RegisterTestFixture(TTSqlServerEventsTests);
    TDUnitX.RegisterTestFixture(TTSqlServerRelationTests);
    TDUnitX.RegisterTestFixture(TTSqlServerContextApiTests);
    TDUnitX.RegisterTestFixture(TTSqlServerUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTSqlServerJSonTests);
    TDUnitX.RegisterTestFixture(TTSqlServerAllTypesTests);
    TDUnitX.RegisterTestFixture(TTSqlServerAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTSqlServerNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTSqlServerNullablePrimitivesJSonTests);
  end;
end;

class procedure TTSqlServerTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('SqlServer') then
    TTSqlServerTestConnection.Finalize;
end;

initialization
  TTSqlServerTestRegister.Register;

finalization
  TTSqlServerTestRegister.Unregister;

end.
