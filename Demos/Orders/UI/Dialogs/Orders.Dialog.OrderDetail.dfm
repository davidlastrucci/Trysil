inherited OrderDetailDialog: TOrderDetailDialog
  Caption = 'Order detail'
  ClientHeight = 205
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 5
  ExplicitTop = 5
  ExplicitHeight = 244
  TextHeight = 15
  inherited ContentPanel: TPanel
    Height = 160
    StyleElements = [seFont, seClient, seBorder]
    ExplicitHeight = 120
    object ProductLabel: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 484
      Height = 15
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Product:'
      ExplicitWidth = 45
    end
    object ProductCombo: TComboBox
      AlignWithMargins = True
      Left = 8
      Top = 27
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Style = csDropDownList
      TabOrder = 0
      OnChange = ProductComboChange
      ExplicitWidth = 472
    end
    object QuantityEdit: TLabeledEdit
      Left = 8
      Top = 74
      Width = 160
      Height = 23
      EditLabel.Width = 49
      EditLabel.Height = 15
      EditLabel.Caption = 'Quantity:'
      TabOrder = 1
      Text = ''
    end
    object PriceEdit: TLabeledEdit
      Left = 8
      Top = 123
      Width = 160
      Height = 23
      EditLabel.Width = 29
      EditLabel.Height = 15
      EditLabel.Caption = 'Price:'
      TabOrder = 2
      Text = ''
    end
  end
  inherited ButtonPanel: TPanel
    Top = 160
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 120
  end
end
