(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.AllTypesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypesJSon,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBAllTypesJSonTests }

  [TestFixture]
  TTMariaDBAllTypesJSonTests = class(TTAbstractAllTypesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTMariaDBAllTypesJSonTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

procedure TTMariaDBAllTypesJSonTests.Setup;
begin
  inherited;
end;

procedure TTMariaDBAllTypesJSonTests.TearDown;
begin
  inherited;
end;

end.
