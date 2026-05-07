(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.IdentityMap;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.IdentityMap,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteIdentityMapTests }

  [TestFixture]
  TTSQLiteIdentityMapTests = class(TTAbstractIdentityMapTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteIdentityMapTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
