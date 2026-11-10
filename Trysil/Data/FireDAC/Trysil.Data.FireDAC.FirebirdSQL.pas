(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.FirebirdSQL;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.FB,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.FirebirdSQL;

type

{ TTFirebirdSQLDriver }

  TTFirebirdSQLDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysFBDriverLink;
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TTFirebirdSQLConnection }

  TTFirebirdSQLConnection = class(TTFireDACConnection)
  strict private
    class var FDriver: TTFirebirdSQLDriver;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;
    function GetDatabaseVersion: String; override;

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
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String;
      const ACharacterSet: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const APort: Integer;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AParameters: TStrings); overload;

    function GetDatabaseObjectName(
      const ADatabaseObjectName: String): String; override;

    class property Driver: TTFirebirdSQLDriver read FDriver;
  end;

implementation

{ TTFirebirdSQLDriver }

constructor TTFirebirdSQLDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysFBDriverLink.Create(nil);
end;

destructor TTFirebirdSQLDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

function TTFirebirdSQLDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

{ TTFirebirdSQLConnection }

class constructor TTFirebirdSQLConnection.ClassCreate;
begin
  FDriver := TTFirebirdSQLDriver.Create;
end;

class destructor TTFirebirdSQLConnection.ClassDestroy;
begin
  FDriver.Free;
  FDriver := nil;
end;

function TTFirebirdSQLConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTFirebirdSQLSyntaxClasses.Create;
end;

function TTFirebirdSQLConnection.GetDatabaseVersion: String;
begin
  result := Format('FirebirdSQL %s', [inherited GetDatabaseVersion]);
end;

class function TTFirebirdSQLConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class function TTFirebirdSQLConnection.GetDriverAliases: TArray<String>;
begin
  result := ['FirebirdSQL', 'Firebird'];
end;

class procedure TTFirebirdSQLConnection.InternalRegisterConnection(
  const AName: String;
  const AParameters: TTFireDACConnectionParameters);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Server=%s', [AParameters.Server]));
    if AParameters.Port <> 0 then
      LParameters.Add(Format('Port=%d', [AParameters.Port]));
    LParameters.Add(Format('Database=%s', [AParameters.DatabaseName]));
    if AParameters.Username.IsEmpty then
      LParameters.Add('OSAuthent=Yes')
    else
    begin
      LParameters.Add(Format('User_Name=%s', [AParameters.Username]));
      LParameters.Add(Format('Password=%s', [AParameters.Password]));
    end;
    if not AParameters.CharacterSet.IsEmpty then
      LParameters.Add(
        Format('CharacterSet=%s', [AParameters.CharacterSet]));
    RegisterConnection(AName, LParameters);
  finally
    LParameters.Free;
  end;
end;

class procedure TTFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, AUsername, APassword, ADatabaseName, String.Empty);
end;

class procedure TTFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String;
  const ACharacterSet: String);
var
  LParameters: TTFireDACConnectionParameters;
begin
  LParameters := TTFireDACConnectionParameters.Create(
    GetDriver, AServer, AUsername, APassword, ADatabaseName);
  LParameters.CharacterSet := ACharacterSet;
  InternalRegisterConnection(AName, LParameters);
end;

class procedure TTFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const APort: Integer;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  InternalRegisterConnection(
    AName,
    TTFireDACConnectionParameters.Create(
      GetDriver, AServer, APort, AUsername, APassword, ADatabaseName));
end;

class procedure TTFirebirdSQLConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

function TTFirebirdSQLConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  result := TTDatabaseObjectName.Quoted(
    ADatabaseObjectName, '"', '"', TTNameCase.Upper);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTFirebirdSQLConnection>();

end.
