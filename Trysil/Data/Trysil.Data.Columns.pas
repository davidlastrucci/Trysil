(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.Columns;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Mapping,
  Trysil.Rtti;

type

{ TTColumn }

  TTColumn = class abstract
  strict protected
    FField: TField;
    FColumnMap: TTColumnMap;

    function GetValue: TTValue; virtual; abstract;
    function GetNullableValue: TTValue; virtual; abstract;
  public
    constructor Create(
      const AField: TField; const AColumnMap: TTColumnMap);

    procedure SetValue(const AEntity: TObject);

    property Value: TTValue read GetValue;
  end;

  TTColumnClass = class of TTColumn;

{ TTStringColumn }

  TTStringColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTIntegerColumn }

  TTIntegerColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTLargeIntegerColumn }

  TTLargeIntegerColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDoubleColumn }

  TTDoubleColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTBooleanColumn }

  TTBooleanColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDateTimeColumn }

  TTDateTimeColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTGuidColumn }

  TTGuidColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTBlobColumn }

  TTBlobColumn = class(TTColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTColumnFactory }

  TTColumnFactory = class
  strict private
    class var FInstance: TTColumnFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FColumnTypes: TDictionary<TClass, TClass>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterColumnClass<T: TField; C: TTColumn>();

    function CreateColumn(
      const AField: TField; const AColumnMap: TTColumnMap): TTColumn;

    class property Instance: TTColumnFactory read FInstance;
  end;

{ TTColumnRegister }

  TTColumnRegister = class
  public
    class procedure RegisterColumnClasses;
  end;

implementation

{ TTColumn }

constructor TTColumn.Create(
  const AField: TField; const AColumnMap: TTColumnMap);
begin
  inherited Create;
  FField := AField;
  FColumnMap := AColumnMap;
end;

procedure TTColumn.SetValue(const AEntity: TObject);
begin
  if FColumnMap.Member.IsNullable then
    FColumnMap.Member.SetValue(AEntity, GetNullableValue())
  else
    FColumnMap.Member.SetValue(AEntity, GetValue());
end;

{ TTStringColumn }

function TTStringColumn.GetValue: TTValue;
begin
  result := TTValue.From<String>(FField.AsString);
end;

function TTStringColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<String>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsString;
  result := TTValue.From<TTNullable<String>>(LValue);
end;

{ TTIntegerColumn }

function TTIntegerColumn.GetValue: TTValue;
begin
  result := TTValue.From<Integer>(FField.AsInteger);
end;

function TTIntegerColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Integer>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsInteger;
  result := TTValue.From<TTNullable<Integer>>(LValue);
end;

{ TTLargeIntegerColumn }

function TTLargeIntegerColumn.GetValue: TTValue;
begin
  result := TTValue.From<Int64>(FField.AsLargeInt);
end;

function TTLargeIntegerColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Int64>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsLargeInt;
  result := TTValue.From<TTNullable<Int64>>(LValue);
end;

{ TTDoubleColumn }

function TTDoubleColumn.GetValue: TTValue;
begin
  result := TTValue.From<Double>(FField.AsFloat);
end;

function TTDoubleColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Double>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsFloat;
  result := TTValue.From<TTNullable<Double>>(LValue);
end;

{ TTBooleanColumn }

function TTBooleanColumn.GetValue: TTValue;
begin
  result := TTValue.From<Boolean>(FField.AsBoolean);
end;

function TTBooleanColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Boolean>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsBoolean;
  result := TTValue.From<TTNullable<Boolean>>(LValue);
end;

{ TTDateTimeColumn }

function TTDateTimeColumn.GetValue: TTValue;
begin
  result := TTValue.From<TDateTime>(FField.AsDateTime);
end;

function TTDateTimeColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<TDateTime>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsDateTime;
  result := TTValue.From<TTNullable<TDateTime>>(LValue);
end;

{ TTGuidColumn }

function TTGuidColumn.GetValue: TTValue;
begin
  result := TTValue.From<TGuid>(FField.AsGuid);
end;

function TTGuidColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<TGuid>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsGuid;
  result := TTValue.From<TTNullable<TGuid>>(LValue);
end;

{ TTBlobColumn }

function TTBlobColumn.GetValue: TTValue;
begin
  result := TTValue.From<TBytes>(TBlobField(FField).AsBytes);
end;

function TTBlobColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<TBytes>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := TBlobField(FField).AsBytes;
  result := TTValue.From<TTNullable<TBytes>>(LValue);
end;

{ TTColumnFactory }

class constructor TTColumnFactory.ClassCreate;
begin
  FInstance := TTColumnFactory.Create;
  TTColumnRegister.RegisterColumnClasses;
end;

class destructor TTColumnFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTColumnFactory.Create;
begin
  inherited Create;
  FColumnTypes := TDictionary<TClass, TClass>.Create;
end;

destructor TTColumnFactory.Destroy;
begin
  FColumnTypes.Free;
  inherited Destroy;
end;

procedure TTColumnFactory.RegisterColumnClass<T, C>;
begin
  FColumnTypes.Add(T, C);
end;

function TTColumnFactory.CreateColumn(
  const AField: TField; const AColumnMap: TTColumnMap): TTColumn;
var
  LClass: TClass;
begin
  if not FColumnTypes.TryGetValue(AField.ClassType, LClass) then
    raise ETException.CreateFmt(SColumnTypeError, [AField.ClassName]);
  result := TTColumnClass(LClass).Create(AField, AColumnMap);
end;

{ TTColumnRegister }

class procedure TTColumnRegister.RegisterColumnClasses;
var
  LInstance: TTColumnFactory;
begin
  LInstance := TTColumnFactory.Instance;

  // TTStringColumn
  LInstance.RegisterColumnClass<TStringField, TTStringColumn>();
  LInstance.RegisterColumnClass<TWideStringField, TTStringColumn>();
  LInstance.RegisterColumnClass<TMemoField, TTStringColumn>();
  LInstance.RegisterColumnClass<TWideMemoField, TTStringColumn>();

  // TTIntegerColumn
  LInstance.RegisterColumnClass<TSmallintField, TTIntegerColumn>();
  LInstance.RegisterColumnClass<TIntegerField, TTIntegerColumn>();

  // TTLargeIntegerColumn
  LInstance.RegisterColumnClass<TLargeintField, TTLargeIntegerColumn>();

  // TTDoubleColumn
  LInstance.RegisterColumnClass<TFMTBCDField, TTDoubleColumn>();
  LInstance.RegisterColumnClass<TBCDField, TTDoubleColumn>();
  LInstance.RegisterColumnClass<TFloatField, TTDoubleColumn>();
  LInstance.RegisterColumnClass<TSingleField, TTDoubleColumn>();
  LInstance.RegisterColumnClass<TCurrencyField, TTDoubleColumn>();

  // TTBooleanColumn
  LInstance.RegisterColumnClass<TBooleanField, TTBooleanColumn>();

  // TTDateTimeColumn
  LInstance.RegisterColumnClass<TDateField, TTDateTimeColumn>();
  LInstance.RegisterColumnClass<TDateTimeField, TTDateTimeColumn>();
  LInstance.RegisterColumnClass<TSQLTimeStampField, TTDateTimeColumn>();

  // TTGuidColumn
  LInstance.RegisterColumnClass<TGuidField, TTGuidColumn>();

  // TTBlobColumn
  LInstance.RegisterColumnClass<TBlobField, TTBlobColumn>();
end;

end.
