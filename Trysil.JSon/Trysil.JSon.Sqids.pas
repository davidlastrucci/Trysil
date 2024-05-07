(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Sqids;

interface

uses
  System.SysUtils,
  System.Classes,
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  System.NetEncoding.Sqids,
{$ENDIF}
  System.JSon;

type

{ TTJSonSqids }

  TTJSonSqids = class
  strict private
    class var FInstance: TTJSonSqids;

    class constructor ClassCreate;
    class destructor ClassDestroy;
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  strict private
    const Alphabet: String = '8J2LD03ZR67AXESKWT4FQGM9PCBH1Y5IONVU';
    const Length: Integer = 8;
  strict private
    FSqids: TSqidsEncoding;
    FUseSqids: Boolean;

    function GetSqids: TSqidsEncoding;
{$ENDIF}
    function GetUseSqids: Boolean;
    procedure SetUseSqids(const AValue: Boolean);
  public
{$IF CompilerVersion >= 36} // Delphi 12 Athens
    constructor Create;
    destructor Destroy; override;
{$ENDIF}
    function Decode(const AValue: TJSonValue): TJSonValue;
    function TryDecode(
      const AValue: TJSonValue; out AResult: TJSonValue): Boolean;
    function Encode(const AValue: TJSonValue): TJSonValue;

    property UseSqids: Boolean read GetUseSqids write SetUseSqids;

    class property Instance: TTJSonSqids read FInstance;
  end;

implementation

{ TTJSonSqids }

class constructor TTJSonSqids.ClassCreate;
begin
  FInstance := TTJSonSqids.Create;
end;

class destructor TTJSonSqids.ClassDestroy;
begin
  FInstance.Free;
end;

{$IF CompilerVersion >= 36} // Delphi 12 Athens

constructor TTJSonSqids.Create;
begin
  inherited Create;
  FUseSqids := False;
  FSqids := nil;
end;

destructor TTJSonSqids.Destroy;
begin
  if Assigned(FSqids) then
    FSqids.Free;
  inherited Destroy;
end;

function TTJSonSqids.GetSqids: TSqidsEncoding;
begin
  if not Assigned(FSqids) then
    FSqids := TSqidsEncoding.Create(Alphabet, Length);
  result := FSqids;
end;

{$ENDIF}

function TTJSonSqids.Decode(const AValue: TJSonValue): TJSonValue;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
    result := TJSonNumber.Create(
      GetSqids().DecodeSingle(AValue.GetValue<String>().ToUpper()))
  else
    result := AValue;
{$ELSE}
  result := AValue;
{$ENDIF}
end;

function TTJSonSqids.TryDecode(
  const AValue: TJSonValue; out AResult: TJSonValue): Boolean;
{$IF CompilerVersion >= 36} // Delphi 12 Athens
var
  LResult: Integer;
{$ENDIF}
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
  begin
    result := GetSqids().TryDecodeSingle(
      AValue.GetValue<String>().ToUpper(), LResult);
    if result then
      AResult := TJSonNumber.Create(LResult);
  end
  else
  begin
    AResult := AValue;
    result := True;
  end;
{$ELSE}
  AResult := AValue;
  result := True;
{$ENDIF}
end;

function TTJSonSqids.Encode(const AValue: TJSonValue): TJSonValue;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
    result := TJSonString.Create(
      GetSqids().Encode(AValue.GetValue<Integer>()).ToLower())
  else
    result := AValue;
{$ELSE}
  result := AValue;
{$ENDIF}
end;

function TTJSonSqids.GetUseSqids: Boolean;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  result := FUseSqids;
{$ELSE}
  result := False;
{$ENDIF}
end;

procedure TTJSonSqids.SetUseSqids(const AValue: Boolean);
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  FUseSqids := AValue;
{$ENDIF}
end;

end.
