(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.JSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.JSon,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseJSonTests }

  [TestFixture]
  TTInterBaseJSonTests = class(TTAbstractJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTInterBaseJSonTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

end.
