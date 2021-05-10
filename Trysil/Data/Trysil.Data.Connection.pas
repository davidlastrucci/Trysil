unit Trysil.Data.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Data,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Filter,
  Trysil.Events.Abstract,
  Trysil.Data.SqlSyntax;

type

{ TTGenericConnection }

  TTGenericConnection = class abstract(TTConnection)
  strict private
    FSyntaxClasses: TTSyntaxClasses;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; virtual; abstract;

    function GetColumnMap(
      const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;

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
      const AFilter: TTFilter): TTReader; override;

    function CreateInsertCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTInsertCommand; override;

    function CreateUpdateCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTUpdateCommand; override;

    function CreateDeleteCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDeleteCommand; override;

    procedure GetMetadata(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;

    function GetSequenceID(const ATableMap: TTTableMap): TTPrimaryKey; override;
  public
    constructor Create;
    destructor Destroy; override;

    property SyntaxClasses: TTSyntaxClasses read FSyntaxClasses;
  end;

{ TTGenericReader }

  TTGenericReader = class(TTReader)
  strict private
    FSyntax: TTSelectSyntax;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTGenericInsertCommand }

  TTGenericInsertCommand = class(TTInsertCommand)
  strict private
    FConnection: TTGenericConnection;
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTGenericUpdateCommand }

  TTGenericUpdateCommand = class(TTUpdateCommand)
  strict private
    FConnection: TTGenericConnection;
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTGenericDeleteCommand }

  TTGenericDeleteCommand = class(TTDeleteCommand)
  strict private
    FConnection: TTGenericConnection;
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

implementation

{ TTGenericConnection }

constructor TTGenericConnection.Create;
begin
  inherited Create;
  FSyntaxClasses := CreateSyntaxClasses;
end;

destructor TTGenericConnection.Destroy;
begin
  FSyntaxClasses.Free;
  inherited Destroy;
end;

function TTGenericConnection.CreateReader(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTReader;
begin
  result := TTGenericReader.Create(
    Self, AMapper, ATableMap, ATableMetadata, AFilter);
end;

function TTGenericConnection.CreateInsertCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTInsertCommand;
begin
  result := TTGenericInsertCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateUpdateCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTUpdateCommand;
begin
  result := TTGenericUpdateCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateDeleteCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDeleteCommand;
begin
  result := TTGenericDeleteCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.GetColumnMap(
  const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;
var
  LColumn: TTColumnMap;
begin
  result := nil;
  for LColumn in ATableMap.Columns do
    if LColumn.Name.Equals(AColumnName) then
    begin
      result := LColumn;
      Break;
    end;

  if not Assigned(result) then
    raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);
end;

procedure TTGenericConnection.GetMetadata(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTMetadataSyntax;
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

function TTGenericConnection.GetSequenceID(
  const ATableMap: TTTableMap): TTPrimaryKey;
var
  LSyntax: TTSequenceSyntax;
begin
  LSyntax := FSyntaxClasses.Sequence.Create(Self, ATableMap);
  try
    result := LSyntax.ID;
  finally
    LSyntax.Free;
  end;
end;

function TTGenericConnection.SelectCount(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Integer;
var
  LID: TTPrimaryKey;
  LSyntax: TTSelectCountSyntax;
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

{ TTGenericReader }

constructor TTGenericReader.Create(
  const AConnection: TTGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FSyntax := AConnection.SyntaxClasses.Select.Create(
    AConnection, AMapper, ATableMap, ATableMetadata, AFilter);
end;

destructor TTGenericReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTGenericReader.GetDataset: TDataset;
begin
  result := FSyntax.Dataset;
end;

{ TTGenericInsertCommand }

constructor TTGenericInsertCommand.Create(
  const AConnection: TTGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTGenericInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Insert.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent, []);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericUpdateCommand }

constructor TTGenericUpdateCommand.Create(
  const AConnection: TTGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTGenericUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Update.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent, GetWhereColumns);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericDeleteCommand }

constructor TTGenericDeleteCommand.Create(
  const AConnection: TTGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTGenericDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
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
