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
  Trysil.Expert.Model;

type

{ TTAPIHttpModifier }

  TTAPIHttpModifier = class
  strict private
    FProjectName: String;
    FEntities: TList<TTEntity>;
    FSource: TStrings;
    FDestination: TStrings;

    function ModifyUses: Integer;
    procedure ModifyRegister(const AIndex: Integer);
  public
    constructor Create(
      const AProjectName: String; const AEntities: TList<TTEntity>);
    destructor Destroy; override;

    procedure Modify;
  end;

implementation

{ TTAPIHttpModifier }

constructor TTAPIHttpModifier.Create(
  const AProjectName: String; const AEntities: TList<TTEntity>);
begin
  inherited Create;
  FProjectName := AProjectName;
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

function TTAPIHttpModifier.ModifyUses: Integer;
var
  LInUses: Boolean;
  LIndex: Integer;
  LRow: String;
  LEntity: TTEntity;
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
      FDestination.Add(FSource[LIndex].Replace(';', ','));
      for LEntity in FEntities do
        FDestination.Add(Format('  %s.Controller.%s,', [FProjectName, LEntity.Name]));
      FDestination[FDestination.Count - 1] :=
        FDestination[FDestination.Count - 1].Replace(',', ';');
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

    if LRow.Equals('PROCEDURE THTTP.REGISTERCONTROLLERS;') then
      LInRegister := True;

    if LInRegister and (LRow.EndsWith('END;')) then
    begin
      for LEntity in FEntities do
        FDestination.Add(Format(
          '  FServer.RegisterController<T%sController>();', [
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
    Format('API\%s.Http', [FProjectName]));
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
