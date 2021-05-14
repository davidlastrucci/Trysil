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
  FireDAC.Phys.SQLite,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.SQLite;

type

{ TTSQLiteConnection }

  TTSQLiteConnection = class(TTFireDACConnection)
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
  end;

implementation

{ TTSQLiteConnection }

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
    AName, 'SQLite', AParameters);
end;

end.
