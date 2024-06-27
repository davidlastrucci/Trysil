(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Data.Columns,
  Trysil.Events.Abstract;

type

{$SCOPEDENUMS ON}

{ TTParam }

  TTParam = class abstract
  strict protected
    function GetName: String; virtual; abstract;
    function GetSize: Integer; virtual; abstract;
    function GetAsString: String; virtual; abstract;
    procedure SetAsString(const Value: String); virtual; abstract;
    function GetAsInteger: Integer; virtual; abstract;
    procedure SetAsInteger(const Value: Integer); virtual; abstract;
    function GetAsLargeInt: Int64; virtual; abstract;
    procedure SetAsLargeInt(const Value: Int64); virtual; abstract;
    function GetAsDouble: Double; virtual; abstract;
    procedure SetAsDouble(const Value: Double); virtual; abstract;
    function GetAsBoolean: Boolean; virtual; abstract;
    procedure SetAsBoolean(const Value: Boolean); virtual; abstract;
    function GetAsDateTime: TDateTime; virtual; abstract;
    procedure SetAsDateTime(const Value: TDateTime); virtual; abstract;
    function GetAsGuid: TGUID; virtual; abstract;
    procedure SetAsGuid(const Value: TGUID); virtual; abstract;
    procedure SetAsBytes(const Value: TBytes); virtual; abstract;
  public
    procedure Clear; virtual; abstract;

    property Name: String read GetName;
    property Size: Integer read GetSize;
    property AsString: String write SetAsString;
    property AsInteger: Integer write SetAsInteger;
    property AsLargeInt: Int64 write SetAsLargeInt;
    property AsDouble: Double write SetAsDouble;
    property AsBoolean: Boolean write SetAsBoolean;
    property AsDateTime: TDateTime write SetAsDateTime;
    property AsGuid: TGUID write SetAsGuid;
    property AsBytes: TBytes write SetAsBytes;
  end;

{ TTReader }

  TTReader = class abstract
  strict private
    FTableMap: TTTableMap;
    FColumns: TObjectDictionary<String, TTColumn>;
    FDataset: TDataset;

    function GetEof: Boolean;
    function GetIsEmpty: Boolean;
  strict protected
    function GetDataset: TDataset; virtual; abstract;
  public
    constructor Create(const ATableMap: TTTableMap);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function ColumnByName(const AColumnName: String): TTColumn;

    procedure Next;

    property Eof: Boolean read GetEof;
    property IsEmpty: Boolean read GetIsEmpty;
  end;

{ TTUpdateMode }

  TTUpdateMode = (KeyAndVersionColumn, KeyOnly);

{ TTAbstractCommand }

  TTAbstractCommand = class abstract
  strict protected
    FTableMap: TTTableMap;
    FTableMetadata: TTTableMetadata;
    FUpdateMode: TTUpdateMode;

    function GetWhereColumns: TArray<TTColumnMap>;
  public
    constructor Create(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); virtual; abstract;
  end;

{ TTConnection }

  TTConnection = class abstract(TTMetadataProvider)
  strict protected
    FUpdateMode: TTUpdateMode;

    function GetDatabaseVersion: String; virtual; abstract;
    function InternalCreateDataSet(
      const ASQL: String; const AFilter: TTFilter): TDataSet; virtual; abstract;
    function GetInTransaction: Boolean; virtual; abstract;
    function GetSupportTransaction: Boolean; virtual; abstract;
    function CheckExists(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Boolean; virtual; abstract;
  public
    constructor Create;

    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;

    function SelectCount(
      const ATableMap: TTTableMap;
      const AFilter: TTFilter): Integer; virtual; abstract;

    function GetDatabaseObjectName(
      const ADatabaseObjectName: String): String; virtual;
    function GetParameterName(
      const AParameterName: String): String;

    function GetSequenceID(
      const ATableMap: TTTableMap): TTPrimaryKey; virtual; abstract;

    procedure CheckRelations(
      const ATableMap: TTTableMap; const AEntity: TObject);

    function CreateDataSet(
      const ASQL: String; const AFilter: TTFilter): TDataSet;

    function Execute(
      const ASQL: String;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; overload; virtual; abstract;

    function Execute(const ASQL: String): Integer; overload; virtual;

    function CreateReader(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTReader; virtual; abstract;

    function CreateInsertCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; virtual; abstract;

    function CreateUpdateCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; virtual; abstract;

    function CreateDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; virtual; abstract;

    property DatabaseVersion: String read GetDatabaseVersion;
    property InTransaction: Boolean read GetInTransaction;
    property SupportTransaction: Boolean read GetSupportTransaction;
    property UpdateMode: TTUpdateMode read FUpdateMode write FUpdateMode;
  end;

implementation

{ TTReader }

constructor TTReader.Create(const ATableMap: TTTableMap);
begin
  inherited Create;
  FTableMap := ATableMap;
  FColumns := TObjectDictionary<String, TTColumn>.Create([doOwnsValues]);
  FDataset := nil;
end;

destructor TTReader.Destroy;
begin
  if Assigned(FDataset) then
    FDataset.Free;
  FColumns.Free;
  inherited Destroy;
end;

procedure TTReader.AfterConstruction;
var
  LColumnMap: TTColumnMap;
begin
  inherited AfterConstruction;
  FDataset := GetDataset;
  for LColumnMap in FTableMap.Columns do
  begin
    if FColumns.ContainsKey(LColumnMap.Name) then
      raise ETException.CreateFmt(SDuplicateColumn, [LColumnMap.Name]);
    FColumns.Add(
      LColumnMap.Name,
      TTColumnFactory.Instance.CreateColumn(
        FDataset.FieldByName(LColumnMap.Name), LColumnMap));
  end;
end;

function TTReader.ColumnByName(const AColumnName: String): TTColumn;
begin
  if not FColumns.TryGetValue(AColumnName, result) then
    raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);
end;

function TTReader.GetEof: Boolean;
begin
  result := FDataset.Eof;
end;

function TTReader.GetIsEmpty: Boolean;
begin
  result := FDataset.IsEmpty;
end;

procedure TTReader.Next;
begin
  FDataset.Next;
end;

{ TTAbstractCommand }

constructor TTAbstractCommand.Create(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create;
  FTableMap := ATableMap;
  FTableMetadata := ATableMetadata;
  FUpdateMode := AUpdateMode;
end;

function TTAbstractCommand.GetWhereColumns: TArray<TTColumnMap>;
var
  LLength: Integer;
begin
  LLength := 1;
  if FUpdateMode = TTUpdateMode.KeyAndVersionColumn then
    Inc(LLength);
  SetLength(result, LLength);
  result[0] := FTableMap.PrimaryKey;
  if FUpdateMode = TTUpdateMode.KeyAndVersionColumn then
    result[1] := FTableMap.VersionColumn;
end;

{ TTConnection }

constructor TTConnection.Create;
begin
  inherited Create;
  FUpdateMode := TTUpdateMode.KeyAndVersionColumn;
end;

function TTConnection.CreateDataSet(
  const ASQL: String; const AFilter: TTFilter): TDataSet;
begin
  result := InternalCreateDataSet(ASQL, AFilter);
  try
    result.Open;
  except
    result.Free;
    raise;
  end;
end;

procedure TTConnection.CheckRelations(
  const ATableMap: TTTableMap; const AEntity: TObject);
var
  LRelation: TTRelationMap;
begin
  for LRelation in ATableMap.Relations do
    if not LRelation.IsCascade then
      if CheckExists(
        ATableMap, LRelation.TableName, LRelation.ColumnName, AEntity) then
        raise ETException.CreateFmt(SRelationError, [AEntity.ToString()]);
end;

function TTConnection.Execute(const ASQL: String): Integer;
begin
  result := Execute(ASQL, nil, nil, nil);
end;

function TTConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  result := ADatabaseObjectName;
end;

function TTConnection.GetParameterName(
  const AParameterName: String): String;
begin
  result := AParameterName.Replace(' ', '_', [rfReplaceAll]);
end;

end.
