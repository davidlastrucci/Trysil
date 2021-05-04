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

  Trysil.Types,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Data.Columns,
  Trysil.Events.Abstract;

type
  ITDataSetParam = interface
  ['{75B98CB8-FA42-458E-9B2F-332568091302}']
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(const Value: Boolean);
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(const Value: TDateTime);
    function GetAsGuid: TGUID;
    procedure SetAsGuid(const Value: TGUID);
    function GetAsFloat: Double;
    procedure SetAsFloat(const Value: Double);
    function GetAsLargeInt: Int64;
    procedure SetAsLargeInt(const Value: Int64);
    function GetAsInteger: Integer;
    procedure SetAsInteger(const Value: Integer);
    function GetAsString: string;
    procedure SetAsString(const Value: string);

    procedure Clear;

    property AsString: string read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsLargeInt: Int64 read GetAsLargeInt write SetAsLargeInt;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
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

{ TTDataAbstractCommand }

  TTDataAbstractCommand = class abstract
  strict protected
    FMapper: TTMapper;
    FTableMap: TTTableMap;
    FTableMetadata: TTTableMetadata;
  public
    constructor Create(
    const AMapper: TTMapper;
    const ATableMap: TTTableMap;
    const ATableMetadata: TTTableMetadata);

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
    function GetInTransaction: Boolean; virtual; abstract;
    function SelectCount(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Integer; virtual; abstract;
  public
    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;

    function GetSequenceID(
      const ASequenceName: String): TTPrimaryKey; virtual; abstract;

    procedure CheckRelations(
      const ATableMap: TTTableMap; const AEntity: TObject);

    function CreateDataSet(const ASQL: string): TDataSet; virtual; abstract;

    function Execute(const ASQL: string;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; overload; virtual; abstract;

    function Execute(const ASQL: string): Integer; overload; virtual;

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
  end;

{ resourcestring }

resourcestring
  SColumnNotFound = 'Column %0:s not found.';
  SRelationError = '"%s" is currently in use, unable to delete.';

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
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create;
  FMapper := AMapper;
  FTableMap := ATableMap;
  FTableMetadata := ATableMetadata;
end;

{ TTDataConnection }

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

function TTDataConnection.Execute(const ASQL: string): Integer;
begin
  Result := Execute(ASQL, nil, nil, nil, nil);
end;

end.
