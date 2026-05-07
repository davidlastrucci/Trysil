(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.ChangeTracking;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ChangeTracking,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerChangeTrackingTests }

  [TestFixture]
  TTSqlServerChangeTrackingTests = class(TTAbstractChangeTrackingTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerChangeTrackingTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
