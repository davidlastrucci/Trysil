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

{ TTSQLiteSequenceSyntax }

  TTSQLiteSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTSQLiteSelectSyntax }

  TTSQLiteSelectSyntax = class(TTSelectSyntax)
  strict protected
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;

    function GetFilterTopSyntax: String; override;
  end;

{ TTSQLiteSyntaxClasses }

  TTSQLiteSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
  end;

implementation

{ TTSQLiteSequenceSyntax }

function TTSQLiteSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT MAX(ROWID) + 1 FROM %s', [FTableMap.Name]);
end;

{ TTSQLiteSelectSyntax }

function TTSQLiteSelectSyntax.InternalGetSqlSyntax(
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

function TTSQLiteSelectSyntax.GetFilterTopSyntax: String;
begin
  result := Format('LIMIT %d', [FFilter.Top.MaxRecord]);
end;

{ TTSQLiteSyntaxClasses }

function TTSQLiteSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTSQLiteSequenceSyntax;
end;

function TTSQLiteSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTSQLiteSelectSyntax;
end;

end.
