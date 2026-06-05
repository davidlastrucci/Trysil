inherited ProductDialog: TProductDialog
  Caption = 'Product'
  ClientHeight = 193
  StyleElements = [seFont, seClient, seBorder]
  ExplicitHeight = 232
  TextHeight = 15
  inherited ContentPanel: TPanel
    Height = 148
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 624
    ExplicitHeight = 396
    object BrandLabel: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 55
      Width = 484
      Height = 15
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Brand:'
      ExplicitWidth = 34
    end
    object BrandCombo: TComboBox
      AlignWithMargins = True
      Left = 8
      Top = 74
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Style = csDropDownList
      TabOrder = 1
    end
    object DescriptionEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 24
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 63
      EditLabel.Height = 15
      EditLabel.Caption = 'Description:'
      MaxLength = 100
      TabOrder = 0
      Text = ''
      ExplicitWidth = 482
    end
    object PriceEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 121
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 29
      EditLabel.Height = 15
      EditLabel.Caption = 'Price:'
      TabOrder = 2
      Text = ''
      ExplicitWidth = 482
    end
  end
  inherited ButtonPanel: TPanel
    Top = 148
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 140
  end
end
