(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.UpdateMode;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.UpdateMode,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLUpdateModeTests }

  [TestFixture]
  TTFirebirdSQLUpdateModeTests = class(TTAbstractUpdateModeTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLUpdateModeTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
