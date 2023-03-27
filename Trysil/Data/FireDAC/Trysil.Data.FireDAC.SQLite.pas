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
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

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
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; override;
    function GetDatabaseVersion: String; override;
  public
    class procedure RegisterConnection(
      const AName: String; const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String; const AParameters: TStrings); overload;

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
end;

class destructor TTSQLiteConnection.ClassDestroy;
begin
  FDriver.Free;
end;

function TTSQLiteConnection.CreateSyntaxClasses: TTSyntaxClasses;
begin
  result := TTSQLiteSyntaxClasses.Create;
end;

function TTSQLiteConnection.GetDatabaseVersion: String;
begin
  result := Format('SQLite %s', [inherited GetDatabaseVersion]);
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

end.
