(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.ChangeTracking;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ChangeTracking,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBChangeTrackingTests }

  [TestFixture]
  TTMariaDBChangeTrackingTests = class(TTAbstractChangeTrackingTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBChangeTrackingTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
