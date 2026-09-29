(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.SchemaReader;

{$I Trysil.Expert.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.UI.Intf,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.Intf,
  FireDAC.Phys,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB,
  FireDAC.Phys.IB,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.PG,
{$IFDEF TRYSIL_EXPERT_ENTERPRISE}
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.Oracle,
{$ENDIF}
  FireDAC.Phys.SQLite,

  Trysil.Expert.Consts,
  Trysil.Expert.Classes,
  Trysil.Expert.SQLCreator,
  Trysil.Expert.Schema;

type

{ TTDatabaseParameters }

  TTDatabaseParameters = record
  strict private
    FDatabaseType: TTSQLCreatorType;
    FHost: String;
    FPort: Integer;
    FDatabase: String;
    FUsername: String;
    FPassword: String;
  public
    property DatabaseType: TTSQLCreatorType
      read FDatabaseType write FDatabaseType;
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property Database: String read FDatabase write FDatabase;
    property Username: String read FUsername write FUsername;
    property Password: String read FPassword write FPassword;
  end;

{ TTSchemaReader }

  TTSchemaReader = class
  strict private
    const DefaultOraclePort: Integer = 1521;
  strict private
    FParameters: TTDatabaseParameters;
    FConnection: TFDConnection;

    procedure Configure;
    procedure ConfigureServer;
    procedure ConfigureMSSQL;
    procedure ConfigureOracle;
    procedure ConfigureSQLite;
    function CreateMetaInfo(
      const AKind: TFDPhysMetaInfoKind): TFDMetaInfoQuery;
    function FamilyOf(const ADataType: TFDDataType): TTSchemaFamily;
    function CreateColumn(const AMetaInfo: TFDMetaInfoQuery): TTSchemaColumn;
    procedure ReadColumns(
      const ATable: TTSchemaTable; const AMetaInfo: TFDMetaInfoQuery);
    procedure ReadTable(const ASchema: TTSchema; const ATableName: String);
    procedure ReadIndexes(const ATable: TTSchemaTable);
    function ReadIndexFirstColumn(
      const ATableName: String; const AIndexName: String): String;
    procedure ReadSequences(const ASchema: TTSchema);
  public
    constructor Create(const AParameters: TTDatabaseParameters);
    destructor Destroy; override;

    procedure Read(const ASchema: TTSchema; const ATableNames: TList<String>);

    class function DriverAvailable(
      const ADatabaseType: TTSQLCreatorType): Boolean;
  end;

implementation

{ TTSchemaReader }

constructor TTSchemaReader.Create(const AParameters: TTDatabaseParameters);
begin
  inherited Create;
  FParameters := AParameters;
  FConnection := TFDConnection.Create(nil);
end;

destructor TTSchemaReader.Destroy;
begin
  FConnection.Free;
  inherited Destroy;
end;

class function TTSchemaReader.DriverAvailable(
  const ADatabaseType: TTSQLCreatorType): Boolean;
begin
{$IFDEF TRYSIL_EXPERT_ENTERPRISE}
  result := True;
{$ELSE}
  result := not (ADatabaseType in [
    TTSQLCreatorType.ctOracle, TTSQLCreatorType.ctMSSQL]);
{$ENDIF}
end;

procedure TTSchemaReader.Configure;
const
  DriverIDs: array [TTSQLCreatorType] of String = (
    'FB', 'IB', 'MySQL', 'Ora', 'PG', 'MSSQL', 'SQLite');
begin
  FConnection.LoginPrompt := False;
  FConnection.Params.DriverID := DriverIDs[FParameters.DatabaseType];
  FConnection.Params.Values['MetaCaseIns'] := 'True';
  case FParameters.DatabaseType of
    TTSQLCreatorType.ctMSSQL:
      ConfigureMSSQL;
    TTSQLCreatorType.ctOracle:
      ConfigureOracle;
    TTSQLCreatorType.ctSQLite:
      ConfigureSQLite;
    else
      ConfigureServer;
  end;
end;

procedure TTSchemaReader.ConfigureServer;
begin
  FConnection.Params.Database := FParameters.Database;
  FConnection.Params.UserName := FParameters.Username;
  FConnection.Params.Password := FParameters.Password;
  if not FParameters.Host.IsEmpty then
  begin
    FConnection.Params.Values['Server'] := FParameters.Host;
    if FParameters.DatabaseType in [
      TTSQLCreatorType.ctFirebird, TTSQLCreatorType.ctInterBase] then
      FConnection.Params.Values['Protocol'] := 'TCPIP';
  end;
  if FParameters.Port > 0 then
    FConnection.Params.Values['Port'] := FParameters.Port.ToString;
end;

procedure TTSchemaReader.ConfigureMSSQL;
begin
  ConfigureServer;
  FConnection.Params.Values['ODBCAdvanced'] := 'TrustServerCertificate=yes';
end;

procedure TTSchemaReader.ConfigureOracle;
var
  LPort: Integer;
begin
  LPort := FParameters.Port;
  if LPort <= 0 then
    LPort := DefaultOraclePort;
  FConnection.Params.Database := Format('//%s:%d/%s', [
    FParameters.Host, LPort, FParameters.Database]);
  FConnection.Params.UserName := FParameters.Username;
  FConnection.Params.Password := FParameters.Password;
end;

procedure TTSchemaReader.ConfigureSQLite;
begin
  if not TFile.Exists(FParameters.Database) then
    raise ETExpertException.CreateFmt(
      SDatabaseFileNotFound, [FParameters.Database]);
  FConnection.Params.Database := FParameters.Database;
  FConnection.Params.Values['OpenMode'] := 'ReadOnly';
end;

function TTSchemaReader.CreateMetaInfo(
  const AKind: TFDPhysMetaInfoKind): TFDMetaInfoQuery;
begin
  result := TFDMetaInfoQuery.Create(nil);
  result.Connection := FConnection;
  result.MetaInfoKind := AKind;
end;

function TTSchemaReader.FamilyOf(
  const ADataType: TFDDataType): TTSchemaFamily;
begin
  case ADataType of
    TFDDataType.dtBoolean:
      result := TTSchemaFamily.sfBoolean;
    TFDDataType.dtSByte, TFDDataType.dtInt16, TFDDataType.dtInt32,
    TFDDataType.dtInt64, TFDDataType.dtByte, TFDDataType.dtUInt16,
    TFDDataType.dtUInt32, TFDDataType.dtUInt64, TFDDataType.dtSingle,
    TFDDataType.dtDouble, TFDDataType.dtExtended, TFDDataType.dtCurrency,
    TFDDataType.dtBCD, TFDDataType.dtFmtBCD:
      result := TTSchemaFamily.sfNumber;
    TFDDataType.dtDateTime, TFDDataType.dtTime, TFDDataType.dtDate,
    TFDDataType.dtDateTimeStamp:
      result := TTSchemaFamily.sfDateTime;
    TFDDataType.dtAnsiString, TFDDataType.dtWideString, TFDDataType.dtMemo,
    TFDDataType.dtWideMemo, TFDDataType.dtXML, TFDDataType.dtHMemo,
    TFDDataType.dtWideHMemo:
      result := TTSchemaFamily.sfText;
    TFDDataType.dtByteString, TFDDataType.dtBlob, TFDDataType.dtHBlob,
    TFDDataType.dtHBFile:
      result := TTSchemaFamily.sfBinary;
    TFDDataType.dtGUID:
      result := TTSchemaFamily.sfGuid;
    else
      result := TTSchemaFamily.sfOther;
  end;
end;

function TTSchemaReader.CreateColumn(
  const AMetaInfo: TFDMetaInfoQuery): TTSchemaColumn;
var
  LDataType: TFDDataType;
  LAttributes: Integer;
begin
  LDataType := TFDDataType(AMetaInfo.FieldByName('COLUMN_DATATYPE').AsInteger);
  LAttributes := AMetaInfo.FieldByName('COLUMN_ATTRIBUTES').AsInteger;
  result := TTSchemaColumn.Create(
    AMetaInfo.FieldByName('COLUMN_NAME').AsString,
    AMetaInfo.FieldByName('COLUMN_TYPENAME').AsString);
  try
    result.Family := FamilyOf(LDataType);
    result.Bounded := LDataType in [
      TFDDataType.dtAnsiString, TFDDataType.dtWideString];
    result.Length := AMetaInfo.FieldByName('COLUMN_LENGTH').AsInteger;
    result.AllowNull :=
      (LAttributes and (1 shl Ord(TFDDataAttribute.caAllowNull))) <> 0;
  except
    result.Free;
    raise;
  end;
end;

procedure TTSchemaReader.ReadColumns(
  const ATable: TTSchemaTable; const AMetaInfo: TFDMetaInfoQuery);
begin
  AMetaInfo.First;
  while not AMetaInfo.Eof do
  begin
    ATable.Columns.Add(CreateColumn(AMetaInfo));
    AMetaInfo.Next;
  end;
end;

procedure TTSchemaReader.ReadTable(
  const ASchema: TTSchema; const ATableName: String);
var
  LMetaInfo: TFDMetaInfoQuery;
  LTable: TTSchemaTable;
begin
  LMetaInfo := CreateMetaInfo(TFDPhysMetaInfoKind.mkTableFields);
  try
    LMetaInfo.ObjectName := ATableName;
    LMetaInfo.Open;
    if not LMetaInfo.IsEmpty then
    begin
      LTable := TTSchemaTable.Create(ATableName);
      ASchema.Tables.Add(LTable);
      ReadColumns(LTable, LMetaInfo);
      ReadIndexes(LTable);
    end;
  finally
    LMetaInfo.Free;
  end;
end;

procedure TTSchemaReader.ReadIndexes(const ATable: TTSchemaTable);
var
  LMetaInfo: TFDMetaInfoQuery;
  LColumnName: String;
begin
  LMetaInfo := CreateMetaInfo(TFDPhysMetaInfoKind.mkIndexes);
  try
    LMetaInfo.ObjectName := ATable.Name;
    LMetaInfo.Open;
    while not LMetaInfo.Eof do
    begin
      LColumnName := ReadIndexFirstColumn(
        ATable.Name, LMetaInfo.FieldByName('INDEX_NAME').AsString);
      if not LColumnName.IsEmpty then
        ATable.IndexedColumns.Add(LColumnName);
      LMetaInfo.Next;
    end;
  finally
    LMetaInfo.Free;
  end;
end;

function TTSchemaReader.ReadIndexFirstColumn(
  const ATableName: String; const AIndexName: String): String;
var
  LMetaInfo: TFDMetaInfoQuery;
  LPosition: Integer;
begin
  result := String.Empty;
  LPosition := MaxInt;
  LMetaInfo := CreateMetaInfo(TFDPhysMetaInfoKind.mkIndexFields);
  try
    LMetaInfo.BaseObjectName := ATableName;
    LMetaInfo.ObjectName := AIndexName;
    LMetaInfo.Open;
    while not LMetaInfo.Eof do
    begin
      if LMetaInfo.FieldByName('COLUMN_POSITION').AsInteger < LPosition then
      begin
        LPosition := LMetaInfo.FieldByName('COLUMN_POSITION').AsInteger;
        result := LMetaInfo.FieldByName('COLUMN_NAME').AsString;
      end;
      LMetaInfo.Next;
    end;
  finally
    LMetaInfo.Free;
  end;
end;

procedure TTSchemaReader.ReadSequences(const ASchema: TTSchema);
var
  LNames: TStringList;
  LRead: Boolean;
begin
  LNames := TStringList.Create;
  try
    try
      FConnection.GetGeneratorNames(
        String.Empty, String.Empty, String.Empty, LNames, [osMy, osOther],
        False);
      LRead := True;
    except
      on EFDException do
        LRead := False;
    end;
    ASchema.Sequences.AddRange(LNames.ToStringArray);
    ASchema.SequencesKnown := LRead and ((LNames.Count > 0) or
      (FParameters.DatabaseType in [
        TTSQLCreatorType.ctFirebird, TTSQLCreatorType.ctInterBase,
        TTSQLCreatorType.ctOracle, TTSQLCreatorType.ctPostgreSQL]));
  finally
    LNames.Free;
  end;
end;

procedure TTSchemaReader.Read(
  const ASchema: TTSchema; const ATableNames: TList<String>);
var
  LTableName: String;
begin
  Configure;
  FConnection.Connected := True;
  try
    for LTableName in ATableNames do
      if not Assigned(ASchema.FindTable(LTableName)) then
        ReadTable(ASchema, LTableName);
    ReadSequences(ASchema);
  finally
    FConnection.Connected := False;
  end;
end;

end.
