inherited CustomerDialog: TCustomerDialog
  Caption = 'Customer'
  ClientHeight = 378
  StyleElements = [seFont, seClient, seBorder]
  ExplicitHeight = 417
  TextHeight = 15
  inherited ContentPanel: TPanel
    Height = 333
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 488
    ExplicitHeight = 293
    object CompanyNameEdit: TLabeledEdit
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
      EditLabel.Width = 88
      EditLabel.Height = 15
      EditLabel.Caption = 'Company name:'
      MaxLength = 100
      TabOrder = 0
      Text = ''
      ExplicitWidth = 472
    end
    object AddressEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 71
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 45
      EditLabel.Height = 15
      EditLabel.Caption = 'Address:'
      MaxLength = 100
      TabOrder = 1
      Text = ''
      ExplicitWidth = 472
    end
    object CityEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 118
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 24
      EditLabel.Height = 15
      EditLabel.Caption = 'City:'
      MaxLength = 100
      TabOrder = 2
      Text = ''
      ExplicitWidth = 472
    end
    object RegionEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 165
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 40
      EditLabel.Height = 15
      EditLabel.Caption = 'Region:'
      MaxLength = 100
      TabOrder = 3
      Text = ''
      ExplicitWidth = 472
    end
    object PostalCodeEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 212
      Width = 192
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 300
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 64
      EditLabel.Height = 15
      EditLabel.Caption = 'Postal code:'
      MaxLength = 20
      TabOrder = 4
      Text = ''
      ExplicitWidth = 180
    end
    object CountryEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 259
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 46
      EditLabel.Height = 15
      EditLabel.Caption = 'Country:'
      MaxLength = 100
      TabOrder = 5
      Text = ''
      ExplicitWidth = 472
    end
    object EmailEdit: TLabeledEdit
      AlignWithMargins = True
      Left = 8
      Top = 306
      Width = 484
      Height = 23
      Margins.Left = 8
      Margins.Top = 24
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      EditLabel.Width = 32
      EditLabel.Height = 15
      EditLabel.Caption = 'Email:'
      MaxLength = 255
      TabOrder = 6
      Text = ''
      ExplicitWidth = 472
    end
  end
  inherited ButtonPanel: TPanel
    Top = 333
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 293
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
