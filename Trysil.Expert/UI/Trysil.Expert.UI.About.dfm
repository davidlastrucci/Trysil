object TAboutForm: TTAboutForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 194
  ClientWidth = 472
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object TrysilImage: TImage
    Left = 8
    Top = 8
    Width = 48
    Height = 48
  end
  object TitleLabel: TLabel
    Left = 68
    Top = 16
    Width = 106
    Height = 15
    Caption = 'Trysil - Delphi ORM'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object CopyrightLabel: TLabel
    Left = 68
    Top = 52
    Width = 166
    Height = 15
    Caption = 'Copyright '#169' by David Lastrucci'
  end
  object Bevel: TBevel
    Left = 64
    Top = 78
    Width = 400
    Height = 5
    Shape = bsTopLine
  end
  object WebLabelLabel: TLabel
    Left = 68
    Top = 91
    Width = 27
    Height = 15
    Caption = 'WEB:'
  end
  object WebLabel: TLabel
    Left = 120
    Top = 91
    Width = 134
    Height = 15
    Cursor = crHandPoint
    Caption = 'https://www.lastrucci.net'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    OnClick = WebLabelClick
    OnMouseEnter = HyperLinkOn
    OnMouseLeave = HyperLinkOff
  end
  object EmailLabelLabel: TLabel
    Left = 68
    Top = 110
    Width = 32
    Height = 15
    Caption = 'Email:'
  end
  object EmailLabel: TLabel
    Left = 120
    Top = 110
    Width = 144
    Height = 15
    Cursor = crHandPoint
    Caption = 'david.lastrucci@gmail.com'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    OnClick = EmailLabelClick
    OnMouseEnter = HyperLinkOn
    OnMouseLeave = HyperLinkOff
  end
  object GitHubLabelLabel: TLabel
    Left = 68
    Top = 129
    Width = 41
    Height = 15
    Caption = 'GitHub:'
  end
  object GitHubLabel: TLabel
    Left = 120
    Top = 129
    Width = 210
    Height = 15
    Cursor = crHandPoint
    Caption = 'https://github.com/davidlastrucci/trysil'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    OnClick = GitHubLabelClick
    OnMouseEnter = HyperLinkOn
    OnMouseLeave = HyperLinkOff
  end
  object DescriptionLabel: TLabel
    Left = 68
    Top = 33
    Width = 303
    Height = 15
    Caption = 'Open source Object-relational mapping (ORM) for Delphi'
  end
  object CloseButton: TButton
    Left = 378
    Top = 155
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
