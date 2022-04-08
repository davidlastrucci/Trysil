(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Types;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TTJSonSerializerConfig }

  TTJSonSerializerConfig = record
  strict private
    FMaxLevels: Integer;
    FDetails: Boolean;
  public
    constructor Create(const AConfig: TTJSonSerializerConfig); overload;
    constructor Create(
      const AMaxLevels: Integer; const ADetails: Boolean); overload;

    property MaxLevels: Integer read FMaxLevels write FMaxLevels;
    property Details: Boolean read FDetails write FDetails;
  end;

implementation

{ TTJSonSerializerConfig }

constructor TTJSonSerializerConfig.Create(
  const AConfig: TTJSonSerializerConfig);
begin
  FMaxLevels := AConfig.FMaxLevels;
  FDetails := AConfig.FDetails;
end;

constructor TTJSonSerializerConfig.Create(
  const AMaxLevels: Integer; const ADetails: Boolean);
begin
  FMaxLevels := AMaxLevels;
  FDetails := ADetails;
end;

end.
