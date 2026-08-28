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
  FireDAC.Stan.Consts,
  DUnitX.TestFramework,

  Trysil.Data.FireDAC.ConnectionPool;

type

{ TTConnectionPoolTests }

  [TestFixture]
  TTConnectionPoolTests = class
  public
    [Test]
    procedure PoolParametersAreNotAssignedByDefault;

    [Test]
    procedure TwoArgumentConstructorKeepsTheFireDACTimeouts;

    [Test]
    procedure FourArgumentConstructorKeepsEveryValue;

    [Test]
    procedure DisabledPoolParametersAreStillAssigned;
  end;

implementation

{ TTConnectionPoolTests }

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

initialization
  TDUnitX.RegisterTestFixture(TTConnectionPoolTests);

end.
