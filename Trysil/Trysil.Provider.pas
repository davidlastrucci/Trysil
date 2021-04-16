(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Provider;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.IdentityMap,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Data.Columns,
  Trysil.Rtti;

type

{ TTProvider }

  TTProvider = class
  strict private
    FConnection: TTDataConnection;
    FContext: TObject;
    FMetadata: TTMetadata;
    FMapper: TTMapper;

    FIdentityMap: TTIdentityMap;
    FLazyOwner: TObjectList<TObject>;


    function InternalCreateEntity<T: class, constructor>(
      const ATableMap: TTTAbleMap; const AReader: TTDataReader): T;

    function GetValue(
      const AReader: TTDataReader; const AColumnName: String): TTValue;

    procedure MapColumns<T: class>(
      const ATableMap: TTTAbleMap;
      const AReader: TTDataReader;
      const AEntity: T);
    procedure MapLazyColumn<T: class>(
      const AReader: TTDataReader;
      const AColumnName: String;
      const ARttiMember: TTRttiMember;
      const AEntity: T);
    procedure MapLazyColumns<T: class>(
      const ATableMap: TTTAbleMap;
      const AReader: TTDataReader;
      const AEntity: T);
    procedure MapLazyListColumns<T: class>(
      const ATableMap: TTTAbleMap;
      const AReader: TTDataReader;
      const AEntity: T);

    procedure MapEntity<T: class>(
      const ATableMap: TTTAbleMap;
      const AReader: TTDataReader;
      const AEntity: T);

    function GetPrimaryKey(
      const ATablemap: TTTableMap; const AReader: TTDataReader): TTPrimaryKey;
    function GetWhere(
      const ATablemap: TTTableMap; const AID: TTPrimaryKey): String;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata;
      const AMapper: TTMapper);
    destructor Destroy; override;

    function CreateEntity<T: class, constructor>(): T;
    function CloneEntity<T: class, constructor>(const AEntity: T): T;

    function GetMetadata<T: class>(): TTTableMetadata;

    procedure Select<T: class, constructor>(
      const AResult: TTList<T>; const AFilter: TTFilter);

    function Get<T: class, constructor>(const AID: TTPrimaryKey): T;

    procedure Refresh<T: class>(const AEntity: T);
  end;

{ resourcestring }

resourcestring
  SNotDefinedPrimaryKey = 'Primary key: not defined.';
  SNotValidPrimaryKeyType = 'Primary key: not valid type.';
  SNotDefinedSequence = 'Sequence: not defined.';

implementation

{ TTProvider }

constructor TTProvider.Create(
  const AConnection: TTDataConnection;
  const AContext: TObject;
  const AMetadata: TTMetadata;
  const AMapper: TTMapper);
begin
  inherited Create;
  FConnection := AConnection;
  FContext := AContext;
  FMetadata := AMetadata;
  FMapper := AMapper;

  FIdentityMap := TTIdentityMap.Create;
  FLazyOwner := TObjectList<TObject>.Create(True);
end;

destructor TTProvider.Destroy;
begin
  FLazyOwner.Free;
  FIdentityMap.Free;
  inherited Destroy;
end;

function TTProvider.CreateEntity<T>(): T;
var
  LTableMap: TTTableMap;
  LPrimaryKey: TTPrimaryKey;
  LColumnMap: TTColumnMap;
begin
  LTableMap := FMapper.Load<T>();
  if not Assigned(LTablemap.PrimaryKey) then
    raise ETException.Create(SNotDefinedPrimaryKey);
  if LTableMap.SequenceName.IsEmpty then
    raise ETException.Create(SNotDefinedSequence);

  result := T.Create;
  try
    LPrimaryKey := FConnection.GetSequenceID(LTableMap.SequenceName);
    LTableMap.PrimaryKey.Member.SetValue(result, LPrimaryKey);

    MapLazyColumns<T>(LTableMap, nil, result);
    MapLazyListColumns<T>(LTableMap, nil, result);

    FIdentityMap.AddEntity<T>(LPrimaryKey, result);
  except
    result.Free;
    raise;
  end;
end;

function TTProvider.InternalCreateEntity<T>(
  const ATableMap: TTTAbleMap; const AReader: TTDataReader): T;
var
  LPrimaryKey: TTPrimaryKey;
begin
  LPrimaryKey := GetPrimaryKey(ATableMap, AReader);
  result := FIdentityMap.GetEntity<T>(LPrimaryKey);
  if not Assigned(result) then
  begin
    result := T.Create;
    FIdentityMap.AddEntity<T>(LPrimaryKey, result);
  end;

  MapEntity<T>(ATableMap, AReader, result);
end;

function TTProvider.CloneEntity<T>(const AEntity: T): T;
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LDetailColumnMap: TTDetailColumnMap;
begin
  LTableMap := FMapper.Load<T>();
  result := T.Create;
  try
    MapLazyColumns<T>(LTableMap, nil, result);
    MapLazyListColumns<T>(LTableMap, nil, result);
    for LColumnMap in LTableMap.Columns do
      LColumnMap.Member.SetValue(result, LColumnMap.Member.GetValue(AEntity));
    for LDetailColumnMap in LTableMap.DetailColums do
      LDetailColumnMap.Member.SetValue(
        result, LDetailColumnMap.Member.GetValue(AEntity));
  except
    result.Free;
    raise;
  end;
end;

function TTProvider.GetValue(
  const AReader: TTDataReader; const AColumnName: String): TTValue;
var
  LDataColumn: TTDataColumn;
begin
    if Assigned(AReader) then
    begin
      LDataColumn := AReader.ColumnByName(AColumnName);
      result := LDataColumn.Value;
    end
    else
      result := 0;
end;

procedure TTProvider.MapColumns<T>(
  const ATableMap: TTTAbleMap; const AReader: TTDataReader; const AEntity: T);
var
  LColumnMap: TTColumnMap;
  LDataColumn: TTDataColumn;
  LValue: TTValue;
begin
  for LColumnMap in ATableMap.Columns do
  begin
    if not LColumnMap.Member.IsClass then
    begin
      LDataColumn := AReader.ColumnByName(LColumnMap.Name);
      LDataColumn.SetValue(AEntity);
    end;
  end;
end;

procedure TTProvider.MapLazyColumn<T>(
  const AReader: TTDataReader;
  const AColumnName: String;
  const ARttiMember: TTRttiMember;
  const AEntity: T);
var
  LValue: TTValue;
  LResult: TObject;
begin
  LValue := GetValue(AReader, AColumnName);
  LResult := ARttiMember.CreateObject(
    AEntity, FContext, FMapper, AColumnName, LValue);
  if Assigned(LResult) then
    FLazyOwner.Add(LResult);
end;

procedure TTProvider.MapLazyColumns<T>(
  const ATableMap: TTTAbleMap; const AReader: TTDataReader; const AEntity: T);
var
  LColumnMap: TTColumnMap;
begin
  for LColumnMap in ATableMap.Columns do
    if LColumnMap.Member.IsClass then
      MapLazyColumn<T>(AReader, LColumnMap.Name, LColumnMap.Member, AEntity);
end;

procedure TTProvider.MapLazyListColumns<T>(
  const ATableMap: TTTAbleMap; const AReader: TTDataReader; const AEntity: T);
var
  LColumnMap: TTDetailColumnMap;
begin
  for LColumnMap in ATableMap.DetailColums do
    if LColumnMap.Member.IsClass then
      MapLazyColumn<T>(AReader, LColumnMap.Name, LColumnMap.Member, AEntity);
end;

procedure TTProvider.MapEntity<T>(
  const ATableMap: TTTAbleMap; const AReader: TTDataReader; const AEntity: T);
begin
  MapColumns<T>(ATableMap, AReader, AEntity);
  MapLazyColumns<T>(ATableMap, AReader, AEntity);
  MapLazyListColumns<T>(ATableMap, AReader, AEntity);
end;

function TTProvider.GetMetadata<T>: TTTableMetadata;
begin
  result := FMetadata.Load<T>();
end;

function TTProvider.GetPrimaryKey(
  const ATablemap: TTTableMap; const AReader: TTDataReader): TTPrimaryKey;
var
  LDataColumn: TTDataColumn;
  LResult: TTValue;
begin
  if not Assigned(ATablemap.PrimaryKey) then
    raise ETException.Create(SNotDefinedPrimaryKey);
  LDataColumn := AReader.ColumnByName(ATablemap.PrimaryKey.Name);
  LResult := LDataColumn.Value;
  if not LResult.IsType<TTPrimaryKey>() then
    raise ETException.Create(SNotValidPrimaryKeyType);
  result := LResult.AsType<TTPrimaryKey>();
end;

function TTProvider.GetWhere(
  const ATablemap: TTTableMap; const AID: TTPrimaryKey): String;
begin
  if not Assigned(ATablemap.PrimaryKey) then
    raise ETException.Create(SNotDefinedPrimaryKey);
  result := Format('%s = %d', [ATablemap.PrimaryKey.Name, AID]);
end;

procedure TTProvider.Select<T>(
  const AResult: TTList<T>; const AFilter: TTFilter);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LReader: TTDataReader;
begin
  LTableMap := FMapper.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, AFilter);
  try
    AResult.Clear;
    while not LReader.Eof do
    begin
      AResult.Add(InternalCreateEntity<T>(LTableMap, LReader));
      LReader.Next;
    end;
  finally
      LReader.Free;
  end;
end;

function TTProvider.Get<T>(const AID: TTPrimaryKey): T;
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTDataReader;
begin
  result := default(T);
  LTableMap := FMapper.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LFilter := TTFilter.Create(GetWhere(LTablemap, AID));
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
  try
    if not LReader.IsEmpty then
      result := InternalCreateEntity<T>(LTableMap, LReader);
  finally
    LReader.Free;
  end;
end;

procedure TTProvider.Refresh<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTDataReader;
begin
  LTableMap := FMapper.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LFilter := TTFilter.Create(GetWhere(
    LTablemap,
    LTablemap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>()));
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
  try
      MapEntity<T>(LTableMap, LReader, AEntity);
  finally
    LReader.Free;
  end;
end;

end.
