(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Relation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Relation,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBRelationTests }

  [TestFixture]
  TTMariaDBRelationTests = class(TTAbstractRelationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBRelationTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
