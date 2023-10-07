(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.IOTA.Services;

interface

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI;

type

{ TTIOTAServices }

  TTIOTAServices = class
  strict private
    class function IDEServices: IBorlandIDEServices;
  public
    class function SplashScreenServices: IOTASplashScreenServices;

    class function WizardServices: IOTAWizardServices;
    class function AboutBoxServices: IOTAAboutBoxServices;
    class function INTAServices: ToolsAPI.INTAServices;
    class function ActionServices: IOTAActionServices;
    class function IDEThemingServices: IOTAIDEThemingServices;
    class function ModuleServices: IOTAModuleServices;
  end;

implementation

{ TTIOTAServices }

class function TTIOTAServices.IDEServices: IBorlandIDEServices;
begin
  result := BorlandIDEServices;
  Assert(Assigned(result));
end;

class function TTIOTAServices.SplashScreenServices: IOTASplashScreenServices;
begin
  result := ToolsAPI.SplashScreenServices;
end;

class function TTIOTAServices.WizardServices: IOTAWizardServices;
begin
  result := nil;
  if IDEServices.SupportsService(IOTAWizardServices) then
    result := IDEServices.GetService(IOTAWizardServices) as IOTAWizardServices;
end;

class function TTIOTAServices.AboutBoxServices: IOTAAboutBoxServices;
begin
  result := nil;
  if IDEServices.SupportsService(IOTAAboutBoxServices) then
    result :=
      IDEServices.GetService(IOTAAboutBoxServices) as IOTAAboutBoxServices;
end;

class function TTIOTAServices.INTAServices: ToolsAPI.INTAServices;
begin
  result := nil;
  if IDEServices.SupportsService(ToolsAPI.INTAServices) then
    result :=
      IDEServices.GetService(ToolsAPI.INTAServices) as ToolsAPI.INTAServices;
end;

class function TTIOTAServices.ActionServices: IOTAActionServices;
begin
  result := nil;
  if IDEServices.SupportsService(IOTAActionServices) then
    result := IDEServices.GetService(IOTAActionServices) as IOTAActionServices;
end;

class function TTIOTAServices.IDEThemingServices: IOTAIDEThemingServices;
begin
  result := nil;
  if IDEServices.SupportsService(IOTAIDEThemingServices) then
    result :=
      IDEServices.GetService(IOTAIDEThemingServices) as IOTAIDEThemingServices;
end;

class function TTIOTAServices.ModuleServices: IOTAModuleServices;
begin
  result := nil;
  if IDEServices.SupportsService(IOTAModuleServices) then
    result := IDEServices.GetService(IOTAModuleServices) as IOTAModuleServices;
end;

end.
