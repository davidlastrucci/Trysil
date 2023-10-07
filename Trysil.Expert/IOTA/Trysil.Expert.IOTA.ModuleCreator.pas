(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.IOTA.ModuleCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI,
  DesignIntf,

  Trysil.Expert.IOTA.Services,
  Trysil.Expert.IOTA.SourceFile;

type

{ TTModuleCreator }

  TTModuleCreator = class(
    TInterfacedObject, IOTACreator, IOTAModuleCreator)
  strict private
    FUnitName: String;
    FSource: String;

    // IOTACreator
    function GetCreatorType: String;
    function GetExisting: Boolean;
    function GetFileSystem: String;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;

    // IOTAModuleCreator
    function GetAncestorName: String;
    function GetImplFileName: String;
    function GetIntfFileName: String;
    function GetFormName: String;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: String): IOTAFile;
    function NewImplSource(
      const ModuleIdent, FormIdent, AncestorIdent: String): IOTAFile;
    function NewIntfSource(
      const ModuleIdent, FormIdent, AncestorIdent: String): IOTAFile;
    procedure FormCreated(const FormEditor: IOTAFormEditor);
  public
    constructor Create(const AUnitName: String; const ASource: String);
  end;

implementation

{ TTModuleCreator }

constructor TTModuleCreator.Create(
  const AUnitName: String; const ASource: String);
begin
  inherited Create;
  FUnitName := AUnitName;
  FSource := ASource;
end;

procedure TTModuleCreator.FormCreated(const FormEditor: IOTAFormEditor);
begin
  // Do nothing
end;

function TTModuleCreator.GetAncestorName: String;
begin
  result := '';
end;

function TTModuleCreator.GetCreatorType: String;
begin
  result := sUnit;
end;

function TTModuleCreator.GetExisting: Boolean;
begin
  result := False;
end;

function TTModuleCreator.GetFileSystem: string;
begin
  result := '';
end;

function TTModuleCreator.GetFormName: string;
begin
  result := '';
end;

function TTModuleCreator.GetImplFileName: string;
begin
  result := Format('%s.pas', [FUnitName]);
end;

function TTModuleCreator.GetIntfFileName: string;
begin
  result := '';
end;

function TTModuleCreator.GetMainForm: Boolean;
begin
  result := False;
end;

function TTModuleCreator.GetOwner: IOTAModule;
var
  LModuleServices: IOTAModuleServices;
  LModule, LResult: IOTAModule;
begin
  result := nil;
  LModuleServices := TTIOTAServices.ModuleServices;
  if Assigned(LModuleServices) then
  begin
    LModule := LModuleServices.CurrentModule;
    if Assigned(LModule) then
      if LModule.QueryInterface(IOTAProject, LResult) = S_OK then
        result := LResult;
  end;
end;

function TTModuleCreator.GetShowForm: Boolean;
begin
  result := False;
end;

function TTModuleCreator.GetShowSource: Boolean;
begin
  result := True;
end;

function TTModuleCreator.GetUnnamed: Boolean;
begin
  result := True;
end;

function TTModuleCreator.NewFormFile(
  const FormIdent, AncestorIdent: String): IOTAFile;
begin
  result := nil;
end;

function TTModuleCreator.NewImplSource(
  const ModuleIdent, FormIdent, AncestorIdent: String): IOTAFile;
begin
  result := TTSourceFile.Create(FSource);
end;

function TTModuleCreator.NewIntfSource(
  const ModuleIdent, FormIdent, AncestorIdent: String): IOTAFile;
begin
  result := nil;
end;

end.

