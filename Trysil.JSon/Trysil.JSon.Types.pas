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
  System.Classes,
  System.JSon;

{$SCOPEDENUMS ON}

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

    class function Default: TTJSonSerializerConfig; static;
    class function WithDetails: TTJSonSerializerConfig; static;
    class function WithRelations: TTJSonSerializerConfig; static;
    class function EntityOnly: TTJSonSerializerConfig; static;
  end;

{ TTJSonValueState }

  TTJSonValueState = (Missing, Invalid, Valid);

{ TTJSonValues }

  TTJSonValues = class
  strict private
    class function StateOf(const AJSon: TJSonValue): TTJSonValueState;
  public
    class function GetString(
      const AJSon: TJSonValue;
      const AName: String;
      out AValue: String): TTJSonValueState;
    class function GetInteger(
      const AJSon: TJSonValue;
      const AName: String;
      out AValue: Integer): TTJSonValueState;
    class function GetArray(
      const AJSon: TJSonValue;
      const AName: String;
      out AValue: TJSonArray): TTJSonValueState;
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

class function TTJSonSerializerConfig.Default: TTJSonSerializerConfig;
begin
  result := TTJSonSerializerConfig.Create(-1, False);
end;

class function TTJSonSerializerConfig.WithDetails: TTJSonSerializerConfig;
begin
  result := TTJSonSerializerConfig.Create(1, True);
end;

class function TTJSonSerializerConfig.WithRelations: TTJSonSerializerConfig;
begin
  result := TTJSonSerializerConfig.Create(1, False);
end;

class function TTJSonSerializerConfig.EntityOnly: TTJSonSerializerConfig;
begin
  result := TTJSonSerializerConfig.Create(0, False);
end;

{ TTJSonValues }

class function TTJSonValues.StateOf(
  const AJSon: TJSonValue): TTJSonValueState;
begin
  if (not Assigned(AJSon)) or (AJSon is TJSonNull) then
    result := TTJSonValueState.Missing
  else
    result := TTJSonValueState.Valid;
end;

class function TTJSonValues.GetString(
  const AJSon: TJSonValue;
  const AName: String;
  out AValue: String): TTJSonValueState;
var
  LValue: TJSonValue;
begin
  AValue := String.Empty;
  LValue := AJSon.FindValue(AName);
  result := StateOf(LValue);
  if (result = TTJSonValueState.Valid) and
    (not LValue.TryGetValue<String>(AValue)) then
    result := TTJSonValueState.Invalid;
end;

class function TTJSonValues.GetInteger(
  const AJSon: TJSonValue;
  const AName: String;
  out AValue: Integer): TTJSonValueState;
var
  LValue: TJSonValue;
begin
  AValue := 0;
  LValue := AJSon.FindValue(AName);
  result := StateOf(LValue);
  if (result = TTJSonValueState.Valid) and
    (not LValue.TryGetValue<Integer>(AValue)) then
    result := TTJSonValueState.Invalid;
end;

class function TTJSonValues.GetArray(
  const AJSon: TJSonValue;
  const AName: String;
  out AValue: TJSonArray): TTJSonValueState;
var
  LValue: TJSonValue;
begin
  AValue := nil;
  LValue := AJSon.FindValue(AName);
  result := StateOf(LValue);
  if result = TTJSonValueState.Valid then
    if LValue is TJSonArray then
      AValue := TJSonArray(LValue)
    else
      result := TTJSonValueState.Invalid;
end;

end.
