inherited BrandDialog: TBrandDialog
  Caption = 'Brand'
  ClientHeight = 96
  StyleElements = [seFont, seClient, seBorder]
  ExplicitHeight = 135
  TextHeight = 15
  inherited ContentPanel: TPanel
    Height = 51
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 488
    ExplicitHeight = 11
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
      ExplicitWidth = 472
    end
  end
  inherited ButtonPanel: TPanel
    Top = 51
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 11
    ExplicitWidth = 488
    inherited OkButton: TButton
      ExplicitLeft = 302
      ExplicitHeight = 25
    end
    inherited CancelButton: TButton
      ExplicitLeft = 395
      ExplicitHeight = 25
    end
  end
end
