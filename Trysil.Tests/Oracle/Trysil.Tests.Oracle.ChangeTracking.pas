(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.ChangeTracking;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ChangeTracking,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleChangeTrackingTests }

  [TestFixture]
  TTOracleChangeTrackingTests = class(TTAbstractChangeTrackingTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleChangeTrackingTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
