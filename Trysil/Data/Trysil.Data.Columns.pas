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

{ TTDataColumn }

  TTDataColumn = class abstract
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

  TTDataColumnClass = class of TTDataColumn;

{ TTDataStringColumn }

  TTDataStringColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataIntegerColumn }

  TTDataIntegerColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataLargeIntegerColumn }

  TTDataLargeIntegerColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataDoubleColumn }

  TTDataDoubleColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataBooleanColumn }

  TTDataBooleanColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataDateTimeColumn }

  TTDataDateTimeColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataGuidColumn }

  TTDataGuidColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataBlobColumn }

  TTDataBlobColumn = class(TTDataColumn)
  strict protected
    function GetValue: TTValue; override;
    function GetNullableValue: TTValue; override;
  end;

{ TTDataColumnFactory }

  TTDataColumnFactory = class
  strict private
    class var FInstance: TTDataColumnFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FDataColumnTypes: TDictionary<TClass, TClass>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterColumnClass<T: TField; C: TTDataColumn>();

    function CreateColumn(
      const AField: TField; const AColumnMap: TTColumnMap): TTDataColumn;

    class property Instance: TTDataColumnFactory read FInstance;
  end;

{ TTDataColumnRegister }

  TTDataColumnRegister = class
  public
    class procedure RegisterColumnClasses;
  end;

implementation

{ TTDataColumn }

constructor TTDataColumn.Create(
  const AField: TField; const AColumnMap: TTColumnMap);
begin
  inherited Create;
  FField := AField;
  FColumnMap := AColumnMap;
end;

procedure TTDataColumn.SetValue(const AEntity: TObject);
begin
  if FColumnMap.Member.IsNullable then
    FColumnMap.Member.SetValue(AEntity, GetNullableValue())
  else
    FColumnMap.Member.SetValue(AEntity, GetValue());
end;

{ TTDataStringColumn }

function TTDataStringColumn.GetValue: TTValue;
begin
  result := TTValue.From<String>(FField.AsString);
end;

function TTDataStringColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<String>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsString;
  result := TTValue.From<TTNullable<String>>(LValue);
end;

{ TTDataIntegerColumn }

function TTDataIntegerColumn.GetValue: TTValue;
begin
  result := TTValue.From<Integer>(FField.AsInteger);
end;

function TTDataIntegerColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Integer>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsInteger;
  result := TTValue.From<TTNullable<Integer>>(LValue);
end;

{ TTDataLargeIntegerColumn }

function TTDataLargeIntegerColumn.GetValue: TTValue;
begin
  result := TTValue.From<Int64>(FField.AsLargeInt);
end;

function TTDataLargeIntegerColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Int64>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsLargeInt;
  result := TTValue.From<TTNullable<Int64>>(LValue);
end;

{ TTDataDoubleColumn }

function TTDataDoubleColumn.GetValue: TTValue;
begin
  result := TTValue.From<Double>(FField.AsFloat);
end;

function TTDataDoubleColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Double>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsFloat;
  result := TTValue.From<TTNullable<Double>>(LValue);
end;

{ TTDataBooleanColumn }

function TTDataBooleanColumn.GetValue: TTValue;
begin
  result := TTValue.From<Boolean>(FField.AsBoolean);
end;

function TTDataBooleanColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<Boolean>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsBoolean;
  result := TTValue.From<TTNullable<Boolean>>(LValue);
end;

{ TTDataDateTimeColumn }

function TTDataDateTimeColumn.GetValue: TTValue;
begin
  result := TTValue.From<TDateTime>(FField.AsDateTime);
end;

function TTDataDateTimeColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<TDateTime>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsDateTime;
  result := TTValue.From<TTNullable<TDateTime>>(LValue);
end;

{ TTDataGuidColumn }

function TTDataGuidColumn.GetValue: TTValue;
begin
  result := TTValue.From<TGuid>(FField.AsGuid);
end;

function TTDataGuidColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<TGuid>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := FField.AsGuid;
  result := TTValue.From<TTNullable<TGuid>>(LValue);
end;

{ TTDataBlobColumn }

function TTDataBlobColumn.GetValue: TTValue;
begin
  result := TTValue.From<TBytes>(TBlobField(FField).AsBytes);
end;

function TTDataBlobColumn.GetNullableValue: TTValue;
var
  LValue: TTNullable<TBytes>;
begin
  if FField.IsNull then
    LValue := nil
  else
    LValue := TBlobField(FField).AsBytes;
  result := TTValue.From<TTNullable<TBytes>>(LValue);
end;

{ TTDataColumnFactory }

class constructor TTDataColumnFactory.ClassCreate;
begin
  FInstance := TTDataColumnFactory.Create;
  TTDataColumnRegister.RegisterColumnClasses;
end;

class destructor TTDataColumnFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTDataColumnFactory.Create;
begin
  inherited Create;
  FDataColumnTypes := TDictionary<TClass, TClass>.Create;
end;

destructor TTDataColumnFactory.Destroy;
begin
  FDataColumnTypes.Free;
  inherited Destroy;
end;

procedure TTDataColumnFactory.RegisterColumnClass<T, C>;
begin
  FDataColumnTypes.Add(T, C);
end;

function TTDataColumnFactory.CreateColumn(
  const AField: TField; const AColumnMap: TTColumnMap): TTDataColumn;
var
  LClass: TClass;
begin
  if not FDataColumnTypes.TryGetValue(AField.ClassType, LClass) then
    raise ETException.CreateFmt(SColumnTypeError, [AField.ClassName]);
  result := TTDataColumnClass(LClass).Create(AField, AColumnMap);
end;

{ TTDataColumnRegister }

class procedure TTDataColumnRegister.RegisterColumnClasses;
var
  LInstance: TTDataColumnFactory;
begin
  LInstance := TTDataColumnFactory.Instance;

  // TTDataStringColumn
  LInstance.RegisterColumnClass<TStringField, TTDataStringColumn>();
  LInstance.RegisterColumnClass<TWideStringField, TTDataStringColumn>();
  LInstance.RegisterColumnClass<TMemoField, TTDataStringColumn>();
  LInstance.RegisterColumnClass<TWideMemoField, TTDataStringColumn>();

  // TTDataIntegerColumn
  LInstance.RegisterColumnClass<TSmallintField, TTDataIntegerColumn>();
  LInstance.RegisterColumnClass<TIntegerField, TTDataIntegerColumn>();

  // TTDataLargeIntegerColumn
  LInstance.RegisterColumnClass<TLargeintField, TTDataLargeIntegerColumn>();

  // TTDataDoubleColumn
  LInstance.RegisterColumnClass<TFMTBCDField, TTDataDoubleColumn>();
  LInstance.RegisterColumnClass<TBCDField, TTDataDoubleColumn>();
  LInstance.RegisterColumnClass<TFloatField, TTDataDoubleColumn>();
  LInstance.RegisterColumnClass<TSingleField, TTDataDoubleColumn>();
  LInstance.RegisterColumnClass<TCurrencyField, TTDataDoubleColumn>();

  // TTDataBooleanColumn
  LInstance.RegisterColumnClass<TBooleanField, TTDataBooleanColumn>();

  // TTDataDateTimeColumn
  LInstance.RegisterColumnClass<TDateField, TTDataDateTimeColumn>();
  LInstance.RegisterColumnClass<TDateTimeField, TTDataDateTimeColumn>();
  LInstance.RegisterColumnClass<TSQLTimeStampField, TTDataDateTimeColumn>();

  // TTDataGuidColumn
  LInstance.RegisterColumnClass<TGuidField, TTDataGuidColumn>();

  // TTDataBlobColumn
  LInstance.RegisterColumnClass<TBlobField, TTDataBlobColumn>();
end;

end.
