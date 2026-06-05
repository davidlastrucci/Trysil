(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.UpdateMode;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.UpdateMode,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseUpdateModeTests }

  [TestFixture]
  TTInterBaseUpdateModeTests = class(TTAbstractUpdateModeTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTInterBaseUpdateModeTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

end.
