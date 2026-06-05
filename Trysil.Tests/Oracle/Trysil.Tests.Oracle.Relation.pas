(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Relation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Relation,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleRelationTests }

  [TestFixture]
  TTOracleRelationTests = class(TTAbstractRelationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleRelationTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
