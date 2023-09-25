(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.EntryPoint;

interface

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI,
  DesignIntf,

  Trysil.Expert;

{ WizardEntryPoint }

  function InitWizard(
    const BorlandIDEServices: IBorlandIDEServices;
    RegisterProc: TWizardRegisterProc;
    var Terminate: TWizardTerminateProc): Boolean; stdcall;

implementation

{ WizardEntryPoint }

const
  InvalidIndex = -1;

var
  FExpertIndex: Integer = InvalidIndex;

function GetWizardServices: IOTAWizardServices;
begin
  Assert(Assigned(BorlandIDEServices));
  result := nil;
  if BorlandIDEServices.SupportsService(IOTAWizardServices) then
    result := BorlandIDEServices as IOTAWizardServices;
  Assert(Assigned(result));
end;

procedure FinalizeWizard;
var
  LWizardServices: IOTAWizardServices;
begin
  if FExpertIndex > InvalidIndex then
  begin
    LWizardServices := GetWizardServices;
    LWizardServices.RemoveWizard(FExpertIndex);
    FExpertIndex := InvalidIndex;
  end;
end;

function InitWizard(
  const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  LWizardServices: IOTAWizardServices;
begin
  LWizardServices := GetWizardServices;
  FExpertIndex := LWizardServices.AddWizard(TTExpert.Create as IOTAWizard);
  result := (FExpertIndex > InvalidIndex);
  if result then
    Terminate := FinalizeWizard;
end;

exports InitWizard name WizardEntryPoint;

end.
