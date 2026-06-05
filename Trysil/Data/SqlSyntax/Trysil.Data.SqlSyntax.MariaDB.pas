(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax.MariaDB;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Data.SqlSyntax;

type

{ TTMariaDBSequenceSyntax }

  TTMariaDBSequenceSyntax = class(TTSequenceSyntax)
  strict protected
    function GetSequenceSyntax: String; override;
  end;

{ TTMariaDBVersionSyntax }

  TTMariaDBVersionSyntax = class(TTVersionSyntax)
  strict protected
    function GetSQL: String; override;
  end;

{ TTMariaDBSyntaxClasses }

  TTMariaDBSyntaxClasses = class(TTSyntaxClasses)
  public
    function Sequence: TTSequenceSyntaxClass; override;
    function Version: TTVersionSyntaxClass; override;
  end;

implementation

{ TTMariaDBSequenceSyntax }

function TTMariaDBSequenceSyntax.GetSequenceSyntax: String;
begin
  result := Format('SELECT NEXTVAL(%s) AS ID', [FTableMap.SequenceName]);
end;

{ TTMariaDBVersionSyntax }

function TTMariaDBVersionSyntax.GetSQL: String;
begin
  result := 'SELECT VERSION()';
end;

{ TTMariaDBSyntaxClasses }

function TTMariaDBSyntaxClasses.Sequence: TTSequenceSyntaxClass;
begin
  result := TTMariaDBSequenceSyntax;
end;

function TTMariaDBSyntaxClasses.Version: TTVersionSyntaxClass;
begin
  result := TTMariaDBVersionSyntax;
end;

end.
