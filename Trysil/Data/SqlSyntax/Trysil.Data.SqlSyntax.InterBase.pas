(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.InterBase;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Data.SqlSyntax;

type

{ TTInterBaseSequenceSyntax }

  TTInterBaseSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTInterBaseSelectSyntax }

  TTInterBaseSelectSyntax = class(TTSelectSyntax)
  strict protected
    function GetSQL: String; override;

    function GetFilterPagingSyntax(): String; override;
  end;

{ TTInterBaseVersionSyntax }

  TTInterBaseVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTInterBaseSyntaxClasses }

  TTInterBaseSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Select: TTSelectSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTInterBaseSequenceSyntax }

function TTInterBaseSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format(
    'SELECT GEN_ID(%s, 1) ID FROM RDB$DATABASE', [FTableMap.SequenceName]);
end;

{ TTInterBaseSelectSyntax }

function TTInterBaseSelectSyntax.GetSQL: String;
var
  LResult: TStringBuilder;
  LWhere: String;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.Append('SELECT ');
    LResult.Append(GetColumns());
    LResult.AppendFormat(' FROM %s', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    if FTableMap.HasJoins then
      LResult.Append(GetJoins());
    LWhere := GetWhere();
    if not LWhere.IsEmpty then
      LResult.AppendFormat(' WHERE %s', [LWhere]);
    LResult.Append(GetOrderBy());
    if not FFilter.Paging.IsEmpty then
      LResult.AppendFormat(' %s', [GetFilterPagingSyntax()]);

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTInterBaseSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('ROWS %d TO %d', [
    FFilter.Paging.Start + 1, FFilter.Paging.Start + FFilter.Paging.Limit]);
end;

{ TTInterBaseVersionSyntax }

function TTInterBaseVersionSyntax.GetSQL: String;
begin
  result := 'SELECT CAST(''InterBase'' AS VARCHAR(20)) FROM RDB$DATABASE';
end;

{ TTInterBaseSyntaxClasses }

function TTInterBaseSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTInterBaseSequenceSyntax;
end;

function TTInterBaseSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTInterBaseSelectSyntax;
end;

function TTInterBaseSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTInterBaseVersionSyntax;
end;

end.
