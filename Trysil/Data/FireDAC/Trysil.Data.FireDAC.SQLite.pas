(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.SQLite;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  Data.DB,
 {$IFDEF MSWINDOWS}
  Winapi.Windows,
 {$ENDIF}
  FireDAC.Phys,
  FireDAC.Phys.SQLite,

  Trysil.Types,
  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Filter,
  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.SQLite;

type

{ TTSQLiteDriver }

  TTSQLiteDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysSQLiteDriverLink;

    function GetSEEKey: String;
    procedure SetSEEKey(const AValue: String);
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;

    property SEEKey: String read GetSEEKey write SetSEEKey;
  end;

{ TTSQLiteConnection }

  TTSQLiteConnection = class(TTFireDACConnection)
  strict private
    class var FDriver: TTSQLiteDriver;
    class var FSequences: TDictionary<String, TTPrimaryKey>;
    class var FSequencesLock: TSpinLock;
    class constructor ClassCreate;
    class destructor ClassDestroy;

    function SequenceKey(const ATableMap: TTTableMap): String;
    function IsSequenceComputed(const AKey: String): Boolean;
    procedure InitializeSequence(
      const AKey: String; const ALast: TTPrimaryKey);
    function ReadSequenceSeed(const ATableMap: TTTableMap): TTPrimaryKey;
    procedure EnsureSequence(const ATableMap: TTTableMap);
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;
    function GetDatabaseVersion: String; override;

    class function GetDriver: String; override;
    class function GetDriverAliases: TArray<String>; override;
    class procedure InternalRegisterConnection(
      const AName: String;
      const AParameters: TTFireDACConnectionParameters); override;
  public
    function GetSequenceID(const ATableMap: TTTableMap): TTPrimaryKey; override;

    function SelectCount(
      const ATableMap: TTTableMap;
      const AFilter: TTFilter): Int64; override;

    function CreateReader(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTReader; override;

    function CreateInsertCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateUpdateCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateSoftDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateUndeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    class procedure RegisterConnection(
      const AName: String; const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String; const AParameters: TStrings); overload;

    function GetDatabaseObjectName(
      const ADatabaseObjectName: String): String; override;

    class property Driver: TTSQLiteDriver read FDriver;
  end;

implementation

{ TTSQLiteDriver }

constructor TTSQLiteDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
end;

destructor TTSQLiteDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

function TTSQLiteDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

function TTSQLiteDriver.GetSEEKey: String;
begin
{$IF CompilerVersion >= 35} // Delphi 11 Alexandria
  result := FDriverLink.SEEKey;
{$ELSE}
  result := String.Empty;
{$ENDIF}
end;

procedure TTSQLiteDriver.SetSEEKey(const AValue: String);
begin
{$IF CompilerVersion >= 35} // Delphi 11 Alexandria
  FDriverLink.SEEKey := AValue;
{$ENDIF}
end;

{ TTSQLiteConnection }

class constructor TTSQLiteConnection.ClassCreate;
begin
  FDriver := TTSQLiteDriver.Create;
  FSequences := TDictionary<String, TTPrimaryKey>.Create;
  FSequencesLock := TSpinLock.Create(False);
end;

class destructor TTSQLiteConnection.ClassDestroy;
begin
  FSequencesLock.Enter;
  try
    FSequences.Free;
    FSequences := nil;
  finally
    FSequencesLock.Exit;
  end;
  FDriver.Free;
  FDriver := nil;
end;

function TTSQLiteConnection.SequenceKey(
  const ATableMap: TTTableMap): String;
begin
  result := Format(
    '%s.%s', [ConnectionName, ATableMap.Name]).ToLowerInvariant;
end;

function TTSQLiteConnection.IsSequenceComputed(
  const AKey: String): Boolean;
begin
  FSequencesLock.Enter;
  try
    result := FSequences.ContainsKey(AKey);
  finally
    FSequencesLock.Exit;
  end;
end;

procedure TTSQLiteConnection.InitializeSequence(
  const AKey: String; const ALast: TTPrimaryKey);
begin
  FSequencesLock.Enter;
  try
    FSequences.TryAdd(AKey, ALast);
  finally
    FSequencesLock.Exit;
  end;
end;

function TTSQLiteConnection.ReadSequenceSeed(
  const ATableMap: TTTableMap): TTPrimaryKey;
var
  LSyntax: TTSequenceSyntax;
  LDataset: TDataSet;
  LLast: Int64;
begin
  LSyntax := TTSQLiteSequenceSyntax.Create(Self, ATableMap);
  try
    LDataset := CreateDataSet(LSyntax.SQL, TTFilter.Empty());
    try
      LLast := LDataset.Fields[0].AsLargeInt - 1;
    finally
      LDataset.Free;
    end;
  finally
    LSyntax.Free;
  end;

  if LLast > High(TTPrimaryKey) then
    LLast := High(TTPrimaryKey);
  result := TTPrimaryKey(LLast);
end;

procedure TTSQLiteConnection.EnsureSequence(
  const ATableMap: TTTableMap);
var
  LKey: String;
begin
  if Assigned(ATableMap.PrimaryKey) and (not ATableMap.HasJoins) then
  begin
    LKey := SequenceKey(ATableMap);
    if not IsSequenceComputed(LKey) then
      InitializeSequence(LKey, ReadSequenceSeed(ATableMap));
  end;
end;

function TTSQLiteConnection.GetSequenceID(
  const ATableMap: TTTableMap): TTPrimaryKey;
var
  LKey: String;
  LFromDatabase: TTPrimaryKey;
  LLast: TTPrimaryKey;
  LNext: Int64;
begin
  LKey := SequenceKey(ATableMap);
  LFromDatabase := inherited GetSequenceID(ATableMap);

  FSequencesLock.Enter;
  try
    LNext := LFromDatabase;
    if FSequences.TryGetValue(LKey, LLast) and (LLast >= LFromDatabase) then
      LNext := Int64(LLast) + 1;

    if LNext > High(TTPrimaryKey) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SSequenceOutOfRange), [
          ATableMap.Name,
          LNext]);

    result := TTPrimaryKey(LNext);
    FSequences.AddOrSetValue(LKey, result);
  finally
    FSequencesLock.Exit;
  end;
end;

function TTSQLiteConnection.SelectCount(
  const ATableMap: TTTableMap;
  const AFilter: TTFilter): Int64;
begin
  EnsureSequence(ATableMap);
  result := inherited SelectCount(ATableMap, AFilter);
end;

function TTSQLiteConnection.CreateReader(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTReader;
begin
  EnsureSequence(ATableMap);
  result := inherited CreateReader(ATableMap, ATableMetadata, AFilter);
end;

function TTSQLiteConnection.CreateInsertCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  EnsureSequence(ATableMap);
  result := inherited CreateInsertCommand(ATableMap, ATableMetadata);
end;

function TTSQLiteConnection.CreateUpdateCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  EnsureSequence(ATableMap);
  result := inherited CreateUpdateCommand(ATableMap, ATableMetadata);
end;

function TTSQLiteConnection.CreateSoftDeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  EnsureSequence(ATableMap);
  result := inherited CreateSoftDeleteCommand(ATableMap, ATableMetadata);
end;

function TTSQLiteConnection.CreateUndeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  EnsureSequence(ATableMap);
  result := inherited CreateUndeleteCommand(ATableMap, ATableMetadata);
end;

function TTSQLiteConnection.CreateDeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  EnsureSequence(ATableMap);
  result := inherited CreateDeleteCommand(ATableMap, ATableMetadata);
end;

function TTSQLiteConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTSQLiteSyntaxClasses.Create;
end;

function TTSQLiteConnection.GetDatabaseVersion: String;
begin
  result := Format('SQLite %s', [inherited GetDatabaseVersion]);
end;

class function TTSQLiteConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class function TTSQLiteConnection.GetDriverAliases: TArray<String>;
begin
  result := ['SQLite'];
end;

class procedure TTSQLiteConnection.InternalRegisterConnection(
  const AName: String; const AParameters: TTFireDACConnectionParameters);
begin
  RegisterConnection(
    AName,
    AParameters.Username,
    AParameters.Password,
    AParameters.DatabaseName);
end;

class procedure TTSQLiteConnection.RegisterConnection(
  const AName: String; const ADatabaseName: String);
begin
  RegisterConnection(AName, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTSQLiteConnection.RegisterConnection(
  const AName: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Database=%s', [ADatabaseName]));
    if not AUsername.IsEmpty then
    begin
      LParameters.Add(Format('User_Name=%s', [AUserName]));
      LParameters.Add(Format('Password=%s', [APassword]));
    end;
    LParameters.Add('LockingMode=Normal');

    RegisterConnection(AName, LParameters);
  finally
    LParameters.Free;
  end;
end;

class procedure TTSQLiteConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

function TTSQLiteConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  if ADatabaseObjectName.Contains(']') then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNotEscapableObjectName), [
        ADatabaseObjectName,
        ']',
        'SQLite']);

  result := TTDatabaseObjectName.Quoted(
    ADatabaseObjectName, '[', ']', TTNameCase.AsIs);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTSQLiteConnection>();

end.
