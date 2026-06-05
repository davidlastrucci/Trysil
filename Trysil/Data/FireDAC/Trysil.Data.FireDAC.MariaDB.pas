(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.MariaDB;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.MySQL,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.MariaDB;

type

{ TTMariaDBDriver }

  TTMariaDBDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysMySQLDriverLink;
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

{ TTMariaDBConnection }

  TTMariaDBConnection = class(TTFireDACConnection)
  strict private
    const DefaultPort: Integer = 3306;
  strict private
    class var FDriver: TTMariaDBDriver;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;
    function GetDatabaseVersion: String; override;

    class function GetDriver: String; override;
    class procedure InternalRegisterConnection(
      const AName: String;
      const AParameters: TTFireDACConnectionParameters); override;
  public
    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

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

    class property Driver: TTMariaDBDriver read FDriver;
  end;

implementation

{ TTMariaDBDriver }

constructor TTMariaDBDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysMySQLDriverLink.Create(nil);
end;

destructor TTMariaDBDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

procedure TTMariaDBDriver.AfterConstruction;
begin
  inherited AfterConstruction;
  FDriverLink.DriverID := 'Trysil_MariaDB';
end;

function TTMariaDBDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

{ TTMariaDBConnection }

class constructor TTMariaDBConnection.ClassCreate;
begin
  FDriver := TTMariaDBDriver.Create;
end;

class destructor TTMariaDBConnection.ClassDestroy;
begin
  FDriver.Free;
end;

function TTMariaDBConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTMariaDBSyntaxClasses.Create;
end;

function TTMariaDBConnection.GetDatabaseVersion: String;
begin
  result := Format('MariaDB %s', [inherited GetDatabaseVersion]);
end;

class function TTMariaDBConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class procedure TTMariaDBConnection.InternalRegisterConnection(
  const AName: String; const AParameters: TTFireDACConnectionParameters);
begin
  if AParameters.Port = 0 then
    RegisterConnection(
      AName,
      AParameters.Server,
      AParameters.Username,
      AParameters.Password,
      AParameters.DatabaseName)
  else
    RegisterConnection(
      AName,
      AParameters.Server,
      AParameters.Port,
      AParameters.Username,
      AParameters.Password,
      AParameters.DatabaseName);
end;

class procedure TTMariaDBConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, DefaultPort, AUsername, APassword, ADatabaseName);
end;

class procedure TTMariaDBConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const APort: Integer;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Server=%s', [AServer]));
    LParameters.Add(Format('Port=%d', [APort]));
    LParameters.Add(Format('Database=%s', [ADatabaseName]));
    LParameters.Add(Format('User_Name=%s', [AUserName]));
    LParameters.Add(Format('Password=%s', [APassword]));

    RegisterConnection(AName, LParameters);
  finally
    LParameters.Free;
  end;
end;

class procedure TTMariaDBConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTMariaDBConnection>();

end.
