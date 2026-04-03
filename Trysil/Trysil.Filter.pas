(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Filter;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Generics.Collections,
  Trysil.Rtti;

type

{ TTFilterPaging }

  TTFilterPaging = record
  strict private
    FStart: Integer;
    FLimit: Integer;
    FOrderBy: String;

    function GetIsEmpty: Boolean;
    function GetHasPagination: Boolean;
  public
    constructor Create(
      const AStart: Integer; const ALimit: Integer; const AOrderBy: String);

    property Start: Integer read FStart write FStart;
    property Limit: Integer read FLimit write FLimit;
    property OrderBy: String read FOrderBy write FOrderBy;
    property IsEmpty: Boolean read GetIsEmpty;
    property HasPagination: Boolean read GetHasPagination;

    class function Empty: TTFilterPaging; static;
  end;

{ TTFilterParameter }

  TTFilterParameter = record
  strict private
    FName: String;
    FDataType: TFieldType;
    FSize: Integer;
    FValue: TTValue;
  public
    constructor Create(
      const AName: String;
      const ADataType: TFieldType;
      const ASize: Integer;
      const AValue: TTValue);

    property Name: String read FName;
    property DataType: TFieldType read FDataType;
    property Size: Integer read FSize;
    property Value: TTValue read FValue;
  end;

{ TTFilter }

  TTFilter = record
  strict private
    FWhere: String;
    FParameters: TArray<TTFilterParameter>;
    FPaging: TTFilterPaging;
    FIncludeDeleted: Boolean;

    function GetIsEmpty: Boolean;
  public
    constructor Create(const AWhere: String); overload;

    constructor Create(
      const AWhere: String;
      const AMaxRecord: Integer;
      const AOrderBy: String); overload;

    constructor Create(
      const AWhere: String;
      const AStart: Integer;
      const ALimit: Integer;
      const AOrderBy: String); overload;

    procedure AddParameter(
      const AName: String;
      const ADataType: TFieldType;
      const AValue: TTValue); overload;

    procedure AddParameter(
      const AName: String;
      const ADataType: TFieldType;
      const ASize: Integer;
      const AValue: TTValue); overload;

    property Where: String read FWhere write FWhere;
    property Parameters: TArray<TTFilterParameter> read FParameters;
    property Paging: TTFilterPaging read FPaging;
    property IsEmpty: Boolean read GetIsEmpty;
    property IncludeDeleted: Boolean read FIncludeDeleted write FIncludeDeleted;

    class function Empty: TTFilter; static;
  end;

{ TTFilterOperator }

  TTFilterOperator = (foAnd, foOr);

{ TTFilterCondition<T> }

  TTFilterBuilder<T: class> = class;

  TTFilterCondition<T: class> = class
  strict private
    FBuilder: TTFilterBuilder<T>;
    FColumnName: String;
    FParamIndex: Integer;
    FOperator: TTFilterOperator;

    function ParamName: String;

    function AddCondition(
      const AOperatorSQL: String;
      const AValue: TTValue): TTFilterBuilder<T>;
  public
    constructor Create(
      const ABuilder: TTFilterBuilder<T>;
      const AColumnName: String;
      const AParamIndex: Integer;
      const AOperator: TTFilterOperator);

    function Equal(const AValue: TTValue): TTFilterBuilder<T>;
    function NotEqual(const AValue: TTValue): TTFilterBuilder<T>;
    function Greater(const AValue: TTValue): TTFilterBuilder<T>;
    function GreaterOrEqual(const AValue: TTValue): TTFilterBuilder<T>;
    function Less(const AValue: TTValue): TTFilterBuilder<T>;
    function LessOrEqual(const AValue: TTValue): TTFilterBuilder<T>;
    function Like(const AValue: String): TTFilterBuilder<T>;
    function NotLike(const AValue: String): TTFilterBuilder<T>;
    function IsNull: TTFilterBuilder<T>;
    function IsNotNull: TTFilterBuilder<T>;
  end;

{ TTFilterBuilder<T> }

  TTFilterBuilder<T: class> = class
  strict private
    FTableMetadata: TTTableMetadata;
    FConditions: TTObjectList<TTFilterCondition<T>>;
    FWhereParts: TArray<String>;
    FOperators: TArray<TTFilterOperator>;
    FParameters: TArray<TTFilterParameter>;
    FOrderBy: String;
    FStart: Integer;
    FLimit: Integer;
    FIncludeDeleted: Boolean;
    FParamCounter: Integer;

    function BuildWhereClause: String;
  private
    function NextParamIndex: Integer;
    procedure AppendCondition(
      const AOperator: TTFilterOperator;
      const AConditionSQL: String);
    procedure AppendParameter(
      const AColumnName: String;
      const AParamName: String;
      const AValue: TTValue);
  public
    constructor Create(const AMetadata: TTMetadata);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Where(const AColumnName: String): TTFilterCondition<T>;
    function AndWhere(const AColumnName: String): TTFilterCondition<T>;
    function OrWhere(const AColumnName: String): TTFilterCondition<T>;

    function OrderByAsc(const AColumnName: String): TTFilterBuilder<T>;
    function OrderByDesc(const AColumnName: String): TTFilterBuilder<T>;
    function Limit(const ALimit: Integer): TTFilterBuilder<T>;
    function Offset(const AStart: Integer): TTFilterBuilder<T>;
    function IncludeDeleted: TTFilterBuilder<T>;

    function Build: TTFilter;
  end;

implementation

{ TTFilterPaging }

constructor TTFilterPaging.Create(
  const AStart: Integer;
  const ALimit: Integer;
  const AOrderBy: String);
begin
  FStart := AStart;
  FLimit := ALimit;
  FOrderBy := AOrderBy;
end;

function TTFilterPaging.GetIsEmpty: Boolean;
begin
  result := (FStart < 0) or (FLimit <= 0);
end;

function TTFilterPaging.GetHasPagination: Boolean;
begin
  result := (FStart >= 0) and (FLimit > 0);
end;

class function TTFilterPaging.Empty: TTFilterPaging;
begin
  result := TTFilterPaging.Create(-1, -1, String.Empty);
end;

{ TTFilterParameter }

constructor TTFilterParameter.Create(
  const AName: String;
  const ADataType: TFieldType;
  const ASize: Integer;
  const AValue: TTValue);
begin
  FName := AName;
  FDataType := ADataType;
  FSize := ASize;
  FValue := AValue;
end;

{ TTFilter }

constructor TTFilter.Create(const AWhere: String);
begin
  FWhere := AWhere;
  SetLength(FParameters, 0);
  FPaging := TTFilterPaging.Empty();
  FIncludeDeleted := False;
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AMaxRecord: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  SetLength(FParameters, 0);
  FPaging := TTFilterPaging.Create(0, AMaxRecord, AOrderBy);
  FIncludeDeleted := False;
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AStart: Integer;
  const ALimit: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  SetLength(FParameters, 0);
  FPaging := TTFilterPaging.Create(AStart, ALimit, AOrderBy);
  FIncludeDeleted := False;
end;

procedure TTFilter.AddParameter(
  const AName: String;
  const ADataType: TFieldType;
  const AValue: TTValue);
begin
  AddParameter(AName, ADataType, 0, AValue);
end;

procedure TTFilter.AddParameter(
  const AName: String;
  const ADataType: TFieldType;
  const ASize: Integer;
  const AValue: TTValue);
var
  LLength: Integer;
begin
  LLength := Length(FParameters);
  SetLength(FParameters, LLength + 1);
  FParameters[LLength] := TTFilterParameter.Create(
    AName, ADataType, ASize, AValue);
end;

class function TTFilter.Empty: TTFilter;
begin
  result := TTFilter.Create(String.Empty);
end;

function TTFilter.GetIsEmpty: Boolean;
begin
  result := FWhere.IsEmpty and FPaging.IsEmpty;
end;

{ TTFilterCondition<T> }

constructor TTFilterCondition<T>.Create(
  const ABuilder: TTFilterBuilder<T>;
  const AColumnName: String;
  const AParamIndex: Integer;
  const AOperator: TTFilterOperator);
begin
  inherited Create;
  FBuilder := ABuilder;
  FColumnName := AColumnName;
  FParamIndex := AParamIndex;
  FOperator := AOperator;
end;

function TTFilterCondition<T>.ParamName: String;
begin
  result := Format(':p%d', [FParamIndex]);
end;

function TTFilterCondition<T>.AddCondition(
  const AOperatorSQL: String;
  const AValue: TTValue): TTFilterBuilder<T>;
begin
  FBuilder.AppendCondition(
    FOperator,
    Format('%s %s %s', [FColumnName, AOperatorSQL, ParamName]));
  FBuilder.AppendParameter(FColumnName, ParamName, AValue);
  result := FBuilder;
end;

function TTFilterCondition<T>.Equal(const AValue: TTValue): TTFilterBuilder<T>;
begin
  result := AddCondition('=', AValue);
end;

function TTFilterCondition<T>.NotEqual(
  const AValue: TTValue): TTFilterBuilder<T>;
begin
  result := AddCondition('<>', AValue);
end;

function TTFilterCondition<T>.Greater(
  const AValue: TTValue): TTFilterBuilder<T>;
begin
  result := AddCondition('>', AValue);
end;

function TTFilterCondition<T>.GreaterOrEqual(
  const AValue: TTValue): TTFilterBuilder<T>;
begin
  result := AddCondition('>=', AValue);
end;

function TTFilterCondition<T>.Less(const AValue: TTValue): TTFilterBuilder<T>;
begin
  result := AddCondition('<', AValue);
end;

function TTFilterCondition<T>.LessOrEqual(
  const AValue: TTValue): TTFilterBuilder<T>;
begin
  result := AddCondition('<=', AValue);
end;

function TTFilterCondition<T>.Like(const AValue: String): TTFilterBuilder<T>;
begin
  result := AddCondition('LIKE', TTValue.From<String>(AValue));
end;

function TTFilterCondition<T>.NotLike(const AValue: String): TTFilterBuilder<T>;
begin
  result := AddCondition('NOT LIKE', TTValue.From<String>(AValue));
end;

function TTFilterCondition<T>.IsNull: TTFilterBuilder<T>;
begin
  FBuilder.AppendCondition(
    FOperator, Format('%s IS NULL', [FColumnName]));
  result := FBuilder;
end;

function TTFilterCondition<T>.IsNotNull: TTFilterBuilder<T>;
begin
  FBuilder.AppendCondition(
    FOperator, Format('%s IS NOT NULL', [FColumnName]));
  result := FBuilder;
end;

{ TTFilterBuilder<T> }

constructor TTFilterBuilder<T>.Create(const AMetadata: TTMetadata);
begin
  inherited Create;
  FTableMetadata := AMetadata.Load<T>();
  FConditions := TTObjectList<TTFilterCondition<T>>.Create(True);
end;

destructor TTFilterBuilder<T>.Destroy;
begin
  FConditions.Free;
  inherited Destroy;
end;

procedure TTFilterBuilder<T>.AfterConstruction;
begin
  inherited AfterConstruction;
  SetLength(FWhereParts, 0);
  SetLength(FOperators, 0);
  SetLength(FParameters, 0);
  FOrderBy := String.Empty;
  FStart := -1;
  FLimit := -1;
  FIncludeDeleted := False;
  FParamCounter := 0;
end;

function TTFilterBuilder<T>.NextParamIndex: Integer;
begin
  result := FParamCounter;
  Inc(FParamCounter);
end;

procedure TTFilterBuilder<T>.AppendCondition(
  const AOperator: TTFilterOperator;
  const AConditionSQL: String);
var
  LLength: Integer;
begin
  LLength := Length(FWhereParts);
  SetLength(FWhereParts, LLength + 1);
  SetLength(FOperators, LLength + 1);
  FWhereParts[LLength] := AConditionSQL;
  FOperators[LLength] := AOperator;
end;

procedure TTFilterBuilder<T>.AppendParameter(
  const AColumnName: String;
  const AParamName: String;
  const AValue: TTValue);
var
  LColumnMetadata: TTColumnMetadata;
  LLength: Integer;
begin
  if not Assigned(FTableMetadata) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(STableMapNotFound));

  LColumnMetadata := FTableMetadata.Columns.Find(AColumnName);
  if not Assigned(LColumnMetadata) then
    raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);

  LLength := Length(FParameters);
  SetLength(FParameters, LLength + 1);
  FParameters[LLength] := TTFilterParameter.Create(
    AParamName, LColumnMetadata.DataType, LColumnMetadata.DataSize, AValue);
end;

function TTFilterBuilder<T>.BuildWhereClause: String;
var
  LIndex: Integer;
begin
  result := String.Empty;
  for LIndex := 0 to High(FWhereParts) do
  begin
    if LIndex = 0 then
      result := FWhereParts[0]
    else if FOperators[LIndex] = foOr then
      result := Format('%s OR %s', [result, FWhereParts[LIndex]])
    else
      result := Format('%s AND %s', [result, FWhereParts[LIndex]]);
  end;
end;

function TTFilterBuilder<T>.Where(
  const AColumnName: String): TTFilterCondition<T>;
begin
  result := TTFilterCondition<T>.Create(Self, AColumnName, NextParamIndex, foAnd);
  FConditions.Add(result);
end;

function TTFilterBuilder<T>.AndWhere(
  const AColumnName: String): TTFilterCondition<T>;
begin
  result := TTFilterCondition<T>.Create(Self, AColumnName, NextParamIndex, foAnd);
  FConditions.Add(result);
end;

function TTFilterBuilder<T>.OrWhere(
  const AColumnName: String): TTFilterCondition<T>;
begin
  result := TTFilterCondition<T>.Create(Self, AColumnName, NextParamIndex, foOr);
  FConditions.Add(result);
end;

function TTFilterBuilder<T>.OrderByAsc(
  const AColumnName: String): TTFilterBuilder<T>;
begin
  FOrderBy := AColumnName;
  result := Self;
end;

function TTFilterBuilder<T>.OrderByDesc(
  const AColumnName: String): TTFilterBuilder<T>;
begin
  FOrderBy := Format('%s DESC', [AColumnName]);
  result := Self;
end;

function TTFilterBuilder<T>.Limit(const ALimit: Integer): TTFilterBuilder<T>;
begin
  FLimit := ALimit;
  result := Self;
end;

function TTFilterBuilder<T>.Offset(const AStart: Integer): TTFilterBuilder<T>;
begin
  FStart := AStart;
  result := Self;
end;

function TTFilterBuilder<T>.IncludeDeleted: TTFilterBuilder<T>;
begin
  FIncludeDeleted := True;
  result := Self;
end;

function TTFilterBuilder<T>.Build: TTFilter;
var
  LWhere: String;
  LParam: TTFilterParameter;
begin
  LWhere := BuildWhereClause;

  if (FStart >= 0) or (FLimit > 0) then
    result := TTFilter.Create(LWhere, FStart, FLimit, FOrderBy)
  else if not FOrderBy.IsEmpty then
    result := TTFilter.Create(LWhere, -1, FOrderBy)
  else
    result := TTFilter.Create(LWhere);

  result.IncludeDeleted := FIncludeDeleted;

  for LParam in FParameters do
    result.AddParameter(
      LParam.Name, LParam.DataType, LParam.Size, LParam.Value);
end;

end.
