(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBHttpEntityTests }

  [TestFixture]
  TTMariaDBHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
