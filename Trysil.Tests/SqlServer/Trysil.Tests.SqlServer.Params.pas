(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Params;

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework,

  Trysil.Data.FireDAC.SqlServer;

type

{ TTSqlServerParamsTests }

  [TestFixture]
  TTSqlServerParamsTests = class
  strict private
    FParameters: TStrings;
    FEncrypt: TTSqlServerEncrypt;
    FTrustServerCertificate: TTSqlServerTrustServerCertificate;
    FDriverODBCAdvanced: String;

    function HasODBCAdvanced: Boolean;
    function ODBCAdvanced: String;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TheKeywordIsAddedWhenThereIsNothingElse;

    [Test]
    procedure TheDriverWideValueIsKept;

    [Test]
    procedure TheDriverWideKeywordIsLeftAlone;

    [Test]
    procedure AKeywordFromTheHostWins;

    [Test]
    procedure AKeywordFromTheHostWinsWhateverItsCase;

    [Test]
    procedure ATrailingSemicolonDoesNotProduceAnEmptyItem;

    [Test]
    procedure NothingIsWrittenOnDriverDefault;
  end;

implementation

{ TTSqlServerParamsTests }

procedure TTSqlServerParamsTests.Setup;
begin
  FEncrypt := TTSqlServerParams.Instance.Encrypt;
  FTrustServerCertificate :=
    TTSqlServerParams.Instance.TrustServerCertificate;
  FDriverODBCAdvanced := TTSqlServerConnection.Driver.ODBCAdvanced;

  TTSqlServerParams.Instance.Encrypt := TTSqlServerEncrypt.DriverDefault;
  TTSqlServerConnection.Driver.ODBCAdvanced := String.Empty;
  FParameters := TStringList.Create;
end;

procedure TTSqlServerParamsTests.TearDown;
begin
  FParameters.Free;
  TTSqlServerConnection.Driver.ODBCAdvanced := FDriverODBCAdvanced;
  TTSqlServerParams.Instance.TrustServerCertificate :=
    FTrustServerCertificate;
  TTSqlServerParams.Instance.Encrypt := FEncrypt;
end;

function TTSqlServerParamsTests.HasODBCAdvanced: Boolean;
begin
  result := FParameters.IndexOfName('ODBCAdvanced') >= 0;
end;

function TTSqlServerParamsTests.ODBCAdvanced: String;
begin
  result := FParameters.Values['ODBCAdvanced'];
end;

procedure TTSqlServerParamsTests.TheKeywordIsAddedWhenThereIsNothingElse;
begin
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual(
    'TrustServerCertificate=yes',
    ODBCAdvanced,
    'TrustServerCertificate is not a connection def keyword of its own: ' +
    'the only channel to the driver is ODBCAdvanced');
end;

procedure TTSqlServerParamsTests.TheDriverWideValueIsKept;
begin
  TTSqlServerConnection.Driver.ODBCAdvanced := 'ApplicationIntent=ReadOnly';
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual(
    'ApplicationIntent=ReadOnly;TrustServerCertificate=yes',
    ODBCAdvanced,
    'FireDAC uses the driver-wide ODBCAdvanced only when the per ' +
    'connection one is empty, so writing ours used to throw away ' +
    'everything the host had put there');
end;

procedure TTSqlServerParamsTests.TheDriverWideKeywordIsLeftAlone;
begin
  TTSqlServerConnection.Driver.ODBCAdvanced := 'TrustServerCertificate=no';
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.IsFalse(
    HasODBCAdvanced,
    'The host decided the keyword driver-wide: writing nothing per ' +
    'connection leaves FireDAC reading the host value intact');
end;

procedure TTSqlServerParamsTests.AKeywordFromTheHostWins;
begin
  FParameters.Add('ODBCAdvanced=TrustServerCertificate=no');
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual(
    'TrustServerCertificate=no',
    ODBCAdvanced,
    'An explicit value from the host wins, as it already did for ' +
    'Encrypt: appending would have named the keyword twice and left the ' +
    'winner to the ODBC driver');
end;

procedure TTSqlServerParamsTests.AKeywordFromTheHostWinsWhateverItsCase;
begin
  FParameters.Add('ODBCAdvanced=trustservercertificate=NO');
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.Yes;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual(
    'trustservercertificate=NO',
    ODBCAdvanced,
    'ODBC keywords are not case sensitive, so a case variant from the ' +
    'host is the same keyword and must not earn a second copy');
end;

procedure TTSqlServerParamsTests.ATrailingSemicolonDoesNotProduceAnEmptyItem;
begin
  FParameters.Add('ODBCAdvanced=ApplicationIntent=ReadOnly;');
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.No;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.AreEqual(
    'ApplicationIntent=ReadOnly;TrustServerCertificate=no',
    ODBCAdvanced,
    'A separator the host already wrote must not become an empty ' +
    'element in the ODBC connection string');
end;

procedure TTSqlServerParamsTests.NothingIsWrittenOnDriverDefault;
begin
  TTSqlServerConnection.Driver.ODBCAdvanced := 'ApplicationIntent=ReadOnly';
  TTSqlServerParams.Instance.TrustServerCertificate :=
    TTSqlServerTrustServerCertificate.DriverDefault;

  TTSqlServerParams.Instance.AddExtraParameters(FParameters);

  Assert.IsFalse(
    HasODBCAdvanced,
    'DriverDefault means Trysil has no opinion, so it must not touch a ' +
    'parameter the host owns');
end;

end.
