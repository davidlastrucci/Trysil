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
 {$IFDEF MSWINDOWS}
  Winapi.Windows,
 {$ENDIF}
  FireDAC.Phys,
  FireDAC.Phys.SQLite,

  Trysil.Types,
  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Mapping,
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
