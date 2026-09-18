(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.SqlServer;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.MSSQL,

  Trysil.Classes,
  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.SqlServer;

type

{$SCOPEDENUMS ON}

{ TTSqlServerDriver }

  TTSqlServerDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysMSSQLDriverLink;

    function GetODBCDriver: String;
    procedure SetODBCDriver(const AValue: String);
    function GetODBCAdvanced: String;
    procedure SetODBCAdvanced(const AValue: String);
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    property ODBCDriver: String read GetODBCDriver write SetODBCDriver;
    property ODBCAdvanced: String read GetODBCAdvanced write SetODBCAdvanced;
  end;

{ TTSqlServerEncrypt }

  TTSqlServerEncrypt = (DriverDefault, Yes, No);

{ TTSqlServerTrustServerCertificate }

  TTSqlServerTrustServerCertificate = (DriverDefault, Yes, No);

{ TTSqlServerParams }

  TTSqlServerParams = class
  strict private
    class var FInstance: TTSqlServerParams;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FEncrypt: TTSqlServerEncrypt;
    FTrustServerCertificate: TTSqlServerTrustServerCertificate;

    function DriverODBCAdvanced: String;
    function IndexOfName(
      const AParameters: TStrings; const AName: String): Integer;
    function KeywordOf(const AItem: String): String;
    function ContainsKeyword(
      const AValue: String; const AKeyword: String): Boolean;
    function JoinKeyword(
      const AValue: String;
      const AKeyword: String;
      const AKeywordValue: String): String;

    procedure AddValue(
      const AParameters: TStrings;
      const AName: String;
      const AValue: String);
    procedure AddKeyword(
      const AParameters: TStrings;
      const AName: String;
      const AKeyword: String;
      const AKeywordValue: String);
    procedure AddEncryption(const AParameters: TStrings);
    procedure AddTrustServerCertificate(const AParameters: TStrings);
  public
    procedure AfterConstruction; override;

    procedure AddExtraParameters(const AParameters: TStrings);

    property Encrypt: TTSqlServerEncrypt read FEncrypt write FEncrypt;
    property TrustServerCertificate: TTSqlServerTrustServerCertificate
      read FTrustServerCertificate write FTrustServerCertificate;

    class property Instance: TTSqlServerParams read FInstance;
  end;

{ TTSqlServerConnection }

  TTSqlServerConnection = class(TTFireDACConnection)
  strict private
    class var FDriver: TTSqlServerDriver;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;

    class function GetDriver: String; override;
    class function GetDriverAliases: TArray<String>; override;
    class procedure InternalRegisterConnection(
      const AName: String;
      const AParameters: TTFireDACConnectionParameters); override;
  public
    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AParameters: TStrings); overload;

    function GetDatabaseObjectName(
      const ADatabaseObjectName: String): String; override;

    class property Driver: TTSqlServerDriver read FDriver;
  end;

implementation

{ TTSqlServerDriver }

constructor TTSqlServerDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysMSSQLDriverLink.Create(nil);
end;

destructor TTSqlServerDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

procedure TTSqlServerDriver.AfterConstruction;
begin
  inherited AfterConstruction;
  FDriverLink.ListServers := False;
end;

function TTSqlServerDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

function TTSqlServerDriver.GetODBCDriver: String;
begin
  result := FDriverLink.ODBCDriver;
end;

procedure TTSqlServerDriver.SetODBCDriver(const AValue: String);
begin
  FDriverLink.ODBCDriver := AValue;
end;

function TTSqlServerDriver.GetODBCAdvanced: String;
begin
  result := FDriverLink.ODBCAdvanced;
end;

procedure TTSqlServerDriver.SetODBCAdvanced(const AValue: String);
begin
  FDriverLink.ODBCAdvanced := AValue;
end;

{ TTSqlServerParams }

class constructor TTSqlServerParams.ClassCreate;
begin
  FInstance := TTSqlServerParams.Create;
end;

class destructor TTSqlServerParams.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

procedure TTSqlServerParams.AddValue(
  const AParameters: TStrings;
  const AName: String;
  const AValue: String);
begin
  if IndexOfName(AParameters, AName) < 0 then
    AParameters.Add(Format('%s=%s', [AName, AValue]));
end;

function TTSqlServerParams.DriverODBCAdvanced: String;
begin
  result := String.Empty;
  if Assigned(TTSqlServerConnection.Driver) then
    result := TTSqlServerConnection.Driver.ODBCAdvanced;
end;

function TTSqlServerParams.IndexOfName(
  const AParameters: TStrings; const AName: String): Integer;
var
  LIndex: Integer;
begin
  result := -1;
  for LIndex := 0 to AParameters.Count - 1 do
    if TTIdentifier.Same(AParameters.Names[LIndex], AName) then
    begin
      result := LIndex;
      Break;
    end;
end;

function TTSqlServerParams.KeywordOf(const AItem: String): String;
var
  LIndex: Integer;
begin
  LIndex := AItem.IndexOf('=');
  if LIndex < 0 then
    result := AItem.Trim
  else
    result := AItem.Substring(0, LIndex).Trim;
end;

function TTSqlServerParams.ContainsKeyword(
  const AValue: String; const AKeyword: String): Boolean;
var
  LItem: String;
begin
  result := False;
  for LItem in AValue.Split([';']) do
    if TTIdentifier.Same(KeywordOf(LItem), AKeyword) then
    begin
      result := True;
      Break;
    end;
end;

function TTSqlServerParams.JoinKeyword(
  const AValue: String;
  const AKeyword: String;
  const AKeywordValue: String): String;
var
  LValue: String;
begin
  LValue := AValue.Trim;
  while LValue.EndsWith(';') do
    LValue := LValue.Substring(0, LValue.Length - 1).Trim;

  if LValue.IsEmpty then
    result := Format('%s=%s', [AKeyword, AKeywordValue])
  else
    result := Format('%s;%s=%s', [LValue, AKeyword, AKeywordValue]);
end;

procedure TTSqlServerParams.AddKeyword(
  const AParameters: TStrings;
  const AName: String;
  const AKeyword: String;
  const AKeywordValue: String);
var
  LIndex: Integer;
  LValue: String;
begin
  LIndex := IndexOfName(AParameters, AName);
  if LIndex < 0 then
    LValue := DriverODBCAdvanced
  else
    LValue := AParameters.ValueFromIndex[LIndex];

  if not ContainsKeyword(LValue, AKeyword) then
  begin
    LValue := JoinKeyword(LValue, AKeyword, AKeywordValue);
    if LIndex < 0 then
      AParameters.Add(Format('%s=%s', [AName, LValue]))
    else
      AParameters[LIndex] := Format('%s=%s', [AName, LValue]);
  end;
end;

procedure TTSqlServerParams.AddEncryption(const AParameters: TStrings);
begin
  case FEncrypt of
    TTSqlServerEncrypt.DriverDefault:
      ;

    TTSqlServerEncrypt.Yes:
      AddValue(AParameters, 'Encrypt', 'Yes');

    TTSqlServerEncrypt.No:
      AddValue(AParameters, 'Encrypt', 'No');
  end;
end;

procedure TTSqlServerParams.AddTrustServerCertificate(
  const AParameters: TStrings);
begin
  case FTrustServerCertificate of
    TTSqlServerTrustServerCertificate.DriverDefault:
      ;

    TTSqlServerTrustServerCertificate.Yes:
      AddKeyword(
        AParameters, 'ODBCAdvanced', 'TrustServerCertificate', 'yes');

    TTSqlServerTrustServerCertificate.No:
      AddKeyword(
        AParameters, 'ODBCAdvanced', 'TrustServerCertificate', 'no');
  end;
end;

procedure TTSqlServerParams.AddExtraParameters(const AParameters: TStrings);
begin
  AddEncryption(AParameters);
  AddTrustServerCertificate(AParameters);
end;

procedure TTSqlServerParams.AfterConstruction;
begin
  inherited AfterConstruction;
  FEncrypt := TTSqlServerEncrypt.DriverDefault;
  FTrustServerCertificate :=
    TTSqlServerTrustServerCertificate.DriverDefault;
end;

{ TTSqlServerConnection }

class constructor TTSqlServerConnection.ClassCreate;
begin
  FDriver := TTSqlServerDriver.Create;
end;

class destructor TTSqlServerConnection.ClassDestroy;
begin
  FDriver.Free;
  FDriver := nil;
end;

function TTSqlServerConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTSqlServerSyntaxClasses.Create;
end;

class function TTSqlServerConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class function TTSqlServerConnection.GetDriverAliases: TArray<String>;
begin
  result := ['SqlServer'];
end;

class procedure TTSqlServerConnection.InternalRegisterConnection(
  const AName: String; const AParameters: TTFireDACConnectionParameters);
begin
  RegisterConnection(
    AName,
    AParameters.Server,
    AParameters.Username,
    AParameters.Password,
    AParameters.DatabaseName);
end;

class procedure TTSqlServerConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTSqlServerConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Server=%s', [AServer]));
    LParameters.Add(Format('Database=%s', [ADatabaseName]));
    if AUsername.IsEmpty then
      LParameters.Add('OSAuthent=Yes')
    else
    begin
      LParameters.Add(Format('User_Name=%s', [AUserName]));
      LParameters.Add(Format('Password=%s', [APassword]));
    end;

    RegisterConnection(AName, LParameters);
  finally
    LParameters.Free;
  end;
end;

class procedure TTSqlServerConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.AddStrings(AParameters);
    TTSqlServerParams.Instance.AddExtraParameters(LParameters);
    TTFireDACConnectionPool.Instance.RegisterConnection(
      AName, FDriver.DriverLink.DriverID, LParameters);
  finally
    LParameters.Free;
  end;
end;

function TTSqlServerConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  result := TTDatabaseObjectName.Quoted(
    ADatabaseObjectName, '[', ']', TTNameCase.AsIs);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTSqlServerConnection>();

end.
