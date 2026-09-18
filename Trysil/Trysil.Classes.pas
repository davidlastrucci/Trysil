(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Classes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  System.Generics.Collections,
  System.Generics.Defaults;

type

{ TTIdentifier }

  TTIdentifier = record
  strict private
    const MaxLength = 30;
    const PrefixLength = 23;

    class function BytePrefix(
      const AValue: String;
      const ABytes: Integer): String; static;
  public
    class function Same(
      const ALeft: String;
      const ARight: String): Boolean; static;
    class function JoinAliasName(
      const AAlias: String;
      const AColumnName: String): String; static;
    class function PublishedName(const AMemberName: String): String; static;
    class function Comparer: IEqualityComparer<String>; static;
  end;

{ TTListEnumerator<T> }

  TTListEnumerator<T> = class
  strict private
    FList: TList<T>;
    FIndex: Integer;
    function GetCurrent: T;
  public
    constructor Create(const AList: TList<T>);

    function MoveNext: Boolean;

    property Current: T read GetCurrent;
  end;

implementation

type

{ TTIdentifierComparer }

  TTIdentifierComparer = class(TEqualityComparer<String>)
  public
    function Equals(
      const ALeft: String; const ARight: String): Boolean; override;
    function GetHashCode(const AValue: String): Integer; override;
  end;

var
  GComparer: IEqualityComparer<String>;

{ TTIdentifierComparer }

function TTIdentifierComparer.Equals(
  const ALeft: String; const ARight: String): Boolean;
begin
  result := TTIdentifier.Same(ALeft, ARight);
end;

function TTIdentifierComparer.GetHashCode(const AValue: String): Integer;
begin
  result := THashBobJenkins.GetHashValue(AValue.ToUpperInvariant);
end;

{ TTIdentifier }

class function TTIdentifier.Same(
  const ALeft: String;
  const ARight: String): Boolean;
begin
  result := ALeft.ToUpperInvariant = ARight.ToUpperInvariant;
end;

class function TTIdentifier.JoinAliasName(
  const AAlias: String;
  const AColumnName: String): String;
begin
  result := Format('%s_%s', [AAlias, AColumnName]);
  if TEncoding.UTF8.GetByteCount(result) > MaxLength then
    result := Format('%s_%.6x', [
      BytePrefix(result, PrefixLength),
      THashBobJenkins.GetHashValue(result.ToUpperInvariant) and
        $FFFFFF]);
end;

class function TTIdentifier.BytePrefix(
  const AValue: String;
  const ABytes: Integer): String;
begin
  result := AValue;
  while TEncoding.UTF8.GetByteCount(result) > ABytes do
    result := result.Substring(0, result.Length - 1);
end;

class function TTIdentifier.PublishedName(
  const AMemberName: String): String;
begin
  result := AMemberName;
  if (result.Length > 1) and CharInSet(result.Chars[0], ['f', 'F']) and
    CharInSet(result.Chars[1], ['A' .. 'Z']) then
    result := result.Substring(1);
  if result.Length <= 2 then
    result := result.ToLowerInvariant
  else
    result := Format('%s%s', [
      result.Substring(0, 1).ToLowerInvariant,
      result.Substring(1)]);
end;

class function TTIdentifier.Comparer: IEqualityComparer<String>;
begin
  result := GComparer;
end;

{ TTListEnumerator<T> }

constructor TTListEnumerator<T>.Create(const AList: TList<T>);
begin
  inherited Create;
  FList := AList;
  FIndex := -1;
end;

function TTListEnumerator<T>.GetCurrent: T;
begin
  result := FList[FIndex];
end;

function TTListEnumerator<T>.MoveNext: Boolean;
begin
  result := (FIndex < (FList.Count - 1));
  if result then
    Inc(FIndex);
end;

initialization
  GComparer := TTIdentifierComparer.Create;

finalization
  GComparer := nil;

end.
