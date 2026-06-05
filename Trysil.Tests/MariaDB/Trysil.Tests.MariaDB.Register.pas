(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Register;

interface

type

{ TTMariaDBTestRegister }

  TTMariaDBTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.MariaDB.Connection,
  Trysil.Tests.MariaDB.Crud,
  Trysil.Tests.MariaDB.ChangeTracking,
  Trysil.Tests.MariaDB.IdentityMap,
  Trysil.Tests.MariaDB.Validation,
  Trysil.Tests.MariaDB.Join,
  Trysil.Tests.MariaDB.Session,
  Trysil.Tests.MariaDB.Transaction,
  Trysil.Tests.MariaDB.Lazy,
  Trysil.Tests.MariaDB.Events,
  Trysil.Tests.MariaDB.Relation,
  Trysil.Tests.MariaDB.ContextApi,
  Trysil.Tests.MariaDB.UpdateMode,
  Trysil.Tests.MariaDB.JSon,
  Trysil.Tests.MariaDB.AllTypes,
  Trysil.Tests.MariaDB.AllTypesJSon,
  Trysil.Tests.MariaDB.NullablePrimitives,
  Trysil.Tests.MariaDB.NullablePrimitivesJSon;

{ TTMariaDBTestRegister }

class procedure TTMariaDBTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('MariaDB') then
  begin
    TTMariaDBTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTMariaDBCrudTests);
    TDUnitX.RegisterTestFixture(TTMariaDBChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTMariaDBIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTMariaDBValidationTests);
    TDUnitX.RegisterTestFixture(TTMariaDBJoinTests);
    TDUnitX.RegisterTestFixture(TTMariaDBSessionTests);
    TDUnitX.RegisterTestFixture(TTMariaDBTransactionTests);
    TDUnitX.RegisterTestFixture(TTMariaDBLazyTests);
    TDUnitX.RegisterTestFixture(TTMariaDBEventsTests);
    TDUnitX.RegisterTestFixture(TTMariaDBRelationTests);
    TDUnitX.RegisterTestFixture(TTMariaDBContextApiTests);
    TDUnitX.RegisterTestFixture(TTMariaDBUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTMariaDBJSonTests);
    TDUnitX.RegisterTestFixture(TTMariaDBAllTypesTests);
    TDUnitX.RegisterTestFixture(TTMariaDBAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTMariaDBNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTMariaDBNullablePrimitivesJSonTests);
  end;
end;

class procedure TTMariaDBTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('MariaDB') then
    TTMariaDBTestConnection.Finalize;
end;

initialization
  TTMariaDBTestRegister.Register;

finalization
  TTMariaDBTestRegister.Unregister;

end.
