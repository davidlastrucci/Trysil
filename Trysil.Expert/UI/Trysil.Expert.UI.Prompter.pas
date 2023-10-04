(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Prompter;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.StdCtrls;

type

{ TTPrompter }

  TTPrompter = class
  strict private
    FSourceTextbox: TEdit;
    FDestinationTextbox: TEdit;
    FSuggestionFormat: String;
    FOldText: String;
  public
    constructor Create(
      const ASourceTextbox: TEdit;
      const ADestinationTextbox: TEdit); overload;

    constructor Create(
      const ASourceTextbox: TEdit;
      const ADestinationTextbox: TEdit;
      const ASuggestionFormat: String); overload;

    procedure Start;
    procedure DoChanged;
  end;

implementation

{ TTPrompter }

constructor TTPrompter.Create(const ASourceTextbox, ADestinationTextbox: TEdit);
begin
  Create(ASourceTextbox, ADestinationTextbox, '%s');
end;

constructor TTPrompter.Create(
  const ASourceTextbox: TEdit;
  const ADestinationTextbox: TEdit;
  const ASuggestionFormat: String);
begin
  inherited Create;
  FSourceTextbox := ASourceTextbox;
  FDestinationTextbox := ADestinationTextbox;
  FSuggestionFormat := ASuggestionFormat;
end;

procedure TTPrompter.Start;
begin
  FOldText := FSourceTextbox.Text;
  if String(FDestinationTextbox.Text).IsEmpty then
    FDestinationTextbox.Text :=
      Format(FSuggestionFormat, [FSourceTextbox.Text]);
end;

procedure TTPrompter.DoChanged;
var
  AOldText: String;
begin
  AOldText := Format(FSuggestionFormat, [FOldText]);
  if AOldText.Equals(FDestinationTextbox.Text) then
    FDestinationTextbox.Text :=
      Format(FSuggestionFormat, [FSourceTextbox.Text]);
  FOldText := FSourceTextbox.Text;
end;

end.
