(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.ActionsMenu;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.ImageList,
  System.Actions,
  Vcl.ImgList,
  Vcl.ActnList,
  Vcl.Controls,
  Vcl.Menus,
  ToolsAPI,

  Trysil.Expert.Project,
  Trysil.Expert.UI.Design,
  Trysil.Expert.UI.GenerateSQL,
  Trysil.Expert.UI.GenerateModel,
  Trysil.Expert.UI.Settings,
  Trysil.Expert.UI.About;

type

{ TTActionsMenuDatamodule }

  TTActionsMenuDatamodule = class(TDataModule)
    ImageList: TImageList;
    ActionLists: TActionList;
    TTEDesignAction: TAction;
    TTEGenerateSQLAction: TAction;
    TTEGenerateModelAction: TAction;
    TTESettingsAction: TAction;
    TTEAboutAction: TAction;
    PopupMenu: TPopupMenu;
    TTEDesignMenuItem: TMenuItem;
    TTESeparator01MenuItem: TMenuItem;
    TTEGenerateModelMenuItem: TMenuItem;
    TTEGenerateSQLMenuItem: TMenuItem;
    TTESeparator02MenuItem: TMenuItem;
    TTESettingsMenuItem: TMenuItem;
    TTESeparator03MenuItem: TMenuItem;
    TTEAboutMenuItem: TMenuItem;
    procedure TTEDesignActionUpdate(Sender: TObject);
    procedure TTEDesignActionExecute(Sender: TObject);
    procedure TTEGenerateSQLActionUpdate(Sender: TObject);
    procedure TTEGenerateSQLActionExecute(Sender: TObject);
    procedure TTEGenerateModelActionUpdate(Sender: TObject);
    procedure TTEGenerateModelActionExecute(Sender: TObject);
    procedure TTESettingsActionExecute(Sender: TObject);
    procedure TTEAboutActionExecute(Sender: TObject);
  strict private
    const JSonFolder: String = '__trysil.model';
  strict private
    FTrysilMenuItem: TMenuItem;

    procedure AddMenuAndToolbar;

    procedure AddMainMenu(const AServices: INTAServices);
    procedure AddSubMenuItems(const AServices: INTAServices);
    procedure AddSubMenuItem(
      const AServices: INTAServices;
      const AAction: TAction;
      const AMenuItem: TMenuItem);

    procedure AddToolbar(const AServices: INTAServices);
    procedure AddToolbarButtons(const AServices: INTAServices);
    procedure AddToolbarButton(
      const AServices: INTAServices; const AAction: TAction);

    function ActiveProject: IOTAProject;
    function IsActiveProject: Boolean;
    function ActiveTrysilProject: TTProject;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

resourcestring
  SMenuCaption = 'Trysil';
  SMenuName = 'TrysilMenuItem';
  SToolbarName = 'TrysilToolbar';
  SToolbarTitle = 'Trysil - Delphi ORM';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TTActionsMenuDatamodule }

constructor TTActionsMenuDatamodule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTrysilMenuItem := TMenuItem.Create(nil);
end;

destructor TTActionsMenuDatamodule.Destroy;
begin
  FTrysilMenuItem.Free;
  inherited Destroy;
end;

procedure TTActionsMenuDatamodule.AfterConstruction;
begin
  inherited AfterConstruction;
  AddMenuAndToolbar;
end;

procedure TTActionsMenuDatamodule.AddMenuAndToolbar;
var
  LServices: INTAServices;
begin
  inherited AfterConstruction;
  if BorlandIDEServices.SupportsService(INTAServices) then
  begin
    LServices := (BorlandIDEServices as INTAServices);
    LServices.AddImages(ImageList);
    AddMainMenu(LServices);
    AddToolbar(LServices);
  end;
end;

procedure TTActionsMenuDatamodule.AddMainMenu(const AServices: INTAServices);
begin
  FTrysilMenuItem.Caption := SMenuCaption;
  FTrysilMenuItem.Name := SMenuName;
  AServices.AddActionMenu(
    'ToolsMenu', nil, FTrysilMenuItem, False, False);

  AddSubMenuItems(AServices);
end;

procedure TTActionsMenuDatamodule.AddSubMenuItems(const AServices: INTAServices);
begin
  AddSubMenuItem(AServices, TTEDesignAction, TTEDesignMenuItem);
  AddSubMenuItem(AServices, nil, TTESeparator01MenuItem);
  AddSubMenuItem(AServices, TTEGenerateSQLAction, TTEGenerateSQLMenuItem);
  AddSubMenuItem(AServices, TTEGenerateModelAction, TTEGenerateModelMenuItem);
  AddSubMenuItem(AServices, nil, TTESeparator02MenuItem);
  AddSubMenuItem(AServices, TTESettingsAction, TTESettingsMenuItem);
  AddSubMenuItem(AServices, nil, TTESeparator03MenuItem);
  AddSubMenuItem(AServices, TTEAboutAction, TTEAboutMenuItem);
end;

procedure TTActionsMenuDatamodule.AddSubMenuItem(
  const AServices: INTAServices;
  const AAction: TAction;
  const AMenuItem: TMenuItem);
begin
  AServices.AddActionMenu(
    FTrysilMenuItem.Name, AAction, AMenuItem, True, True);
end;

procedure TTActionsMenuDatamodule.AddToolbar(const AServices: INTAServices);
begin
  AServices.NewToolbar(SToolbarName, SToolbarTitle);
  AddToolbarButtons(AServices);
end;

procedure TTActionsMenuDatamodule.AddToolbarButtons(
  const AServices: INTAServices);
begin
  AddToolbarButton(AServices, TTEDesignAction);
  AddToolbarButton(AServices, TTEGenerateSQLAction);
  AddToolbarButton(AServices, TTEGenerateModelAction);
  AddToolbarButton(AServices, TTESettingsAction);
  AddToolbarButton(AServices, TTEAboutAction);
end;

procedure TTActionsMenuDatamodule.AddToolbarButton(
  const AServices: INTAServices;
  const AAction: TAction);
begin
  AServices.AddToolButton(
    SToolbarName,
    Format('%sButton', [AAction.Name]),
    AAction,
    False);
end;

function TTActionsMenuDatamodule.ActiveProject: IOTAProject;
begin
  result := nil;
  if BorlandIDEServices.SupportsService(IOTAModuleServices) then
    result := (BorlandIDEServices as IOTAModuleServices).GetActiveProject;
end;

function TTActionsMenuDatamodule.IsActiveProject: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := ActiveProject;
  result := Assigned(LProject);
  if result then
    result := TFile.Exists(LProject.FileName);
end;

function TTActionsMenuDatamodule.ActiveTrysilProject: TTProject;
var
  LProject: IOTAProject;
begin
  LProject := ActiveProject;
  if Assigned(LProject) then
    result := TTProject.Create(LProject.FileName);
end;

procedure TTActionsMenuDatamodule.TTEDesignActionUpdate(Sender: TObject);
begin
  TTEDesignAction.Enabled := IsActiveProject;
end;

procedure TTActionsMenuDatamodule.TTEDesignActionExecute(Sender: TObject);
begin
  if IsActiveProject then
    TTDesignForm.ShowDialog(ActiveTrysilProject);
end;

procedure TTActionsMenuDatamodule.TTEGenerateSQLActionUpdate(Sender: TObject);
begin
  TTEGenerateSQLAction.Enabled := IsActiveProject;
end;

procedure TTActionsMenuDatamodule.TTEGenerateSQLActionExecute(Sender: TObject);
begin
  if IsActiveProject then
    TTGenerateSQL.ShowDialog(ActiveTrysilProject);
end;

procedure TTActionsMenuDatamodule.TTEGenerateModelActionUpdate(Sender: TObject);
begin
  TTEGenerateModelAction.Enabled := IsActiveProject;
end;

procedure TTActionsMenuDatamodule.TTEGenerateModelActionExecute(Sender: TObject);
begin
  if IsActiveProject then
    TTGenerateModel.ShowDialog(ActiveTrysilProject);
end;

procedure TTActionsMenuDatamodule.TTESettingsActionExecute(Sender: TObject);
begin
  TTSettingsForm.ShowDialog;
end;

procedure TTActionsMenuDatamodule.TTEAboutActionExecute(Sender: TObject);
begin
  TTAboutForm.ShowDialog;
end;

end.
