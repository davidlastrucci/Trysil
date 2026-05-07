(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Relation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Relation,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerRelationTests }

  [TestFixture]
  TTSqlServerRelationTests = class(TTAbstractRelationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerRelationTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
