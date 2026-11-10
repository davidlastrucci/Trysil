(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.InterBase;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.IB,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.InterBase;

type

{ TTInterBaseDriver }

  TTInterBaseDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysIBDriverLink;
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TTInterBaseConnection }

  TTInterBaseConnection = class(TTFireDACConnection)
  strict private
    class var FDriver: TTInterBaseDriver;
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

    class property Driver: TTInterBaseDriver read FDriver;
  end;

implementation

{ TTInterBaseDriver }

constructor TTInterBaseDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysIBDriverLink.Create(nil);
end;

destructor TTInterBaseDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

function TTInterBaseDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

{ TTInterBaseConnection }

class constructor TTInterBaseConnection.ClassCreate;
begin
  FDriver := TTInterBaseDriver.Create;
end;

class destructor TTInterBaseConnection.ClassDestroy;
begin
  FDriver.Free;
  FDriver := nil;
end;

function TTInterBaseConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTInterBaseSyntaxClasses.Create;
end;

class function TTInterBaseConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class function TTInterBaseConnection.GetDriverAliases: TArray<String>;
begin
  result := ['InterBase'];
end;

class procedure TTInterBaseConnection.InternalRegisterConnection(
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

class procedure TTInterBaseConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTInterBaseConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, AUsername, APassword, ADatabaseName, String.Empty);
end;

class procedure TTInterBaseConnection.RegisterConnection(
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

class procedure TTInterBaseConnection.RegisterConnection(
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

class procedure TTInterBaseConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

function TTInterBaseConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
  result := TTDatabaseObjectName.Quoted(
    ADatabaseObjectName, '"', '"', TTNameCase.Upper);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTInterBaseConnection>();

end.
