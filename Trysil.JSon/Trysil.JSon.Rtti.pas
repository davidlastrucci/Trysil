(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Rtti;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.DateUtils,
  System.TypInfo,
  System.Rtti,
  Trysil.Rtti;

type

{ TTJSonNullable }

  TTJSonNullable = class
  strict private
    FContext: TRttiContext;
    FNullable: TTValue;

    FType: TRttiType;
    FGenericType: TRttiType;
    FGetIsNull: TRttiMethod;
    FGetValue: TRttiMethod;
    FSetValue: TRttiMethod;
    FClear: TRttiMethod;

    function GetValue: TTValue;
    procedure SetValue(const AValue: TTValue);

    function FindGenericType(const AName: String): TRttiType;
  public
    constructor Create(
      const AContext: TRttiContext; const ANullable: TTValue);

    procedure AfterConstruction; override;

    property GenericType: TRttiType read FGenericType;
    property Value: TTValue read GetValue write SetValue;
  end;

{ TTJSonList }

  TTJSonList = class
  strict private
    FContext: TRttiContext;
    FList: TObject;

    FType: TRttiType;
    FCount: TRttiProperty;
    FItems: TRttiIndexedProperty;
    FAdd: TRttiMethod;
    FIsList: Boolean;

    function SearchCount: Boolean;
    function SearchItems: Boolean;
    function SearchAdd: Boolean;

    function GetCount: Integer;
    function GetItems(const AIndex: Integer): TTValue;
  public
    constructor Create(
      const AContext: TRttiContext; const AList: TObject);
    procedure AfterConstruction; override;

    function Add(const AValue: TTValue): Integer;

    property Count: Integer read GetCount;
    property IsList: Boolean read FIsList;
    property Items[const AIndex: Integer]: TTValue read GetItems;
  end;

{ TTJSonLazyList }

  TTJSonLazyList = class(TTRttiLazy)
  strict private
    FCreateList: TRttiMethod;
    FAddEntity: TRttiMethod;

    function GetIsList: Boolean;
  public
    constructor Create(const AObject: TObject);

    procedure AfterConstruction; override;

    procedure CreateList;
    function AddEntity: TObject;

    property IsList: Boolean read GetIsList;
  end;

{ TTJSon }

  TTJSon = class
  strict protected
    FRttiContext: TRttiContext;

    function GetName(const AName: String): String;
    function IsDateTime(const AValue: TTValue): Boolean;

    function GetLazyObject(const AObject: TObject): TObject;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TTJSonNullable }

constructor TTJSonNullable.Create(
  const AContext: TRttiContext; const ANullable: TTValue);
begin
  inherited Create;
  FContext := AContext;
  FNullable := ANullable;

  FType := nil;
  FGenericType := nil;
  FGetIsNull := nil;
  FGetValue := nil;
  FSetValue := nil;
  FClear := nil;
end;

procedure TTJSonNullable.AfterConstruction;
begin
  inherited AfterConstruction;
  FType := FContext.GetType(FNullable.TypeInfo);
  if Assigned(FType) then
  begin
    FGenericType := FindGenericType(FType.Name);
    FGetIsNull := FType.GetMethod('GetIsNull');
    FGetValue := FType.GetMethod('GetValue');
    FSetValue := FType.GetMethod('SetValue');
    FClear := FType.GetMethod('Clear');
  end;
end;

function TTJSonNullable.FindGenericType(const AName: String): TRttiType;
var
  LIndex: Integer;
  LGenericName: String;
begin
  result := nil;
  LIndex := AName.IndexOf('<');
  if LIndex >= 0  then
  begin
    LGenericName := AName.Substring(LIndex + 1);
    LIndex := LGenericName.IndexOf('>');
    if LIndex >= 0 then
    begin
      LGenericName := LGenericName.Substring(0, LIndex);
      result := FContext.FindType(LGenericName);
    end;
  end;
end;

function TTJSonNullable.GetValue: TTValue;
var
  LIsNull: TTValue;
begin
  result := nil;
  if Assigned(FGetIsNull) then
  begin
    LIsNull := FGetIsNull.Invoke(FNullable, []);
    if (not LIsNull.AsType<Boolean>()) and Assigned(FGetValue) then
      result := FGetValue.Invoke(FNullable, []);
  end;
end;

procedure TTJSonNullable.SetValue(const AValue: TTValue);
begin
  if AValue.IsEmpty then
  begin
    if Assigned(FClear) then
      FClear.Invoke(FNullable, []);
  end
  else if Assigned(FSetValue) then
    FSetValue.Invoke(FNullable, [AValue]);
end;

{ TTJSonList }

constructor TTJSonList.Create(
  const AContext: TRttiContext; const AList: TObject);
begin
  inherited Create;
  FContext := AContext;
  FList := AList;

  FType := nil;
  FCount := nil;
  FItems := nil;
  FAdd := nil;
end;

procedure TTJSonList.AfterConstruction;
begin
  inherited AfterConstruction;
  FType := FContext.GetType(FList.ClassInfo);
  FIsList := SearchCount and SearchItems and SearchAdd;
end;

function TTJSonList.SearchCount: Boolean;
begin
  FCount := FType.GetProperty('Count');
  result := Assigned(FCount);
end;

function TTJSonList.SearchItems: Boolean;
begin
  FItems := FType.GetIndexedProperty('Items');
  result := Assigned(FItems);
end;

function TTJSonList.SearchAdd: Boolean;
begin
  FAdd := FType.GetMethod('Add');
  result := Assigned(FAdd);
end;

function TTJSonList.GetCount: Integer;
var
  LResult: TTValue;
begin
  result := -1;
  if Assigned(FCount) then
  begin
    LResult := FCount.GetValue(FList);
    if LResult.IsType<Integer>() then
      result := LResult.AsType<Integer>();
  end;
end;

function TTJSonList.GetItems(const AIndex: Integer): TTValue;
begin
  result := nil;
  if Assigned(FCount) then
    result := FItems.GetValue(FList, [AIndex]);
end;

function TTJSonList.Add(const AValue: TTValue): Integer;
var
  LResult: TTValue;
begin
  result := -1;
  if Assigned(FCount) then
  begin
    LResult := FAdd.Invoke(FList, [AValue]);
    result := LResult.AsType<Integer>();
  end;
end;

{ TTJSonLazyList }

constructor TTJSonLazyList.Create(const AObject: TObject);
begin
  inherited Create(AObject);
  FCreateList := nil;
  FAddEntity := nil;
end;

procedure TTJSonLazyList.AfterConstruction;
begin
  inherited AfterConstruction;
  if Assigned(FType) then
  begin
    FCreateList := FType.GetMethod('CreateList');
    FAddEntity := FType.GetMethod('AddEntity');
  end;
end;

function TTJSonLazyList.GetIsList: Boolean;
begin
  result := Assigned(FCreateList) and Assigned(FAddEntity);
end;

procedure TTJSonLazyList.CreateList;
begin
  if Assigned(FCreateList) then
    FCreateList.Invoke(FObject, []);
end;

function TTJSonLazyList.AddEntity: TObject;
var
  LResult: TTValue;
begin
  result := nil;
  if Assigned(FAddEntity) then
  begin
    LResult := FAddEntity.Invoke(FObject, []);
    if LResult.IsObject then
      result := LResult.AsObject;
  end;
end;

{ TTJSon }

constructor TTJSon.Create;
begin
  inherited Create;
  FRttiContext.Create;
end;

destructor TTJSon.Destroy;
begin
  FRttiContext.Free;
  inherited Destroy;
end;

function TTJSon.GetName(const AName: String): String;
begin
  result := AName;
  if result.StartsWith('f') or result.StartsWith('F') then
    result := result.Substring(1);
  if result.Length <= 2 then
    result := result.ToLower()
  else
    result := result.Substring(0, 1).ToLower() + result.Substring(1);
end;

function TTJSon.IsDateTime(const AValue: TTValue): Boolean;
var
  LTypeName: String;
begin
  LTypeName := String(AValue.TypeInfo.Name).ToLower();

  result :=
    LTypeName.Equals('tdatetime') or
    LTypeName.Equals('tdate') or
    LTypeName.Equals('ttime');
end;

function TTJSon.GetLazyObject(const AObject: TObject): TObject;
var
  LRttiLazy: TTRttiLazy;
begin
  result := AObject;
  if TTRttiLazy.IsLazy(result) then
  begin
    LRttiLazy := TTRttiLazy.Create(result);
    try
      result := LRttiLazy.ObjectValue;
    finally
      LRttiLazy.Free;
    end;
  end;
end;

end.
