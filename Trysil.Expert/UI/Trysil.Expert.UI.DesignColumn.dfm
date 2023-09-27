inherited TDesignColumnForm: TTDesignColumnForm
  ClientHeight = 181
  ClientWidth = 333
  Color = clWhite
  ExplicitWidth = 349
  ExplicitHeight = 220
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 333
    Height = 132
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 330
    ExplicitHeight = 121
    object ColumnTypeLabel: TLabel
      Left = 72
      Top = 16
      Width = 72
      Height = 15
      Caption = 'Column type:'
    end
    object TreeView: TTreeView
      Left = 72
      Top = 33
      Width = 250
      Height = 88
      HideSelection = False
      Indent = 27
      ReadOnly = True
      ShowButtons = False
      ShowLines = False
      ShowRoot = False
      TabOrder = 0
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
  inherited ButtonsPanel: TPanel
    Top = 132
    Width = 333
    ExplicitTop = 121
    ExplicitWidth = 330
    object OkeyButton: TButton
      AlignWithMargins = True
      Left = 167
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = OkeyButtonClick
      ExplicitLeft = 164
      ExplicitTop = 24
    end
    object CancelButton: TButton
      Left = 246
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 243
      ExplicitTop = 24
    end
  end
end
