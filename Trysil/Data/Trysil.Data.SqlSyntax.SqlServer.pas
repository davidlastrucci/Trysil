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

{ TTDataSqlServerSequenceSyntax }

  TTDataSqlServerSequenceSyntax = class(TTDataSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTDataSqlServerSelectSyntax }

  TTDataSqlServerSelectSyntax = class(TTDataSelectSyntax)
  strict protected
    function GetFilterTopSyntax: String; override;
  end;

{ TTDataSqlServerSyntaxClasses }

  TTDataSqlServerSyntaxClasses = class(TTDataSyntaxClasses)
  public
    function Sequence: TTDataSequenceSyntaxClass; override;
    function SelectCount: TTDataSelectCountSyntaxClass; override;
    function Select: TTDataSelectSyntaxClass; override;
    function Metadata: TTDataMetadataSyntaxClass; override;
    function Insert: TTDataCommandSyntaxClass; override;
    function Update: TTDataCommandSyntaxClass; override;
    function Delete: TTDataCommandSyntaxClass; override;
  end;

implementation

{ TTDataSqlServerSequenceSyntax }

function TTDataSqlServerSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format('SELECT NEXT VALUE FOR [%s] AS ID', [FSequenceName]);
end;

{ TTDataSqlServerSelectSyntax }

function TTDataSqlServerSelectSyntax.GetFilterTopSyntax: String;
begin
  result := Format('TOP %d', [FFilter.Top.MaxRecord]);
end;

{ TTDataSqlServerSyntaxClasses }

function TTDataSqlServerSyntaxClasses.Sequence: TTDataSequenceSyntaxClass;
begin
  result := TTDataSqlServerSequenceSyntax;
end;

function TTDataSqlServerSyntaxClasses.SelectCount: TTDataSelectCountSyntaxClass;
begin
  result := TTDataSelectCountSyntax;
end;

function TTDataSqlServerSyntaxClasses.Select: TTDataSelectSyntaxClass;
begin
  result := TTDataSqlServerSelectSyntax;
end;

function TTDataSqlServerSyntaxClasses.Metadata: TTDataMetadataSyntaxClass;
begin
  result := TTDataMetadataSyntax;
end;

function TTDataSqlServerSyntaxClasses.Insert: TTDataCommandSyntaxClass;
begin
  result := TTDataInsertSyntax;
end;

function TTDataSqlServerSyntaxClasses.Update: TTDataCommandSyntaxClass;
begin
  result := TTDataUpdateSyntax;
end;

function TTDataSqlServerSyntaxClasses.Delete: TTDataCommandSyntaxClass;
begin
  result := TTDataDeleteSyntax;
end;

end.
