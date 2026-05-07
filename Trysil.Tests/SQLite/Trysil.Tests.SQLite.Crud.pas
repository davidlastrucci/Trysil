(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Crud;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Crud,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteCrudTests }

  [TestFixture]
  TTSQLiteCrudTests = class(TTAbstractCrudTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteCrudTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
