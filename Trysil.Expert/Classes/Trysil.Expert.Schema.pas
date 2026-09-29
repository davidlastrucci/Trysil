(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.Schema;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type

{ TTSchemaFamily }

  TTSchemaFamily = (
    sfText,
    sfNumber,
    sfBoolean,
    sfDateTime,
    sfGuid,
    sfBinary,
    sfOther);

{ TTSchemaFamilies }

  TTSchemaFamilies = set of TTSchemaFamily;

{ TTSchemaColumn }

  TTSchemaColumn = class
  strict private
    FName: String;
    FTypeName: String;
    FFamily: TTSchemaFamily;
    FBounded: Boolean;
    FLength: Integer;
    FAllowNull: Boolean;

    function GetTypeDescription: String;
  public
    constructor Create(const AName: String; const ATypeName: String);

    property Name: String read FName;
    property TypeName: String read FTypeName;
    property Family: TTSchemaFamily read FFamily write FFamily;
    property Bounded: Boolean read FBounded write FBounded;
    property Length: Integer read FLength write FLength;
    property AllowNull: Boolean read FAllowNull write FAllowNull;
    property TypeDescription: String read GetTypeDescription;
  end;

{ TTSchemaTable }

  TTSchemaTable = class
  strict private
    FName: String;
    FColumns: TObjectList<TTSchemaColumn>;
    FIndexedColumns: TList<String>;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;

    function FindColumn(const AName: String): TTSchemaColumn;
    function HasIndexOn(const AColumnName: String): Boolean;

    property Name: String read FName;
    property Columns: TObjectList<TTSchemaColumn> read FColumns;
    property IndexedColumns: TList<String> read FIndexedColumns;
  end;

{ TTSchema }

  TTSchema = class
  strict private
    FTables: TObjectList<TTSchemaTable>;
    FSequences: TList<String>;
    FSequencesKnown: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function FindTable(const AName: String): TTSchemaTable;
    function HasSequence(const AName: String): Boolean;

    property Tables: TObjectList<TTSchemaTable> read FTables;
    property Sequences: TList<String> read FSequences;
    property SequencesKnown: Boolean
      read FSequencesKnown write FSequencesKnown;
  end;

implementation

{ TTSchemaColumn }

constructor TTSchemaColumn.Create(
  const AName: String; const ATypeName: String);
begin
  inherited Create;
  FName := AName;
  FTypeName := ATypeName;
  FFamily := TTSchemaFamily.sfOther;
  FBounded := False;
  FLength := 0;
  FAllowNull := True;
end;

function TTSchemaColumn.GetTypeDescription: String;
begin
  if FBounded then
    result := Format('%s(%d)', [FTypeName, FLength])
  else
    result := FTypeName;
end;

{ TTSchemaTable }

constructor TTSchemaTable.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
  FColumns := TObjectList<TTSchemaColumn>.Create(True);
  FIndexedColumns := TList<String>.Create;
end;

destructor TTSchemaTable.Destroy;
begin
  FIndexedColumns.Free;
  FColumns.Free;
  inherited Destroy;
end;

function TTSchemaTable.FindColumn(const AName: String): TTSchemaColumn;
var
  LColumn: TTSchemaColumn;
begin
  result := nil;
  for LColumn in FColumns do
    if String.Compare(LColumn.Name, AName, True) = 0 then
    begin
      result := LColumn;
      Break;
    end;
end;

function TTSchemaTable.HasIndexOn(const AColumnName: String): Boolean;
var
  LColumnName: String;
begin
  result := False;
  for LColumnName in FIndexedColumns do
    if String.Compare(LColumnName, AColumnName, True) = 0 then
    begin
      result := True;
      Break;
    end;
end;

{ TTSchema }

constructor TTSchema.Create;
begin
  inherited Create;
  FTables := TObjectList<TTSchemaTable>.Create(True);
  FSequences := TList<String>.Create;
  FSequencesKnown := False;
end;

destructor TTSchema.Destroy;
begin
  FSequences.Free;
  FTables.Free;
  inherited Destroy;
end;

function TTSchema.FindTable(const AName: String): TTSchemaTable;
var
  LTable: TTSchemaTable;
begin
  result := nil;
  for LTable in FTables do
    if String.Compare(LTable.Name, AName, True) = 0 then
    begin
      result := LTable;
      Break;
    end;
end;

function TTSchema.HasSequence(const AName: String): Boolean;
var
  LSequence: String;
begin
  result := not FSequencesKnown;
  if not result then
    for LSequence in FSequences do
      if String.Compare(LSequence, AName, True) = 0 then
      begin
        result := True;
        Break;
      end;
end;

end.
