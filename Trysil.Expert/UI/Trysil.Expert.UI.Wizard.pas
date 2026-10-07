(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Wizard;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.ExtCtrls;

type

{ TWizardPageEnabled }

  TWizardPageEnabled = function: Boolean of object;

{ TWizardPageCheck }

  TWizardPageCheck = function: Boolean of object;

{ TTWizardPage }

  TTWizardPage = record
  strict private
    FPage: TPanel;
    FControl: TWinControl;
    FEnabled: TWizardPageEnabled;
    FCheck: TWizardPageCheck;

    function GetVisible: Boolean;
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(
      const APage: TPanel;
      const AControl: TWinControl;
      const AEnabled: TWizardPageEnabled;
      const ACheck: TWizardPageCheck);

    function Enabled: Boolean;
    function Check: Boolean;
    procedure SetFocus;

    property Visible: Boolean read GetVisible write SetVisible;
  end;

{ TTWizard }

  TTWizard = class
  strict private
    FHandle: HWND;
    FPages: TList<TTWizardPage>;
    FIndex: Integer;

    function SearchEnabled(
      const AIndex: Integer; const AStep: Integer): Integer;
    procedure MoveTo(const AIndex: Integer);
    function GetIsFirst: Boolean;
    function GetIsLast: Boolean;
  public
    constructor Create(const AHandle: HWND);
    destructor Destroy; override;

    procedure AddPage(const APage: TTWizardPage);
    procedure Start;

    procedure PreviousPage;
    procedure NextPage;

    property IsFirst: Boolean read GetIsFirst;
    property IsLast: Boolean read GetIsLast;
  end;

implementation

{ TTWizardPage }

constructor TTWizardPage.Create(
  const APage: TPanel;
  const AControl: TWinControl;
  const AEnabled: TWizardPageEnabled;
  const ACheck: TWizardPageCheck);
begin
  FPage := APage;
  FControl := AControl;
  FEnabled := AEnabled;
  FCheck := ACheck;
end;

function TTWizardPage.Enabled: Boolean;
begin
  if Assigned(FEnabled) then
    result := FEnabled
  else
    result := True;
end;

function TTWizardPage.Check: Boolean;
begin
  if Assigned(FCheck) then
    result := FCheck
  else
    result := True;
end;

procedure TTWizardPage.SetFocus;
begin
  FControl.SetFocus;
end;

function TTWizardPage.GetVisible: Boolean;
begin
  result := FPage.Visible;
end;

procedure TTWizardPage.SetVisible(const AValue: Boolean);
begin
  FPage.Visible := AValue;
  if FPage.Visible then
    FPage.Align := TAlign.alClient;
end;

{ TTWizard }

constructor TTWizard.Create(const AHandle: HWND);
begin
  inherited Create;
  FHandle := AHandle;
  FPages := TList<TTWizardPage>.Create;
end;

destructor TTWizard.Destroy;
begin
  FPages.Free;
  inherited Destroy;
end;

procedure TTWizard.AddPage(const APage: TTWizardPage);
begin
  APage.Visible := False;
  FPages.Add(APage);
end;

procedure TTWizard.Start;
begin
  FIndex := 0;
  FPages[FIndex].Visible := True;
end;

function TTWizard.SearchEnabled(
  const AIndex: Integer; const AStep: Integer): Integer;
begin
  result := AIndex;
  while (result >= 0) and
    (result < FPages.Count) and
    (not FPages[result].Enabled) do
    Inc(result, AStep);

  if result >= FPages.Count then
    result := -1;
end;

procedure TTWizard.MoveTo(const AIndex: Integer);
begin
  LockWindowUpdate(FHandle);
  try
    FPages[FIndex].Visible := False;
    FIndex := AIndex;
    FPages[FIndex].Visible := True;
    FPages[FIndex].SetFocus;
  finally
    LockWindowUpdate(0);
  end;
end;

function TTWizard.GetIsFirst: Boolean;
begin
  result := SearchEnabled(FIndex - 1, -1) < 0;
end;

function TTWizard.GetIsLast: Boolean;
begin
  result := SearchEnabled(FIndex + 1, 1) < 0;
end;

procedure TTWizard.PreviousPage;
var
  LIndex: Integer;
begin
  LIndex := SearchEnabled(FIndex - 1, -1);
  if LIndex >= 0 then
    MoveTo(LIndex);
end;

procedure TTWizard.NextPage;
var
  LIndex: Integer;
begin
  if FPages[FIndex].Check then
  begin
    LIndex := SearchEnabled(FIndex + 1, 1);
    if LIndex >= 0 then
      MoveTo(LIndex);
  end;
end;

end.
