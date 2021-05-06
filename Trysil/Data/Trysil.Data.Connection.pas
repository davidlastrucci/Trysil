unit Trysil.Data.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,

  Trysil.Types,
  Trysil.Data,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Filter,
  Trysil.Events.Abstract,
  Trysil.Data.SqlSyntax;

type

{ TTDataGenericConnection }

  TTDataGenericConnection = class abstract(TTDataConnection)
  strict private
    FSyntaxClasses: TTDataSyntaxClasses;
  strict protected
    function CreateSyntaxClasses: TTDataSyntaxClasses; virtual; abstract;

    function SelectCount(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Integer; override;
  public
    function CreateReader(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTDataReader; override;

    function CreateInsertCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataInsertCommand; override;

    function CreateUpdateCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataUpdateCommand; override;

    function CreateDeleteCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataDeleteCommand; override;

    procedure GetMetadata(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;

    function GetSequenceID(const ASequenceName: String): TTPrimaryKey; override;
  public
    constructor Create;
    destructor Destroy; override;

    property SyntaxClasses: TTDataSyntaxClasses read FSyntaxClasses;
  end;

{ TTDataGenericReader }

  TTDataGenericReader = class(TTDataReader)
  strict private
    FSyntax: TTDataSelectSyntax;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const AConnection: TTDataGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTDataGenericInsertCommand }

  TTDataGenericInsertCommand = class(TTDataInsertCommand)
  strict private
    FConnection: TTDataGenericConnection;
  public
    constructor Create(
      const AConnection: TTDataGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataGenericUpdateCommand }

  TTDataGenericUpdateCommand = class(TTDataUpdateCommand)
  strict private
    FConnection: TTDataGenericConnection;
  public
    constructor Create(
      const AConnection: TTDataGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataGenericDeleteCommand }

  TTDataGenericDeleteCommand = class(TTDataDeleteCommand)
  strict private
    FConnection: TTDataGenericConnection;
  public
    constructor Create(
      const AConnection: TTDataGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

implementation

{ TTDataGenericConnection }

constructor TTDataGenericConnection.Create;
begin
  inherited Create;
  FSyntaxClasses := CreateSyntaxClasses;
end;

destructor TTDataGenericConnection.Destroy;
begin
  FSyntaxClasses.Free;
  inherited Destroy;
end;

function TTDataGenericConnection.CreateReader(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTDataReader;
begin
  result := TTDataGenericReader.Create(
    Self, AMapper, ATableMap, ATableMetadata, AFilter);
end;

function TTDataGenericConnection.CreateInsertCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataInsertCommand;
begin
  result := TTDataGenericInsertCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTDataGenericConnection.CreateUpdateCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataUpdateCommand;
begin
  result := TTDataGenericUpdateCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTDataGenericConnection.CreateDeleteCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataDeleteCommand;
begin
  result := TTDataGenericDeleteCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

procedure TTDataGenericConnection.GetMetadata(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTDataMetadataSyntax;
  LIndex: Integer;
begin
  LSyntax := FSyntaxClasses.Metadata.Create(
    Self, AMapper, ATableMap, ATableMetadata);
  try
    for LIndex := 0 to LSyntax.Dataset.FieldDefs.Count - 1 do
      ATableMetadata.Columns.Add(
        LSyntax.Dataset.FieldDefs[LIndex].Name,
        LSyntax.Dataset.FieldDefs[LIndex].DataType,
        LSyntax.Dataset.FieldDefs[LIndex].Size);
  finally
    LSyntax.Free;
  end;
end;

function TTDataGenericConnection.GetSequenceID(
  const ASequenceName: String): TTPrimaryKey;
var
  LSyntax: TTDataSequenceSyntax;
begin
  LSyntax := FSyntaxClasses.Sequence.Create(Self, ASequenceName);
  try
    result := LSyntax.ID;
  finally
    LSyntax.Free;
  end;
end;

function TTDataGenericConnection.SelectCount(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Integer;
var
  LID: TTPrimaryKey;
  LSyntax: TTDataSelectCountSyntax;
begin
  LID := ATableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := FSyntaxClasses.SelectCount.Create(
    Self, ATableMap, ATableName, AColumnName, LID);
  try
    result := LSyntax.Count;
  finally
    LSyntax.Free;
  end;
end;

{ TTDataGenericReader }

constructor TTDataGenericReader.Create(
  const AConnection: TTDataGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FSyntax := AConnection.SyntaxClasses.Select.Create(
    AConnection, AMapper, ATableMap, ATableMetadata, AFilter);
end;

destructor TTDataGenericReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTDataGenericReader.GetDataset: TDataset;
begin
  result := FSyntax.Dataset;
end;

{ TTDataGenericInsertCommand }

constructor TTDataGenericInsertCommand.Create(
  const AConnection: TTDataGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTDataGenericInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Insert.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent, []);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataGenericUpdateCommand }

constructor TTDataGenericUpdateCommand.Create(
  const AConnection: TTDataGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTDataGenericUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Update.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent, GetWhereColumns);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataGenericDeleteCommand }

constructor TTDataGenericDeleteCommand.Create(
  const AConnection: TTDataGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTDataGenericDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Delete.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent, GetWhereColumns);
  finally
    LSyntax.Free;
  end;
end;

end.
