inherited TSettingsForm: TTSettingsForm
  ClientHeight = 302
  ClientWidth = 509
  Color = clWhite
  ExplicitWidth = 525
  ExplicitHeight = 341
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 509
    Height = 253
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 509
    ExplicitHeight = 248
    object TrysilGroupbox: TGroupBox
      Left = 72
      Top = 12
      Width = 425
      Height = 89
      Caption = 'Trysil  '
      TabOrder = 0
      object TrysilDirectoryLabel: TLabel
        Left = 24
        Top = 28
        Width = 51
        Height = 15
        Caption = 'Directory:'
      end
      object TrysilDirectoryTextbox: TEdit
        Left = 24
        Top = 49
        Width = 380
        Height = 23
        TabOrder = 0
        Text = '__trysil'
      end
    end
    object EntitiesGroupbox: TGroupBox
      Left = 72
      Top = 107
      Width = 425
      Height = 138
      Caption = 'Entities  '
      TabOrder = 1
      object ModelDirectoryLabel: TLabel
        Left = 24
        Top = 28
        Width = 51
        Height = 15
        Caption = 'Directory:'
      end
      object UnitFilenamesLabel: TLabel
        Left = 24
        Top = 78
        Width = 79
        Height = 15
        Caption = 'Unit filenames:'
      end
      object ModelDirectoryTextbox: TEdit
        Left = 24
        Top = 49
        Width = 380
        Height = 23
        TabOrder = 0
        Text = 'Model'
      end
      object UnitFilenamesTextbox: TEdit
        Left = 24
        Top = 99
        Width = 380
        Height = 23
        TabOrder = 1
        Text = '{ProjectName}.Model.{EntityName}'
      end
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 253
    Width = 509
    ExplicitTop = 248
    ExplicitWidth = 509
    object CancelButton: TButton
      Left = 422
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object SaveButton: TButton
      AlignWithMargins = True
      Left = 343
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Save'
      Default = True
      TabOrder = 0
      OnClick = SaveButtonClick
    end
  end
end
