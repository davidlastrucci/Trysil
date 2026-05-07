(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Register;

interface

type

{ TTFirebirdSQLTestRegister }

  TTFirebirdSQLTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.FirebirdSQL.Connection,
  Trysil.Tests.FirebirdSQL.Crud,
  Trysil.Tests.FirebirdSQL.ChangeTracking,
  Trysil.Tests.FirebirdSQL.IdentityMap,
  Trysil.Tests.FirebirdSQL.Validation,
  Trysil.Tests.FirebirdSQL.Join,
  Trysil.Tests.FirebirdSQL.Session,
  Trysil.Tests.FirebirdSQL.Transaction,
  Trysil.Tests.FirebirdSQL.Lazy,
  Trysil.Tests.FirebirdSQL.Events,
  Trysil.Tests.FirebirdSQL.Relation,
  Trysil.Tests.FirebirdSQL.ContextApi,
  Trysil.Tests.FirebirdSQL.UpdateMode,
  Trysil.Tests.FirebirdSQL.JSon,
  Trysil.Tests.FirebirdSQL.AllTypes,
  Trysil.Tests.FirebirdSQL.AllTypesJSon,
  Trysil.Tests.FirebirdSQL.NullablePrimitives,
  Trysil.Tests.FirebirdSQL.NullablePrimitivesJSon;

{ TTFirebirdSQLTestRegister }

class procedure TTFirebirdSQLTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('FirebirdSQL') then
  begin
    TTFirebirdSQLTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTFirebirdSQLCrudTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLValidationTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLJoinTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLSessionTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLTransactionTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLLazyTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLEventsTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLRelationTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLContextApiTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLJSonTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLAllTypesTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTFirebirdSQLNullablePrimitivesJSonTests);
  end;
end;

class procedure TTFirebirdSQLTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('FirebirdSQL') then
    TTFirebirdSQLTestConnection.Finalize;
end;

initialization
  TTFirebirdSQLTestRegister.Register;

finalization
  TTFirebirdSQLTestRegister.Unregister;

end.
