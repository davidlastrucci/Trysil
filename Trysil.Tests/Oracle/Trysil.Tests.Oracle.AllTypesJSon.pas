(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.AllTypesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypesJSon,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleAllTypesJSonTests }

  [TestFixture]
  TTOracleAllTypesJSonTests = class(TTAbstractAllTypesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTOracleAllTypesJSonTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

procedure TTOracleAllTypesJSonTests.Setup;
begin
  inherited;
end;

procedure TTOracleAllTypesJSonTests.TearDown;
begin
  inherited;
end;

end.
