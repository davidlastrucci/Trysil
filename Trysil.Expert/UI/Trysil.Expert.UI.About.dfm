inherited TAboutForm: TTAboutForm
  Margins.Top = 12
  ClientHeight = 463
  ClientWidth = 492
  Color = clWhite
  ExplicitWidth = 508
  ExplicitHeight = 502
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 492
    Height = 414
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 476
    ExplicitHeight = 166
    object Bevel01: TBevel
      Left = 68
      Top = 76
      Width = 408
      Height = 5
      Shape = bsTopLine
    end
    object CopyrightLabel: TLabel
      Left = 72
      Top = 50
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
      Top = 355
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
      ParentShowHint = False
      ShowHint = False
      OnClick = EmailLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object EmailLabelLabel: TLabel
      Left = 72
      Top = 355
      Width = 32
      Height = 15
      Caption = 'Email:'
    end
    object GitHubLabel: TLabel
      Left = 124
      Top = 376
      Width = 215
      Height = 15
      Cursor = crHandPoint
      Caption = 'https://github.com/davidlastrucci/trysil/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = GitHubLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object GitHubLabelLabel: TLabel
      Left = 72
      Top = 376
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
      Top = 334
      Width = 139
      Height = 15
      Cursor = crHandPoint
      Caption = 'https://www.lastrucci.net/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = WebLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object WebLabelLabel: TLabel
      Left = 72
      Top = 334
      Width = 27
      Height = 15
      Caption = 'WEB:'
    end
    object Bevel02: TBevel
      Left = 68
      Top = 212
      Width = 408
      Height = 5
      Shape = bsTopLine
    end
    object Trysil01Label: TLabel
      Left = 84
      Top = 107
      Width = 380
      Height = 45
      Caption = 
        'During world war II, ORM was a British operation to establish a ' +
        'reception base centred on Trysil in the eastern part of German-o' +
        'ccupied Norway.'
      WordWrap = True
    end
    object Trysil02Label: TLabel
      Left = 84
      Top = 142
      Width = 178
      Height = 15
      Caption = 'That'#39's why I called Trysil my ORM!'
    end
    object Trysil03Label: TLabel
      Left = 84
      Top = 163
      Width = 118
      Height = 15
      Caption = 'Trysil Operation ORM'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Trysil04Label: TLabel
      Left = 84
      Top = 184
      Width = 208
      Height = 15
      Cursor = crHandPoint
      Caption = 'https://codenames.info/operation/orm'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = Trysil04LabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object Bevel03: TBevel
      Left = 68
      Top = 323
      Width = 408
      Height = 5
      Shape = bsTopLine
    end
    object SupportedDatabaseLabel: TLabel
      Left = 72
      Top = 223
      Width = 119
      Height = 15
      Caption = 'Supported databases:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object FirebirdLabel: TLabel
      Left = 84
      Top = 242
      Width = 72
      Height = 15
      Caption = '- Firebird SQL'
    end
    object MSSQLLabel: TLabel
      Left = 84
      Top = 261
      Width = 118
      Height = 15
      Caption = '- Microsoft SQL Server'
    end
    object PostgreSQLLabel: TLabel
      Left = 84
      Top = 280
      Width = 69
      Height = 15
      Caption = '- PostgreSQL'
    end
    object SQLiteLabel: TLabel
      Left = 84
      Top = 299
      Width = 42
      Height = 15
      Caption = '- SQLite'
    end
    object Trysil00Label: TLabel
      Left = 72
      Top = 87
      Width = 61
      Height = 15
      Caption = 'Why Trysil?'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 414
    Width = 492
    TabOrder = 0
    ExplicitTop = 166
    ExplicitWidth = 476
    object CloseButton: TButton
      Left = 405
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Close'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 389
    end
  end
end
