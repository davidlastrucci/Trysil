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

  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.Connection,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.SQLite;

type

{ TTDataSQLiteConnection }

  TTDataSQLiteConnection = class(TTDataFireDACConnection)
  strict protected
    function CreateSyntaxClasses: TTDataSyntaxClasses; override;
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

{ TTDataSQLiteConnection }

function TTDataSQLiteConnection.CreateSyntaxClasses: TTDataSyntaxClasses;
begin
  result := TTDataSQLiteSyntaxClasses.Create;
end;

class procedure TTDataSQLiteConnection.RegisterConnection(
  const AName: String; const ADatabaseName: String);
begin
  RegisterConnection(AName, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTDataSQLiteConnection.RegisterConnection(
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

class procedure TTDataSQLiteConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  TTDataFireDACConnectionPool.Instance.RegisterConnection(
    AName, 'SQLite', AParameters);
end;

end.
