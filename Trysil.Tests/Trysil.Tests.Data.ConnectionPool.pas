(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Data.ConnectionPool;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Consts,
  DUnitX.TestFramework,

  Trysil.Exceptions,
  Trysil.Data.FireDAC.ConnectionPool;

type

{ TTConnectionPoolTests }

  [TestFixture]
  TTConnectionPoolTests = class
  strict private
    const TestConnectionName: String = 'TrysilTestPoolConnection';
  strict private
    FEnabled: Boolean;
    FMaximumItems: Integer;
    FCleanupTimeout: Cardinal;
    FExpireTimeout: Cardinal;

    function CreateParameters(const ADatabase: String): TStrings;
    procedure RegisterTestConnection(const ADatabase: String);
    function TryRegisterTestConnection(const ADatabase: String): Boolean;
    procedure RestoreConfig;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure PoolParametersAreNotAssignedByDefault;

    [Test]
    procedure TwoArgumentConstructorKeepsTheFireDACTimeouts;

    [Test]
    procedure FourArgumentConstructorKeepsEveryValue;

    [Test]
    procedure DisabledPoolParametersAreStillAssigned;

    [Test]
    procedure RegisteringTheSameConnectionTwiceIsANoOp;

    [Test]
    procedure RegisteringADifferentConnectionRaises;

    [Test]
    procedure UnregisteringLetsTheNameBeRegisteredAgain;

    [Test]
    procedure GlobalPoolConfigDoesNotAffectTheSignature;

    [Test]
    procedure ARejectedRegistrationDoesNotBurnTheName;
  end;

implementation

{ TTConnectionPoolTests }

function TTConnectionPoolTests.CreateParameters(
  const ADatabase: String): TStrings;
begin
  result := TStringList.Create;
  try
    result.Add(Format('Database=%s', [ADatabase]));
  except
    result.Free;
    raise;
  end;
end;

procedure TTConnectionPoolTests.RegisterTestConnection(
  const ADatabase: String);
var
  LParameters: TStrings;
begin
  LParameters := CreateParameters(ADatabase);
  try
    TTFireDACConnectionPool.Instance.RegisterConnection(
      TestConnectionName, 'SQLite', LParameters);
  finally
    LParameters.Free;
  end;
end;

function TTConnectionPoolTests.TryRegisterTestConnection(
  const ADatabase: String): Boolean;
begin
  result := True;
  try
    RegisterTestConnection(ADatabase);
  except
    on E: ETException do
      result := False;
  end;
end;

procedure TTConnectionPoolTests.Setup;
var
  LConfig: TTFireDACConfigConnectionPool;
begin
  LConfig := TTFireDACConnectionPool.Instance.Config;
  FEnabled := LConfig.Enabled;
  FMaximumItems := LConfig.MaximumItems;
  FCleanupTimeout := LConfig.CleanupTimeout;
  FExpireTimeout := LConfig.ExpireTimeout;
end;

procedure TTConnectionPoolTests.RestoreConfig;
var
  LConfig: TTFireDACConfigConnectionPool;
begin
  LConfig := TTFireDACConnectionPool.Instance.Config;
  LConfig.Enabled := FEnabled;
  LConfig.MaximumItems := FMaximumItems;
  LConfig.CleanupTimeout := FCleanupTimeout;
  LConfig.ExpireTimeout := FExpireTimeout;
end;

procedure TTConnectionPoolTests.TearDown;
begin
  try
    TTFireDACConnectionPool.Instance.UnregisterConnection(
      TestConnectionName);
  except
    // The test may not have registered anything
  end;
  RestoreConfig;
end;

procedure TTConnectionPoolTests.RegisteringTheSameConnectionTwiceIsANoOp;
begin
  RegisterTestConnection('pool-test.db');
  Assert.IsTrue(
    TryRegisterTestConnection('pool-test.db'),
    'An identical registration must be accepted and change nothing');
end;

procedure TTConnectionPoolTests.RegisteringADifferentConnectionRaises;
begin
  RegisterTestConnection('pool-test.db');
  Assert.IsFalse(
    TryRegisterTestConnection('other-pool-test.db'),
    'A different definition under a name in use must be rejected');
end;

procedure TTConnectionPoolTests.UnregisteringLetsTheNameBeRegisteredAgain;
begin
  RegisterTestConnection('pool-test.db');
  TTFireDACConnectionPool.Instance.UnregisterConnection(TestConnectionName);
  Assert.IsTrue(
    TryRegisterTestConnection('other-pool-test.db'),
    'Unregistering must clear the name from the registry as well');
end;

procedure TTConnectionPoolTests.PoolParametersAreNotAssignedByDefault;
var
  LParameters: TTFireDACPoolParameters;
begin
  LParameters := Default(TTFireDACPoolParameters);
  Assert.IsFalse(
    LParameters.IsAssigned,
    'Unset pool parameters must fall back to the global configuration');
end;

procedure TTConnectionPoolTests.TwoArgumentConstructorKeepsTheFireDACTimeouts;
var
  LParameters: TTFireDACPoolParameters;
begin
  LParameters := TTFireDACPoolParameters.Create(True, 5);
  Assert.IsTrue(LParameters.IsAssigned);
  Assert.IsTrue(LParameters.Enabled);
  Assert.AreEqual<Integer>(5, LParameters.MaximumItems);
  Assert.AreEqual<Cardinal>(
    C_FD_PoolCleanupTimeout, LParameters.CleanupTimeout);
  Assert.AreEqual<Cardinal>(
    C_FD_PoolExpireTimeout, LParameters.ExpireTimeout);
end;

procedure TTConnectionPoolTests.FourArgumentConstructorKeepsEveryValue;
var
  LParameters: TTFireDACPoolParameters;
begin
  LParameters := TTFireDACPoolParameters.Create(True, 2, 1000, 2000);
  Assert.IsTrue(LParameters.IsAssigned);
  Assert.IsTrue(LParameters.Enabled);
  Assert.AreEqual<Integer>(2, LParameters.MaximumItems);
  Assert.AreEqual<Cardinal>(1000, LParameters.CleanupTimeout);
  Assert.AreEqual<Cardinal>(2000, LParameters.ExpireTimeout);
end;

procedure TTConnectionPoolTests.DisabledPoolParametersAreStillAssigned;
var
  LParameters: TTFireDACPoolParameters;
begin
  LParameters := TTFireDACPoolParameters.Create(False, 1);
  Assert.IsTrue(
    LParameters.IsAssigned,
    'Disabling the pool for one connection is an explicit choice');
  Assert.IsFalse(LParameters.Enabled);
end;

procedure TTConnectionPoolTests.GlobalPoolConfigDoesNotAffectTheSignature;
var
  LConfig: TTFireDACConfigConnectionPool;
begin
  LConfig := TTFireDACConnectionPool.Instance.Config;
  LConfig.Enabled := True;
  LConfig.MaximumItems := 10;
  RegisterTestConnection('pool-test.db');

  LConfig.MaximumItems := 25;
  Assert.IsTrue(
    TryRegisterTestConnection('pool-test.db'),
    'The signature must not depend on the global pool configuration');
end;

procedure TTConnectionPoolTests.ARejectedRegistrationDoesNotBurnTheName;
begin
  RegisterTestConnection('pool-test.db');
  Assert.IsFalse(
    TryRegisterTestConnection('other-pool-test.db'),
    'A different definition under a name in use must be rejected');

  TTFireDACConnectionPool.Instance.RegisterConfig(
    TestConnectionName, TTFireDACPoolParameters.Create(True, 7));
  Assert.IsTrue(
    TryRegisterTestConnection('pool-test.db'),
    'A rejected attempt must not stop the original from resolving');
end;

initialization
  TDUnitX.RegisterTestFixture(TTConnectionPoolTests);

end.
