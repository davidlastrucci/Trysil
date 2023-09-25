object TSettingsForm: TTSettingsForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 219
  ClientWidth = 459
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
  object ModelDirectoryLabel: TLabel
    Left = 68
    Top = 70
    Width = 87
    Height = 15
    Caption = 'Model directory:'
  end
  object UnitFilenamesLabel: TLabel
    Left = 68
    Top = 120
    Width = 79
    Height = 15
    Caption = 'Unit filenames:'
  end
  object TrysilDirectoryLabel: TLabel
    Left = 68
    Top = 16
    Width = 79
    Height = 15
    Caption = 'Trysil directory:'
  end
  object ModelDirectoryTextbox: TEdit
    Left = 68
    Top = 91
    Width = 380
    Height = 23
    TabOrder = 1
    Text = 'Model'
  end
  object UnitFilenamesTextbox: TEdit
    Left = 68
    Top = 141
    Width = 380
    Height = 23
    TabOrder = 2
    Text = '{ProjectName}.Model.{EntityName}'
  end
  object SaveButton: TButton
    AlignWithMargins = True
    Left = 294
    Top = 178
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 9
    Caption = '&Save'
    Default = True
    TabOrder = 3
    OnClick = SaveButtonClick
  end
  object CancelButton: TButton
    AlignWithMargins = True
    Left = 373
    Top = 178
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 9
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object TrysilDirectoryTextbox: TEdit
    Left = 68
    Top = 37
    Width = 380
    Height = 23
    TabOrder = 0
    Text = '__trysil'
  end
end
