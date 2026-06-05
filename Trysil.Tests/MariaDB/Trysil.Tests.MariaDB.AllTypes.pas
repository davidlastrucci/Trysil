(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBAllTypesTests }

  [TestFixture]
  TTMariaDBAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTMariaDBAllTypesTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

procedure TTMariaDBAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTMariaDBAllTypesTests.TearDown;
begin
  inherited;
end;

end.
