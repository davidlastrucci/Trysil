(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.ContextApi;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ContextApi,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseContextApiTests }

  [TestFixture]
  TTInterBaseContextApiTests = class(TTAbstractContextApiTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTInterBaseContextApiTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

end.
