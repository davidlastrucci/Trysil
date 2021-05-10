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
    function GetFilterTopSyntax: String; override;
  end;

{ TTSqlServerSyntaxClasses }

  TTSqlServerSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
  end;

implementation

{ TTSqlServerSequenceSyntax }

function TTSqlServerSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT NEXT VALUE FOR [%s] AS ID', [FTableMap.SequenceName]);
end;

{ TTSqlServerSelectSyntax }

function TTSqlServerSelectSyntax.GetFilterTopSyntax: String;
begin
  result := Format('TOP %d', [FFilter.Top.MaxRecord]);
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

end.
