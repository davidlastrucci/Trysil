object TThemedForm: TTThemedForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object ContentPanel: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 392
    Align = alClient
    BevelOuter = bvNone
    Caption = 'ContentPanel'
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    StyleElements = [seFont, seBorder]
    ExplicitLeft = 228
    ExplicitTop = 220
    ExplicitWidth = 185
    ExplicitHeight = 41
    object TrysilImage: TImage
      Left = 12
      Top = 12
      Width = 48
      Height = 48
    end
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 392
    Width = 624
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'ButtonsPanel'
    Padding.Left = 12
    Padding.Top = 12
    Padding.Right = 12
    Padding.Bottom = 12
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    StyleElements = [seFont, seBorder]
    ExplicitTop = 400
  end
end
