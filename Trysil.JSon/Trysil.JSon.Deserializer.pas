(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Deserializer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.Rtti,
  System.TypInfo,
  Trysil.Rtti,
  Trysil.Mapping,

  Trysil.JSon.Attributes,
  Trysil.JSon.Rtti,
  Trysil.JSon.Events,
  Trysil.JSon.Sqids,
  Trysil.JSon.Deserializer.Classes;

type

{ TTJSonDeserializer }

  TTJSonDeserializer = class(TTJSon)
  strict private
    FRttiContext: TRttiContext;

    procedure SetLazyID(
      const AName: String;
      const AObject: TObject;
      const AJSon: TJSonValue);

    procedure SetNullableValue(
      const AColumnMap: TTColumnMap;
      const AObject: TObject;
      const AValue: TJSonValue);
    procedure SetObjectValue(
      const AName: String;
      const AObject: TObject;
      const AJSon: TJSonValue);
    procedure SetValue(
      const AColumnMap: TTColumnMap;
      const AObject: TObject;
      const AValue: TJSonValue);

    procedure SetClassColumnValue(
      const AName: String;
      const AObject: TObject;
      const AJSon: TJSonValue);
    procedure SetSqidsPrimaryKeyValue(
      const AColumnMap: TTColumnMap;
      const AObject: TObject;
      const AName: String;
      const AJSon: TJSonValue);
    procedure SetColumnValue(
      const AColumnMap: TTColumnMap;
      const ATableMap: TTTableMap;
      const AObject: TObject;
      const AJSon: TJSonValue);

    procedure ColumnsFromJSonObject(
      const AJSon: TJSonValue; const AObject: TObject);
    procedure DetailColumnsFromJSonObject(
      const AJSon: TJSonValue; const AObject: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure EntityFromJSon(
      const AJSon: TJSonValue; const AObject: TObject);
  end;

implementation

{ TTJSonDeserializer }

constructor TTJSonDeserializer.Create;
begin
  inherited Create;
  FRttiContext := TRttiContext.Create;
end;

destructor TTJSonDeserializer.Destroy;
begin
  FRttiContext.Free;
  inherited Destroy;
end;

procedure TTJSonDeserializer.SetLazyID(
  const AName: String;
  const AObject: TObject;
  const AJSon: TJSonValue);
var
  LValue: TJSonValue;
  LLazy: TTRttiLazy;
begin
  LValue := AJSon.GetValue<TJSonValue>(Format('%sID', [GetName(AName)]), nil);
  if Assigned(LValue) then
  begin
    LLazy := TTRttiLazy.Create(AObject);
    try
      LLazy.ID := TTJSonSqids.Instance.Decode(LValue.ToString());
    finally
      LLazy.Free;
    end;
  end;
end;

procedure TTJSonDeserializer.SetNullableValue(
  const AColumnMap: TTColumnMap;
  const AObject: TObject;
  const AValue: TJSonValue);
var
  LValue: TTValue;
  LNullable: TTJSonNullable;
  LDeserializer: TTJSonAbstractDeserializer;
begin
  LValue := AColumnMap.Member.GetValue(AObject);

  LNullable := TTJSonNullable.Create(FRttiContext, LValue);
  try
    if Assigned(AValue) and (not (AValue is TJSonNull))then
    begin
      LDeserializer := TTJSonDeserializers.Instance.Get(
        LNullable.GenericType.Handle).Create;
      try
        LNullable.Value := LDeserializer.FromJSon(AValue);
      finally
        LDeserializer.Free;
      end;
    end
    else
      LNullable.Value := TTValue.Empty;

    AColumnMap.Member.SetValue(AObject, LValue);
  finally
    LNullable.Free;
  end;
end;

procedure TTJSonDeserializer.SetObjectValue(
  const AName: String;
  const AObject: TObject;
  const AJSon: TJSonValue);
var
  LLazyList: TTJSonLazyList;
  LArray: TJSonArray;
  LValue: TJSonValue;
  LEntity: TObject;
begin
  LLazyList := TTJSonLazyList.Create(AObject);
  try
    if LLazyList.IsList then
    begin
      LLazyList.CreateList;

      LArray := AJSon.GetValue<TJSonArray>(AName, nil);
      if Assigned(LArray) then
        for LValue in LArray do
          if LValue is TJSonObject then
          begin
            LEntity := LLazyList.AddEntity;
            EntityFromJSon(TJSonObject(LValue), LEntity);
          end;
    end;
  finally
    LLazyList.Free;
  end;
end;

procedure TTJSonDeserializer.SetValue(
  const AColumnMap: TTColumnMap;
  const AObject: TObject;
  const AValue: TJSonValue);
var
  LDeserializer: TTJSonAbstractDeserializer;
begin
  if Assigned(AValue) and (not (AValue is TJSonNull)) then
  begin
    LDeserializer := TTJSonDeserializers.Instance.Get(
      AColumnMap.Member.RttiType.Handle).Create;
    try
      AColumnMap.Member.SetValue(AObject, LDeserializer.FromJSon(AValue));
    finally
      LDeserializer.Free;
    end;
  end;
end;

procedure TTJSonDeserializer.DetailColumnsFromJSonObject(
  const AJSon: TJSonValue; const AObject: TObject);
var
  LTableMap: TTTableMap;
  LDetailColumnMap: TTDetailColumnMap;
  LName: String;
  LValue: TTValue;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LDetailColumnMap in LTableMap.DetailColums do
  begin
    LName := GetName(LDetailColumnMap.Member.Name);
    LValue := LDetailColumnMap.Member.GetValue(AObject);
    if LValue.IsObject then
      SetObjectValue(LName, LValue.AsObject, AJSon);
  end;
end;

procedure TTJSonDeserializer.SetClassColumnValue(
  const AName: String; const AObject: TObject; const AJSon: TJSonValue);
begin
  if TTRttiLazy.IsLazy(AObject) then
  begin
    SetLazyID(AName, AObject, AJSon);
    SetObjectValue(AName, AObject, AJSon);
  end;
end;

procedure TTJSonDeserializer.SetSqidsPrimaryKeyValue(
  const AColumnMap: TTColumnMap;
  const AObject: TObject;
  const AName: String;
  const AJSon: TJSonValue);
var
  LJSonNumber: TJSonNumber;
begin
  LJSonNumber := TJSonNumber.Create(TTJSonSqids.Instance.Decode(
    AJSon.GetValue<String>(AName, String.Empty)));
  try
    SetValue(AColumnMap, AObject, LJSonNumber);
  finally
    LJSonNumber.Free;
  end;
end;

procedure TTJSonDeserializer.SetColumnValue(
  const AColumnMap: TTColumnMap;
  const ATableMap: TTTableMap;
  const AObject: TObject;
  const AJSon: TJSonValue);
var
  LName: String;
begin
  LName := GetName(AColumnMap.Member.Name);
  if AColumnMap.Member.IsNullable then
    SetNullableValue(
      AColumnMap, AObject, AJSon.GetValue<TJSonValue>(LName, nil))
  else if AColumnMap.Member.IsClass then
    SetClassColumnValue(
      LName, AColumnMap.Member.GetValue(AObject).AsObject, AJSon)
  else if TTJSonSqids.Instance.UseSqids and
    (AColumnMap = ATableMap.PrimaryKey) then
    SetSqidsPrimaryKeyValue(AColumnMap, AObject, LName, AJSon)
  else
    SetValue(
      AColumnMap, AObject, AJSon.GetValue<TJSonValue>(LName, nil));
end;

procedure TTJSonDeserializer.ColumnsFromJSonObject(
  const AJSon: TJSonValue; const AObject: TObject);
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LJSonIgnore: TJSonIgnoreAttribute;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LColumnMap in LTableMap.Columns do
  begin
    LJSonIgnore := LColumnMap.Member.GetAttribute<TJSonIgnoreAttribute>();
    if not Assigned(LJSonIgnore) then
      SetColumnValue(LColumnMap, LTableMap, AObject, AJSon);
  end;
end;

procedure TTJSonDeserializer.EntityFromJSon(
  const AJSon: TJSonValue; const AObject: TObject);
var
  LEvent: TTJSonEvent;
begin
  ColumnsFromJSonObject(AJSon, AObject);
  DetailColumnsFromJSonObject(AJSon, AObject);
  LEvent := TTJSonEventFactory.Instance.CreateEvent(AObject);
  if Assigned(LEvent) then
    try
      LEvent.DoAfterDeserialized(AJSon);
    finally
      LEvent.Free;
    end;
end;

end.
