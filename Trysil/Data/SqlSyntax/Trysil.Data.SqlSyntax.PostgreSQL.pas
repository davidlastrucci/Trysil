(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.PostgreSQL;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Data.SqlSyntax;

type

{ TTPostgreSQLSequenceSyntax }

  TTPostgreSQLSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTPostgreSQLSelectSyntax }

  TTPostgreSQLSelectSyntax = class(TTSelectSyntax)
  strict protected
    function GetFilterPagingSyntax: String; override;
  end;

{ TTPostgreSQLVersionSyntax }

  TTPostgreSQLVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTPostgreSQLSyntaxClasses }

  TTPostgreSQLSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTPostgreSQLSequenceSyntax }

function TTPostgreSQLSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT NEXTVAL(''%s'') AS ID', [FTableMap.SequenceName]);
end;

{ TTPostgreSQLSelectSyntax }

function TTPostgreSQLSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('LIMIT %d OFFSET %d', [
    FFilter.Paging.Limit, FFilter.Paging.Start]);
end;

{ TTPostgreSQLVersionSyntax }

function TTPostgreSQLVersionSyntax.GetSQL: String;
begin
  result := 'SELECT VERSION()';
end;

{ TTPostgreSQLSyntaxClasses }

function TTPostgreSQLSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTPostgreSQLSequenceSyntax;
end;

function TTPostgreSQLSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTPostgreSQLSelectSyntax;
end;

function TTPostgreSQLSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTPostgreSQLVersionSyntax;
end;

end.
