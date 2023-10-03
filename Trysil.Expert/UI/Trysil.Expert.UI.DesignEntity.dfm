inherited TDesignEntityForm: TTDesignEntityForm
  ClientHeight = 229
  ClientWidth = 463
  Color = clWhite
  ExplicitWidth = 479
  ExplicitHeight = 268
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 463
    Height = 180
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 463
    ExplicitHeight = 180
    object NameLabel: TLabel
      Left = 72
      Top = 16
      Width = 66
      Height = 15
      Caption = 'Entity name:'
    end
    object SequenceNameLabel: TLabel
      Left = 73
      Top = 120
      Width = 87
      Height = 15
      Caption = 'Sequence name:'
    end
    object TableNameLabel: TLabel
      Left = 72
      Top = 70
      Width = 63
      Height = 15
      Caption = 'Table name:'
    end
    object NameTextbox: TEdit
      Left = 73
      Top = 37
      Width = 380
      Height = 23
      MaxLength = 128
      TabOrder = 0
      Text = 'Name'
      OnChange = NameTextboxChange
    end
    object SequenceNameTextbox: TEdit
      Left = 73
      Top = 140
      Width = 380
      Height = 23
      MaxLength = 128
      TabOrder = 2
      Text = 'SequenceName'
    end
    object TableNameTextbox: TEdit
      Left = 73
      Top = 91
      Width = 380
      Height = 23
      MaxLength = 128
      TabOrder = 1
      Text = 'TableName'
      OnChange = TableNameTextboxChange
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 180
    Width = 463
    ExplicitTop = 180
    ExplicitWidth = 463
    object CancelButton: TButton
      Left = 376
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
      Left = 297
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
