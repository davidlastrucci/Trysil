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

{ TTSQLiteVersionSyntax }

  TTSQLiteVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTSQLiteSyntaxClasses }

  TTSQLiteSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTSQLiteSequenceSyntax }

function TTSQLiteSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT IFNULL(MAX(ROWID), 0) + 1 FROM %s', [FTableMap.Name]);
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

function TTSQLiteSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTSQLiteVersionSyntax;
end;

end.
