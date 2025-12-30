(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.Interbase;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Phys,
  FireDAC.Phys.IB,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.Interbase;

type

{ TTInterbaseDriver }

  TTInterbaseDriver = class(TTFireDACDriver)
  strict private
    FDriverLink: TFDPhysIBDriverLink;
  strict protected
    function GetDriverLink: TFDPhysDriverLink; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TTInterbaseConnection }

  TTInterbaseConnection = class(TTFireDACConnection)
  strict private
    class var FDriver: TTInterbaseDriver;
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

    class property Driver: TTInterbaseDriver read FDriver;
  end;

implementation

{ TTInterbaseDriver }

constructor TTInterbaseDriver.Create;
begin
  inherited Create;
  FDriverLink := TFDPhysIBDriverLink.Create(nil);
end;

destructor TTInterbaseDriver.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

function TTInterbaseDriver.GetDriverLink: TFDPhysDriverLink;
begin
  result := FDriverLink;
end;

{ TTInterbaseConnection }

class constructor TTInterbaseConnection.ClassCreate;
begin
  FDriver := TTInterbaseDriver.Create;
end;

class destructor TTInterbaseConnection.ClassDestroy;
begin
  FDriver.Free;
end;

function TTInterbaseConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTInterbaseSyntaxClasses.Create;
end;

function TTInterbaseConnection.GetDatabaseVersion: String;
begin
  result := Format('Interbase %s', [inherited GetDatabaseVersion]);
end;

class function TTInterbaseConnection.GetDriver: String;
begin
  result := FDriver.DriverLink.DriverID;
end;

class procedure TTInterbaseConnection.InternalRegisterConnection(
  const AName: String;
  const AParameters: TTFireDACConnectionParameters);
begin
  RegisterConnection(
    AName,
    AParameters.Server,
    AParameters.Username,
    AParameters.Password,
    AParameters.DatabaseName);
end;

class procedure TTInterbaseConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTInterbaseConnection.RegisterConnection(
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

class procedure TTInterbaseConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

initialization
  TTFireDACConnectionFactory.Instance.RegisterDriver<TTInterbaseConnection>();

end.
