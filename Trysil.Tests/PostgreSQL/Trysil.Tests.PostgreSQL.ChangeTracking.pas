(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.ChangeTracking;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ChangeTracking,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLChangeTrackingTests }

  [TestFixture]
  TTPostgreSQLChangeTrackingTests = class(TTAbstractChangeTrackingTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLChangeTrackingTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
