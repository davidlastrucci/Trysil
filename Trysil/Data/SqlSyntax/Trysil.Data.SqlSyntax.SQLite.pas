(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.SQLite;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Mapping,
  Trysil.Data.SqlSyntax;

type

{ TTDataSQLiteSequenceSyntax }

  TTDataSQLiteSequenceSyntax = class(TTDataSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTDataSQLiteSelectSyntax }

  TTDataSQLiteSelectSyntax = class(TTDataSelectSyntax)
  strict protected
    function GetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;

    function GetFilterTopSyntax: String; override;
  end;

{ TTDataSQLiteSyntaxClasses }

  TTDataSQLiteSyntaxClasses = class(TTDataSyntaxClasses)
  public
    function Sequence: TTDataSequenceSyntaxClass; override;
    function Select: TTDataSelectSyntaxClass; override;
  end;

implementation

{ TTDataSQLiteSequenceSyntax }

function TTDataSQLiteSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format('SELECT MAX(ROWID) + 1 FROM %s', [FSequenceName]);
end;

{ TTDataSQLiteSelectSyntax }

function TTDataSQLiteSelectSyntax.GetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.Append('SELECT ');
    LResult.Append(GetColumns());
    LResult.AppendFormat(' FROM %s', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    if not FFilter.Where.IsEmpty then
      LResult.AppendFormat(' WHERE %s', [FFilter.Where]);
    LResult.Append(GetOrderBy());
    if FFilter.Top.MaxRecord > 0 then
      LResult.AppendFormat(' %s', [GetFilterTopSyntax]);

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTDataSQLiteSelectSyntax.GetFilterTopSyntax: String;
begin
  result := Format('LIMIT %d', [FFilter.Top.MaxRecord]);
end;

{ TTDataSQLiteSyntaxClasses }

function TTDataSQLiteSyntaxClasses.Sequence: TTDataSequenceSyntaxClass;
begin
  result := TTDataSQLiteSequenceSyntax;
end;

function TTDataSQLiteSyntaxClasses.Select: TTDataSelectSyntaxClass;
begin
  result := TTDataSQLiteSelectSyntax;
end;

end.
