(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerNullablePrimitivesJSonTests }

  [TestFixture]
  TTSqlServerNullablePrimitivesJSonTests = class(
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

function TTSqlServerNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

procedure TTSqlServerNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTSqlServerNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
