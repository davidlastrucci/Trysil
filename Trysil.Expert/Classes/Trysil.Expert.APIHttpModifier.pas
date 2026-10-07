(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIHttpModifier;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  ToolsAPI,

  Trysil.Expert.IOTA,
  Trysil.Expert.Config,
  Trysil.Expert.Model;

type

{ TTAPIHttpModifier }

  TTAPIHttpModifier = class
  strict private
    FProjectName: String;
    FControllerNames: String;
    FEntities: TList<TTEntity>;
    FSource: TStrings;
    FDestination: TStrings;

    function ControllerUnit(const AEntity: TTEntity): String;
    function HasUnit(const AEntity: TTEntity): Boolean;
    function HasRegistration(const AEntity: TTEntity): Boolean;
    procedure AddUses(const ARow: String);
    function ModifyUses: Integer;
    procedure ModifyRegister(const AIndex: Integer);
  public
    constructor Create(
      const AProjectName: String;
      const AControllerNames: String;
      const AEntities: TList<TTEntity>);
    destructor Destroy; override;

    procedure Modify;
  end;

implementation

{ TTAPIHttpModifier }

constructor TTAPIHttpModifier.Create(
  const AProjectName: String;
  const AControllerNames: String;
  const AEntities: TList<TTEntity>);
begin
  inherited Create;
  FProjectName := AProjectName;
  FControllerNames := AControllerNames;
  FEntities := AEntities;
  FSource := TStringList.Create;
  FDestination := TStringList.Create;
end;

destructor TTAPIHttpModifier.Destroy;
begin
  FDestination.Free;
  FSource.Free;
  inherited Destroy;
end;

function TTAPIHttpModifier.ControllerUnit(const AEntity: TTEntity): String;
begin
  result := TTUtils.UnitName(FControllerNames, FProjectName, AEntity.Name);
end;

function TTAPIHttpModifier.HasUnit(const AEntity: TTEntity): Boolean;
var
  LUnit: String;
  LRow: String;
begin
  result := False;
  LUnit := ControllerUnit(AEntity).ToUpper();
  for LRow in FSource do
    result := result or
      LRow.ToUpper().Trim().Equals(Format('%s,', [LUnit])) or
      LRow.ToUpper().Trim().Equals(Format('%s;', [LUnit]));
end;

function TTAPIHttpModifier.HasRegistration(const AEntity: TTEntity): Boolean;
begin
  result := FSource.Text.ToUpper().Contains(
    Format('REGISTERCONTROLLER<T%sCONTROLLER>', [AEntity.Name.ToUpper()]));
end;

procedure TTAPIHttpModifier.AddUses(const ARow: String);
var
  LUnits: TStrings;
  LEntity: TTEntity;
  LIndex: Integer;
begin
  LUnits := TStringList.Create;
  try
    for LEntity in FEntities do
      if not HasUnit(LEntity) then
        LUnits.Add(ControllerUnit(LEntity));

    if LUnits.Count = 0 then
      FDestination.Add(ARow)
    else
    begin
      FDestination.Add(ARow.Replace(';', ','));
      for LIndex := 0 to LUnits.Count - 2 do
        FDestination.Add(Format('  %s,', [LUnits[LIndex]]));
      FDestination.Add(Format('  %s;', [LUnits[LUnits.Count - 1]]));
    end;
  finally
    LUnits.Free;
  end;
end;

function TTAPIHttpModifier.ModifyUses: Integer;
var
  LInUses: Boolean;
  LIndex: Integer;
  LRow: String;
begin
  LInUses := False;
  result := 0;
  for LIndex := 0 to FSource.Count - 1 do
  begin
    result := LIndex;

    LRow := FSource[LIndex].ToUpper().Trim();

    if LRow.StartsWith('USES') then
      LInUses := True;

    if LInUses and (LRow.EndsWith(';')) then
    begin
      AddUses(FSource[LIndex]);
      Break;
    end
    else
      FDestination.Add(FSource[LIndex]);
  end;
end;

procedure TTAPIHttpModifier.ModifyRegister(const AIndex: Integer);
var
  LInRegister: Boolean;
  LIndex: Integer;
  LRow: String;
  LEntity: TTEntity;
begin
  LInRegister := False;
  for LIndex := AIndex + 1 to FSource.Count - 1 do
  begin
    LRow := FSource[LIndex].ToUpper().Trim();

    if LRow.StartsWith('PROCEDURE ') and
      LRow.EndsWith('.REGISTERENTITYCONTROLLERS;') then
      LInRegister := True;

    if LInRegister and (LRow.EndsWith('END;')) then
    begin
      for LEntity in FEntities do
        if not HasRegistration(LEntity) then
          FDestination.Add(Format(
            '  Server.RegisterController<T%sController>();', [
            LEntity.Name]));
      FDestination.Add(FSource[LIndex]);
      LInRegister := False;
    end
    else
      FDestination.Add(FSource[LIndex]);
  end;
end;

procedure TTAPIHttpModifier.Modify;
var
  LSourceEditor: IOTASourceEditor;
  LIndex: Integer;
begin
  LSourceEditor := TTIOTA.ShowSourceEditor(
    Format('%s.Http', [FProjectName]));
  if Assigned(LSourceEditor) then
  begin
    FSource.Text := TTIOTA.GetSourceFile(LSourceEditor);
    FDestination.Clear;

    LIndex := ModifyUses;
    ModifyRegister(LIndex);

    TTIOTA.RewriteSourceFile(LSourceEditor, FDestination.Text);
  end;
end;

end.
