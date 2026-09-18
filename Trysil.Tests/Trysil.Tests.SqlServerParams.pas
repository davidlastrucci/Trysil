(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServerParams;

interface

uses
  System.Classes,
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SqlServer;

type

{ TTSqlServerParamsTests }

  [TestFixture]
  TTSqlServerParamsTests = class
  strict private
    FEncrypt: TTSqlServerEncrypt;
    FTrustServerCertificate: TTSqlServerTrustServerCertificate;
    FParameters: TStrings;

    function ValueOf(const AName: String): String;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure DriverDefaultEmitsNothing;

    [Test]
    procedure EncryptIsEmittedWhenAsked;

    [Test]
    procedure TrustTravelsThroughODBCAdvanced;

    [Test]
    procedure TrustIsAppendedToWhatTheHostWrote;

    [Test]
    procedure AnExplicitValueIsNotOverwritten;

    [Test]
    procedure TwoCallsDoNotDuplicateAValue;

    [Test]
    procedure RegisterConnectionDoesNotGrowTheCallerList;
  end;

implementation

{ TTSqlServerParamsTests }

procedure TTSqlServerParamsTests.Setup;
begin
  FEncrypt := TTSqlServerParams.Instance.Encrypt;
  FTrustServerCertificate :=
    TTSqlServerParams.Instance.TrustServerCertificate;
  TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.DriverDefault;
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.DriverDefault;
  FParameters := TStringList.Create;
end;

procedure TTSqlServerParamsTests.TearDown;
begin
  FParameters.Free;
  TTSqlServerParams.Instance.Encrypt := FEncrypt;
  TTSqlServerParams.Instance.TrustServerCertificate :=
    FTrustServerCertificate;
end;

function TTSqlServerParamsTests.ValueOf(const AName: String): String;
begin
  result := FParameters.Values[AName];
end;

procedure TTSqlServerParamsTests.DriverDefaultEmitsNothing;
begin
  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual<Integer>(0, FParameters.Count,
    'DriverDefault must leave the connection definition alone');
end;

procedure TTSqlServerParamsTests.EncryptIsEmittedWhenAsked;
begin
  TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.No;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual('No', ValueOf('Encrypt'));
  Assert.AreEqual(String.Empty, ValueOf('ODBCAdvanced'),
    'The other setting is left at the driver default');
end;

procedure TTSqlServerParamsTests.TrustTravelsThroughODBCAdvanced;
begin
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual('TrustServerCertificate=yes', ValueOf('ODBCAdvanced'),
    'TrustServerCertificate is not a keyword FireDAC knows, so a plain ' +
    'parameter is dropped from the connection string without an error');
  Assert.AreEqual(String.Empty, ValueOf('TrustServerCertificate'),
    'The naked parameter must not be emitted: it would do nothing');
end;

procedure TTSqlServerParamsTests.TrustIsAppendedToWhatTheHostWrote;
begin
  FParameters.Add('ODBCAdvanced=ColumnEncryption=Enabled');
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual(
    'ColumnEncryption=Enabled;TrustServerCertificate=yes',
    ValueOf('ODBCAdvanced'),
    'ODBCAdvanced is one string for many settings, so ours is appended: ' +
    'skipping it, as Encrypt does, would drop it in the same silence this ' +
    'setting exists to end');
  Assert.AreEqual<Integer>(1, FParameters.Count);
end;

procedure TTSqlServerParamsTests.AnExplicitValueIsNotOverwritten;
begin
  FParameters.Add('Encrypt=No');
  TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual('No', ValueOf('Encrypt'),
    'What the host wrote by hand wins over the process-wide value');
  Assert.AreEqual<Integer>(1, FParameters.Count);
end;

procedure TTSqlServerParamsTests.TwoCallsDoNotDuplicateAValue;
begin
  TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.Yes;
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);
  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual<Integer>(2, FParameters.Count,
    'A list registered twice must not grow, or its signature moves and ' +
    'the second registration is refused as a duplicate');
  Assert.AreEqual('TrustServerCertificate=yes', ValueOf('ODBCAdvanced'),
    'And the appended setting must not be appended twice');
end;

procedure TTSqlServerParamsTests.RegisterConnectionDoesNotGrowTheCallerList;
var
  LCount: Integer;
begin
  TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.Yes;
  FParameters.Add('Server=localhost');
  FParameters.Add('Database=Probe');
  FParameters.Add('OSAuthent=Yes');
  LCount := FParameters.Count;

  TTSqlServerConnection.RegisterConnection('TrysilListProbeA', FParameters);
  TTSqlServerConnection.RegisterConnection('TrysilListProbeB', FParameters);

  Assert.AreEqual<Integer>(LCount, FParameters.Count,
    'RegisterConnection applies the process-wide settings to a copy: if ' +
    'it wrote into the caller list, the second registration would carry ' +
    'a different signature and be refused as a duplicate');
end;

initialization
  TDUnitX.RegisterTestFixture(TTSqlServerParamsTests);

end.
