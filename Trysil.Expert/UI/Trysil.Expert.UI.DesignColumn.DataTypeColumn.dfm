object TDesignDataTypeColumnForm: TTDesignDataTypeColumnForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 285
  ClientWidth = 464
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object ColumnNameLabel: TLabel
    Left = 68
    Top = 70
    Width = 79
    Height = 15
    Caption = 'Column name:'
  end
  object DataTypeLabel: TLabel
    Left = 68
    Top = 120
    Width = 53
    Height = 15
    Caption = 'Data type:'
  end
  object DataSizeLabel: TLabel
    Left = 72
    Top = 170
    Width = 23
    Height = 15
    Caption = 'Size:'
  end
  object TrysilImage: TImage
    Left = 8
    Top = 8
    Width = 48
    Height = 48
    AutoSize = True
  end
  object NameLabel: TLabel
    Left = 68
    Top = 16
    Width = 35
    Height = 15
    Caption = 'Name:'
  end
  object ColumnNameTextbox: TEdit
    Left = 68
    Top = 91
    Width = 380
    Height = 23
    MaxLength = 128
    TabOrder = 1
    Text = 'ColumnName'
  end
  object DataTypeComboBox: TComboBox
    Left = 68
    Top = 141
    Width = 380
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = 'String'
    OnChange = DataTypeComboBoxChange
    Items.Strings = (
      'String'
      'Memo'
      'Smallint'
      'Integer'
      'LargeInteger'
      'Double'
      'Boolean'
      'DateTime'
      'Guid'
      'Blob')
  end
  object DataSizeTextbox: TNumberBox
    Left = 72
    Top = 191
    Width = 52
    Height = 23
    Alignment = taRightJustify
    Enabled = False
    TabOrder = 3
  end
  object RequiredCheckbox: TCheckBox
    Left = 75
    Top = 224
    Width = 72
    Height = 17
    Caption = 'Required'
    TabOrder = 4
  end
  object SaveButton: TButton
    AlignWithMargins = True
    Left = 294
    Top = 248
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 9
    Caption = '&Save'
    Default = True
    TabOrder = 5
    OnClick = SaveButtonClick
  end
  object CancelButton: TButton
    AlignWithMargins = True
    Left = 373
    Top = 248
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 9
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object NameTextbox: TEdit
    Left = 68
    Top = 37
    Width = 380
    Height = 23
    MaxLength = 128
    TabOrder = 0
    Text = 'Name'
  end
end
