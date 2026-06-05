(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseNullablePrimitivesJSonTests }

  [TestFixture]
  TTInterBaseNullablePrimitivesJSonTests = class(
    TTAbstractNullablePrimitivesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTInterBaseNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

procedure TTInterBaseNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTInterBaseNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
