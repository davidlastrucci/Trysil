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

{ TTDataSyntaxConnection }

  TTDataSyntaxConnection = class abstract(TTDataConnection)
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

{ TTDataSyntaxDataReader }

  TTDataSyntaxDataReader = class(TTDataReader)
  strict private
    FSyntax: TTDataSelectSyntax;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const AConnection: TTDataSyntaxConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTDataSyntaxDataInsertCommand }

  TTDataSyntaxDataInsertCommand = class(TTDataInsertCommand)
  strict private
    FConnection: TTDataSyntaxConnection;
  public
    constructor Create(
      const AConnection: TTDataSyntaxConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataSyntaxDataUpdateCommand }

  TTDataSyntaxDataUpdateCommand = class(TTDataUpdateCommand)
  strict private
    FConnection: TTDataSyntaxConnection;
  public
    constructor Create(
      const AConnection: TTDataSyntaxConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataSyntaxDataDeleteCommand }

  TTDataSyntaxDataDeleteCommand = class(TTDataDeleteCommand)
  strict private
    FConnection: TTDataSyntaxConnection;
  public
    constructor Create(
      const AConnection: TTDataSyntaxConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

implementation

{ TTDataSyntaxesConnection }

constructor TTDataSyntaxConnection.Create;
begin
  inherited Create;
  FSyntaxClasses := CreateSyntaxClasses;
end;

destructor TTDataSyntaxConnection.Destroy;
begin
  FSyntaxClasses.Free;
  inherited Destroy;
end;

function TTDataSyntaxConnection.CreateReader(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTDataReader;
begin
  result := TTDataSyntaxDataReader.Create(
    Self, AMapper, ATableMap, ATableMetadata, AFilter);
end;

function TTDataSyntaxConnection.CreateInsertCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataInsertCommand;
begin
  result := TTDataSyntaxDataInsertCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTDataSyntaxConnection.CreateUpdateCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataUpdateCommand;
begin
  result := TTDataSyntaxDataUpdateCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTDataSyntaxConnection.CreateDeleteCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataDeleteCommand;
begin
  result := TTDataSyntaxDataDeleteCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

procedure TTDataSyntaxConnection.GetMetadata(
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

function TTDataSyntaxConnection.GetSequenceID(
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

function TTDataSyntaxConnection.SelectCount(
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

{ TTDataSyntaxDataReader }

constructor TTDataSyntaxDataReader.Create(
  const AConnection: TTDataSyntaxConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FSyntax := AConnection.SyntaxClasses.Select.Create(
    AConnection, AMapper, ATableMap, ATableMetadata, AFilter);
end;

destructor TTDataSyntaxDataReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTDataSyntaxDataReader.GetDataset: TDataset;
begin
  result := FSyntax.Dataset;
end;

{ TTDataSyntaxDataInsertCommand }

constructor TTDataSyntaxDataInsertCommand.Create(
  const AConnection: TTDataSyntaxConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTDataSyntaxDataInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses. Insert.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent, []);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataSyntaxDataUpdateCommand }

constructor TTDataSyntaxDataUpdateCommand.Create(
  const AConnection: TTDataSyntaxConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTDataSyntaxDataUpdateCommand.Execute(
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

{ TTDataSyntaxDataDeleteCommand }

constructor TTDataSyntaxDataDeleteCommand.Create(
  const AConnection: TTDataSyntaxConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTDataSyntaxDataDeleteCommand.Execute(
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
