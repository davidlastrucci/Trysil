(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Attributes;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TNamedAttribute }

  TNamedAttribute = class(TCustomAttribute)
  strict private
    FName: String;
  public
    constructor Create(const AName: String);

    property Name: String read FName;
  end;

{ TTableAttribute }

  TTableAttribute = class(TNamedAttribute);

{ TSequenceAttribute }

  TSequenceAttribute = class(TNamedAttribute);

{ TPrimaryKeyAttribute }

  TPrimaryKeyAttribute = class(TCustomAttribute);

{ TColumnAttribute }

  TColumnAttribute = class(TNamedAttribute);

{ TDetailColumnAttribute }

  TDetailColumnAttribute = class(TNamedAttribute)
  strict private
    FDetailName: String;
  public
    constructor Create(const AName: String; const ADetailName: String);

    property DetailName: String read FDetailName;
  end;

{ TVersionColumnAttribute }

  TVersionColumnAttribute = class(TCustomAttribute);

{ TRelationAttribute }

  TRelationAttribute = class(TCustomAttribute)
  strict private
    FTableName: String;
    FColumnName: String;
    FIsCascade: Boolean;
  public
    constructor Create(
      const ATableName: String;
      const AColumnName: String;
      const AIsCascade: Boolean);

    property TableName: String read FTableName;
    property ColumnName: String read FColumnName;
    property IsCascade: Boolean read FIsCascade;
  end;

{ TWhereClauseAttribute }

  TWhereClauseAttribute = class(TCustomAttribute)
  strict private
    FWhere: String;
  public
    constructor Create(const AWhere: String);

    property Where: String read FWhere;
  end;

implementation

{ TNamedAttribute }

constructor TNamedAttribute.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
end;

{ TDetailColumnAttribute }

constructor TDetailColumnAttribute.Create(
  const AName: String; const ADetailName: String);
begin
  inherited Create(AName);
  FDetailName := ADetailName;
end;

{ TRelationAttribute }

constructor TRelationAttribute.Create(
  const ATableName: String;
  const AColumnName: String;
  const AIsCascade: Boolean);
begin
  inherited Create;
  FTableName := ATableName;
  FColumnName := AColumnName;
  FIsCascade := AIsCascade;
end;

{ TWhereClauseAttribute }

constructor TWhereClauseAttribute.Create(const AWhere: String);
begin
  inherited Create;
  FWhere := AWhere;
end;

end.
