(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert;

interface

uses
  System.SysUtils,
  System.Classes,
  DesignIntf,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  Vcl.Graphics,
  ToolsAPI,

  Trysil.Expert.ActionsMenu;

type

{ TTExpert }

  TTExpert = class(TNotifierObject, IOTAWizard)
  strict private
    const WizardID: String = 'Trysil.Expert';
  strict private
    FDatamodule: TTActionsMenuDatamodule;
  public
    constructor Create;
    destructor Destroy; override;

    { IOTAWizard }
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;

    procedure Execute;
  end;

implementation

{ TTExpert }

constructor TTExpert.Create;
begin
  inherited Create;
  FDatamodule := TTActionsMenuDatamodule.Create(nil);
end;

destructor TTExpert.Destroy;
begin
  FDatamodule.Free;
  inherited Destroy;
end;

function TTExpert.GetIDString: string;
begin
  result := WizardID;
end;

function TTExpert.GetName: string;
begin
  result := WizardID;
end;

function TTExpert.GetState: TWizardState;
begin
  result := [wsEnabled];
end;

procedure TTExpert.Execute;
begin
end;

end.
