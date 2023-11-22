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
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,

  Trysil.Expert.IOTA.Services;

type

{ TTThemingServices }

  TTThemingServices = class
  strict private
    class var FInstance: TTThemingServices;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FFormClasses: TList<TFormClass>;
    FThemingServices: IOTAIDEThemingServices;

    function GetThemingEnabled: Boolean;
    procedure ThemeChanged(const AIsDarkTheme: Boolean);
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

type

{ TTStyleServicesNotifierChangedEvent }

  TTStyleServicesNotifierChangedEvent =
    procedure(const AIsDarkTheme: Boolean) of object;

{ TTStyleServicesNotifier }

  TTStyleServicesNotifier = class(
    TInterfacedObject, IOTANotifier, INTAIDEThemingServicesNotifier)
  strict private
    FThemingServices: IOTAIDEThemingServices;
    FChangedEvent: TTStyleServicesNotifierChangedEvent;

    function GetIsDarkTheme: Boolean;
    function GetThemingEnabled: Boolean;

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
      const AChangedEvent: TTStyleServicesNotifierChangedEvent);

      property IsDarkTheme: Boolean read GetIsDarkTheme;
  end;

constructor TTStyleServicesNotifier.Create(
  const AThemingServices: IOTAIDEThemingServices;
  const AChangedEvent: TTStyleServicesNotifierChangedEvent);
begin
  inherited Create;
  FThemingServices := AThemingServices;
  FChangedEvent := FChangedEvent;
end;

function TTStyleServicesNotifier.GetIsDarkTheme: Boolean;
var
  LColor: TColor;
  LRed, LGreen, LBlue: Byte;
begin
  if GetThemingEnabled then
    LColor := FThemingServices.StyleServices.GetSystemColor(clWindow)
  else
    LColor := clWindow;

  LRed := GetRValue(LColor);
  LGreen := GetGValue(LColor);
  LBlue := GetBValue(LColor);

  result := (((LRed + LGreen + LBlue) div 3) < 127);
end;

function TTStyleServicesNotifier.GetThemingEnabled: Boolean;
begin
  result := Assigned(FThemingServices) and
    (FThemingServices.IDEThemingEnabled);
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
begin
  if GetThemingEnabled then
    if Assigned(FChangedEvent) then
      FChangedEvent(GetIsDarkTheme);
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
  FThemingServices := TTIOTAServices.IDEThemingServices;
  if Assigned(FThemingServices) then
  begin
    if FThemingServices.IDEThemingEnabled then
      FThemingServices.AddNotifier(
        TTStyleServicesNotifier.Create(FThemingServices, ThemeChanged));
  end;
end;

function TTThemingServices.GetThemingEnabled: Boolean;
begin
  result := Assigned(FThemingServices) and
    (FThemingServices.IDEThemingEnabled);
end;

procedure TTThemingServices.ThemeChanged(const AIsDarkTheme: Boolean);
{$IF CompilerVersion >= 34}
var
  LFormClass: TFormClass;
{$ENDIF}
begin
{$IF CompilerVersion >= 34}
  if GetThemingEnabled then
    for LFormClass in FFormClasses do
      FThemingServices.RegisterFormClass(LFormClass);
{$ENDIF}
end;

procedure TTThemingServices.RegisterFormClass(const AFormClass: TFormClass);
begin
{$IF CompilerVersion >= 34}
  if GetThemingEnabled and (not FFormClasses.Contains(AFormClass)) then
  begin
    FThemingServices.RegisterFormClass(AFormClass);
    FFormClasses.Add(AFormClass);
  end;
{$ENDIF}
end;

procedure TTThemingServices.ApplyTheme(const AForm: TForm);
begin
  if GetThemingEnabled then
  begin
    RegisterFormClass(TFormClass(AForm.ClassType));
    FThemingServices.ApplyTheme(AForm);
  end;
end;

function TTThemingServices.GetSystemColor(const AColor: TColor): TColor;
begin
  if GetThemingEnabled then
    result := FThemingServices.StyleServices.GetSystemColor(AColor)
  else
    result := AColor;
end;

end.
