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
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Phys,
  FireDAC.Phys.MSSQL,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.SqlServer;

type

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

{ TTSqlServerConnection }

  TTSqlServerConnection = class(TTFireDACConnection)
  strict private
    class var FDriver: TTSqlServerDriver;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;
  public
    function GetDatabaseObjectName(
      const ADatabaseObjectName: String): String; override;
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

{ TTSqlServerConnection }

class constructor TTSqlServerConnection.ClassCreate;
begin
  FDriver := TTSqlServerDriver.Create;
end;

class destructor TTSqlServerConnection.ClassDestroy;
begin
  FDriver.Free;
end;

function TTSqlServerConnection.GetDatabaseObjectName(
  const ADatabaseObjectName: String): String;
begin
   result := Format('[%s]', [ADatabaseObjectName]);
end;

function TTSqlServerConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTSqlServerSyntaxClasses.Create;
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
begin
  TTFireDACConnectionPool.Instance.RegisterConnection(
    AName, FDriver.DriverLink.DriverID, AParameters);
end;

end.
