(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.AboutBoxServices;

interface

uses
  System.SysUtils,
  System.Classes,
  DesignIntf,
  Winapi.Windows,
  Vcl.Graphics,
  ToolsAPI,

  Trysil.Expert.IOTA.Services;

type

{ TTExpertAbout }

  TTExpertAbout = class
  strict private
    const InvalidIndex: Integer = -1;
    class var FAbout: TTExpertAbout;
  strict private
    FAboutBoxServices: IOTAAboutBoxServices;
    FAboutBoxIndex: Integer;

    procedure RegisterSplashScreen;
    procedure RegisterAboutBox;
    procedure UnregisterAboutBox;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    class procedure InitializeAbout;
    class procedure FinalizeAbout;
  end;

resourcestring
  SWizardTitle = 'Trysil - Delphi ORM';
  SWizardCopyright = 'Copyright © by David Lastrucci';
  SWizardDescription = 'Trysil - Delphi ORM is an open source Object-relational mapping (ORM) for Delphi';

implementation

{$R Trysil.Expert.Images.res}

{ TTExpertAbout }

procedure TTExpertAbout.AfterConstruction;
begin
  inherited AfterConstruction;
  FAboutBoxServices := nil;
  FAboutBoxIndex := InvalidIndex;

  RegisterSplashScreen;
  RegisterAboutBox;
end;

procedure TTExpertAbout.BeforeDestruction;
begin
  UnregisterAboutBox;
  inherited BeforeDestruction;
end;

procedure TTExpertAbout.RegisterSplashScreen;
var
  LBitmap: TBitmap;
begin
  ForceDemandLoadState(dlDisable);
  LBitmap := TBitmap.Create;
  try
    LBitmap.LoadFromResourceName(HInstance, 'TRYSIL_SPLASH');
    TTIOTAServices.SplashScreenServices.AddPluginBitmap(
      SWizardTitle,
      LBitmap.Handle,
      False,
      SWizardCopyright,
      '');
  finally
    LBitmap.Free;
  end;
end;

procedure TTExpertAbout.RegisterAboutBox;
var
  LProductImage: HBITMAP;
begin
  if FAboutBoxIndex <= InvalidIndex then
  begin
    FAboutBoxServices := TTIOTAServices.AboutBoxServices;
    if Assigned(FAboutBoxServices) then
    begin
      LProductImage := LoadBitmap(
        FindResourceHInstance(HInstance), 'TRYSIL_ABOUTBOX');
      FAboutBoxIndex := FAboutBoxServices.AddPluginInfo(
        SWizardTitle,
        SWizardDescription,
        LProductImage,
        False,
        '',
        SWizardCopyright);
    end;
  end;
end;

procedure TTExpertAbout.UnregisterAboutBox;
begin
  if (FAboutBoxIndex > InvalidIndex) and Assigned(FAboutBoxServices) then
  begin
    FAboutBoxServices.RemovePluginInfo(FAboutBoxIndex);
    FAboutBoxIndex := InvalidIndex;
    FAboutBoxServices := nil;
  end;
end;

class procedure TTExpertAbout.InitializeAbout;
begin
  FAbout := TTExpertAbout.Create;
end;

class procedure TTExpertAbout.FinalizeAbout;
begin
  FAbout.Free;
end;

initialization
  TTExpertAbout.InitializeAbout;

finalization
  TTExpertAbout.FinalizeAbout;

end.
