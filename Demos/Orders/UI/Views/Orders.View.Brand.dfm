inherited BrandView: TBrandView
  inherited TopPanel: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited TitleLabel: TLabel
      Width = 52
      Caption = 'Brands'
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 52
    end
    inherited NewButton: TSpeedButton
      ExplicitLeft = 496
      ExplicitTop = 9
    end
    inherited EditButton: TSpeedButton
      ExplicitLeft = 530
      ExplicitTop = 9
    end
    inherited DeleteButton: TSpeedButton
      ExplicitLeft = 564
    end
    inherited RefreshButton: TSpeedButton
      ExplicitLeft = 598
    end
  end
  inherited ListView: TListView
    Columns = <
      item
        Caption = 'ID'
        Width = 60
      end
      item
        Caption = 'Description'
        Width = 400
      end>
  end
end
