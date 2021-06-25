(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Generics.Collections;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections;

type

{ TTPredicate<T> }

  TTPredicate<T> = reference to function(const AItem: T): Boolean;

{ ITEnumerator<T> }

  ITEnumerator<T> = interface
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;

    property Current: T read GetCurrent;
  end;

{ ITEnumerable<T> }

  ITEnumerable<T> = interface
    function GetEnumerator: ITEnumerator<T>;
  end;

{ TTEnumerator<T> }

  TTEnumerator<T> = class(TInterfacedObject, ITEnumerator<T>)
  strict private
    FList: TList<T>;
    FPredicate: TTPredicate<T>;
    FIndex: Integer;

    // ITEnumerator<T>
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
  public
    constructor Create(
      const AList: TList<T>; const APredicate: TTPredicate<T>);
  end;

{ TTEnumerable<T> }

  TTEnumerable<T> = class(TInterfacedObject, ITEnumerable<T>)
  strict private
    FList: TList<T>;
    FPredicate: TTPredicate<T>;

    // ITEnumerable<T>
    function GetEnumerator: ITEnumerator<T>;
  public
    constructor Create(
      const AList: TList<T>; const APredicate: TTPredicate<T>);
  end;

{ TTList<T> }

  TTList<T> = class(TList<T>)
  public
    function Where(const APredicate: TTPredicate<T>): ITEnumerable<T>;
  end;

{ TTObjectList<T> }

  TTObjectList<T: class> = class(TTList<T>)
  strict private
    FOwnsObjects: Boolean;
  strict protected
    procedure Notify(
      const AValue: T; AAction: TCollectionNotification); override;
  public
    constructor Create; overload;
    constructor Create(const AOwnsObjects: Boolean); overload;
  end;

implementation

{ TTEnumerator<T> }

constructor TTEnumerator<T>.Create(
  const AList: TList<T>; const APredicate: TTPredicate<T>);
begin
  inherited Create;
  FList := AList;
  FPredicate := APredicate;
  Self.Reset();
end;

function TTEnumerator<T>.GetCurrent: T;
begin
  result := FList[FIndex];
end;

function TTEnumerator<T>.MoveNext: Boolean;
begin
  result := (FIndex < (FList.Count - 1));
  if result then
  begin
    Inc(FIndex);
    if Assigned(FPredicate) then
      while not FPredicate(Self.GetCurrent()) do
      begin
        Inc(FIndex);
        if FIndex > FList.Count - 1 then
        begin
          result := False;
          Break;
        end;
      end;
  end;
end;

procedure TTEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

{ TTEnumerable<T> }

constructor TTEnumerable<T>.Create(
  const AList: TList<T>; const APredicate: TTPredicate<T>);
begin
  inherited Create;
  FList := AList;
  FPredicate := APredicate;
end;

function TTEnumerable<T>.GetEnumerator: ITEnumerator<T>;
begin
  result := TTEnumerator<T>.Create(FList, FPredicate);
end;

{ TTList<T> }

function TTList<T>.Where(
  const APredicate: TTPredicate<T>): ITEnumerable<T>;
begin
  result := TTEnumerable<T>.Create(Self, APredicate);
end;

{ TTObjectList<T> }

constructor TTObjectList<T>.Create;
begin
  Create(True);
end;

constructor TTObjectList<T>.Create(const AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

procedure TTObjectList<T>.Notify(
  const AValue: T; AAction: TCollectionNotification);
begin
  inherited Notify(AValue, AAction);
  if FOwnsObjects and (AAction = TCollectionNotification.cnRemoved) then
    AValue.Free;
end;

end.
