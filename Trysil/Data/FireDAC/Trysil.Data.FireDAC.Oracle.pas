(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.Oracle;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.Oracle,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.Oracle;

type

{ TTOracleDriver }

  TTOracleDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysOracleDriverLink;
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TTOracleConnection }

  TTOracleConnection = class(TTFireDACConnection)
  strict private
    const DefaultPort: Integer = 1521;
  strict private
    class var FDriver: TTOracleDriver;
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
      const AServiceName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const APort: Integer;
      const AUsername: String;
      const APassword: String;
      const AServiceName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AParameters: TStrings); overload;

    class property Driver: TTOracleDriver read FDriver;
  end;

implementation

{ TTOracleDriver }

constructor TTOracleDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysOracleDriverLink.Create(nil);
end;

destructor TTOracleDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

function TTOracleDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

{ TTOracleConnection }

class constructor TTOracleConnection.ClassCreate;
begin
  FDriver := TTOracleDriver.Create;
end;

class destructor TTOracleConnection.ClassDestroy;
begin
  FDriver.Free;
end;

function TTOracleConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTOracleSyntaxClasses.Create;
end;

function TTOracleConnection.GetDatabaseVersion: String;
begin
  result := Format('Oracle %s', [inherited GetDatabaseVersion]);
end;

class function TTOracleConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class procedure TTOracleConnection.InternalRegisterConnection(
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

class procedure TTOracleConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const AServiceName: String);
begin
  RegisterConnection(
    AName, AServer, DefaultPort, AUsername, APassword, AServiceName);
end;

class procedure TTOracleConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const APort: Integer;
  const AUsername: String;
  const APassword: String;
  const AServiceName: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Database=//%s:%d/%s', [AServer, APort, AServiceName]));
    LParameters.Add(Format('User_Name=%s', [AUserName]));
    LParameters.Add(Format('Password=%s', [APassword]));

    RegisterConnection(AName, LParameters);
  finally
    LParameters.Free;
  end;
end;

class procedure TTOracleConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTOracleConnection>();

end.
