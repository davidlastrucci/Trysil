(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.AllTypesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypesJSon,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerAllTypesJSonTests }

  [TestFixture]
  TTSqlServerAllTypesJSonTests = class(TTAbstractAllTypesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSqlServerAllTypesJSonTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

procedure TTSqlServerAllTypesJSonTests.Setup;
begin
  inherited;
end;

procedure TTSqlServerAllTypesJSonTests.TearDown;
begin
  inherited;
end;

end.
