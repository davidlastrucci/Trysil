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

{ TTHttpFilterWhere }

  TTHttpFilterWhere = record
  strict private
    const Conditions: array[0..7] of string =
      ('=', '<>', '<', '<=', '>', '>=', 'LIKE', 'NOT LIKE');
  strict private
    FColumnName: String;
    FCondition: String;
    FValue: String;

    FColumnMetadata: TTColumnMetadata;

    procedure ValidateCondition;
  public
    constructor Create(
      const AJSon: TJSonObject; const ATableMetadata: TTTableMetadata);

    function ToString: String;
  end;

{ TTHttpFilterWhereList }

  TTHttpFilterWhereList = record
  strict private
    FList: TArray<TTHttpFilterWhere>;
  public
    constructor Create(
      const AJSon: TJSonArray; const ATableMetadata: TTTableMetadata);

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
      const AJSon: TJSonArray; const ATableMetadata: TTTableMetadata);

    function ToString: String;
  end;

{ TTHttpFilter<T> }

  TTHttpFilter<T: class> = record
  strict private
    FFilter: TTFilter;
  public
    constructor Create(const AContext: TTContext; const AJSon: TJSonValue);

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
    raise ETHttpBadRequest.CreateFmt(SColumnNotFound, [AName]);
end;

{ TTHttpFilterWhere }

constructor TTHttpFilterWhere.Create(
  const AJSon: TJSonObject; const ATableMetadata: TTTableMetadata);
begin
  FColumnName := AJSon.GetValue<String>('columnName', String.Empty);
  FCondition := AJSon.GetValue<String>('condition', String.Empty);
  FValue := AJSon.GetValue<String>('value', String.Empty);

  FColumnMetadata := ATableMetadata.FindColumn(FColumnName);
  ValidateCondition;
end;

function TTHttpFilterWhere.ToString: String;
begin
  // TODO: FColumnMetadata.DataType
  result := Format('%s %s %s', [FColumnName, FCondition, QuotedStr(FValue)]);
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
    raise ETHttpBadRequest.CreateFmt(SConditionNotValid, [FCondition]);
end;

{ TTHttpFilterWhereList }

constructor TTHttpFilterWhereList.Create(
  const AJSon: TJSonArray; const ATableMetadata: TTTableMetadata);
var
  LIndex: Integer;
begin
  if Assigned(AJSon) then
  begin
    SetLength(FList, AJSon.Count);
    for LIndex := 0 to AJSon.Count - 1 do
      if AJSon[Lindex] is TJSonObject then
        FList[LIndex] := TTHttpFilterWhere.Create(
          TJSonObject(AJSon[Lindex]), ATableMetadata);
  end;
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
begin
  FColumnName := AJSon.GetValue<String>('columnName', String.Empty);
  FDirection := AJSon.GetValue<String>('direction', String.Empty);

  ATableMetadata.FindColumn(FColumnName);
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
    raise ETHttpBadRequest.CreateFmt(SDirectionNotValid, [FDirection]);
end;

{ TTHttpFilterOrderByList }

constructor TTHttpFilterOrderByList.Create(
  const AJSon: TJSonArray; const ATableMetadata: TTTableMetadata);
var
  LIndex: Integer;
begin
  if Assigned(AJSon) then
  begin
    SetLength(FList, AJSon.Count);
    for LIndex := 0 to AJSon.Count - 1 do
      if AJSon[Lindex] is TJSonObject then
        FList[LIndex] := TTHttpFilterOrderBy.Create(
          TJSonObject(AJSon[Lindex]), ATableMetadata);
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
var
  LTableMetadata: TTTableMetadata;
  LWhere: TTHttpFilterWhereList;
  LStart, LLimit: Integer;
  LOrderBy: TTHttpFilterOrderByList;
begin
  LTableMetadata := AContext.GetMetadata<T>();

  LWhere := TTHttpFilterWhereList.Create(
    AJSon.GetValue<TJSonArray>('where', nil), LTableMetadata);
  LStart := AJSon.GetValue<Integer>('start', 0);
  LLimit := AJSon.GetValue<Integer>('limit', 0);
  LOrderBy := TTHttpFilterOrderByList.Create(
    AJSon.GetValue<TJSonArray>('orderBy', nil), LTableMetadata);

  FFilter := TTFilter.Create(
    LWhere.ToString, LStart, LLimit, LOrderBy.ToString);
end;

end.
