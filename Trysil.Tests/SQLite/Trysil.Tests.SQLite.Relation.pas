(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Relation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Relation,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteRelationTests }

  [TestFixture]
  TTSQLiteRelationTests = class(TTAbstractRelationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

{ TTSQLiteRelationTests }

function TTSQLiteRelationTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
