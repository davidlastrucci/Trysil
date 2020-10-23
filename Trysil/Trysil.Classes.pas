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
  System.Generics.Collections;

type

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

end.
