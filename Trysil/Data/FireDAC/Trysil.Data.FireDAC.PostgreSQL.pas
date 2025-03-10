(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.PostgreSQL;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.PG,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.PostgreSQL;

type

{ TTPostgreSQLDriver }

  TTPostgreSQLDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysPgDriverLink;
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TTPostgreSQLConnection }

  TTPostgreSQLConnection = class(TTFireDACConnection)
  strict private
    const DefaultPort: Integer = 5432;
  strict private
    class var FDriver: TTPostgreSQLDriver;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;

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

    class property Driver: TTPostgreSQLDriver read FDriver;
  end;

implementation

{ TTPostgreSQLDriver }

constructor TTPostgreSQLDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysPgDriverLink.Create(nil);
end;

destructor TTPostgreSQLDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

function TTPostgreSQLDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

{ TTPostgreSQLConnection }

class constructor TTPostgreSQLConnection.ClassCreate;
begin
  FDriver := TTPostgreSQLDriver.Create;
end;

class destructor TTPostgreSQLConnection.ClassDestroy;
begin
  FDriver.Free;
end;

function TTPostgreSQLConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTPostgreSQLSyntaxClasses.Create;
end;

class function TTPostgreSQLConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class procedure TTPostgreSQLConnection.InternalRegisterConnection(
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

class procedure TTPostgreSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, DefaultPort, AUsername, APassword, ADatabaseName);
end;

class procedure TTPostgreSQLConnection.RegisterConnection(
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

class procedure TTPostgreSQLConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTPostgreSQLConnection>();

end.
