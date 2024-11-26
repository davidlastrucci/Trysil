inherited TAPIRestForm: TTAPIRestForm
  StyleElements = [seFont, seClient, seBorder]
  TextHeight = 15
  inherited ContentPanel: TPanel
    StyleElements = [seFont, seBorder]
    object APIPagePanel: TPanel
      AlignWithMargins = True
      Left = 72
      Top = 152
      Width = 230
      Height = 229
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object APIPageGroupbox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 226
        Height = 221
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'API REST  '
        TabOrder = 0
        object APIBaseUriLabel: TLabel
          Left = 24
          Top = 28
          Width = 45
          Height = 15
          Caption = 'Base Uri:'
        end
        object APIPortLabel: TLabel
          Left = 24
          Top = 78
          Width = 25
          Height = 15
          Caption = 'Port:'
        end
        object APIUrlLabel: TLabel
          Left = 24
          Top = 128
          Width = 112
          Height = 15
          Caption = 'http://127.0.0.1:4450/'
        end
        object APIBaseUriTextbox: TEdit
          Left = 24
          Top = 49
          Width = 141
          Height = 23
          TabOrder = 0
          OnChange = CalculateUrlLabel
        end
        object APIPortTextbox: TEdit
          Left = 24
          Top = 99
          Width = 69
          Height = 23
          NumbersOnly = True
          TabOrder = 1
          Text = '4450'
          OnChange = CalculateUrlLabel
        end
        object APIAuthorizationCheckbox: TCheckBox
          Left = 24
          Top = 153
          Width = 97
          Height = 17
          Caption = 'Authorization'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object APILogCheckbox: TCheckBox
          Left = 24
          Top = 176
          Width = 97
          Height = 17
          Caption = 'Log'
          TabOrder = 3
        end
      end
    end
    object ServicePagePanel: TPanel
      AlignWithMargins = True
      Left = 358
      Top = 8
      Width = 232
      Height = 149
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 3
      object ServicePageGroupBox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 228
        Height = 141
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Service  '
        TabOrder = 0
        object ServiceNameLabel: TLabel
          Left = 24
          Top = 28
          Width = 35
          Height = 15
          Caption = 'Name:'
        end
        object ServiceDisplayNameLabel: TLabel
          Left = 24
          Top = 78
          Width = 74
          Height = 15
          Caption = 'Display name:'
        end
        object ServiceDescriptionLabel: TLabel
          Left = 24
          Top = 128
          Width = 63
          Height = 15
          Caption = 'Description:'
        end
        object ServiceNameTextbox: TEdit
          Left = 24
          Top = 49
          Width = 497
          Height = 23
          TabOrder = 0
        end
        object ServiceDisplayNameTextbox: TEdit
          Left = 24
          Top = 99
          Width = 497
          Height = 23
          TabOrder = 1
        end
        object ServiceDescriptionTextbox: TEdit
          Left = 24
          Top = 148
          Width = 497
          Height = 23
          TabOrder = 2
        end
      end
    end
    object ProjectPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 232
      Height = 175
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object ProjectPageGroupBox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 228
        Height = 167
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Project  '
        TabOrder = 0
        object ProjectDirectoryLabel: TLabel
          Left = 24
          Top = 28
          Width = 51
          Height = 15
          Caption = 'Directory:'
        end
        object ProjectNameLabel: TLabel
          Left = 24
          Top = 78
          Width = 73
          Height = 15
          Caption = 'Project name:'
        end
        object ProjectNameButton: TSpeedButton
          Left = 494
          Top = 97
          Width = 27
          Height = 27
          Hint = 'Select new project'
          Flat = True
          Glyph.Data = {
            F6060000424DF606000000000000360000002800000018000000180000000100
            180000000000C006000000000000000000000000000000000000FF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF82C2EA82C2EA82C2EA82
            C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA
            CFE7F6FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF82C2
            EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82
            C2EA82C2EA82C2EAADD7F0FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FF82C2EA9ED0EF82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2
            EA82C2EA82C2EA82C2EA82C2EA82C2EA8EC7EBFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FF82C2EAD3E9F882C2EA82C2EA82C2EA82C2EA
            82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EAE9F4FBFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF82C2EAFCFEFF8EC8EC82
            C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA
            82C2EACBE5F5FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF82C2
            EAFFFFFFC1E1F582C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82
            C2EA82C2EA82C2EA82C2EAA9D4F0FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FF82C2EAFFFFFFF3F9FD85C3EA82C2EA82C2EA82C2EA82C2EA82C2
            EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA8BC6EBFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FF82C2EAFFFFFFFFFFFFCDE7F785C3EA82C2EA
            82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EA82C2EAA6D3EFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF82C2EAFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF82C2EA
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF82C2
            EAD6EBF8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFF82C2EAFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFCDE6F684C2E982C2EA82C2EA82C2EA82C2EA82C2EA82C2EAA7D4
            EFFEFEFFFFFFFFFFFFFFFFFFFF82C2EAFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFAFCFDA1D1EFB5DAF1FFFFFFFFFFFFFFFFFF82C2EAFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFF7FAFD98CCED82C2EA82C2EA82C2EAB0D8F1
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
            FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
            FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
            00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
          ParentShowHint = False
          ShowHint = True
          OnClick = ProjectNameButtonClick
        end
        object ProjectDirectoryTextbox: TEdit
          Left = 24
          Top = 49
          Width = 497
          Height = 23
          TabOrder = 0
        end
        object ProjectNameTextBox: TEdit
          Left = 24
          Top = 99
          Width = 468
          Height = 23
          TabOrder = 1
        end
        object ProjectModelFromHttpCheckbox: TCheckBox
          Left = 24
          Top = 136
          Width = 165
          Height = 17
          Caption = 'Load model from HTTP'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
      end
    end
    object TenantDatabasePagePanel: TPanel
      AlignWithMargins = True
      Left = 358
      Top = 161
      Width = 230
      Height = 88
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 4
      object TenantDatabasePageGroupBox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 226
        Height = 80
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Tenant (localhost) database  '
        TabOrder = 0
        object TenantConnectionNameLabel: TLabel
          Left = 24
          Top = 78
          Width = 98
          Height = 15
          Caption = 'Connection name:'
        end
        object TenantHostLabel: TLabel
          Left = 23
          Top = 128
          Width = 28
          Height = 15
          Caption = 'Host:'
        end
        object TenantUsernameLabel: TLabel
          Left = 24
          Top = 178
          Width = 56
          Height = 15
          Caption = 'Username:'
        end
        object TenantPasswordLabel: TLabel
          Left = 24
          Top = 228
          Width = 53
          Height = 15
          Caption = 'Password:'
        end
        object TenantDatabaseNameLabel: TLabel
          Left = 24
          Top = 278
          Width = 84
          Height = 15
          Caption = 'Database name:'
        end
        object TenantDriverLabel: TLabel
          Left = 24
          Top = 28
          Width = 77
          Height = 15
          Caption = 'Database type:'
        end
        object TenantPortLabel: TLabel
          Left = 452
          Top = 128
          Width = 25
          Height = 15
          Caption = 'Port:'
        end
        object TenantConnectionNameTextbox: TEdit
          Left = 24
          Top = 99
          Width = 497
          Height = 23
          TabOrder = 1
          Text = 'api_localhost'
        end
        object TenantHostTextbox: TEdit
          Left = 23
          Top = 149
          Width = 423
          Height = 23
          TabOrder = 2
        end
        object TenantUsernameTextbox: TEdit
          Left = 24
          Top = 199
          Width = 497
          Height = 23
          TabOrder = 4
        end
        object TenantPasswordTextbox: TEdit
          Left = 24
          Top = 249
          Width = 497
          Height = 23
          PasswordChar = '*'
          TabOrder = 5
        end
        object TenantDatabaseNameTextbox: TEdit
          Left = 23
          Top = 299
          Width = 497
          Height = 23
          TabOrder = 6
        end
        object TenantDriverCombobox: TComboBox
          Left = 24
          Top = 49
          Width = 497
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'Firebird'
          OnClick = TenantDriverComboboxClick
          Items.Strings = (
            'Firebird'
            'Microsoft SQL Server'
            'PostgreSQL'
            'SQLite')
        end
        object TenantPortTextbox: TEdit
          Left = 452
          Top = 149
          Width = 69
          Height = 23
          Enabled = False
          NumbersOnly = True
          TabOrder = 3
          Text = '4450'
          OnChange = CalculateUrlLabel
        end
      end
    end
    object LogDatabasePagePanel: TPanel
      AlignWithMargins = True
      Left = 358
      Top = 270
      Width = 230
      Height = 88
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object LogDatabasePageGroupBox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 226
        Height = 80
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'HTTP Log database  '
        TabOrder = 0
        object LogConnectionNameLabel: TLabel
          Left = 25
          Top = 78
          Width = 98
          Height = 15
          Caption = 'Connection name:'
        end
        object LogHostLabel: TLabel
          Left = 25
          Top = 128
          Width = 28
          Height = 15
          Caption = 'Host:'
        end
        object LogUsernameLabel: TLabel
          Left = 24
          Top = 177
          Width = 56
          Height = 15
          Caption = 'Username:'
        end
        object LogPasswordLabel: TLabel
          Left = 24
          Top = 227
          Width = 53
          Height = 15
          Caption = 'Password:'
        end
        object LogDatabaseNameLabel: TLabel
          Left = 24
          Top = 277
          Width = 84
          Height = 15
          Caption = 'Database name:'
        end
        object LogDriverLabel: TLabel
          Left = 24
          Top = 28
          Width = 77
          Height = 15
          Caption = 'Database type:'
        end
        object LogPortLabel: TLabel
          Left = 452
          Top = 127
          Width = 25
          Height = 15
          Caption = 'Port:'
        end
        object LogConnectionNameTextbox: TEdit
          Left = 24
          Top = 99
          Width = 497
          Height = 23
          TabOrder = 1
          Text = 'api_http_log'
        end
        object LogHostTextbox: TEdit
          Left = 25
          Top = 148
          Width = 421
          Height = 23
          TabOrder = 2
        end
        object LogUsernameTextbox: TEdit
          Left = 24
          Top = 198
          Width = 497
          Height = 23
          TabOrder = 4
        end
        object LogPasswordTextbox: TEdit
          Left = 24
          Top = 248
          Width = 497
          Height = 23
          PasswordChar = '*'
          TabOrder = 5
        end
        object LogDatabaseNameTextbox: TEdit
          Left = 24
          Top = 298
          Width = 497
          Height = 23
          TabOrder = 6
        end
        object LogDriverCombobox: TComboBox
          Left = 24
          Top = 49
          Width = 497
          Height = 23
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'Firebird'
          OnClick = LogDriverComboboxClick
          Items.Strings = (
            'Firebird'
            'Microsoft SQL Server'
            'PostgreSQL'
            'SQLite')
        end
        object LogPortTextbox: TEdit
          Left = 452
          Top = 148
          Width = 69
          Height = 23
          Enabled = False
          NumbersOnly = True
          TabOrder = 3
          Text = '0'
          OnChange = CalculateUrlLabel
        end
      end
    end
    object DBDriverListbox: TListBox
      Left = 13
      Top = 116
      Width = 47
      Height = 67
      ItemHeight = 15
      Items.Strings = (
        'FB'
        'MSSQL'
        'PG'
        'SQLite')
      TabOrder = 5
      Visible = False
    end
  end
  inherited ButtonsPanel: TPanel
    StyleElements = [seFont, seBorder]
    object CancelButton: TButton
      Left = 537
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object FinishButton: TButton
      AlignWithMargins = True
      Left = 458
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Finish'
      Default = True
      Enabled = False
      TabOrder = 2
      OnClick = FinishButtonClick
    end
    object BackButton: TButton
      AlignWithMargins = True
      Left = 72
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 60
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = '&Back'
      Enabled = False
      TabOrder = 0
      OnClick = BackButtonClick
    end
    object NextButton: TButton
      AlignWithMargins = True
      Left = 151
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = '&Next'
      Default = True
      TabOrder = 1
      OnClick = NextButtonClick
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'dproj'
    Filter = 'Delphi project|*.dproj|All files|*.*'
    FilterIndex = 0
    Left = 12
    Top = 72
  end
end
