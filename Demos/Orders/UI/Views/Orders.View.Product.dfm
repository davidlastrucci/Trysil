inherited ProductView: TProductView
  inherited TopPanel: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited TitleLabel: TLabel
      Width = 67
      Caption = 'Products'
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 67
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
        Width = 300
      end
      item
        Alignment = taRightJustify
        Caption = 'Price'
        Width = 100
      end>
  end
end
