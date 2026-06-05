(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleNullablePrimitivesJSonTests }

  [TestFixture]
  TTOracleNullablePrimitivesJSonTests = class(
    TTAbstractNullablePrimitivesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTOracleNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

procedure TTOracleNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTOracleNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
