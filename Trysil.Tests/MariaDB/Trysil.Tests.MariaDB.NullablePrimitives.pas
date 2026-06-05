(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBNullablePrimitivesTests }

  [TestFixture]
  TTMariaDBNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTMariaDBNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

procedure TTMariaDBNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTMariaDBNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
