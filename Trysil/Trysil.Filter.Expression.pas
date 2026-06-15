(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Filter.Expression;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Rtti;

type

{ TTExpressionParam }

  TTExpressionParam = record
  strict private
    FColumnName: String;
    FValue: TTValue;
  public
    constructor Create(const AColumnName: String; const AValue: TTValue);

    property ColumnName: String read FColumnName;
    property Value: TTValue read FValue;
  end;

{ TTExpression }

  TTExpression = record
  strict private
    FSql: String;
    FParams: TArray<TTExpressionParam>;

    class function MergeParameters(
      const ALeft: TArray<TTExpressionParam>;
      const ARight: TArray<TTExpressionParam>): TArray<TTExpressionParam>; static;
  public
    constructor Create(
      const ASql: String; const AParams: TArray<TTExpressionParam>);

    class operator LogicalAnd(
      const ALeft: TTExpression; const ARight: TTExpression): TTExpression;
    class operator LogicalOr(
      const ALeft: TTExpression; const ARight: TTExpression): TTExpression;
    class operator LogicalNot(const AValue: TTExpression): TTExpression;

    property Sql: String read FSql;
    property Params: TArray<TTExpressionParam> read FParams;
  end;

{ TTProperty }

  TTProperty = record
  strict private
    FColumnName: String;
    FSqlReference: String;

    function Compare(
      const AOperator: String; const AValue: TTValue): TTExpression;
  public
    constructor Create(const AColumnName: String); overload;
    constructor Create(
      const AAlias: String; const AColumnName: String); overload;

    class operator Equal(
      const AProperty: TTProperty; const AValue: TTValue): TTExpression;
    class operator NotEqual(
      const AProperty: TTProperty; const AValue: TTValue): TTExpression;
    class operator GreaterThan(
      const AProperty: TTProperty; const AValue: TTValue): TTExpression;
    class operator GreaterThanOrEqual(
      const AProperty: TTProperty; const AValue: TTValue): TTExpression;
    class operator LessThan(
      const AProperty: TTProperty; const AValue: TTValue): TTExpression;
    class operator LessThanOrEqual(
      const AProperty: TTProperty; const AValue: TTValue): TTExpression;

    function Like(const AValue: String): TTExpression;
    function NotLike(const AValue: String): TTExpression;
    function IsNull: TTExpression;
    function IsNotNull: TTExpression;
    function Between(const ALow: TTValue; const AHigh: TTValue): TTExpression;
    function InValues(const AValues: array of TTValue): TTExpression;

    property ColumnName: String read FColumnName;
    property SqlReference: String read FSqlReference;
  end;

implementation

{ TTExpressionParam }

constructor TTExpressionParam.Create(const AColumnName: String; const AValue: TTValue);
begin
  FColumnName := AColumnName;
  FValue := AValue;
end;

{ TTExpression }

constructor TTExpression.Create(
  const ASql: String; const AParams: TArray<TTExpressionParam>);
begin
  FSql := ASql;
  FParams := AParams;
end;

class function TTExpression.MergeParameters(
  const ALeft: TArray<TTExpressionParam>;
  const ARight: TArray<TTExpressionParam>): TArray<TTExpressionParam>;
var
  LLeftLength: Integer;
  LIndex: Integer;
begin
  LLeftLength := Length(ALeft);
  SetLength(result, LLeftLength + Length(ARight));
  for LIndex := 0 to High(ALeft) do
    result[LIndex] := ALeft[LIndex];
  for LIndex := 0 to High(ARight) do
    result[LLeftLength + LIndex] := ARight[LIndex];
end;

class operator TTExpression.LogicalAnd(
  const ALeft: TTExpression; const ARight: TTExpression): TTExpression;
begin
  result := TTExpression.Create(
    Format('(%s AND %s)', [ALeft.Sql, ARight.Sql]),
    MergeParameters(ALeft.Params, ARight.Params));
end;

class operator TTExpression.LogicalOr(
  const ALeft: TTExpression; const ARight: TTExpression): TTExpression;
begin
  result := TTExpression.Create(
    Format('(%s OR %s)', [ALeft.Sql, ARight.Sql]),
    MergeParameters(ALeft.Params, ARight.Params));
end;

class operator TTExpression.LogicalNot(
  const AValue: TTExpression): TTExpression;
begin
  result := TTExpression.Create(
    Format('NOT (%s)', [AValue.Sql]), AValue.Params);
end;

{ TTProperty }

constructor TTProperty.Create(const AColumnName: String);
begin
  FColumnName := AColumnName;
  FSqlReference := AColumnName;
end;

constructor TTProperty.Create(
  const AAlias: String; const AColumnName: String);
begin
  FColumnName := Format('%s_%s', [AAlias, AColumnName]);
  FSqlReference := Format('%s.%s', [AAlias, AColumnName]);
end;

function TTProperty.Compare(
  const AOperator: String; const AValue: TTValue): TTExpression;
begin
  result := TTExpression.Create(
    Format('%s %s ?', [FSqlReference, AOperator]),
    [TTExpressionParam.Create(FColumnName, AValue)]);
end;

class operator TTProperty.Equal(
  const AProperty: TTProperty; const AValue: TTValue): TTExpression;
begin
  result := AProperty.Compare('=', AValue);
end;

class operator TTProperty.NotEqual(
  const AProperty: TTProperty; const AValue: TTValue): TTExpression;
begin
  result := AProperty.Compare('<>', AValue);
end;

class operator TTProperty.GreaterThan(
  const AProperty: TTProperty; const AValue: TTValue): TTExpression;
begin
  result := AProperty.Compare('>', AValue);
end;

class operator TTProperty.GreaterThanOrEqual(
  const AProperty: TTProperty; const AValue: TTValue): TTExpression;
begin
  result := AProperty.Compare('>=', AValue);
end;

class operator TTProperty.LessThan(
  const AProperty: TTProperty; const AValue: TTValue): TTExpression;
begin
  result := AProperty.Compare('<', AValue);
end;

class operator TTProperty.LessThanOrEqual(
  const AProperty: TTProperty; const AValue: TTValue): TTExpression;
begin
  result := AProperty.Compare('<=', AValue);
end;

function TTProperty.Like(const AValue: String): TTExpression;
begin
  result := Compare('LIKE', TTValue.From<String>(AValue));
end;

function TTProperty.NotLike(const AValue: String): TTExpression;
begin
  result := Compare('NOT LIKE', TTValue.From<String>(AValue));
end;

function TTProperty.IsNull: TTExpression;
begin
  result := TTExpression.Create(Format('%s IS NULL', [FSqlReference]), []);
end;

function TTProperty.IsNotNull: TTExpression;
begin
  result := TTExpression.Create(Format('%s IS NOT NULL', [FSqlReference]), []);
end;

function TTProperty.Between(
  const ALow: TTValue; const AHigh: TTValue): TTExpression;
begin
  result := TTExpression.Create(
    Format('%s BETWEEN ? AND ?', [FSqlReference]),
    [TTExpressionParam.Create(FColumnName, ALow),
     TTExpressionParam.Create(FColumnName, AHigh)]);
end;

function TTProperty.InValues(const AValues: array of TTValue): TTExpression;
var
  LPlaceholders: String;
  LParams: TArray<TTExpressionParam>;
  LIndex: Integer;
begin
  SetLength(LParams, Length(AValues));
  LPlaceholders := String.Empty;
  for LIndex := 0 to High(AValues) do
  begin
    if LIndex = 0 then
      LPlaceholders := '?'
    else
      LPlaceholders := Format('%s, ?', [LPlaceholders]);
    LParams[LIndex] := TTExpressionParam.Create(FColumnName, AValues[LIndex]);
  end;
  result := TTExpression.Create(
    Format('%s IN (%s)', [FSqlReference, LPlaceholders]), LParams);
end;

end.
