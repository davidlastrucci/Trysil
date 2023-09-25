object TDesignEntityForm: TTDesignEntityForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 212
  ClientWidth = 464
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
  object NameLabel: TLabel
    Left = 68
    Top = 16
    Width = 66
    Height = 15
    Caption = 'Entity name:'
  end
  object TableNameLabel: TLabel
    Left = 68
    Top = 70
    Width = 63
    Height = 15
    Caption = 'Table name:'
  end
  object SequenceNameLabel: TLabel
    Left = 69
    Top = 120
    Width = 87
    Height = 15
    Caption = 'Sequence name:'
  end
  object NameTextbox: TEdit
    Left = 69
    Top = 37
    Width = 380
    Height = 23
    MaxLength = 128
    TabOrder = 0
    Text = 'Name'
  end
  object TableNameTextbox: TEdit
    Left = 69
    Top = 91
    Width = 380
    Height = 23
    MaxLength = 128
    TabOrder = 1
    Text = 'TableName'
  end
  object SequenceNameTextbox: TEdit
    Left = 69
    Top = 141
    Width = 380
    Height = 23
    MaxLength = 128
    TabOrder = 2
    Text = 'SequenceName'
  end
  object SaveButton: TButton
    AlignWithMargins = True
    Left = 295
    Top = 176
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
    Left = 374
    Top = 176
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
end
