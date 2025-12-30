(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.Interbase;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Data.SqlSyntax;

type

{ TTInterbaseSequenceSyntax }

  TTInterbaseSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTInterbaseSelectSyntax }

  TTInterbaseSelectSyntax = class(TTSelectSyntax)
  strict protected
    function GetSQL: String; override;

    function GetFilterPagingSyntax(): String; override;
  end;

{ TTInterbaseVersionSyntax }

  TTInterbaseVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTInterbaseSyntaxClasses }

  TTInterbaseSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTInterbaseSequenceSyntax }

function TTInterbaseSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT GEN_ID(%s, 1) ID FROM RDB$DATABASE', [FTableMap.SequenceName]);
end;

{ TTInterbaseSelectSyntax }

function TTInterbaseSelectSyntax.GetSQL: String;
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
    if not FFilter.Paging.IsEmpty then
      LResult.AppendFormat(' %s', [GetFilterPagingSyntax()]);

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTInterbaseSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('ROWS %d TO %d', [
    FFilter.Paging.Start + 1,
    FFilter.Paging.Start + FFilter.Paging.Limit]);
end;

{ TTInterbaseVersionSyntax }

function TTInterbaseVersionSyntax.GetSQL: String;
begin
  // TODO: ???
  result := 'SELECT '''' FROM rdb$database;';
end;

{ TTInterbaseSyntaxClasses }

function TTInterbaseSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTInterbaseSequenceSyntax;
end;

function TTInterbaseSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTInterbaseSelectSyntax;
end;

function TTInterbaseSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTInterbaseVersionSyntax;
end;

end.
