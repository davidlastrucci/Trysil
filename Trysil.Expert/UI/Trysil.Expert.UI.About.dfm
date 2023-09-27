inherited TAboutForm: TTAboutForm
  Margins.Top = 12
  ClientHeight = 215
  ClientWidth = 476
  Color = clWhite
  ExplicitWidth = 492
  ExplicitHeight = 254
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 476
    Height = 166
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 476
    ExplicitHeight = 166
    object Bevel: TBevel
      Left = 68
      Top = 78
      Width = 400
      Height = 5
      Shape = bsTopLine
    end
    object CopyrightLabel: TLabel
      Left = 72
      Top = 52
      Width = 166
      Height = 15
      Caption = 'Copyright '#169' by David Lastrucci'
    end
    object DescriptionLabel: TLabel
      Left = 72
      Top = 33
      Width = 303
      Height = 15
      Caption = 'Open source Object-relational mapping (ORM) for Delphi'
    end
    object EmailLabel: TLabel
      Left = 124
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
    object EmailLabelLabel: TLabel
      Left = 72
      Top = 110
      Width = 32
      Height = 15
      Caption = 'Email:'
    end
    object GitHubLabel: TLabel
      Left = 124
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
    object GitHubLabelLabel: TLabel
      Left = 72
      Top = 129
      Width = 41
      Height = 15
      Caption = 'GitHub:'
    end
    object TitleLabel: TLabel
      Left = 72
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
    object WebLabel: TLabel
      Left = 124
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
    object WebLabelLabel: TLabel
      Left = 72
      Top = 89
      Width = 27
      Height = 15
      Caption = 'WEB:'
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 166
    Width = 476
    TabOrder = 0
    ExplicitTop = 166
    ExplicitWidth = 476
    object CloseButton: TButton
      Left = 389
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Close'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
  end
end
