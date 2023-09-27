(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Themes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Generics.Collections,
  ToolsAPI,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms;

type

{ TTStyleServicesNotifier }

  TTStyleServicesNotifier = class(
    TInterfacedObject, IOTANotifier, INTAIDEThemingServicesNotifier)
  strict private
    FThemingServices: IOTAIDEThemingServices;
    FFormClasses: TList<TFormClass>;

    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    // INTAIDEThemingServiceNotifier
    procedure ChangedTheme;
    procedure ChangingTheme;
  public
    constructor Create(
      const AThemingServices: IOTAIDEThemingServices;
      const AFormClasses: TList<TFormClass>);
  end;

{ TTThemingServices }

  TTThemingServices = class
  strict private
    class var FInstance: TTThemingServices;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FFormClasses: TList<TFormClass>;
    FThemingServices: IOTAIDEThemingServices;

    procedure RegisterFormClass(const AFormClass: TFormClass);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure ApplyTheme(const AForm: TForm);
    function GetSystemColor(const AColor: TColor): TColor;

    class property Instance: TTThemingServices read FInstance;
  end;

implementation

{ TTStyleServicesNotifier }

constructor TTStyleServicesNotifier.Create(
  const AThemingServices: IOTAIDEThemingServices;
  const AFormClasses: TList<TFormClass>);
begin
  inherited Create;
  FThemingServices := AThemingServices;
  FFormClasses := AFormClasses;
end;

procedure TTStyleServicesNotifier.AfterSave;
begin
  // Do nothing
end;

procedure TTStyleServicesNotifier.BeforeSave;
begin
  // Do nothing
end;

procedure TTStyleServicesNotifier.Destroyed;
begin
  // Do nothing
end;

procedure TTStyleServicesNotifier.Modified;
begin
  // Do nothing
end;

procedure TTStyleServicesNotifier.ChangedTheme;
var
  LFormClass: TFormClass;
begin
  if Assigned(FThemingServices) and
    (FThemingServices.IDEThemingEnabled) then
  begin
    for LFormClass in FFormClasses do
      FThemingServices.RegisterFormClass(LFormClass);
  end;
end;

procedure TTStyleServicesNotifier.ChangingTheme;
begin
  // Do nothing
end;

{ TTThemingServices }

class constructor TTThemingServices.ClassCreate;
begin
  FInstance := TTThemingServices.Create;
end;

class destructor TTThemingServices.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTThemingServices.Create;
begin
  inherited Create;
  FFormClasses := TList<TFormClass>.Create;
  FThemingServices := nil;
end;

destructor TTThemingServices.Destroy;
begin
  FFormClasses.Free;
  inherited Destroy;
end;

procedure TTThemingServices.AfterConstruction;
begin
  inherited AfterConstruction;
  if BorlandIDEServices.SupportsService(IOTAIDEThemingServices) then
  begin
    FThemingServices := (BorlandIDEServices as IOTAIDEThemingServices);
    if FThemingServices.IDEThemingEnabled then
      FThemingServices.AddNotifier(
        TTStyleServicesNotifier.Create(FThemingServices, FFormClasses));
  end;
end;

procedure TTThemingServices.RegisterFormClass(const AFormClass: TFormClass);
begin
  if not FFormClasses.Contains(AFormClass) then
  begin
    FThemingServices.RegisterFormClass(AFormClass);
    FFormClasses.Add(AFormClass);
  end;
end;

procedure TTThemingServices.ApplyTheme(const AForm: TForm);
begin
  if Assigned(FThemingServices) and
    (FThemingServices.IDEThemingEnabled) then
  begin
    RegisterFormClass(TFormClass(AForm.ClassType));
    FThemingServices.ApplyTheme(AForm);
  end;
end;

function TTThemingServices.GetSystemColor(const AColor: TColor): TColor;
begin
  if Assigned(FThemingServices) and
    (FThemingServices.IDEThemingEnabled) then
    result := FThemingServices.StyleServices.GetSystemColor(AColor)
  else
    result := AColor;
end;

end.
