inherited TReferenceDatabaseForm: TTReferenceDatabaseForm
  Caption = 'Reference database'
  ClientHeight = 294
  ClientWidth = 465
  Color = clWhite
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 465
    Height = 245
    object HostLabel: TLabel
      Left = 73
      Top = 16
      Width = 28
      Height = 15
      Caption = 'Host:'
    end
    object PortLabel: TLabel
      Left = 385
      Top = 16
      Width = 25
      Height = 15
      Caption = 'Port:'
    end
    object DatabaseLabel: TLabel
      Left = 73
      Top = 178
      Width = 84
      Height = 15
      Caption = 'Database name:'
    end
    object UsernameLabel: TLabel
      Left = 73
      Top = 70
      Width = 56
      Height = 15
      Caption = 'Username:'
    end
    object PasswordLabel: TLabel
      Left = 73
      Top = 124
      Width = 53
      Height = 15
      Caption = 'Password:'
    end
    object HostTextbox: TEdit
      Left = 73
      Top = 37
      Width = 304
      Height = 23
      TabOrder = 0
    end
    object PortTextbox: TEdit
      Left = 385
      Top = 37
      Width = 68
      Height = 23
      NumbersOnly = True
      TabOrder = 1
      Text = '0'
    end
    object DatabaseTextbox: TEdit
      Left = 73
      Top = 199
      Width = 352
      Height = 23
      TabOrder = 4
    end
    object DatabaseButton: TButton
      Left = 429
      Top = 199
      Width = 24
      Height = 23
      Caption = '...'
      TabOrder = 5
      OnClick = DatabaseButtonClick
    end
    object UsernameTextbox: TEdit
      Left = 73
      Top = 91
      Width = 380
      Height = 23
      TabOrder = 2
    end
    object PasswordTextbox: TEdit
      Left = 73
      Top = 145
      Width = 380
      Height = 23
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 245
    Width = 465
    object CancelButton: TButton
      Left = 378
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 537
    end
    object GenerateButton: TButton
      AlignWithMargins = True
      Left = 299
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Generate'
      Default = True
      TabOrder = 0
      OnClick = GenerateButtonClick
      ExplicitLeft = 458
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'SQLite databases|*.db;*.sqlite;*.sqlite3;*.db3|All files|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 64
  end
  object WaitCursor: TFDGUIxWaitCursor
    Provider = 'Console'
    ScreenCursor = gcrNone
    Left = 8
    Top = 92
  end
end
