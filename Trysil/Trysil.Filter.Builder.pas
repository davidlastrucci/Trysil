(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Filter.Builder;

interface

uses
  System.SysUtils,
  System.Rtti,
  Data.DB,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Metadata,
  Trysil.Generics.Collections,
  Trysil.Context;

type

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
      const AValue: TValue): TTFilterBuilder<T>;
  public
    constructor Create(
      const ABuilder: TTFilterBuilder<T>;
      const AColumnName: String;
      const AParamIndex: Integer;
      const AOperator: TTFilterOperator);

    function Equal(const AValue: TValue): TTFilterBuilder<T>;
    function NotEqual(const AValue: TValue): TTFilterBuilder<T>;
    function Greater(const AValue: TValue): TTFilterBuilder<T>;
    function GreaterOrEqual(const AValue: TValue): TTFilterBuilder<T>;
    function Less(const AValue: TValue): TTFilterBuilder<T>;
    function LessOrEqual(const AValue: TValue): TTFilterBuilder<T>;
    function Like(const AValue: String): TTFilterBuilder<T>;

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
      const AValue: TValue);
  public
    constructor Create(const AContext: TTContext);
    destructor Destroy; override;

    function Where(const AColumnName: String): TTFilterCondition<T>;
    function AndWhere(const AColumnName: String): TTFilterCondition<T>;
    function OrWhere(const AColumnName: String): TTFilterCondition<T>;

    function OrderByAsc(const AColumnName: String): TTFilterBuilder<T>;
    function OrderByDesc(const AColumnName: String): TTFilterBuilder<T>;
    function Limit(const ALimit: Integer): TTFilterBuilder<T>;
    function Offset(const AStart: Integer): TTFilterBuilder<T>;

    function Build: TTFilter;

    class function New(const AContext: TTContext): TTFilterBuilder<T>; static;
  end;

implementation

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
  const AValue: TValue): TTFilterBuilder<T>;
begin
  FBuilder.AppendCondition(
    FOperator,
    Format('%s %s %s', [FColumnName, AOperatorSQL, ParamName]));
  FBuilder.AppendParameter(FColumnName, ParamName, AValue);
  result := FBuilder;
end;

function TTFilterCondition<T>.Equal(const AValue: TValue): TTFilterBuilder<T>;
begin
  result := AddCondition('=', AValue);
end;

function TTFilterCondition<T>.NotEqual(const AValue: TValue): TTFilterBuilder<T>;
begin
  result := AddCondition('<>', AValue);
end;

function TTFilterCondition<T>.Greater(const AValue: TValue): TTFilterBuilder<T>;
begin
  result := AddCondition('>', AValue);
end;

function TTFilterCondition<T>.GreaterOrEqual(const AValue: TValue): TTFilterBuilder<T>;
begin
  result := AddCondition('>=', AValue);
end;

function TTFilterCondition<T>.Less(const AValue: TValue): TTFilterBuilder<T>;
begin
  result := AddCondition('<', AValue);
end;

function TTFilterCondition<T>.LessOrEqual(const AValue: TValue): TTFilterBuilder<T>;
begin
  result := AddCondition('<=', AValue);
end;

function TTFilterCondition<T>.Like(const AValue: String): TTFilterBuilder<T>;
begin
  result := AddCondition('LIKE', TValue.From<String>(AValue));
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

constructor TTFilterBuilder<T>.Create(const AContext: TTContext);
begin
  inherited Create;
  FTableMetadata := AContext.GetMetadata<T>();
  FConditions := TTObjectList<TTFilterCondition<T>>.Create(True);
  SetLength(FWhereParts, 0);
  SetLength(FOperators, 0);
  SetLength(FParameters, 0);
  FOrderBy := String.Empty;
  FStart := -1;
  FLimit := -1;
  FParamCounter := 0;
end;

destructor TTFilterBuilder<T>.Destroy;
begin
  FConditions.Free;
  inherited Destroy;
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
  const AValue: TValue);
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

  for LParam in FParameters do
    result.AddParameter(
      LParam.Name, LParam.DataType, LParam.Size, LParam.Value);
end;

class function TTFilterBuilder<T>.New(
  const AContext: TTContext): TTFilterBuilder<T>;
begin
  result := TTFilterBuilder<T>.Create(AContext);
end;

end.
