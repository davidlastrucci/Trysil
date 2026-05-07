(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.Register;

interface

type

{ TTPostgreSQLTestRegister }

  TTPostgreSQLTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.PostgreSQL.Connection,
  Trysil.Tests.PostgreSQL.Crud,
  Trysil.Tests.PostgreSQL.ChangeTracking,
  Trysil.Tests.PostgreSQL.IdentityMap,
  Trysil.Tests.PostgreSQL.Validation,
  Trysil.Tests.PostgreSQL.Join,
  Trysil.Tests.PostgreSQL.Session,
  Trysil.Tests.PostgreSQL.Transaction,
  Trysil.Tests.PostgreSQL.Lazy,
  Trysil.Tests.PostgreSQL.Events,
  Trysil.Tests.PostgreSQL.Relation,
  Trysil.Tests.PostgreSQL.ContextApi,
  Trysil.Tests.PostgreSQL.UpdateMode,
  Trysil.Tests.PostgreSQL.JSon,
  Trysil.Tests.PostgreSQL.AllTypes,
  Trysil.Tests.PostgreSQL.AllTypesJSon,
  Trysil.Tests.PostgreSQL.NullablePrimitives,
  Trysil.Tests.PostgreSQL.NullablePrimitivesJSon;

{ TTPostgreSQLTestRegister }

class procedure TTPostgreSQLTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('PostgreSQL') then
  begin
    TTPostgreSQLTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTPostgreSQLCrudTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLValidationTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLJoinTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLSessionTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLTransactionTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLLazyTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLEventsTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLRelationTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLContextApiTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLJSonTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLAllTypesTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTPostgreSQLNullablePrimitivesJSonTests);
  end;
end;

class procedure TTPostgreSQLTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('PostgreSQL') then
    TTPostgreSQLTestConnection.Finalize;
end;

initialization
  TTPostgreSQLTestRegister.Register;

finalization
  TTPostgreSQLTestRegister.Unregister;

end.
