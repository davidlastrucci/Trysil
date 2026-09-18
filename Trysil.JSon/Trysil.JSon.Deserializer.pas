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
  System.Generics.Collections,
  System.JSon,
  System.Rtti,
  System.TypInfo,
  System.DateUtils,
  Trysil.Consts,
  Trysil.Rtti,
  Trysil.Mapping,

  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions,
  Trysil.JSon.Attributes,
  Trysil.JSon.Rtti,
  Trysil.JSon.Events,
  Trysil.JSon.Sqids,
  Trysil.JSon.Types,
  Trysil.JSon.Deserializer.Classes;

type

{ TTJSonDeserializer }

  TTJSonDeserializer = class(TTJSon)
  strict private
    FRttiContext: TRttiContext;

    procedure CheckJSonObjects(
      const AJSon: TJSonArray; const AName: String);

    class function IsConversionError(
      const AException: Exception): Boolean; static;
    procedure RaiseNotValidValue(const AName: String);
    function ValueFromJSon(
      const ADeserializer: TTJSonAbstractDeserializer;
      const AColumnMap: TTColumnMap;
      const AValue: TJSonValue): TTValue;
    function LazyIDFromJSon(
      const AName: String; const AValue: TJSonValue): Integer;

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

    function CanDeserializeMember(const AMember: TTRttiMember): Boolean;
    function CanDeserializeColumn(
      const ATableMap: TTTableMap;
      const AColumnMap: TTColumnMap): Boolean;

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

class function TTJSonDeserializer.IsConversionError(
  const AException: Exception): Boolean;
begin
  result :=
    (AException is EJSONException) or
    (AException is EConvertError) or
    (AException is EDateTimeException) or
    (AException is EArgumentException) or
    (AException is ERangeError) or
    (AException is EIntOverflow) or
    (AException is EMathError) or
    (AException is EVariantError);
end;

procedure TTJSonDeserializer.RaiseNotValidValue(const AName: String);
begin
  Exception.RaiseOuterException(
    ETJSonException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidJSonValue), [AName]));
end;

function TTJSonDeserializer.ValueFromJSon(
  const ADeserializer: TTJSonAbstractDeserializer;
  const AColumnMap: TTColumnMap;
  const AValue: TJSonValue): TTValue;
begin
  result := TTValue.Empty;
  try
    result := ADeserializer.FromJSon(AValue);
  except
    on E: Exception do
      if IsConversionError(E) then
        RaiseNotValidValue(GetName(AColumnMap.Member.Name))
      else
        raise;
  end;
end;

function TTJSonDeserializer.LazyIDFromJSon(
  const AName: String; const AValue: TJSonValue): Integer;
begin
  result := 0;
  try
    result := TTJSonSqids.Instance.Decode(AValue.Value);
  except
    on E: Exception do
      if IsConversionError(E) then
        RaiseNotValidValue(AName)
      else
        raise;
  end;
end;

procedure TTJSonDeserializer.SetLazyID(
  const AName: String;
  const AObject: TObject;
  const AJSon: TJSonValue);
var
  LValue: TJSonValue;
  LLazy: TTRttiLazy;
begin
  LValue := AJSon.GetValue<TJSonValue>(Format('%sID', [AName]), nil);
  if Assigned(LValue) then
  begin
    LLazy := TTRttiLazy.Create(AObject);
    try
      LLazy.ID := LazyIDFromJSon(Format('%sID', [AName]), LValue);
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
      LDeserializer := TTJSonDeserializers.Instance.GetInstance(
        LNullable.GenericType.Handle);
      LNullable.Value := ValueFromJSon(LDeserializer, AColumnMap, AValue);
    end
    else
      LNullable.Value := TTValue.Empty;

    AColumnMap.Member.SetValue(AObject, LValue);
  finally
    LNullable.Free;
  end;
end;

procedure TTJSonDeserializer.CheckJSonObjects(
  const AJSon: TJSonArray; const AName: String);
var
  LIndex: Integer;
begin
  for LIndex := 0 to AJSon.Count - 1 do
    if not (AJSon.Items[LIndex] is TJSonObject) then
      raise ETJSonException.CreateFmt(
        TTLanguage.Instance.Translate(SNotAJSonObjectInList), [
          LIndex,
          AName]);
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
      if TTJSonValues.GetArray(AJSon, AName, LArray) =
        TTJSonValueState.Invalid then
        raise ETJSonException.CreateFmt(
          TTLanguage.Instance.Translate(SNotValidJSonArray), [
            AName]);

      if Assigned(LArray) then
      begin
        CheckJSonObjects(LArray, AName);

        LLazyList.PrepareList;
        for LValue in LArray do
        begin
          LEntity := LLazyList.AddEntity;
          EntityFromJSon(TJSonObject(LValue), LEntity);
        end;
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
    LDeserializer := TTJSonDeserializers.Instance.GetInstance(
      AColumnMap.Member.RttiType.Handle);
    AColumnMap.Member.SetValue(
      AObject, ValueFromJSon(LDeserializer, AColumnMap, AValue));
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
  for LDetailColumnMap in LTableMap.DetailColumns do
  begin
    if CanDeserializeMember(LDetailColumnMap.Member) then
    begin
      LName := GetName(LDetailColumnMap.Member.Name);
      LValue := LDetailColumnMap.Member.GetValue(AObject);
      if LValue.IsObject then
        SetObjectValue(LName, LValue.AsObject, AJSon);
    end;
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
  LJSonValue: TJSonValue;
  LPrimaryKey: Integer;
  LJSonNumber: TJSonNumber;
begin
  LJSonValue := AJSon.GetValue<TJSonValue>(AName, nil);
  if Assigned(LJSonValue) and (not (LJSonValue is TJSonNull)) then
  begin
    if not TTJSonSqids.Instance.TryDecode(LJSonValue.Value, LPrimaryKey) then
      raise ETJSonException.CreateFmt(
        TTLanguage.Instance.Translate(SNotValidSqid), [AName]);

    LJSonNumber := TJSonNumber.Create(LPrimaryKey);
    try
      SetValue(AColumnMap, AObject, LJSonNumber);
    finally
      LJSonNumber.Free;
    end;
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

function TTJSonDeserializer.CanDeserializeMember(
  const AMember: TTRttiMember): Boolean;
begin
  result := TTJSonDirection.CanDeserialize(AMember);
end;

function TTJSonDeserializer.CanDeserializeColumn(
  const ATableMap: TTTableMap;
  const AColumnMap: TTColumnMap): Boolean;
begin
  result := TTJSonDirection.CanDeserializeColumn(ATableMap, AColumnMap);
end;

procedure TTJSonDeserializer.ColumnsFromJSonObject(
  const AJSon: TJSonValue; const AObject: TObject);
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LColumnMap in LTableMap.Columns do
    if CanDeserializeColumn(LTableMap, LColumnMap) then
      SetColumnValue(LColumnMap, LTableMap, AObject, AJSon);
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
