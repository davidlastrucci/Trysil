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
  System.TypInfo,
  System.Rtti,
  Trysil.Rtti,
  Trysil.Types,
  Trysil.Mapping,

  Trysil.JSon.Attributes,
  Trysil.JSon.Types,
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

procedure TTJSonDeserializer.ColumnsFromJSonObject(
  const AJSon: TJSonValue; const AObject: TObject);
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LJSonIgnore: TJSonIgnoreAttribute;
  LName: String;
  LObject: TObject;
  LJSonNumber: TJSonNumber;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LColumnMap in LTableMap.Columns do
  begin
    LJSonIgnore := LColumnMap.Member.GetAttribute<TJSonIgnoreAttribute>();
    if not Assigned(LJSonIgnore) then
    begin
      LName := GetName(LColumnMap.Member.Name);

      if LColumnMap.Member.IsNullable then
        SetNullableValue(
          LColumnMap, AObject, AJSon.GetValue<TJSonValue>(LName, nil))
      else if LColumnMap.Member.IsClass then
      begin
        LObject := LColumnMap.Member.GetValue(AObject).AsObject;
        if TTRttiLazy.IsLazy(LObject) then
        begin
          SetLazyID(LName, LObject, AJSon);
          SetObjectValue(LName, LObject, AJSon);
        end;
      end
      else if TTJSonSqids.Instance.UseSqids and
        (LColumnMap = LTableMap.PrimaryKey) then
      begin
        LJSonNumber := TJSonNumber.Create(TTJSonSqids.Instance.Decode(
          AJSon.GetValue<String>(LName, String.Empty)));
        try
          SetValue(LColumnMap, AObject, LJSonNumber);
        finally
          LJSonNumber.Free;
        end;
      end
      else
        SetValue(LColumnMap, AObject, AJSon.GetValue<TJSonValue>(LName, nil));
    end;
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
