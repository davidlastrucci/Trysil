(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Attributes;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,

  Trysil.Rtti;

type

{ TNamedAttribute }

  TNamedAttribute = class(TCustomAttribute)
  strict private
    FName: String;
  public
    constructor Create(const AName: String);

    property Name: String read FName;
  end;

{ TTableAttribute }

  TTableAttribute = class(TNamedAttribute);

{ TSequenceAttribute }

  TSequenceAttribute = class(TNamedAttribute);

{ TPrimaryKeyAttribute }

  TPrimaryKeyAttribute = class(TCustomAttribute);

{ TColumnAttribute }

  TColumnAttribute = class(TNamedAttribute);

{ TDetailColumnAttribute }

  TDetailColumnAttribute = class(TNamedAttribute)
  strict private
    FDetailName: String;
  public
    constructor Create(const AName: String; const ADetailName: String);

    property DetailName: String read FDetailName;
  end;

{ TVersionColumnAttribute }

  TVersionColumnAttribute = class(TCustomAttribute);

{ TRelationAttribute }

  TRelationAttribute = class(TCustomAttribute)
  strict private
    FTableName: String;
    FColumnName: String;
    FIsCascade: Boolean;
  public
    constructor Create(
      const ATableName: String;
      const AColumnName: String;
      const AIsCascade: Boolean);

    property TableName: String read FTableName;
    property ColumnName: String read FColumnName;
    property IsCascade: Boolean read FIsCascade;
  end;

{ TWhereClauseAttribute }

  TWhereClauseAttribute = class(TCustomAttribute)
  strict private
    FWhere: String;
  public
    constructor Create(const AWhere: String);

    property Where: String read FWhere;
  end;

{ TWhereClauseParameterAttribute }

  TWhereClauseParameterAttribute = class(TCustomAttribute)
  strict private
    FName: String;
    FDataType: TFieldType;
    FSize: Integer;
    FValue: TTValue;

    constructor Create(
      const AName: String;
      const ADataType: TFieldType;
      const ASize: Integer;
      const AValue: TTValue); overload;
  public
    constructor Create(
      const AName: String; const AValue: String); overload;
    constructor Create(
      const AName: String; const AValue: Integer); overload;
    constructor Create(
      const AName: String; const AValue: Int64); overload;
    constructor Create(
      const AName: String; const AValue: Double); overload;
    constructor Create(
      const AName: String; const AValue: Boolean); overload;
    constructor Create(
      const AName: String; const AValue: TDateTime); overload;

    property Name: String read FName;
    property DataType: TFieldType read FDataType;
    property Size: Integer read FSize;
    property Value: TTValue read FValue;
  end;

implementation

{ TNamedAttribute }

constructor TNamedAttribute.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
end;

{ TDetailColumnAttribute }

constructor TDetailColumnAttribute.Create(
  const AName: String; const ADetailName: String);
begin
  inherited Create(AName);
  FDetailName := ADetailName;
end;

{ TRelationAttribute }

constructor TRelationAttribute.Create(
  const ATableName: String;
  const AColumnName: String;
  const AIsCascade: Boolean);
begin
  inherited Create;
  FTableName := ATableName;
  FColumnName := AColumnName;
  FIsCascade := AIsCascade;
end;

{ TWhereClauseAttribute }

constructor TWhereClauseAttribute.Create(const AWhere: String);
begin
  inherited Create;
  FWhere := AWhere;
end;

{ TWhereClauseParameterAttribute }

constructor TWhereClauseParameterAttribute.Create(
  const AName: String;
  const ADataType: TFieldType;
  const ASize: Integer;
  const AValue: TTValue);
begin
  inherited Create;
  FName := AName;
  FDataType := ADataType;
  FSize := ASize;
  FValue := AValue;
end;

constructor TWhereClauseParameterAttribute.Create(
  const AName: String; const AValue: String);
begin
  Create(
    AName, TFieldType.ftWideString, AValue.Length, TTValue.From<String>(AValue));
end;

constructor TWhereClauseParameterAttribute.Create(
  const AName: String; const AValue: Integer);
begin
  Create(AName, TFieldType.ftInteger, 0, TTValue.From<Integer>(AValue));
end;

constructor TWhereClauseParameterAttribute.Create(
  const AName: String; const AValue: Int64);
begin
  Create(AName, TFieldType.ftLargeint, 0, TTValue.From<Int64>(AValue));
end;

constructor TWhereClauseParameterAttribute.Create(
  const AName: String; const AValue: Double);
begin
  Create(AName, TFieldType.ftFloat, 0, TTValue.From<Double>(AValue));
end;

constructor TWhereClauseParameterAttribute.Create(
  const AName: String; const AValue: Boolean);
begin
  Create(AName, TFieldType.ftBoolean, 0, TTValue.From<Boolean>(AValue));
end;

constructor TWhereClauseParameterAttribute.Create(
  const AName: String; const AValue: TDateTime);
begin
  Create(AName, TFieldType.ftDateTime, 0, TTValue.From<TDateTime>(AValue));
end;

end.
