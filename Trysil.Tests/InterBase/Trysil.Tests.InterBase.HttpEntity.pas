(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseHttpEntityTests }

  [TestFixture]
  TTInterBaseHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTInterBaseHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

end.
