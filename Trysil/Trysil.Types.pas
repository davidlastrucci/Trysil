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

  Trysil.Exceptions;

type

{ TTPrimaryKey }

  TTPrimaryKey = Int32;

{ TTVersion }

  TTVersion = Int32;

{ TTNullable<T> }

  TTNullable<T> = record
  strict private
    const NotNullValue = '@';
  strict private
    FValue: T;
    FIsNull: String;

    procedure Clear;

    function GetValue: T;
    function GetIsNull: Boolean;
  public
    constructor Create(const AValue: T); overload;
    constructor Create(const AValue: TTNullable<T>); overload;

    function GetValueOrDefault: T; overload;
    function GetValueOrDefault(const ADefaultValue: T): T; overload;

    function Equals(const AOther: TTNullable<T>): Boolean;

    class operator Implicit(const AValue: TTNullable<T>): T;
    class operator Implicit(const AValue: T): TTNullable<T>;
    class operator Implicit(AValue: Pointer): TTNullable<T>;

    class operator Explicit(const AValue: TTNullable<T>): T;

    class operator Equal(const AValue1, AValue2: TTNullable<T>) : Boolean;
    class operator NotEqual(const AValue1, AValue2: TTNullable<T>) : Boolean;

    property Value: T read GetValue;
    property IsNull: Boolean read GetIsNull;
  end;

{ resourcestring }

resourcestring
  SNullableTypeHasNoValue = 'Nullable type has no value: invalid operation.';
  SCannotAssignPointerToNullable = 'Cannot assign non-null pointer to nullable type.';

implementation

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
  FIsNull := '';
  FValue := Default(T);
end;

function TTNullable<T>.GetValue: T;
begin
  if IsNull then
    raise ETException.Create(SNullableTypeHasNoValue);
  result := FValue;
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
  result := (FIsNull.Length = 0);
end;

end.
