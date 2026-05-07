(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.ChangeTracking;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ChangeTracking,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteChangeTrackingTests }

  [TestFixture]
  TTSQLiteChangeTrackingTests = class(TTAbstractChangeTrackingTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteChangeTrackingTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
