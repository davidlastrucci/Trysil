(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Configuration;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Tests.Config;

type

{ TTTestConfigurationTests }

  [TestFixture]
  TTTestConfigurationTests = class
  public
    [Test]
    procedure TheConfigurationFileIsFound;

    [Test]
    procedure AtLeastOneDatabaseIsEnabled;
  end;

implementation

{ TTTestConfigurationTests }

procedure TTTestConfigurationTests.TheConfigurationFileIsFound;
begin
  Assert.IsFalse(
    TTTestConfig.GetConfigFile.IsEmpty,
    'Trysil.Tests.json was found neither next to the runner nor in any ' +
    'parent folder. Without it every database is reported as disabled, no ' +
    'driver fixture is registered, and the suite passes without touching a ' +
    'database at all');
end;

procedure TTTestConfigurationTests.AtLeastOneDatabaseIsEnabled;
begin
  Assert.IsTrue(
    TTTestConfig.EnabledDatabaseCount > 0,
    'No database is enabled, so every abstract fixture is skipped and the ' +
    'run proves nothing about the ORM. SQLite needs no server and is ' +
    'enabled in the versioned configuration');
end;

initialization
  TDUnitX.RegisterTestFixture(TTTestConfigurationTests);

end.
