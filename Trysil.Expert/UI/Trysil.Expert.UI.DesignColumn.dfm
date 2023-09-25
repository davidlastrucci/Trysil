object TDesignColumnForm: TTDesignColumnForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 170
  ClientWidth = 330
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
    AutoSize = True
  end
  object ColumnTypeLabel: TLabel
    Left = 68
    Top = 16
    Width = 72
    Height = 15
    Caption = 'Column type:'
  end
  object OkeyButton: TButton
    AlignWithMargins = True
    Left = 164
    Top = 134
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 9
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = OkeyButtonClick
  end
  object CancelButton: TButton
    AlignWithMargins = True
    Left = 243
    Top = 134
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 9
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object TreeView: TTreeView
    Left = 68
    Top = 37
    Width = 250
    Height = 88
    HideSelection = False
    Indent = 27
    ReadOnly = True
    ShowButtons = False
    ShowLines = False
    ShowRoot = False
    TabOrder = 2
    OnDblClick = OkeyButtonClick
    Items.NodeData = {
      030300000034000000000000000000000000000000FFFFFFFF00000000000000
      0000000000010B4400610074006100200063006F006C0075006D006E00380000
      00000000000000000001000000FFFFFFFF000000000000000000000000010D45
      006E007400690074007900200063006F006C0075006D006E0042000000000000
      000000000002000000FFFFFFFF000000000000000000000000011245006E0074
      0069007400790020006C00690073007400200063006F006C0075006D006E00}
  end
end
