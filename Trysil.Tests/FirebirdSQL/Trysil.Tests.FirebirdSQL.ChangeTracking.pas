(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.ChangeTracking;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ChangeTracking,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLChangeTrackingTests }

  [TestFixture]
  TTFirebirdSQLChangeTrackingTests = class(TTAbstractChangeTrackingTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLChangeTrackingTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
