(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.Filter;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSon,
  Data.DB,
  Trysil.Consts,
  Trysil.Rtti,
  Trysil.Data.Parameters,
  Trysil.Metadata,
  Trysil.Context,
  Trysil.Filter,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions;

type

{ TTHttpTableMetadataHelper }

  TTHttpTableMetadataHelper = class helper for TTTableMetadata
  public
    function FindColumn(const AName: String): TTColumnMetadata;
  end;

{ TTHttpFilterParameters }

  TTHttpFilterParameters = record
  strict private
    const DefaultMaxLimit: Integer = 1000;
    const DefaultMaxWhereConditions: Integer = 32;
    const DefaultMaxOrderByColumns: Integer = 8;
  strict private
    FMaxLimit: Integer;
    FMaxWhereConditions: Integer;
    FMaxOrderByColumns: Integer;
    FIncludeDeleted: Boolean;

    function GetMaxLimit: Integer;
    function GetMaxWhereConditions: Integer;
    function GetMaxOrderByColumns: Integer;
  public
    constructor Create(
      const AMaxLimit: Integer;
      const AMaxWhereConditions: Integer;
      const AMaxOrderByColumns: Integer); overload;

    constructor Create(
      const AMaxLimit: Integer;
      const AMaxWhereConditions: Integer;
      const AMaxOrderByColumns: Integer;
      const AIncludeDeleted: Boolean); overload;

    class function Defaults: TTHttpFilterParameters; static;

    function LimitOrDefault(const ALimit: Integer): Integer;

    property MaxLimit: Integer read GetMaxLimit;
    property MaxWhereConditions: Integer read GetMaxWhereConditions;
    property MaxOrderByColumns: Integer read GetMaxOrderByColumns;
    property IncludeDeleted: Boolean read FIncludeDeleted;
  end;

{ TTHttpFilterWhere }

  TTHttpFilterWhere = record
  strict private
    const Conditions: array[0..7] of string =
      ('=', '<>', '<', '<=', '>', '>=', 'LIKE', 'NOT LIKE');
  strict private
    FColumnName: String;
    FCondition: String;
    FValue: String;
    FParameterName: String;

    FColumnMetadata: TTColumnMetadata;

    function IsStringColumn: Boolean;
    function IsLikeCondition: Boolean;
    procedure ValidateCondition;
    procedure ValidateConditionForColumn;
    procedure RaiseValueNotValid;
    function GetParameterValue: TTValue;
  public
    constructor Create(
      const AJSon: TJSonObject;
      const ATableMetadata: TTTableMetadata;
      const AParameterIndex: Integer);

    procedure AddParameter(var AFilter: TTFilter);

    function ToString: String;
  end;

{ TTHttpFilterWhereList }

  TTHttpFilterWhereList = record
  strict private
    FList: TArray<TTHttpFilterWhere>;
  public
    constructor Create(
      const AJSon: TJSonArray;
      const ATableMetadata: TTTableMetadata); overload;

    constructor Create(
      const AJSon: TJSonArray;
      const ATableMetadata: TTTableMetadata;
      const AMaxConditions: Integer); overload;

    procedure AddParameters(var AFilter: TTFilter);

    function ToString: String;
  end;

{ TTHttpFilterOrderBy }

  TTHttpFilterOrderBy = record
  strict private
    const Directions: array[0..2] of string = ('ASC', 'DESC', '');
  strict private
    FColumnName: String;
    FDirection: String;

    procedure ValidateDirection;
  public
    constructor Create(
      const AJSon: TJSonObject; const ATableMetadata: TTTableMetadata);

    function ToString: String;
  end;

{ TTHttpFilterOrderByList }

  TTHttpFilterOrderByList = record
  strict private
    FList: TArray<TTHttpFilterOrderBy>;
  public
    constructor Create(
      const AJSon: TJSonArray;
      const ATableMetadata: TTTableMetadata); overload;

    constructor Create(
      const AJSon: TJSonArray;
      const ATableMetadata: TTTableMetadata;
      const AMaxColumns: Integer); overload;

    function ToString: String;
  end;

{ TTHttpFilter<T> }

  TTHttpFilter<T: class> = record
  strict private
    FFilter: TTFilter;
  public
    constructor Create(
      const AContext: TTContext; const AJSon: TJSonValue); overload;

    constructor Create(
      const AContext: TTContext;
      const AJSon: TJSonValue;
      const AParameters: TTHttpFilterParameters); overload;

    property Filter: TTFilter read FFilter;
  end;

implementation

{ TTHttpTableMetadataHelper }

function TTHttpTableMetadataHelper.FindColumn(
  const AName: String): TTColumnMetadata;
var
  LColumn: TTColumnMetadata;
begin
  result := nil;
  for LColumn in Self.Columns do
    if String.Compare(LColumn.ColumnName, AName, True) = 0 then
    begin
      result := LColumn;
      Break;
    end;

  if not Assigned(result) then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SColumnNotFound), [AName]);

  if not result.IsFilterable then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SColumnNotFilterable), [AName]);
end;

{ TTHttpFilterParameters }

constructor TTHttpFilterParameters.Create(
  const AMaxLimit: Integer;
  const AMaxWhereConditions: Integer;
  const AMaxOrderByColumns: Integer);
begin
  Create(AMaxLimit, AMaxWhereConditions, AMaxOrderByColumns, False);
end;

constructor TTHttpFilterParameters.Create(
  const AMaxLimit: Integer;
  const AMaxWhereConditions: Integer;
  const AMaxOrderByColumns: Integer;
  const AIncludeDeleted: Boolean);
begin
  FMaxLimit := AMaxLimit;
  FMaxWhereConditions := AMaxWhereConditions;
  FMaxOrderByColumns := AMaxOrderByColumns;
  FIncludeDeleted := AIncludeDeleted;
end;

class function TTHttpFilterParameters.Defaults: TTHttpFilterParameters;
begin
  result := TTHttpFilterParameters.Create(
    DefaultMaxLimit, DefaultMaxWhereConditions, DefaultMaxOrderByColumns);
end;

function TTHttpFilterParameters.GetMaxLimit: Integer;
begin
  if FMaxLimit = 0 then
    result := DefaultMaxLimit
  else
    result := FMaxLimit;
end;

function TTHttpFilterParameters.GetMaxWhereConditions: Integer;
begin
  if FMaxWhereConditions = 0 then
    result := DefaultMaxWhereConditions
  else
    result := FMaxWhereConditions;
end;

function TTHttpFilterParameters.GetMaxOrderByColumns: Integer;
begin
  if FMaxOrderByColumns = 0 then
    result := DefaultMaxOrderByColumns
  else
    result := FMaxOrderByColumns;
end;

function TTHttpFilterParameters.LimitOrDefault(
  const ALimit: Integer): Integer;
var
  LMaxLimit: Integer;
begin
  LMaxLimit := GetMaxLimit;
  if LMaxLimit < 0 then
    result := ALimit
  else if (ALimit <= 0) or (ALimit > LMaxLimit) then
    result := LMaxLimit
  else
    result := ALimit;
end;

{ TTHttpFilterWhere }

constructor TTHttpFilterWhere.Create(
  const AJSon: TJSonObject;
  const ATableMetadata: TTTableMetadata;
  const AParameterIndex: Integer);
begin
  FCondition := AJSon.GetValue<String>('condition', String.Empty);
  FValue := AJSon.GetValue<String>('value', String.Empty);
  FParameterName := Format('p%d', [AParameterIndex]);

  FColumnMetadata := ATableMetadata.FindColumn(
    AJSon.GetValue<String>('columnName', String.Empty));
  FColumnName := FColumnMetadata.ColumnName;
  ValidateCondition;
  ValidateConditionForColumn;
end;

function TTHttpFilterWhere.ToString: String;
begin
  result := Format('%s %s :%s', [FColumnName, FCondition, FParameterName]);
end;

procedure TTHttpFilterWhere.AddParameter(var AFilter: TTFilter);
begin
  AFilter.AddParameter(
    FParameterName,
    FColumnMetadata.DataType,
    FColumnMetadata.DataSize,
    GetParameterValue,
    FColumnMetadata.IsGuid,
    FColumnMetadata.IsCurrency);
end;

function TTHttpFilterWhere.IsStringColumn: Boolean;
begin
  result := FColumnMetadata.DataType in [
    TFieldType.ftString,
    TFieldType.ftWideString,
    TFieldType.ftFixedChar,
    TFieldType.ftFixedWideChar,
    TFieldType.ftMemo,
    TFieldType.ftWideMemo];
end;

function TTHttpFilterWhere.IsLikeCondition: Boolean;
begin
  result := (String.Compare(FCondition, 'LIKE', True) = 0) or
    (String.Compare(FCondition, 'NOT LIKE', True) = 0);
end;

procedure TTHttpFilterWhere.ValidateConditionForColumn;
begin
  if IsLikeCondition and (not IsStringColumn) then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SConditionNotValidForColumn), [
        FCondition, FColumnName]);
end;

procedure TTHttpFilterWhere.RaiseValueNotValid;
begin
  raise ETHttpBadRequest.CreateFmt(
    TTLanguage.Instance.Translate(SValueNotValid), [FValue, FColumnName]);
end;

function TTHttpFilterWhere.GetParameterValue: TTValue;
begin
  if not TTParameterFactory.Instance.TryValueFromString(
    FColumnMetadata.DataType,
    FColumnMetadata.IsGuid,
    FColumnMetadata.IsCurrency,
    FValue,
    result) then
    RaiseValueNotValid;
end;

procedure TTHttpFilterWhere.ValidateCondition;
var
  LIsValid: Boolean;
  LIndex: Integer;
begin
  LIsValid := False;
  for LIndex := Low(Conditions) to High(Conditions) do
    if String.Compare(Conditions[LIndex], FCondition, True) = 0 then
    begin
      LIsValid := True;
      Break;
    end;

  if not LIsValid then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SConditionNotValid), [FCondition]);
end;

{ TTHttpFilterWhereList }

constructor TTHttpFilterWhereList.Create(
  const AJSon: TJSonArray; const ATableMetadata: TTTableMetadata);
begin
  Create(AJSon, ATableMetadata, -1);
end;

constructor TTHttpFilterWhereList.Create(
  const AJSon: TJSonArray;
  const ATableMetadata: TTTableMetadata;
  const AMaxConditions: Integer);
var
  LIndex: Integer;
begin
  if Assigned(AJSon) then
  begin
    if (AMaxConditions >= 0) and (AJSon.Count > AMaxConditions) then
      raise ETHttpBadRequest.CreateFmt(
        TTLanguage.Instance.Translate(STooManyWhereConditions), [
          AJSon.Count, AMaxConditions]);

    SetLength(FList, AJSon.Count);
    for LIndex := 0 to AJSon.Count - 1 do
    begin
      if not (AJSon.Items[LIndex] is TJSonObject) then
        raise ETHttpBadRequest.Create(
          TTLanguage.Instance.Translate(SWhereNotValid));

      FList[LIndex] := TTHttpFilterWhere.Create(
        TJSonObject(AJSon.Items[LIndex]), ATableMetadata, LIndex);
    end;
  end;
end;

procedure TTHttpFilterWhereList.AddParameters(var AFilter: TTFilter);
var
  LIndex: Integer;
begin
  for LIndex := Low(FList) to High(FList) do
    FList[LIndex].AddParameter(AFilter);
end;

function TTHttpFilterWhereList.ToString: String;
var
  LIndex: Integer;
begin
  result := String.Empty;
  for LIndex := Low(FList) to High(FList) do
    if result.IsEmpty then
      result := FList[LIndex].ToString
    else
      result := Format('%s AND %s', [result, FList[LIndex].ToString]);
end;

{ TTHttpFilterOrderBy }

constructor TTHttpFilterOrderBy.Create(
  const AJSon: TJSonObject; const ATableMetadata: TTTableMetadata);
var
  LColumnMetadata: TTColumnMetadata;
begin
  FDirection := AJSon.GetValue<String>('direction', String.Empty);

  LColumnMetadata := ATableMetadata.FindColumn(
    AJSon.GetValue<String>('columnName', String.Empty));
  FColumnName := LColumnMetadata.ColumnName;
  ValidateDirection;
end;

function TTHttpFilterOrderBy.ToString: String;
begin
  result := Format('%s %s', [FColumnName, FDirection]);
end;

procedure TTHttpFilterOrderBy.ValidateDirection;
var
  LIsValid: Boolean;
  LIndex: Integer;
begin
  LIsValid := False;
  for LIndex := Low(Directions) to High(Directions) do
    if String.Compare(Directions[LIndex], FDirection, True) = 0 then
    begin
      LIsValid := True;
      Break;
    end;

  if not LIsValid then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SDirectionNotValid), [FDirection]);
end;

{ TTHttpFilterOrderByList }

constructor TTHttpFilterOrderByList.Create(
  const AJSon: TJSonArray; const ATableMetadata: TTTableMetadata);
begin
  Create(AJSon, ATableMetadata, -1);
end;

constructor TTHttpFilterOrderByList.Create(
  const AJSon: TJSonArray;
  const ATableMetadata: TTTableMetadata;
  const AMaxColumns: Integer);
var
  LIndex: Integer;
begin
  if Assigned(AJSon) then
  begin
    if (AMaxColumns >= 0) and (AJSon.Count > AMaxColumns) then
      raise ETHttpBadRequest.CreateFmt(
        TTLanguage.Instance.Translate(STooManyOrderByColumns), [
          AJSon.Count, AMaxColumns]);

    SetLength(FList, AJSon.Count);
    for LIndex := 0 to AJSon.Count - 1 do
    begin
      if not (AJSon.Items[LIndex] is TJSonObject) then
        raise ETHttpBadRequest.Create(
          TTLanguage.Instance.Translate(SOrderByItemNotValid));

      FList[LIndex] := TTHttpFilterOrderBy.Create(
        TJSonObject(AJSon.Items[LIndex]), ATableMetadata);
    end;
  end;
end;

function TTHttpFilterOrderByList.ToString: String;
var
  LIndex: Integer;
begin
  result := String.Empty;
  for LIndex := Low(FList) to High(FList) do
    if result.IsEmpty then
      result := FList[LIndex].ToString
    else
      result := Format('%s, %s', [result, FList[LIndex].ToString]);
end;

{ TTHttpFilter<T> }

constructor TTHttpFilter<T>.Create(
  const AContext: TTContext; const AJSon: TJSonValue);
begin
  Create(AContext, AJSon, TTHttpFilterParameters.Defaults);
end;

constructor TTHttpFilter<T>.Create(
  const AContext: TTContext;
  const AJSon: TJSonValue;
  const AParameters: TTHttpFilterParameters);
var
  LTableMetadata: TTTableMetadata;
  LWhere: TTHttpFilterWhereList;
  LStart, LLimit: Integer;
  LOrderBy: TTHttpFilterOrderByList;
begin
  LTableMetadata := AContext.GetMetadata<T>();

  LWhere := TTHttpFilterWhereList.Create(
    AJSon.GetValue<TJSonArray>('where', nil),
    LTableMetadata,
    AParameters.MaxWhereConditions);
  LStart := AJSon.GetValue<Integer>('start', 0);
  if LStart < 0 then
    LStart := 0;
  LLimit := AParameters.LimitOrDefault(AJSon.GetValue<Integer>('limit', 0));
  LOrderBy := TTHttpFilterOrderByList.Create(
    AJSon.GetValue<TJSonArray>('orderBy', nil),
    LTableMetadata,
    AParameters.MaxOrderByColumns);

  FFilter := TTFilter.Create(
    LWhere.ToString, LStart, LLimit, LOrderBy.ToString);
  FFilter.IncludeDeleted := AParameters.IncludeDeleted;
  LWhere.AddParameters(FFilter);
end;

end.
