inherited CustomerView: TCustomerView
  Width = 718
  Height = 403
  ExplicitWidth = 718
  ExplicitHeight = 403
  inherited TopPanel: TPanel
    Width = 718
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 435
    inherited TitleLabel: TLabel
      Width = 80
      Caption = 'Customers'
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 80
    end
    inherited NewButton: TSpeedButton
      Left = 574
      ExplicitLeft = 291
      ExplicitTop = 9
    end
    inherited EditButton: TSpeedButton
      Left = 608
      ExplicitLeft = 325
      ExplicitTop = 9
    end
    inherited DeleteButton: TSpeedButton
      Left = 642
      ExplicitLeft = 359
    end
    inherited RefreshButton: TSpeedButton
      Left = 676
      ExplicitLeft = 393
    end
  end
  inherited ListView: TListView
    Top = 90
    Width = 718
    Height = 313
    Columns = <
      item
        Caption = 'ID'
        Width = 60
      end
      item
        Caption = 'Company name'
        Width = 220
      end
      item
        Caption = 'City'
        Width = 140
      end
      item
        Caption = 'Country'
        Width = 120
      end
      item
        Caption = 'Email'
        Width = 220
      end>
    ExplicitTop = 90
    ExplicitWidth = 435
    ExplicitHeight = 176
  end
  object FilterPanel: TPanel [2]
    AlignWithMargins = True
    Left = 0
    Top = 49
    Width = 718
    Height = 40
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 1
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    ExplicitWidth = 435
    object CityLabel: TLabel
      Left = 14
      Top = 12
      Width = 24
      Height = 15
      Caption = 'City:'
    end
    object ApplyFilterButton: TSpeedButton
      AlignWithMargins = True
      Left = 253
      Top = 5
      Width = 30
      Height = 30
      Cursor = crHandPoint
      Margins.Left = 0
      Margins.Top = 9
      Margins.Right = 4
      Margins.Bottom = 9
      Action = ApplyFilterAction
      Flat = True
      ParentShowHint = False
      ShowHint = True
    end
    object RestoreButton: TSpeedButton
      AlignWithMargins = True
      Left = 432
      Top = 6
      Width = 90
      Height = 28
      Cursor = crHandPoint
      Action = RestoreAction
      Flat = True
      ParentShowHint = False
      ShowHint = True
    end
    object CityEdit: TEdit
      Left = 50
      Top = 8
      Width = 200
      Height = 23
      TabOrder = 0
    end
    object ShowDeletedCheck: TCheckBox
      Left = 300
      Top = 10
      Width = 120
      Height = 17
      Caption = 'Show deleted'
      TabOrder = 1
      OnClick = ShowDeletedCheckClick
    end
  end
  inherited ActionList: TActionList
    object ApplyFilterAction: TAction
      Hint = 'Apply filter'
      ImageIndex = 4
      ImageName = 'Filter'
      OnExecute = ApplyFilterActionExecute
    end
    object RestoreAction: TAction
      Caption = 'Restore'
      Enabled = False
      Hint = 'Restore the selected (soft-deleted) customer'
      OnExecute = RestoreActionExecute
    end
  end
end
