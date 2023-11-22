inherited TDesignEntityListTypeColumnForm: TTDesignEntityListTypeColumnForm
  ClientHeight = 231
  ClientWidth = 466
  Color = clWhite
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 482
  ExplicitHeight = 270
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 466
    Height = 182
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 466
    ExplicitHeight = 182
    object ColumnNameLabel: TLabel
      Left = 72
      Top = 120
      Width = 79
      Height = 15
      Caption = 'Column name:'
    end
    object EntityTypeLabel: TLabel
      Left = 72
      Top = 70
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
    object ColumnNameCombobox: TComboBox
      Left = 72
      Top = 141
      Width = 380
      Height = 23
      Style = csDropDownList
      TabOrder = 3
    end
    object EntityTypeCombobox: TComboBox
      Left = 72
      Top = 91
      Width = 380
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      OnChange = EntityTypeComboboxChange
    end
    object EntityTypeListbox: TListBox
      Left = 83
      Top = 91
      Width = 121
      Height = 23
      ItemHeight = 15
      TabOrder = 2
      Visible = False
    end
    object NameTextbox: TEdit
      Left = 72
      Top = 37
      Width = 380
      Height = 23
      TabOrder = 0
      Text = 'Name'
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 182
    Width = 466
    ExplicitTop = 182
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
