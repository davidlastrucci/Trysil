(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.Time;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Time,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseTimeTests }

  [TestFixture]
  TTInterBaseTimeTests = class(TTAbstractTimeTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTInterBaseTimeTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

procedure TTInterBaseTimeTests.Setup;
begin
  inherited;
end;

procedure TTInterBaseTimeTests.TearDown;
begin
  inherited;
end;

end.
