(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleNullablePrimitivesTests }

  [TestFixture]
  TTOracleNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTOracleNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

procedure TTOracleNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTOracleNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
