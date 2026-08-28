(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.MultiTenant;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Data.FireDAC,

  Trysil.Http.MultiTenant.Config,
  Trysil.Http.MultiTenant;

type

{ TTestTenantConfig }

  TTestTenantConfig = class(TTTenantConfig)
  strict protected
    function GetConnectionName: String; override;
    function GetParameters: TTFireDACConnectionParameters; override;
  end;

{ TTestMultiTenant }

  TTestMultiTenant = TTMultiTenant<TTestTenantConfig>;

{ TTestTenant }

  TTestTenant = TTTenant<TTestTenantConfig>;

{ TTHttpMultiTenantTests }

  [TestFixture]
  TTHttpMultiTenantTests = class
  public
    [Test]
    procedure TryGetDoesNotCreateTheTenant;

    [Test]
    procedure GetOrAddCreatesTheTenantOnce;

    [Test]
    procedure GetOrAddNormalizesTheNameToLowerCase;

    [Test]
    procedure TenantExposesConfigAndConnection;

    [Test]
    procedure RemoveDropsTheTenant;

    [Test]
    procedure GetAllListsTheCreatedTenants;

    [Test]
    procedure RemoveThenGetOrAddRecreatesTheTenant;
  end;

implementation

{ TTestTenantConfig }

function TTestTenantConfig.GetConnectionName: String;
begin
  result := Format('TrysilTestTenant_%s', [FName]);
end;

function TTestTenantConfig.GetParameters: TTFireDACConnectionParameters;
begin
  result := Default(TTFireDACConnectionParameters);
  result.Driver := 'SQLite';
  result.DatabaseName := Format('%s.db', [FName]);
end;

{ TTHttpMultiTenantTests }

procedure TTHttpMultiTenantTests.TryGetDoesNotCreateTheTenant;
var
  LTenant: TTestTenant;
begin
  Assert.IsFalse(
    TTestMultiTenant.Instance.TryGet('alpha', LTenant),
    'TryGet must not create a tenant that does not exist yet');
  Assert.IsFalse(
    Assigned(LTenant), 'TryGet must leave the result unassigned');
end;

procedure TTHttpMultiTenantTests.GetOrAddCreatesTheTenantOnce;
var
  LFirst: TTestTenant;
  LSecond: TTestTenant;
  LFound: TTestTenant;
begin
  LFirst := TTestMultiTenant.Instance.GetOrAdd('beta');
  Assert.IsTrue(Assigned(LFirst));

  LSecond := TTestMultiTenant.Instance.GetOrAdd('beta');
  Assert.IsTrue(
    LFirst = LSecond,
    'GetOrAdd must return the same instance on the second call');

  Assert.IsTrue(TTestMultiTenant.Instance.TryGet('beta', LFound));
  Assert.IsTrue(
    LFirst = LFound, 'TryGet must find the tenant GetOrAdd created');
end;

procedure TTHttpMultiTenantTests.GetOrAddNormalizesTheNameToLowerCase;
var
  LTenant: TTestTenant;
  LFound: TTestTenant;
begin
  LTenant := TTestMultiTenant.Instance.GetOrAdd('Gamma');
  Assert.AreEqual('gamma', LTenant.Name);

  Assert.IsTrue(TTestMultiTenant.Instance.TryGet('GAMMA', LFound));
  Assert.IsTrue(
    LTenant = LFound, 'TryGet must normalize the name like GetOrAdd');
end;

procedure TTHttpMultiTenantTests.TenantExposesConfigAndConnection;
var
  LTenant: TTestTenant;
begin
  LTenant := TTestMultiTenant.Instance.GetOrAdd('delta');
  Assert.IsTrue(Assigned(LTenant.Config));
  Assert.AreEqual('TrysilTestTenant_delta', LTenant.Config.ConnectionName);
  Assert.IsTrue(
    Assigned(LTenant.Connection),
    'A published tenant must have registered its connection');
end;

procedure TTHttpMultiTenantTests.RemoveDropsTheTenant;
var
  LFound: TTestTenant;
begin
  TTestMultiTenant.Instance.GetOrAdd('epsilon');
  Assert.IsTrue(TTestMultiTenant.Instance.TryGet('epsilon', LFound));

  TTestMultiTenant.Instance.Remove('EPSILON');
  Assert.IsFalse(
    TTestMultiTenant.Instance.TryGet('epsilon', LFound),
    'Remove must normalize the name and drop the tenant');
end;

procedure TTHttpMultiTenantTests.RemoveThenGetOrAddRecreatesTheTenant;
var
  LTenant: TTestTenant;
  LFound: TTestTenant;
begin
  TTestMultiTenant.Instance.GetOrAdd('eta');
  TTestMultiTenant.Instance.Remove('eta');

  LTenant := TTestMultiTenant.Instance.GetOrAdd('eta');
  Assert.IsTrue(
    Assigned(LTenant.Connection),
    'Re-adding a removed tenant must not fail on the connection registry');
  Assert.IsTrue(
    TTestMultiTenant.Instance.TryGet('eta', LFound),
    'The re-added tenant must be visible again');
end;

procedure TTHttpMultiTenantTests.GetAllListsTheCreatedTenants;
var
  LNames: TArray<String>;
  LName: String;
  LIsListed: Boolean;
begin
  TTestMultiTenant.Instance.GetOrAdd('zeta');

  LIsListed := False;
  LNames := TTestMultiTenant.Instance.GetAll;
  for LName in LNames do
    if LName.Equals('zeta') then
      LIsListed := True;

  Assert.IsTrue(LIsListed, 'GetAll must list every created tenant');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpMultiTenantTests);

end.
