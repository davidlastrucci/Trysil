(*

  Trysil
  Copyright © David Lastrucci
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
  Trysil.Classes,
  Trysil.Rtti,
  Trysil.Data.Parameters,
  Trysil.Metadata,
  Trysil.Context,
  Trysil.Filter,

  Trysil.JSon.Attributes,
  Trysil.JSon.Types,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions;

type

{ TTHttpTableMetadataHelper }

  TTHttpTableMetadataHelper = class helper for TTTableMetadata
  strict private
    function ColumnByName(const AName: String): TTColumnMetadata;
    function ColumnByJSonName(const AName: String): TTColumnMetadata;
    function Filterable(
      const AColumn: TTColumnMetadata): TTColumnMetadata;
  public
    function FindColumn(const AName: String): TTColumnMetadata;
  end;

{ TTHttpFilterValues }

  TTHttpFilterValues = class
  strict private
    class procedure CheckState(
      const AState: TTJSonValueState; const AName: String);
  public
    class function GetString(
      const AJSon: TJSonValue; const AName: String): String;
    class function GetInteger(
      const AJSon: TJSonValue;
      const AName: String;
      const ADefault: Integer): Integer;
    class function GetArray(
      const AJSon: TJSonValue; const AName: String): TJSonArray;
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
    FSqlReference: String;
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

function TTHttpTableMetadataHelper.ColumnByName(
  const AName: String): TTColumnMetadata;
var
  LColumn: TTColumnMetadata;
begin
  result := nil;
  for LColumn in Self.Columns do
    if TTIdentifier.Same(LColumn.ColumnName, AName) then
    begin
      result := LColumn;
      Break;
    end;
end;

function TTHttpTableMetadataHelper.ColumnByJSonName(
  const AName: String): TTColumnMetadata;
var
  LColumn: TTColumnMetadata;
begin
  result := nil;
  for LColumn in Self.Columns do
    if (not LColumn.JSonName.IsEmpty) and
      TTIdentifier.Same(LColumn.JSonName, AName) then
    begin
      result := LColumn;
      Break;
    end;
end;

function TTHttpTableMetadataHelper.Filterable(
  const AColumn: TTColumnMetadata): TTColumnMetadata;
begin
  result := nil;
  if Assigned(AColumn) and AColumn.IsFilterable and
    TTJSonDirection.CanSerialize(AColumn) then
    result := AColumn;
end;

function TTHttpTableMetadataHelper.FindColumn(
  const AName: String): TTColumnMetadata;
begin
  result := ColumnByName(AName);
  if not Assigned(result) then
    result := ColumnByJSonName(AName);

  result := Filterable(result);
  if not Assigned(result) then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SColumnNotFilterable), [AName]);
end;

{ TTHttpFilterValues }

class procedure TTHttpFilterValues.CheckState(
  const AState: TTJSonValueState; const AName: String);
begin
  if AState = TTJSonValueState.Invalid then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidFilterValue), [
        AName]);
end;

class function TTHttpFilterValues.GetString(
  const AJSon: TJSonValue; const AName: String): String;
var
  LState: TTJSonValueState;
begin
  LState := TTJSonValues.GetString(AJSon, AName, result);
  CheckState(LState, AName);
end;

class function TTHttpFilterValues.GetInteger(
  const AJSon: TJSonValue;
  const AName: String;
  const ADefault: Integer): Integer;
var
  LState: TTJSonValueState;
begin
  LState := TTJSonValues.GetInteger(AJSon, AName, result);
  CheckState(LState, AName);
  if LState = TTJSonValueState.Missing then
    result := ADefault;
end;

class function TTHttpFilterValues.GetArray(
  const AJSon: TJSonValue; const AName: String): TJSonArray;
var
  LState: TTJSonValueState;
begin
  LState := TTJSonValues.GetArray(AJSon, AName, result);
  CheckState(LState, AName);
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
  FCondition := TTHttpFilterValues.GetString(AJSon, 'condition');
  FValue := TTHttpFilterValues.GetString(AJSon, 'value');
  FParameterName := Format('p%d', [AParameterIndex]);

  FColumnName := TTHttpFilterValues.GetString(AJSon, 'columnName');
  FColumnMetadata := ATableMetadata.FindColumn(FColumnName);
  ValidateCondition;
  ValidateConditionForColumn;
end;

function TTHttpFilterWhere.ToString: String;
begin
  result := Format('%s %s :%s', [
    FColumnMetadata.SqlReference, FCondition, FParameterName]);
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
    TFieldType.ftWideMemo,
    TFieldType.ftOraClob];
end;

function TTHttpFilterWhere.IsLikeCondition: Boolean;
begin
  result := TTIdentifier.Same(FCondition, 'LIKE') or
    TTIdentifier.Same(FCondition, 'NOT LIKE');
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
    if TTIdentifier.Same(Conditions[LIndex], FCondition) then
    begin
      FCondition := Conditions[LIndex];
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
  FDirection := TTHttpFilterValues.GetString(AJSon, 'direction');

  LColumnMetadata := ATableMetadata.FindColumn(
    TTHttpFilterValues.GetString(AJSon, 'columnName'));
  FSqlReference := LColumnMetadata.SqlReference;
  ValidateDirection;
end;

function TTHttpFilterOrderBy.ToString: String;
begin
  result := Format('%s %s', [FSqlReference, FDirection]);
end;

procedure TTHttpFilterOrderBy.ValidateDirection;
var
  LIsValid: Boolean;
  LIndex: Integer;
begin
  LIsValid := False;
  for LIndex := Low(Directions) to High(Directions) do
    if TTIdentifier.Same(Directions[LIndex], FDirection) then
    begin
      FDirection := Directions[LIndex];
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
  if Assigned(AJSon) and (not (AJSon is TJSonObject)) then
    raise ETHttpBadRequest.Create(
      TTLanguage.Instance.Translate(SNotValidFilterContent));

  LTableMetadata := AContext.GetMetadata<T>();

  LWhere := TTHttpFilterWhereList.Create(
    TTHttpFilterValues.GetArray(AJSon, 'where'),
    LTableMetadata,
    AParameters.MaxWhereConditions);
  LStart := TTHttpFilterValues.GetInteger(AJSon, 'start', -1);
  if LStart < 0 then
    LStart := -1;
  LLimit := AParameters.LimitOrDefault(
    TTHttpFilterValues.GetInteger(AJSon, 'limit', 0));
  if (LStart > 0) and (LLimit <= 0) then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SStartWithoutLimit), [LStart]);
  LOrderBy := TTHttpFilterOrderByList.Create(
    TTHttpFilterValues.GetArray(AJSon, 'orderBy'),
    LTableMetadata,
    AParameters.MaxOrderByColumns);

  FFilter := TTFilter.Create(
    LWhere.ToString, LStart, LLimit, LOrderBy.ToString);
  FFilter.IncludeDeleted := AParameters.IncludeDeleted;
  LWhere.AddParameters(FFilter);
end;

end.
