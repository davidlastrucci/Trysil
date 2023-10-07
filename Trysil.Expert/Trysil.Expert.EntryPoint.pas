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

  Trysil.Expert.IOTA.Services,
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

procedure FinalizeWizard;
var
  LWizardServices: IOTAWizardServices;
begin
  if FExpertIndex > InvalidIndex then
  begin
    LWizardServices := TTIOTAServices.WizardServices;
    Assert(Assigned(LWizardServices));
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
  LWizardServices := TTIOTAServices.WizardServices;
  Assert(Assigned(LWizardServices));
  FExpertIndex := LWizardServices.AddWizard(TTExpert.Create as IOTAWizard);
  result := (FExpertIndex > InvalidIndex);
  if result then
    Terminate := FinalizeWizard;
end;

exports InitWizard name WizardEntryPoint;

end.
