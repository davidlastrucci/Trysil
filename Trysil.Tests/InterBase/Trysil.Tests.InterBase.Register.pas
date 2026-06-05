(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.Register;

interface

type

{ TTInterBaseTestRegister }

  TTInterBaseTestRegister = class
  public
    class procedure Register;
    class procedure Unregister;
  end;

implementation

uses
  DUnitX.TestFramework,

  Trysil.Tests.Config,
  Trysil.Tests.InterBase.Connection,
  Trysil.Tests.InterBase.Crud,
  Trysil.Tests.InterBase.ChangeTracking,
  Trysil.Tests.InterBase.IdentityMap,
  Trysil.Tests.InterBase.Validation,
  Trysil.Tests.InterBase.Join,
  Trysil.Tests.InterBase.Session,
  Trysil.Tests.InterBase.Transaction,
  Trysil.Tests.InterBase.Lazy,
  Trysil.Tests.InterBase.Events,
  Trysil.Tests.InterBase.Relation,
  Trysil.Tests.InterBase.ContextApi,
  Trysil.Tests.InterBase.UpdateMode,
  Trysil.Tests.InterBase.JSon,
  Trysil.Tests.InterBase.AllTypes,
  Trysil.Tests.InterBase.AllTypesJSon,
  Trysil.Tests.InterBase.NullablePrimitives,
  Trysil.Tests.InterBase.NullablePrimitivesJSon;

{ TTInterBaseTestRegister }

class procedure TTInterBaseTestRegister.Register;
begin
  if TTTestConfig.IsDatabaseEnabled('InterBase') then
  begin
    TTInterBaseTestConnection.Initialize;

    TDUnitX.RegisterTestFixture(TTInterBaseCrudTests);
    TDUnitX.RegisterTestFixture(TTInterBaseChangeTrackingTests);
    TDUnitX.RegisterTestFixture(TTInterBaseIdentityMapTests);
    TDUnitX.RegisterTestFixture(TTInterBaseValidationTests);
    TDUnitX.RegisterTestFixture(TTInterBaseJoinTests);
    TDUnitX.RegisterTestFixture(TTInterBaseSessionTests);
    TDUnitX.RegisterTestFixture(TTInterBaseTransactionTests);
    TDUnitX.RegisterTestFixture(TTInterBaseLazyTests);
    TDUnitX.RegisterTestFixture(TTInterBaseEventsTests);
    TDUnitX.RegisterTestFixture(TTInterBaseRelationTests);
    TDUnitX.RegisterTestFixture(TTInterBaseContextApiTests);
    TDUnitX.RegisterTestFixture(TTInterBaseUpdateModeTests);
    TDUnitX.RegisterTestFixture(TTInterBaseJSonTests);
    TDUnitX.RegisterTestFixture(TTInterBaseAllTypesTests);
    TDUnitX.RegisterTestFixture(TTInterBaseAllTypesJSonTests);
    TDUnitX.RegisterTestFixture(TTInterBaseNullablePrimitivesTests);
    TDUnitX.RegisterTestFixture(TTInterBaseNullablePrimitivesJSonTests);
  end;
end;

class procedure TTInterBaseTestRegister.Unregister;
begin
  if TTTestConfig.IsDatabaseEnabled('InterBase') then
    TTInterBaseTestConnection.Finalize;
end;

initialization
  TTInterBaseTestRegister.Register;

finalization
  TTInterBaseTestRegister.Unregister;

end.
