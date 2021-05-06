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

{ TTDatasetParam }

  TTDatasetParam = class abstract
  strict protected
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
  public
    procedure Clear; virtual; abstract;

    property AsString: String read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsLargeInt: Int64 read GetAsLargeInt write SetAsLargeInt;
    property AsDouble: Double read GetAsDouble write SetAsDouble;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsGuid: TGUID read GetAsGuid write SetAsGuid;
  end;

{ TTDataReader }

  TTDataReader = class abstract
  strict private
    FTableMap: TTTableMap;
    FColumns: TObjectDictionary<String, TTDataColumn>;

    function GetEof: Boolean;
    function GetIsEmpty: Boolean;
  strict protected
    function GetDataset: TDataset; virtual; abstract;
  public
    constructor Create(const ATableMap: TTTableMap);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function ColumnByName(const AColumnName: String): TTDataColumn;

    procedure Next;

    property Eof: Boolean read GetEof;
    property IsEmpty: Boolean read GetIsEmpty;
  end;

{ TTUpdateMode }

  TTUpdateMode = (KeyAndVersionColumn, KeyOnly);

{ TTDataAbstractCommand }

  TTDataAbstractCommand = class abstract
  strict protected
    FMapper: TTMapper;
    FTableMap: TTTableMap;
    FTableMetadata: TTTableMetadata;
    FUpdateMode: TTUpdateMode;

    function GetWhereColumns: TArray<TTColumnMap>;
  public
    constructor Create(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); virtual; abstract;
  end;

{ TTDataInsertCommand }

  TTDataInsertCommand = class abstract(TTDataAbstractCommand);

{ TTDataUpdateCommand }

  TTDataUpdateCommand = class abstract(TTDataAbstractCommand);

{ TTDataDeleteCommand }

  TTDataDeleteCommand = class abstract(TTDataAbstractCommand);

{ TTDataConnection }

  TTDataConnection = class abstract(TTMetadataProvider)
  strict protected
    FUpdateMode: TTUpdateMode;

    function GetInTransaction: Boolean; virtual; abstract;
    function SelectCount(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Integer; virtual; abstract;
  public
    constructor Create;

    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;

    function GetDatabaseObjectName(
      const ADatabaseObjectName: String): String; virtual;
    function GetParameterName(
      const AParameterName: String): String;

    function GetSequenceID(
      const ASequenceName: String): TTPrimaryKey; virtual; abstract;

    procedure CheckRelations(
      const ATableMap: TTTableMap; const AEntity: TObject);

    function CreateDataSet(const ASQL: String): TDataSet; virtual; abstract;

    function Execute(
      const ASQL: String;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; overload; virtual; abstract;

    function Execute(const ASQL: String): Integer; overload; virtual;

    function CreateReader(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTDataReader; virtual; abstract;

    function CreateInsertCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataInsertCommand; virtual; abstract;

    function CreateUpdateCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataUpdateCommand; virtual; abstract;

    function CreateDeleteCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataDeleteCommand; virtual; abstract;

    property InTransaction: Boolean read GetInTransaction;
    property UpdateMode: TTUpdateMode read FUpdateMode write FUpdateMode;
  end;

implementation

{ TTDataReader }

constructor TTDataReader.Create(const ATableMap: TTTableMap);
begin
  inherited Create;
  FTableMap := ATableMap;
  FColumns := TObjectDictionary<String, TTDataColumn>.Create([doOwnsValues]);
end;

destructor TTDataReader.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

procedure TTDataReader.AfterConstruction;
var
  LDataset: TDataset;
  LColumnMap: TTColumnMap;
begin
  inherited AfterConstruction;
  LDataset := GetDataset;
  for LColumnMap in FTableMap.Columns do
    FColumns.Add(
      LColumnMap.Name,
      TTDataColumnFactory.Instance.CreateColumn(
        LDataset.FieldByName(LColumnMap.Name), LColumnMap));
end;

function TTDataReader.ColumnByName(const AColumnName: String): TTDataColumn;
begin
  if not FColumns.TryGetValue(AColumnName, result) then
    raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);
end;

function TTDataReader.GetEof: Boolean;
begin
  result := GetDataset.Eof;
end;

function TTDataReader.GetIsEmpty: Boolean;
begin
  result := GetDataset.IsEmpty;
end;

procedure TTDataReader.Next;
begin
  GetDataset.Next;
end;

{ TTDataAbstractCommand }

constructor TTDataAbstractCommand.Create(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create;
  FMapper := AMapper;
  FTableMap := ATableMap;
  FTableMetadata := ATableMetadata;
  FUpdateMode := AUpdateMode;
end;

function TTDataAbstractCommand.GetWhereColumns: TArray<TTColumnMap>;
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

{ TTDataConnection }

constructor TTDataConnection.Create;
begin
  inherited Create;
  FUpdateMode := TTUpdateMode.KeyAndVersionColumn;
end;

procedure TTDataConnection.CheckRelations(
  const ATableMap: TTTableMap; const AEntity: TObject);
var
  LRelation: TTRelationMap;
begin
  for LRelation in ATableMap.Relations do
    if not LRelation.IsCascade then
      if SelectCount(
        ATableMap, LRelation.TableName, LRelation.ColumnName, AEntity) > 0 then
        raise ETException.CreateFmt(SRelationError, [AEntity.ToString()]);
end;

function TTDataConnection.Execute(const ASQL: String): Integer;
begin
  result := Execute(ASQL, nil, nil, nil, nil);
end;

function TTDataConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  result := ADatabaseObjectName;
end;

function TTDataConnection.GetParameterName(
  const AParameterName: String): String;
begin
  result := AParameterName.Replace(' ', '_', [rfReplaceAll]);
end;

end.
