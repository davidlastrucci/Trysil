inherited TDesignDataTypeColumnForm: TTDesignDataTypeColumnForm
  ClientHeight = 307
  ClientWidth = 466
  Color = clWhite
  ExplicitWidth = 482
  ExplicitHeight = 346
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 466
    Height = 258
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 466
    ExplicitHeight = 258
    object ColumnNameLabel: TLabel
      Left = 72
      Top = 70
      Width = 79
      Height = 15
      Caption = 'Column name:'
    end
    object DataSizeLabel: TLabel
      Left = 72
      Top = 170
      Width = 23
      Height = 15
      Caption = 'Size:'
    end
    object DataTypeLabel: TLabel
      Left = 72
      Top = 120
      Width = 53
      Height = 15
      Caption = 'Data type:'
    end
    object NameLabel: TLabel
      Left = 72
      Top = 16
      Width = 35
      Height = 15
      Caption = 'Name:'
    end
    object ColumnNameTextbox: TEdit
      Left = 72
      Top = 91
      Width = 380
      Height = 23
      MaxLength = 128
      TabOrder = 1
      Text = 'ColumnName'
    end
    object DataTypeComboBox: TComboBox
      Left = 72
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
    object NameTextbox: TEdit
      Left = 72
      Top = 37
      Width = 380
      Height = 23
      MaxLength = 128
      TabOrder = 0
      Text = 'Name'
      OnChange = NameTextboxChange
    end
    object RequiredCheckbox: TCheckBox
      Left = 72
      Top = 225
      Width = 72
      Height = 17
      Caption = 'Required'
      TabOrder = 4
    end
    object DataSizeTextbox: TEdit
      Left = 72
      Top = 191
      Width = 57
      Height = 23
      Enabled = False
      NumbersOnly = True
      TabOrder = 3
      Text = '0'
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 258
    Width = 466
    ExplicitTop = 258
    ExplicitWidth = 466
    object CancelButton: TButton
      Left = 379
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
      Left = 300
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
