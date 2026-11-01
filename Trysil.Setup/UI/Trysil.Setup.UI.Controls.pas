(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.UI.Controls;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Trysil.Setup.Consts,
  Trysil.Setup.Delphi;

const
  SidebarColor = TColor($0016110E);
  SidebarTextColor = TColor($00D9D1C9);
  MutedColor = TColor($009E948B);
  AccentBrightColor = TColor($00EED322);
  DoneBadgeColor = TColor($00634E16);
  DoneGlyphColor = TColor($00F9E867);
  TodoBadgeColor = TColor($002D2621);
  AccentColor = TColor($0090740E);
  SelectedColor = TColor($00FFFEEC);
  BorderColor = TColor($00EBE7E5);
  SecondaryTextColor = TColor($0063554B);
  ErrorColor = TColor($002020B8);
  ChipColor = TColor($00F6F4F3);
  ChipTextColor = TColor($00514137);
  PackagesChipColor = TColor($00FEFACF);
  PackagesChipTextColor = TColor($00755E15);
  SourcesChipColor = TColor($00C7F3FE);
  SourcesChipTextColor = TColor($000E4092);

  StepDoneGlyph = #$2713;

type

{ TTSetupStepState }

  TTSetupStepState = (Todo, Current, Done);

{ TTSetupStep }

  TTSetupStep = class
  strict private
    FPanel: TPanel;
    FBadge: TLabel;
    FCaption: TLabel;

    procedure Paint(
      const ABadge: String;
      const ABackColor: TColor;
      const ABadgeColor: TColor;
      const ACaptionColor: TColor);
  public
    constructor Create(
      const APanel: TPanel;
      const ABadge: TLabel;
      const ACaption: TLabel);

    procedure Show(const AState: TTSetupStepState);
    procedure Hide;
  end;

{ TTSetupCard }

  TTSetupCard = class
  strict private
    FBorder: TPanel;
    FContent: TPanel;
    FRadio: TRadioButton;
    FDescription: TLabel;

    procedure ContentClick(Sender: TObject);
  public
    constructor Create(
      const ABorder: TPanel;
      const AContent: TPanel;
      const ARadio: TRadioButton;
      const ADescription: TLabel);

    procedure Select(const ASelected: TObject);
  end;

{ TTVersionItemPainter }

  TTVersionItemPainter = class
  strict private
    FCanvas: TCanvas;
    FRect: TRect;
    FSpacing: Integer;
    FRight: Integer;

    procedure PaintChip(
      const AText: String;
      const ABackColor: TColor;
      const ATextColor: TColor;
      const AStyle: TFontStyles);
    procedure PaintPlatforms(const APlatforms: TArray<String>);
    procedure PaintPath(const ACanBuild: Boolean);
  public
    constructor Create(const ACanvas: TCanvas; const ARect: TRect);

    procedure Paint(const AVersion: TTDelphiVersion);
  end;

{ TTVersionCard }

  TTVersionCard = class
  strict private
    FCard: TPanel;
    FContent: TPanel;
    FCheckbox: TCheckBox;
    FPaintBox: TPaintBox;
    FVersion: TTDelphiVersion;

    procedure PaintBoxPaint(Sender: TObject);
    procedure CheckboxClick(Sender: TObject);
    procedure PaintSelection;
  public
    constructor Create(
      const ACard: TPanel;
      const AContent: TPanel;
      const ACheckbox: TCheckBox;
      const APaintBox: TPaintBox);

    procedure Bind(const AVersion: TTDelphiVersion);
    function Checked: Boolean;

    property Version: TTDelphiVersion read FVersion;
  end;

implementation

{ TTSetupStep }

constructor TTSetupStep.Create(
  const APanel: TPanel;
  const ABadge: TLabel;
  const ACaption: TLabel);
begin
  inherited Create;
  FPanel := APanel;
  FBadge := ABadge;
  FCaption := ACaption;
end;

procedure TTSetupStep.Paint(
  const ABadge: String;
  const ABackColor: TColor;
  const ABadgeColor: TColor;
  const ACaptionColor: TColor);
begin
  FBadge.Caption := ABadge;
  FBadge.Color := ABackColor;
  FBadge.Font.Color := ABadgeColor;
  FCaption.Font.Color := ACaptionColor;
end;

procedure TTSetupStep.Show(const AState: TTSetupStepState);
begin
  FPanel.Visible := True;
  FPanel.Top := FPanel.Parent.ClientHeight;
  FCaption.Font.Style := [];
  case AState of
    TTSetupStepState.Done:
      Paint(StepDoneGlyph, DoneBadgeColor, DoneGlyphColor, SidebarTextColor);
    TTSetupStepState.Current:
    begin
      Paint(String.Empty, AccentBrightColor, SidebarColor, clWhite);
      FCaption.Font.Style := [TFontStyle.fsBold];
    end;
    TTSetupStepState.Todo:
      Paint(String.Empty, TodoBadgeColor, MutedColor, MutedColor);
  end;
end;

procedure TTSetupStep.Hide;
begin
  FPanel.Visible := False;
end;

{ TTSetupCard }

constructor TTSetupCard.Create(
  const ABorder: TPanel;
  const AContent: TPanel;
  const ARadio: TRadioButton;
  const ADescription: TLabel);
begin
  inherited Create;
  FBorder := ABorder;
  FContent := AContent;
  FRadio := ARadio;
  FDescription := ADescription;
  FContent.OnClick := ContentClick;
  FDescription.OnClick := ContentClick;
end;

procedure TTSetupCard.ContentClick(Sender: TObject);
begin
  if FRadio.Enabled then
    FRadio.Checked := True;
end;

procedure TTSetupCard.Select(const ASelected: TObject);
begin
  FRadio.Checked := (FRadio = ASelected);
  if FRadio.Checked then
  begin
    FBorder.Color := AccentColor;
    FContent.Color := SelectedColor;
  end
  else
  begin
    FBorder.Color := BorderColor;
    FContent.Color := clWhite;
  end;
  FDescription.Enabled := FRadio.Enabled;
end;

{ TTVersionItemPainter }

constructor TTVersionItemPainter.Create(
  const ACanvas: TCanvas; const ARect: TRect);
begin
  inherited Create;
  FCanvas := ACanvas;
  FRect := ARect;
end;

procedure TTVersionItemPainter.PaintChip(
  const AText: String;
  const ABackColor: TColor;
  const ATextColor: TColor;
  const AStyle: TFontStyles);
var
  LText: String;
  LRect: TRect;
  LHeight: Integer;
begin
  LText := AText;
  FCanvas.Font.Style := AStyle;
  FCanvas.Font.Color := ATextColor;
  FCanvas.Brush.Color := ABackColor;
  LHeight := FCanvas.TextHeight(LText) + FSpacing div 2;
  LRect := TRect.Create(
    FRight - FCanvas.TextWidth(LText) - FSpacing * 2,
    FRect.CenterPoint.Y - LHeight div 2,
    FRight,
    FRect.CenterPoint.Y - LHeight div 2 + LHeight);
  FCanvas.FillRect(LRect);
  FCanvas.TextRect(LRect, LText, [tfCenter, tfVerticalCenter, tfSingleLine]);
  FRight := LRect.Left - FSpacing div 2;
end;

procedure TTVersionItemPainter.PaintPlatforms(
  const APlatforms: TArray<String>);
var
  LIndex: Integer;
begin
  for LIndex := High(APlatforms) downto 0 do
    PaintChip(APlatforms[LIndex], ChipColor, ChipTextColor, []);
end;

procedure TTVersionItemPainter.PaintPath(const ACanBuild: Boolean);
begin
  if ACanBuild then
    PaintChip(
      SPackagesChip,
      PackagesChipColor,
      PackagesChipTextColor,
      [TFontStyle.fsBold])
  else
    PaintChip(
      SSourcesChip,
      SourcesChipColor,
      SourcesChipTextColor,
      [TFontStyle.fsBold]);
end;

procedure TTVersionItemPainter.Paint(const AVersion: TTDelphiVersion);
begin
  FSpacing := FCanvas.TextHeight(SMeasureText) div 2;
  FRight := FRect.Right - FSpacing;
  PaintPlatforms(AVersion.Platforms);
  PaintPath(AVersion.CanBuild);
end;

{ TTVersionCard }

constructor TTVersionCard.Create(
  const ACard: TPanel;
  const AContent: TPanel;
  const ACheckbox: TCheckBox;
  const APaintBox: TPaintBox);
begin
  inherited Create;
  FCard := ACard;
  FContent := AContent;
  FCheckbox := ACheckbox;
  FPaintBox := APaintBox;
  FVersion := nil;
  FPaintBox.OnPaint := PaintBoxPaint;
  FCheckbox.OnClick := CheckboxClick;
end;

procedure TTVersionCard.PaintBoxPaint(Sender: TObject);
var
  LPainter: TTVersionItemPainter;
begin
  if Assigned(FVersion) then
  begin
    LPainter := TTVersionItemPainter.Create(
      FPaintBox.Canvas, FPaintBox.ClientRect);
    try
      LPainter.Paint(FVersion);
    finally
      LPainter.Free;
    end;
  end;
end;

procedure TTVersionCard.CheckboxClick(Sender: TObject);
begin
  PaintSelection;
end;

procedure TTVersionCard.PaintSelection;
begin
  if FCheckbox.Checked then
  begin
    FCard.Color := AccentColor;
    FContent.Color := SelectedColor;
  end
  else
  begin
    FCard.Color := BorderColor;
    FContent.Color := clWhite;
  end;
  FPaintBox.Invalidate;
end;

procedure TTVersionCard.Bind(const AVersion: TTDelphiVersion);
begin
  FVersion := AVersion;
  FCard.Visible := Assigned(FVersion);
  if Assigned(FVersion) then
  begin
    FCheckbox.Caption := FVersion.Name;
    FCheckbox.Checked := True;
    PaintSelection;
  end;
end;

function TTVersionCard.Checked: Boolean;
begin
  result := Assigned(FVersion) and FCheckbox.Checked;
end;

end.
