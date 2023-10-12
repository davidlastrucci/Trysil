inherited TAPIRestForm: TTAPIRestForm
  TextHeight = 15
  inherited ContentPanel: TPanel
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 624
    ExplicitHeight = 392
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
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
      end
    end
    object DatabasePagePanel: TPanel
      AlignWithMargins = True
      Left = 358
      Top = 152
      Width = 230
      Height = 229
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object DatabasePageGroupBox: TGroupBox
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
        Caption = 'Database  '
        TabOrder = 0
        ExplicitHeight = 361
        object DBConnectionNameLabel: TLabel
          Left = 24
          Top = 28
          Width = 98
          Height = 15
          Caption = 'Connection name:'
        end
        object DBHostLabel: TLabel
          Left = 24
          Top = 82
          Width = 28
          Height = 15
          Caption = 'Host:'
        end
        object DBUsernameLabel: TLabel
          Left = 24
          Top = 132
          Width = 56
          Height = 15
          Caption = 'Username:'
        end
        object DBPasswordLabel: TLabel
          Left = 24
          Top = 182
          Width = 53
          Height = 15
          Caption = 'Password:'
        end
        object DBDatabaseNameLabel: TLabel
          Left = 24
          Top = 232
          Width = 84
          Height = 15
          Caption = 'Database name:'
        end
        object DBConnectionNameTextbox: TEdit
          Left = 24
          Top = 49
          Width = 497
          Height = 23
          TabOrder = 0
        end
        object DBHostTextbox: TEdit
          Left = 24
          Top = 103
          Width = 497
          Height = 23
          TabOrder = 1
        end
        object DBUsernameTextbox: TEdit
          Left = 24
          Top = 153
          Width = 497
          Height = 23
          TabOrder = 2
        end
        object DBPasswordTextbox: TEdit
          Left = 24
          Top = 203
          Width = 497
          Height = 23
          PasswordChar = '*'
          TabOrder = 3
        end
        object DBDatabaseNameTextbox: TEdit
          Left = 24
          Top = 253
          Width = 497
          Height = 23
          TabOrder = 4
        end
      end
    end
    object ProjectPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 232
      Height = 149
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
        Height = 141
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Project  '
        TabOrder = 0
        ExplicitWidth = 163
        ExplicitHeight = 180
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
        ExplicitLeft = 222
        ExplicitTop = 8
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
  end
  inherited ButtonsPanel: TPanel
    ExplicitTop = 392
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
