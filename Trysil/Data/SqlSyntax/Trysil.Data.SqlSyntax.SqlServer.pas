(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.SqlServer;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Data.SqlSyntax;

type

{ TTSqlServerSequenceSyntax }

  TTSqlServerSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTSqlServerSelectSyntax }

  TTSqlServerSelectSyntax = class(TTSelectSyntax)
  strict protected
    function GetFilterPagingSyntax: String; override;
  end;

{ TTSqlServerSelectCountSyntax }

  TTSqlServerSelectCountSyntax = class(TTSelectCountSyntax)
  strict protected
    function GetCountSyntax: String; override;
  end;

{ TTSqlServerVersionSyntax }

  TTSqlServerVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTSqlServerSyntaxClasses }

  TTSqlServerSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
    function SelectCount: TTSelectCountSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTSqlServerSequenceSyntax }

function TTSqlServerSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT NEXT VALUE FOR %s AS ID', [
      FConnection.GetDatabaseObjectName(FTableMap.SequenceName)]);
end;

{ TTSqlServerSelectSyntax }

function TTSqlServerSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('OFFSET %d ROWS FETCH FIRST %d ROWS ONLY', [
    FFilter.Paging.Start, FFilter.Paging.Limit]);
  if GetOrderBy().IsEmpty then
    result := Format('ORDER BY (SELECT NULL) %s', [result]);
end;

{ TTSqlServerSelectCountSyntax }

function TTSqlServerSelectCountSyntax.GetCountSyntax: String;
begin
  result := 'COUNT_BIG(*)';
end;

{ TTSqlServerVersionSyntax }

function TTSqlServerVersionSyntax.GetSQL: String;
begin
  result := 'SELECT @@VERSION';
end;

{ TTSqlServerSyntaxClasses }

function TTSqlServerSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTSqlServerSequenceSyntax;
end;

function TTSqlServerSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTSqlServerSelectSyntax;
end;

function TTSqlServerSyntaxClasses.SelectCount: TTSelectCountSyntaxClass;
begin
  result := TTSqlServerSelectCountSyntax;
end;

function TTSqlServerSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTSqlServerVersionSyntax;
end;

end.
