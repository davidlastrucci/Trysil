inherited OrderView: TOrderView
  Width = 435
  Height = 266
  ExplicitWidth = 435
  ExplicitHeight = 266
  inherited TopPanel: TPanel
    Width = 435
    StyleElements = [seFont, seClient, seBorder]
    inherited TitleLabel: TLabel
      Width = 50
      Caption = 'Orders'
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 50
    end
    inherited NewButton: TSpeedButton
      Left = 291
    end
    inherited EditButton: TSpeedButton
      Left = 325
    end
    inherited DeleteButton: TSpeedButton
      Left = 359
    end
    inherited RefreshButton: TSpeedButton
      Left = 393
    end
  end
  inherited ListView: TListView
    Width = 435
    Height = 217
    Columns = <
      item
        Caption = 'ID'
        Width = 60
      end
      item
        Caption = 'Order date'
        Width = 120
      end
      item
        Caption = 'Customer'
        Width = 300
      end
      item
        Caption = 'Cashed'
        Width = 80
      end>
  end
end
