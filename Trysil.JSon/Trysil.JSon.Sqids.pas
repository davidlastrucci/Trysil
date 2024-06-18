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
  System.JSon,
  System.NetEncoding.Sqids;
{$ELSE}
  System.JSon;
{$ENDIF}

type

{ TTJSonSqids }

  TTJSonSqids = class
  strict private
    class var FInstance: TTJSonSqids;

    class constructor ClassCreate;
    class destructor ClassDestroy;
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  strict private
    const Alphabet: String = '8j2ld03zr67axeskwt4fqgm9pcbh1y5ionvu';
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
    function Decode(const AValue: String): Integer;
    function TryDecode(const AValue: String; out AResult: Integer): Boolean;
    function Encode(const AValue: Integer): TJSonValue;

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

function TTJSonSqids.Decode(const AValue: String): Integer;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
    result := GetSqids().DecodeSingle(AValue.ToLower())
  else
    result := Integer.Parse(AValue);
{$ELSE}
  result := Integer.Parse(AValue);
{$ENDIF}
end;

function TTJSonSqids.TryDecode(
  const AValue: String; out AResult: Integer): Boolean;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
    result := GetSqids().TryDecodeSingle(AValue.ToLower(), AResult)
  else
    result := Integer.TryParse(AValue, AResult);
{$ELSE}
  result := Integer.TryParse(AValue, AResult);
{$ENDIF}
end;

function TTJSonSqids.Encode(const AValue: Integer): TJSonValue;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
    result := TJSonString.Create(GetSqids().Encode(AValue).ToLower())
  else
    result := TJSonNumber.Create(AValue);
{$ELSE}
  result := TJSonNumber.Create(AValue);
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
