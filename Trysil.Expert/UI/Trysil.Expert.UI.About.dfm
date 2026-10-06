inherited TAboutForm: TTAboutForm
  ClientHeight = 612
  ClientWidth = 488
  Color = clWhite
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 488
    Height = 563
    object Bevel01: TBevel
      Left = 68
      Top = 129
      Width = 408
      Height = 5
      Shape = bsTopLine
    end
    object CopyrightLabel: TLabel
      Left = 72
      Top = 68
      Width = 209
      Height = 15
      Caption = 'Copyright '#169' 2019-2026, David Lastrucci'
    end
    object DescriptionLabel: TLabel
      Left = 72
      Top = 48
      Width = 303
      Height = 15
      Caption = 'Open source Object-relational mapping (ORM) for Delphi'
    end
    object EmailLabel: TLabel
      Left = 125
      Top = 463
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
      Top = 463
      Width = 32
      Height = 15
      Caption = 'Email:'
    end
    object GitHubLabel: TLabel
      Left = 125
      Top = 505
      Width = 172
      Height = 15
      Cursor = crHandPoint
      Caption = 'github.com/davidlastrucci/Trysil'
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
      Top = 505
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
      Left = 125
      Top = 442
      Width = 94
      Height = 15
      Cursor = crHandPoint
      Caption = 'www.lastrucci.net'
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
      Top = 442
      Width = 27
      Height = 15
      Caption = 'Web:'
    end
    object Bevel02: TBevel
      Left = 68
      Top = 262
      Width = 408
      Height = 5
      Shape = bsTopLine
    end
    object Trysil01Label: TLabel
      Left = 84
      Top = 160
      Width = 380
      Height = 30
      Caption = 
        'During world war II, ORM was a British operation to establish a ' +
        'reception base centred on Trysil in the eastern part of German-o' +
        'ccupied Norway.'
      WordWrap = True
    end
    object Trysil02Label: TLabel
      Left = 84
      Top = 195
      Width = 180
      Height = 15
      Caption = 'That'#39's why I called Trysil my ORM!'
    end
    object Trysil03Label: TLabel
      Left = 84
      Top = 216
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
      Top = 237
      Width = 168
      Height = 15
      Cursor = crHandPoint
      Caption = 'codenames.info/operation/orm'
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
      Top = 431
      Width = 408
      Height = 5
      Shape = bsTopLine
    end
    object SupportedDatabaseLabel: TLabel
      Left = 72
      Top = 273
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
      Top = 292
      Width = 72
      Height = 15
      Caption = '- Firebird SQL'
    end
    object MSSQLLabel: TLabel
      Left = 84
      Top = 387
      Width = 64
      Height = 15
      Caption = '- SQL Server'
    end
    object PostgreSQLLabel: TLabel
      Left = 84
      Top = 368
      Width = 69
      Height = 15
      Caption = '- PostgreSQL'
    end
    object SQLiteLabel: TLabel
      Left = 84
      Top = 406
      Width = 42
      Height = 15
      Caption = '- SQLite'
    end
    object Trysil00Label: TLabel
      Left = 72
      Top = 140
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
    object VersionLabel: TLabel
      Left = 72
      Top = 32
      Width = 61
      Height = 15
      Caption = 'Version 2.1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object OracleLabel: TLabel
      Left = 84
      Top = 349
      Width = 42
      Height = 15
      Caption = '- Oracle'
    end
    object InterbaseLabel: TLabel
      Left = 84
      Top = 311
      Width = 56
      Height = 15
      Caption = '- InterBase'
    end
    object MariaDBLabel: TLabel
      Left = 84
      Top = 330
      Width = 53
      Height = 15
      Caption = '- MariaDB'
    end
    object BLogLabelLabel: TLabel
      Left = 72
      Top = 526
      Width = 27
      Height = 15
      Caption = 'Blog:'
    end
    object BlogLabel: TLabel
      Left = 125
      Top = 526
      Width = 92
      Height = 15
      Cursor = crHandPoint
      Caption = 'trysil.lastrucci.net'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = BlogLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object LicenceLabelLabel: TLabel
      Left = 72
      Top = 104
      Width = 42
      Height = 15
      Caption = 'License:'
    end
    object LicenceLabel: TLabel
      Left = 125
      Top = 104
      Width = 111
      Height = 15
      Cursor = crHandPoint
      Caption = 'BSD-3-Clause license'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = LicenceLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object DocsLabelLabel: TLabel
      Left = 72
      Top = 484
      Width = 29
      Height = 15
      Caption = 'Docs:'
    end
    object DocsLabel: TLabel
      Left = 125
      Top = 484
      Width = 156
      Height = 15
      Cursor = crHandPoint
      Caption = 'davidlastrucci.github.io/Trysil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = DocsLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object AllRightsLabel: TLabel
      Left = 72
      Top = 84
      Width = 97
      Height = 15
      Caption = 'All rights reserved.'
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 563
    Width = 488
    object CloseButton: TButton
      Left = 401
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
