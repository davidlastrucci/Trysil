(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Join;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Join,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLJoinTests }

  [TestFixture]
  TTFirebirdSQLJoinTests = class(TTAbstractJoinTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLJoinTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
