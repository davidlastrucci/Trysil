(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.Relation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Relation,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseRelationTests }

  [TestFixture]
  TTInterBaseRelationTests = class(TTAbstractRelationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTInterBaseRelationTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

end.
