(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Register;

interface

type

{ TTOracleTestRegister }

  TTOracleTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.Oracle.Connection,
  Trysil.Tests.Oracle.Crud,
  Trysil.Tests.Oracle.ChangeTracking,
  Trysil.Tests.Oracle.IdentityMap,
  Trysil.Tests.Oracle.Validation,
  Trysil.Tests.Oracle.Join,
  Trysil.Tests.Oracle.Session,
  Trysil.Tests.Oracle.Transaction,
  Trysil.Tests.Oracle.Lazy,
  Trysil.Tests.Oracle.Events,
  Trysil.Tests.Oracle.Relation,
  Trysil.Tests.Oracle.ContextApi,
  Trysil.Tests.Oracle.UpdateMode,
  Trysil.Tests.Oracle.JSon,
  Trysil.Tests.Oracle.AllTypes,
  Trysil.Tests.Oracle.AllTypesJSon,
  Trysil.Tests.Oracle.NullablePrimitives,
  Trysil.Tests.Oracle.NullablePrimitivesJSon;

{ TTOracleTestRegister }

class procedure TTOracleTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('Oracle') then
  begin
    TTOracleTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTOracleCrudTests);
    TDUnitX.RegisterTestFixture(TTOracleChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTOracleIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTOracleValidationTests);
    TDUnitX.RegisterTestFixture(TTOracleJoinTests);
    TDUnitX.RegisterTestFixture(TTOracleSessionTests);
    TDUnitX.RegisterTestFixture(TTOracleTransactionTests);
    TDUnitX.RegisterTestFixture(TTOracleLazyTests);
    TDUnitX.RegisterTestFixture(TTOracleEventsTests);
    TDUnitX.RegisterTestFixture(TTOracleRelationTests);
    TDUnitX.RegisterTestFixture(TTOracleContextApiTests);
    TDUnitX.RegisterTestFixture(TTOracleUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTOracleJSonTests);
    TDUnitX.RegisterTestFixture(TTOracleAllTypesTests);
    TDUnitX.RegisterTestFixture(TTOracleAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTOracleNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTOracleNullablePrimitivesJSonTests);
  end;
end;

class procedure TTOracleTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('Oracle') then
    TTOracleTestConnection.Finalize;
end;

initialization
  TTOracleTestRegister.Register;

finalization
  TTOracleTestRegister.Unregister;

end.
