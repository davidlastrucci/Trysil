inherited TDesignEntityTypeColumnForm: TTDesignEntityTypeColumnForm
  ClientHeight = 258
  ClientWidth = 466
  Color = clWhite
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 482
  ExplicitHeight = 297
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 466
    Height = 209
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 466
    ExplicitHeight = 209
    object ColumnNameLabel: TLabel
      Left = 71
      Top = 70
      Width = 79
      Height = 15
      Caption = 'Column name:'
    end
    object EntityTypeLabel: TLabel
      Left = 72
      Top = 120
      Width = 59
      Height = 15
      Caption = 'Entity type:'
    end
    object NameLabel: TLabel
      Left = 72
      Top = 16
      Width = 77
      Height = 15
      Caption = 'Propery name:'
    end
    object ColumnNameTextbox: TEdit
      Left = 72
      Top = 91
      Width = 380
      Height = 23
      TabOrder = 1
      Text = 'ColumnName'
    end
    object EntityTypeCombobox: TComboBox
      Left = 72
      Top = 141
      Width = 380
      Height = 23
      Style = csDropDownList
      TabOrder = 2
    end
    object EntityTypeListbox: TListBox
      Left = 79
      Top = 141
      Width = 121
      Height = 23
      ItemHeight = 15
      TabOrder = 3
      Visible = False
    end
    object NameTextbox: TEdit
      Left = 72
      Top = 37
      Width = 380
      Height = 23
      TabOrder = 0
      Text = 'Name'
      OnChange = NameTextboxChange
    end
    object RequiredCheckbox: TCheckBox
      Left = 72
      Top = 172
      Width = 72
      Height = 17
      Caption = 'Required'
      TabOrder = 4
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 209
    Width = 466
    ExplicitTop = 209
    ExplicitWidth = 466
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
  end
end
