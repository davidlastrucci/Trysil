(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.Oracle;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Data.SqlSyntax;

type

{ TTOracleSequenceSyntax }

  TTOracleSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTOracleSelectSyntax }

  TTOracleSelectSyntax = class(TTSelectSyntax)
  strict protected
    function GetFilterPagingSyntax: String; override;
  end;

{ TTOracleVersionSyntax }

  TTOracleVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTOracleSyntaxClasses }

  TTOracleSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTOracleSequenceSyntax }

function TTOracleSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format('SELECT %s.NEXTVAL ID FROM DUAL', [FTableMap.SequenceName]);
end;

{ TTOracleSelectSyntax }

function TTOracleSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('OFFSET %d ROWS FETCH NEXT %d ROWS ONLY', [
    FFilter.Paging.Start, FFilter.Paging.Limit]);
end;

{ TTOracleVersionSyntax }

function TTOracleVersionSyntax.GetSQL: String;
begin
  result := 'SELECT version FROM product_component_version WHERE ROWNUM = 1';
end;

{ TTOracleSyntaxClasses }

function TTOracleSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTOracleSequenceSyntax;
end;

function TTOracleSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTOracleSelectSyntax;
end;

function TTOracleSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTOracleVersionSyntax;
end;

end.
