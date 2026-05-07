(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Crud;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Crud,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerCrudTests }

  [TestFixture]
  TTSqlServerCrudTests = class(TTAbstractCrudTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerCrudTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
