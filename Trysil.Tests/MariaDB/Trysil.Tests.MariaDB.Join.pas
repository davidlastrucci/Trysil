(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Join;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Join,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBJoinTests }

  [TestFixture]
  TTMariaDBJoinTests = class(TTAbstractJoinTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBJoinTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
