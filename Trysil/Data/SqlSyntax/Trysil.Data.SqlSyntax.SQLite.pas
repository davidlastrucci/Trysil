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
    function GetFilterPagingSyntax(): String; override;
  end;

{ TTSQLiteVersionSyntax }

  TTSQLiteVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTSQLiteSyntaxClasses }

  TTSQLiteSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTSQLiteSequenceSyntax }

function TTSQLiteSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT MAX(ROWID) + 1 FROM %s', [FTableMap.Name]);
end;

{ TTSQLiteSelectSyntax }

function TTSQLiteSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('LIMIT %d OFFSET %d', [
    FFilter.Paging.Limit, FFilter.Paging.Start]);
end;

{ TTSQLiteVersionSyntax }

function TTSQLiteVersionSyntax.GetSQL: String;
begin
  result := 'SELECT sqlite_version();';
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

function TTSQLiteSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTSQLiteVersionSyntax;
end;

end.
