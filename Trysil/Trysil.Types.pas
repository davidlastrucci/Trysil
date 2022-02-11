(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Types;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Defaults,

  Trysil.Consts,
  Trysil.Exceptions;

type

{$INCLUDE 'Trysil.Conditionals.inc'}

{ TTPrimaryKey }

  TTPrimaryKey = Int32;

{ TTPrimaryKeyHelper }

  TTPrimaryKeyHelper = class
  strict private
    const IsQuoted: Boolean = False;
  public
    class function SqlValue(const AValue: TTPrimaryKey): String;
  end;

{ TTVersion }

  TTVersion = Int32;

{ TTNullable<T> }

{$RTTI EXPLICIT
  FIELDS([vcPrivate])
  METHODS([vcPrivate])}

  TTNullable<T> = record
{$IFDEF Managed_Records}
  strict private
    const NotNullValue: Boolean = False;
    const NullValue: Boolean = True;
{$ELSE}
  strict private
    const NotNullValue: String = '@@@';
    const NullValue: String = String.Empty;
{$ENDIF}
  strict private
    FValue: T;
{$IFDEF Managed_Records}
    FIsNull: Boolean;
{$ELSE}
    FIsNull: String;
{$ENDIF}

    procedure Clear;

    function GetValue: T;
    procedure SetValue(const AValue: T);
    function GetIsNull: Boolean;
  public
    constructor Create(const AValue: T); overload;
    constructor Create(const AValue: TTNullable<T>); overload;

    function GetValueOrDefault: T; overload;
    function GetValueOrDefault(const ADefaultValue: T): T; overload;

    function Equals(const AOther: TTNullable<T>): Boolean;

{$IFDEF Managed_Records}
    class operator Initialize(out ANullable: TTNullable<T>);
{$ENDIF}

    class operator Implicit(const AValue: TTNullable<T>): T;
    class operator Implicit(const AValue: T): TTNullable<T>;
    class operator Implicit(AValue: Pointer): TTNullable<T>;

    class operator Explicit(const AValue: TTNullable<T>): T;

    class operator Equal(const AValue1, AValue2: TTNullable<T>) : Boolean;
    class operator NotEqual(const AValue1, AValue2: TTNullable<T>) : Boolean;

    property Value: T read GetValue;
    property IsNull: Boolean read GetIsNull;
  end;

implementation

{ TTPrimaryKeyHelper }

class function TTPrimaryKeyHelper.SqlValue(const AValue: TTPrimaryKey): String;
begin
  if IsQuoted then
    result := AValue.ToString().QuotedString
  else
    result := AValue.ToString();
end;

{ TTNullable<T> }

constructor TTNullable<T>.Create(const AValue: T);
begin
  FIsNull := NotNullValue;
  FValue := AValue;
end;

constructor TTNullable<T>.Create(const AValue: TTNullable<T>);
begin
  if AValue.IsNull then
    Clear
  else
    Create(AValue.Value);
end;

procedure TTNullable<T>.Clear;
begin
  FIsNull := NullValue;
  FValue := Default(T);
end;

function TTNullable<T>.GetValue: T;
begin
  if IsNull then
    raise ETException.Create(SNullableTypeHasNoValue);
  result := FValue;
end;

procedure TTNullable<T>.SetValue(const AValue: T);
begin
  FIsNull := NotNullValue;
  FValue := AValue;
end;

function TTNullable<T>.GetValueOrDefault: T;
begin
  if not IsNull then
    result := FValue
  else
    result := Default(T);
end;

function TTNullable<T>.GetValueOrDefault(const ADefaultValue: T): T;
begin
  if not IsNull then
    result := FValue
  else
    result := ADefaultValue;
end;

function TTNullable<T>.Equals(const AOther: TTNullable<T>): Boolean;
begin
  if (not IsNull) and (not AOther.IsNull) then
    result := TEqualityComparer<T>.Default.Equals(FValue, AOther.FValue)
  else
    result := (IsNull = AOther.IsNull);
end;

{$IFDEF Managed_Records}
class operator TTNullable<T>.Initialize(out ANullable: TTNullable<T>);
begin
  ANullable.FIsNull := NullValue;
  ANullable.FValue := default(T);
end;
{$ENDIF}

class operator TTNullable<T>.Implicit(const AValue: TTNullable<T>): T;
begin
  result := AValue.Value;
end;

class operator TTNullable<T>.Implicit(const AValue: T): TTNullable<T>;
begin
  result := TTNullable<T>.Create(AValue);
end;

class operator TTNullable<T>.Implicit(AValue: Pointer): TTNullable<T>;
begin
  if not Assigned(AValue) then
    result.Clear
  else
    raise ETException.Create(SCannotAssignPointerToNullable);
end;

class operator TTNullable<T>.Explicit(const AValue: TTNullable<T>): T;
begin
  result := AValue.Value;
end;

class operator TTNullable<T>.Equal(
  const AValue1, AValue2: TTNullable<T>): Boolean;
begin
  result := AValue1.Equals(AValue2);
end;

class operator TTNullable<T>.NotEqual(
  const AValue1, AValue2: TTNullable<T>): Boolean;
begin
  result := not AValue1.Equals(AValue2);
end;

function TTNullable<T>.GetIsNull: Boolean;
begin
  result := (FIsNull = NullValue);
end;

end.
