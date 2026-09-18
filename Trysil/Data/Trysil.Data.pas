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
  System.Character,
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
    function GetDataType: TFieldType; virtual; abstract;
    function GetAsString: String; virtual; abstract;
    procedure SetAsString(const Value: String); virtual; abstract;
    function GetAsInteger: Integer; virtual; abstract;
    procedure SetAsInteger(const Value: Integer); virtual; abstract;
    function GetAsLargeInt: Int64; virtual; abstract;
    procedure SetAsLargeInt(const Value: Int64); virtual; abstract;
    function GetAsDouble: Double; virtual; abstract;
    procedure SetAsDouble(const Value: Double); virtual; abstract;
    function GetAsCurrency: Currency; virtual; abstract;
    procedure SetAsCurrency(const Value: Currency); virtual; abstract;
    function GetAsBoolean: Boolean; virtual; abstract;
    procedure SetAsBoolean(const Value: Boolean); virtual; abstract;
    function GetAsDateTime: TDateTime; virtual; abstract;
    procedure SetAsDateTime(const Value: TDateTime); virtual; abstract;
    function GetAsGuid: TGUID; virtual; abstract;
    procedure SetAsGuid(const Value: TGUID); virtual; abstract;
    procedure SetAsBytes(const Value: TBytes); virtual; abstract;
    procedure SetAsText(const Value: String); virtual;
  public
    procedure Clear; virtual; abstract;

    property Name: String read GetName;
    property Size: Integer read GetSize;
    property DataType: TFieldType read GetDataType;
    property AsString: String write SetAsString;
    property AsInteger: Integer write SetAsInteger;
    property AsLargeInt: Int64 write SetAsLargeInt;
    property AsDouble: Double write SetAsDouble;
    property AsCurrency: Currency write SetAsCurrency;
    property AsBoolean: Boolean write SetAsBoolean;
    property AsDateTime: TDateTime write SetAsDateTime;
    property AsGuid: TGUID write SetAsGuid;
    property AsBytes: TBytes write SetAsBytes;
    property AsText: String write SetAsText;
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

{ TTRawReader }

  TTRawReader = class(TTReader)
  strict private
    FRawDataSet: TDataSet;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const ATableMap: TTTableMap; const ARawDataSet: TDataSet);
  end;

{ TTUpdateMode }

  TTUpdateMode = (KeyAndVersionColumn, KeyOnly);

{ TTNameCase }

  TTNameCase = (AsIs, Upper, Lower);

{ TTDatabaseObjectName }

  TTDatabaseObjectName = class
  strict private
    class function Fold(
      const AName: String;
      const ANameCase: TTNameCase): String; static;
    class function QuotedPart(
      const APart: String;
      const AOpenQuote: String;
      const ACloseQuote: String;
      const ANameCase: TTNameCase): String; static;
  public
    class function Quoted(
      const AName: String;
      const AOpenQuote: String;
      const ACloseQuote: String;
      const ANameCase: TTNameCase): String; static;
  end;

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

{ TTTransactionObserver }

  TTTransactionObserver = class abstract
  protected // internal
    procedure TransactionStarted; virtual; abstract;
    procedure TransactionCommitted; virtual; abstract;
    procedure TransactionRolledback; virtual; abstract;
  end;

{ TTConnection }

  TTConnection = class abstract(TTMetadataProvider)
  strict private
    FTransactionObservers: TList<TTTransactionObserver>;

    function GetTransactionObserverCount: Integer;
    function IsValidParameterChar(const AChar: Char): Boolean;
  strict protected
    FUpdateMode: TTUpdateMode;

    function GetConnectionID: String; virtual;
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
    destructor Destroy; override;

    procedure AddTransactionObserver(
      const AObserver: TTTransactionObserver);
    procedure RemoveTransactionObserver(
      const AObserver: TTTransactionObserver);

    procedure StartTransaction; virtual;
    procedure CommitTransaction; virtual;
    procedure RollbackTransaction; virtual;

    function SelectCount(
      const ATableMap: TTTableMap;
      const AFilter: TTFilter): Int64; virtual; abstract;

    property ConnectionID: String read GetConnectionID;

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

    function CreateSoftDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; virtual; abstract;

    function CreateUndeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; virtual;

    function CreateDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; virtual; abstract;

    property DatabaseVersion: String read GetDatabaseVersion;
    property InTransaction: Boolean read GetInTransaction;
    property SupportTransaction: Boolean read GetSupportTransaction;
    property UpdateMode: TTUpdateMode read FUpdateMode write FUpdateMode;
    property TransactionObserverCount: Integer
      read GetTransactionObserverCount;
  end;

implementation

{ TTParam }

procedure TTParam.SetAsText(const Value: String);
begin
  SetAsString(Value);
end;

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
    if FColumns.ContainsKey(LColumnMap.LookupName) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SDuplicateColumn), [LColumnMap.LookupName]);
    FColumns.Add(
      LColumnMap.LookupName,
      TTColumnFactory.Instance.CreateColumn(
        FDataset.FieldByName(LColumnMap.LookupName), LColumnMap));
  end;
end;

function TTReader.ColumnByName(const AColumnName: String): TTColumn;
begin
  if not FColumns.TryGetValue(AColumnName, result) then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SColumnNotFound), [AColumnName]);
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

{ TTRawReader }

constructor TTRawReader.Create(
  const ATableMap: TTTableMap; const ARawDataSet: TDataSet);
begin
  inherited Create(ATableMap);
  FRawDataSet := ARawDataSet;
end;

function TTRawReader.GetDataset: TDataset;
begin
  result := FRawDataSet;
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
  FTransactionObservers := TList<TTTransactionObserver>.Create;
  FUpdateMode := TTUpdateMode.KeyAndVersionColumn;
end;

destructor TTConnection.Destroy;
begin
  FTransactionObservers.Free;
  inherited Destroy;
end;

procedure TTConnection.AddTransactionObserver(
  const AObserver: TTTransactionObserver);
begin
  if not FTransactionObservers.Contains(AObserver) then
  begin
    FTransactionObservers.Add(AObserver);
    if InTransaction then
      try
        AObserver.TransactionStarted();
      except
        FTransactionObservers.Remove(AObserver);
        raise;
      end;
  end;
end;

procedure TTConnection.RemoveTransactionObserver(
  const AObserver: TTTransactionObserver);
begin
  FTransactionObservers.Remove(AObserver);
end;

function TTConnection.GetTransactionObserverCount: Integer;
begin
  result := FTransactionObservers.Count;
end;

procedure TTConnection.StartTransaction;
var
  LObserver: TTTransactionObserver;
begin
  for LObserver in FTransactionObservers do
    LObserver.TransactionStarted();
end;

procedure TTConnection.CommitTransaction;
var
  LObserver: TTTransactionObserver;
begin
  for LObserver in FTransactionObservers do
    LObserver.TransactionCommitted();
end;

procedure TTConnection.RollbackTransaction;
var
  LObserver: TTTransactionObserver;
begin
  for LObserver in FTransactionObservers do
    LObserver.TransactionRolledback();
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
        raise ETException.CreateFmt(
          TTLanguage.Instance.Translate(SRelationError), [AEntity.ToString()]);
end;

function TTConnection.CreateUndeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  raise ETException.CreateFmt(
    TTLanguage.Instance.Translate(SUndeleteNotImplemented), [ClassName]);
end;

function TTConnection.Execute(const ASQL: String): Integer;
begin
  result := Execute(ASQL, nil, nil, nil);
end;

class function TTDatabaseObjectName.Fold(
  const AName: String;
  const ANameCase: TTNameCase): String;
begin
  case ANameCase of
    TTNameCase.Upper: result := AName.ToUpperInvariant;
    TTNameCase.Lower: result := AName.ToLowerInvariant;
  else
    result := AName;
  end;
end;

class function TTDatabaseObjectName.QuotedPart(
  const APart: String;
  const AOpenQuote: String;
  const ACloseQuote: String;
  const ANameCase: TTNameCase): String;
var
  LPart: String;
begin
  LPart := Fold(APart, ANameCase).Replace(
    ACloseQuote, Format('%0:s%0:s', [ACloseQuote]), [rfReplaceAll]);
  result := Format('%s%s%s', [AOpenQuote, LPart, ACloseQuote]);
end;

class function TTDatabaseObjectName.Quoted(
  const AName: String;
  const AOpenQuote: String;
  const ACloseQuote: String;
  const ANameCase: TTNameCase): String;
var
  LPart: String;
begin
  result := String.Empty;
  if not AName.IsEmpty then
    for LPart in AName.Split(['.']) do
    begin
      if not result.IsEmpty then
        result := Format('%s.', [result]);
      result := Format('%s%s', [
        result, QuotedPart(LPart, AOpenQuote, ACloseQuote, ANameCase)]);
    end;
end;

function TTConnection.GetConnectionID: String;
begin
  result := String.Empty;
end;

function TTConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  result := ADatabaseObjectName;
end;

function TTConnection.IsValidParameterChar(const AChar: Char): Boolean;
begin
  result :=
    CharInSet(AChar, ['0'..'9', 'a'..'z', 'A'..'Z', '#', '$', '_']) or
    AChar.IsLetter;
end;

function TTConnection.GetParameterName(
  const AParameterName: String): String;
var
  LChar: Char;
begin
  result := AParameterName.Replace(' ', '_', [rfReplaceAll]);
  for LChar in result do
    if not IsValidParameterChar(LChar) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SNotValidParameterName), [
          AParameterName,
          LChar]);
end;

end.
