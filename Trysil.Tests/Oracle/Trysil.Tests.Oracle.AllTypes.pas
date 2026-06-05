(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleAllTypesTests }

  [TestFixture]
  TTOracleAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTOracleAllTypesTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

procedure TTOracleAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTOracleAllTypesTests.TearDown;
begin
  inherited;
end;

end.
