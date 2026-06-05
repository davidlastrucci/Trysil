(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBNullablePrimitivesJSonTests }

  [TestFixture]
  TTMariaDBNullablePrimitivesJSonTests = class(
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

function TTMariaDBNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

procedure TTMariaDBNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTMariaDBNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
