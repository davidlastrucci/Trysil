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

  Trysil.Consts,
  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions,
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
    const DefaultAlphabet: String = '8j2ld03zr67axeskwt4fqgm9pcbh1y5ionvu';
    const DefaultLength: Integer = 8;
    const MinAlphabetLength: Integer = 5;
  strict private
    FSqids: TSqidsEncoding;
    FUseSqids: Boolean;
    FAlphabet: String;
    FLock: TObject;

    function GetSqids: TSqidsEncoding;
    procedure CheckAlphabet(const AValue: String);
    function GetAlphabet: String;
    procedure SetAlphabet(const AValue: String);
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
{$IF CompilerVersion >= 36} // Delphi 12 Athens
    property Alphabet: String read GetAlphabet write SetAlphabet;
{$ENDIF}

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
  FInstance := nil;
end;

{$IF CompilerVersion >= 36} // Delphi 12 Athens

constructor TTJSonSqids.Create;
begin
  inherited Create;
  FUseSqids := False;
  FSqids := nil;
  FAlphabet := DefaultAlphabet;
  FLock := TObject.Create;
end;

destructor TTJSonSqids.Destroy;
begin
  if Assigned(FSqids) then
    FSqids.Free;
  FLock.Free;
  inherited Destroy;
end;

function TTJSonSqids.GetSqids: TSqidsEncoding;
begin
  TMonitor.Enter(FLock);
  try
    if not Assigned(FSqids) then
      FSqids := TSqidsEncoding.Create(FAlphabet, DefaultLength);
    result := FSqids;
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TTJSonSqids.GetAlphabet: String;
begin
  TMonitor.Enter(FLock);
  try
    result := FAlphabet;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TTJSonSqids.CheckAlphabet(const AValue: String);
var
  LIndex: Integer;
  LChar: Char;
begin
  if AValue.Length < MinAlphabetLength then
    raise ETJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SSqidsAlphabetTooShort), [
        MinAlphabetLength]);

  for LIndex := 1 to AValue.Length do
  begin
    LChar := AValue.Chars[LIndex - 1];
    if (Ord(LChar) > 127) or CharInSet(LChar, ['A' .. 'Z']) then
      raise ETJSonException.CreateFmt(
        TTLanguage.Instance.Translate(SSqidsAlphabetNotLowerCase), [LChar]);
    if AValue.IndexOf(LChar) <> LIndex - 1 then
      raise ETJSonException.CreateFmt(
        TTLanguage.Instance.Translate(SSqidsAlphabetNotUnique), [LChar]);
  end;
end;

procedure TTJSonSqids.SetAlphabet(const AValue: String);
begin
  CheckAlphabet(AValue);

  TMonitor.Enter(FLock);
  try
    if Assigned(FSqids) then
      raise ETJSonException.Create(
        TTLanguage.Instance.Translate(SSqidsAlphabetInUse));
    FAlphabet := AValue;
  finally
    TMonitor.Exit(FLock);
  end;
end;

{$ENDIF}

function TTJSonSqids.Decode(const AValue: String): Integer;
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  if FUseSqids then
    result := GetSqids().DecodeSingle(AValue.ToLowerInvariant)
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
    result := GetSqids().TryDecodeSingle(AValue.ToLowerInvariant, AResult)
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
    result := TJSonString.Create(GetSqids().Encode(AValue).ToLowerInvariant)
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
