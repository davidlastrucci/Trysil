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

{ TTestFailingTenantConfig }

  TTestFailingTenantConfig = class(TTTenantConfig)
  strict private
    class var FBuilt: Integer;
  strict protected
    function GetConnectionName: String; override;
    function GetParameters: TTFireDACConnectionParameters; override;
  public
    class procedure ResetBuilt;

    class property Built: Integer read FBuilt;
  end;

{ TTestBoundedTenantConfig }

  TTestBoundedTenantConfig = class(TTestFailingTenantConfig)
  end;

{ TTestSweepTenantConfig }

  TTestSweepTenantConfig = class(TTestFailingTenantConfig)
  end;

{ TTestMultiTenant }

  TTestMultiTenant = TTMultiTenant<TTestTenantConfig>;

{ TTestFailingMultiTenant }

  TTestFailingMultiTenant = TTMultiTenant<TTestFailingTenantConfig>;

{ TTestBoundedMultiTenant }

  TTestBoundedMultiTenant = TTMultiTenant<TTestBoundedTenantConfig>;

{ TTestSweepMultiTenant }

  TTestSweepMultiTenant = TTMultiTenant<TTestSweepTenantConfig>;

{ TTestTenant }

  TTestTenant = TTTenant<TTestTenantConfig>;

{ TTHttpTenantCircuitBreakerTests }

  [TestFixture]
  TTHttpTenantCircuitBreakerTests = class
  strict private
    const MaxFailures: Integer = 128;
  strict private
    FRefused: Boolean;

    function TryGetOrAdd(const AName: String): Boolean;
    function RefusalOf(const AName: String): ETTenantUnavailable;
    procedure RefuseBounded(const AName: String);
    procedure RefuseSweep(const AName: String);
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AFailureIsNotRetriedWhileItIsWarm;

    [Test]
    procedure AnExpiredFailureIsRetried;

    [Test]
    procedure ACachedRefusalCarriesTheOriginalCause;

    [Test]
    procedure TheFailuresAreBounded;

    [Test]
    procedure AnExpiredFailureIsSweptWhenAnotherArrives;
  end;

{ TTHttpMultiTenantTests }

  [TestFixture]
  TTHttpMultiTenantTests = class
  strict private
    const TurkishLCID = $041F;
  public
    [Test]
    procedure TryGetDoesNotCreateTheTenant;

    [Test]
    procedure ATenantNameSurvivesTheLocaleOfTheMachine;

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

    [Test]
    procedure ANameThatCannotBeOneIsRefused;

    [Test]
    procedure AnOrdinaryNameIsAccepted;

    [Test]
    procedure TheRefusalIsCatchableAsATenantFailure;
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

{ TTestFailingTenantConfig }

function TTestFailingTenantConfig.GetConnectionName: String;
begin
  result := Format('TrysilTestFailingTenant_%s', [FName]);
end;

function TTestFailingTenantConfig.GetParameters: TTFireDACConnectionParameters;
begin
  Inc(FBuilt);
  result := Default(TTFireDACConnectionParameters);
  result.Driver := 'NoSuchDriver';
  result.DatabaseName := Format('%s.db', [FName]);
end;

class procedure TTestFailingTenantConfig.ResetBuilt;
begin
  FBuilt := 0;
end;

{ TTHttpTenantCircuitBreakerTests }

procedure TTHttpTenantCircuitBreakerTests.Setup;
begin
  FRefused := False;
  TTestFailingTenantConfig.ResetBuilt;
end;

procedure TTHttpTenantCircuitBreakerTests.RefuseBounded(const AName: String);
begin
  try
    TTestBoundedMultiTenant.Instance.GetOrAdd(AName);
  except
    on E: ETTenantUnavailable do
      FRefused := True;
  end;
end;

procedure TTHttpTenantCircuitBreakerTests.RefuseSweep(const AName: String);
begin
  try
    TTestSweepMultiTenant.Instance.GetOrAdd(AName);
  except
    on E: ETTenantUnavailable do
      FRefused := True;
  end;
end;

procedure TTHttpTenantCircuitBreakerTests.TearDown;
begin
  TTestFailingMultiTenant.Instance.FailureCooldown := 5000;
  TTestSweepMultiTenant.Instance.FailureCooldown := 5000;
end;

function TTHttpTenantCircuitBreakerTests.TryGetOrAdd(
  const AName: String): Boolean;
begin
  result := True;
  try
    TTestFailingMultiTenant.Instance.GetOrAdd(AName);
  except
    on E: ETTenantUnavailable do
      result := False;
  end;
end;

function TTHttpTenantCircuitBreakerTests.RefusalOf(
  const AName: String): ETTenantUnavailable;
begin
  result := nil;
  try
    TTestFailingMultiTenant.Instance.GetOrAdd(AName);
  except
    on E: ETTenantUnavailable do
      result := ETTenantUnavailable.Create(
        E.TenantName, E.OriginalClassName, E.Message);
  end;
end;

procedure TTHttpTenantCircuitBreakerTests.AFailureIsNotRetriedWhileItIsWarm;
var
  LAfterFirst: Integer;
begin
  Assert.IsFalse(
    TryGetOrAdd('warm'), 'Precondition: this tenant cannot be created');
  LAfterFirst := TTestFailingTenantConfig.Built;

  Assert.IsFalse(TryGetOrAdd('warm'), 'And it must keep being refused');
  Assert.AreEqual<Integer>(
    LAfterFirst,
    TTestFailingTenantConfig.Built,
    'The second call must be answered from the failure, without touching ' +
    'the database again: a tenant whose server is down would otherwise ' +
    'cost every request a connection timeout');
end;

procedure TTHttpTenantCircuitBreakerTests.AnExpiredFailureIsRetried;
var
  LAfterFirst: Integer;
begin
  TTestFailingMultiTenant.Instance.FailureCooldown := 0;

  Assert.IsFalse(
    TryGetOrAdd('cold'), 'Precondition: this tenant cannot be created');
  LAfterFirst := TTestFailingTenantConfig.Built;

  Assert.IsFalse(TryGetOrAdd('cold'), 'And it is still refused');
  Assert.IsTrue(
    TTestFailingTenantConfig.Built > LAfterFirst,
    'But once the cooldown is over the tenant must be tried again, or a ' +
    'server that came back would stay unreachable for good');
end;

procedure TTHttpTenantCircuitBreakerTests.ACachedRefusalCarriesTheOriginalCause;
var
  LFirst: ETTenantUnavailable;
  LCached: ETTenantUnavailable;
begin
  LFirst := RefusalOf('cause');
  try
    LCached := RefusalOf('cause');
    try
      Assert.IsNotNull(LFirst, 'Precondition: the first call must refuse');
      Assert.IsNotNull(LCached, 'Precondition: the second call must refuse');
      Assert.AreEqual(
        LFirst.OriginalClassName,
        LCached.OriginalClassName,
        'A refusal served from the failure must name the same cause as ' +
        'the one that was actually raised, or the log stops being usable');
      Assert.AreEqual(
        LFirst.Message,
        LCached.Message,
        'And say the same thing');
    finally
      if Assigned(LCached) then
        LCached.Free;
    end;
  finally
    if Assigned(LFirst) then
      LFirst.Free;
  end;
end;

procedure TTHttpTenantCircuitBreakerTests.TheFailuresAreBounded;
var
  LIndex: Integer;
begin
  for LIndex := 1 to MaxFailures * 2 do
    RefuseBounded(Format('bound%d', [LIndex]));

  Assert.IsTrue(FRefused, 'Precondition: these tenants cannot be created');
  Assert.AreEqual<Integer>(
    MaxFailures,
    TTestBoundedMultiTenant.Instance.FailureCount,
    'The failures are keyed by a name that comes from the request, so ' +
    'without a ceiling a caller could grow that dictionary until the ' +
    'process ran out of memory');
end;

procedure
  TTHttpTenantCircuitBreakerTests.AnExpiredFailureIsSweptWhenAnotherArrives;
begin
  TTestSweepMultiTenant.Instance.FailureCooldown := 0;
  RefuseSweep('sweep1');
  RefuseSweep('sweep2');

  Assert.IsTrue(FRefused, 'Precondition: these tenants cannot be created');
  Assert.AreEqual<Integer>(
    1,
    TTestSweepMultiTenant.Instance.FailureCount,
    'A failure that arrives sweeps the expired ones, so the dictionary ' +
    'keeps only what someone may still read: two failures that expire at ' +
    'once must leave one behind, not two');
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

procedure TTHttpMultiTenantTests.ATenantNameSurvivesTheLocaleOfTheMachine;
var
  LSysLocale: TSysLocale;
  LTenant: TTestTenant;
  LFound: TTestTenant;
begin
  LSysLocale := SysLocale;
  try
    SysLocale.DefaultLCID := TurkishLCID;

    LTenant := TTestMultiTenant.Instance.GetOrAdd('Italia');
    Assert.AreEqual(
      'italia',
      LTenant.Name,
      'The name was folded with the language of the machine and then ' +
      'validated against ASCII: on a Turkish machine the I became a ' +
      'dotless one, which the validator refuses, so a perfectly legal ' +
      'tenant could not be created at all');

    Assert.IsTrue(
      TTestMultiTenant.Instance.TryGet('ITALIA', LFound),
      'and the two spellings must reach the same tenant, because this is ' +
      'the identifier that decides which database is opened');
    Assert.IsTrue(LTenant = LFound);
  finally
    SysLocale := LSysLocale;
  end;
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

procedure TTHttpMultiTenantTests.ANameThatCannotBeOneIsRefused;
begin
  Assert.IsFalse(
    TTTenantName.IsValid(String.Empty),
    'An empty name would register a connection definition with no name');
  Assert.IsFalse(
    TTTenantName.IsValid('../other'),
    'The name reaches a database name or a path in most applications');
  Assert.IsFalse(
    TTTenantName.IsValid('acme;Database=other'),
    'And a separator in it is a parameter smuggled into a connection ' +
    'definition');
  Assert.IsFalse(
    TTTenantName.IsValid('.hidden'),
    'A name has to start with a letter or a digit');
  Assert.IsFalse(
    TTTenantName.IsValid(StringOfChar('a', 64)),
    'And it has to be a name, not a payload');
end;

procedure TTHttpMultiTenantTests.AnOrdinaryNameIsAccepted;
begin
  Assert.IsTrue(
    TTTenantName.IsValid('acme'),
    'Precondition: the ordinary case still passes');
  Assert.IsTrue(
    TTTenantName.IsValid('acme.example.com'),
    'A host name is a normal way to name a tenant');
  Assert.IsTrue(
    TTTenantName.IsValid('acme-2_test'),
    'And so is a name carrying a dash or an underscore');
end;

procedure TTHttpMultiTenantTests.TheRefusalIsCatchableAsATenantFailure;
var
  LRefused: Boolean;
begin
  LRefused := False;
  try
    TTestMultiTenant.Instance.GetOrAdd('../other');
  except
    on E: ETTenantUnavailable do
      LRefused := True;
  end;

  Assert.IsTrue(
    LRefused,
    'A host already turns ETTenantUnavailable into its own status, so ' +
    'the narrower refusal has to arrive through the same catch');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpMultiTenantTests);
  TDUnitX.RegisterTestFixture(TTHttpTenantCircuitBreakerTests);

end.
