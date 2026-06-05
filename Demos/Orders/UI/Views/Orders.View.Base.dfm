inherited ViewBase: TViewBase
  object TopPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 640
    Height = 48
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 1
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object TitleLabel: TLabel
      Left = 14
      Top = 14
      Width = 34
      Height = 21
      Caption = 'Title'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object NewButton: TSpeedButton
      Cursor = crHandPoint
      AlignWithMargins = True
      Left = 496
      Top = 9
      Width = 30
      Height = 30
      Margins.Left = 0
      Margins.Top = 9
      Margins.Right = 4
      Margins.Bottom = 9
      Action = NewAction
      Align = alRight
      Flat = True
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 534
      ExplicitTop = 6
    end
    object EditButton: TSpeedButton
      Cursor = crHandPoint
      AlignWithMargins = True
      Left = 530
      Top = 9
      Width = 30
      Height = 30
      Margins.Left = 0
      Margins.Top = 9
      Margins.Right = 4
      Margins.Bottom = 9
      Action = EditAction
      Align = alRight
      Flat = True
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 618
      ExplicitTop = 6
    end
    object DeleteButton: TSpeedButton
      Cursor = crHandPoint
      AlignWithMargins = True
      Left = 564
      Top = 9
      Width = 30
      Height = 30
      Margins.Left = 0
      Margins.Top = 9
      Margins.Right = 4
      Margins.Bottom = 9
      Action = DeleteAction
      Align = alRight
      Flat = True
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 514
    end
    object RefreshButton: TSpeedButton
      Cursor = crHandPoint
      AlignWithMargins = True
      Left = 598
      Top = 9
      Width = 30
      Height = 30
      Margins.Left = 0
      Margins.Top = 9
      Margins.Right = 12
      Margins.Bottom = 9
      Action = RefreshAction
      Align = alRight
      Flat = True
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 612
    end
  end
  object ListView: TListView
    Left = 0
    Top = 49
    Width = 640
    Height = 431
    Align = alClient
    BorderStyle = bsNone
    Columns = <>
    ReadOnly = True
    RowSelect = True
    SmallImages = ListViewImageList
    TabOrder = 1
    ViewStyle = vsReport
    OnCreateItemClass = ListViewCreateItemClass
    OnDblClick = ListViewDblClick
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 48
    Top = 80
    object NewAction: TAction
      Hint = 'New'
      ImageIndex = 0
      OnExecute = NewActionExecute
    end
    object EditAction: TAction
      Hint = 'Edit'
      ImageIndex = 1
      OnExecute = EditActionExecute
    end
    object DeleteAction: TAction
      Hint = 'Delete'
      ImageIndex = 2
      OnExecute = DeleteActionExecute
    end
    object RefreshAction: TAction
      Hint = 'Refresh'
      ImageIndex = 3
      OnExecute = RefreshActionExecute
    end
  end
  object IconCollection: TImageCollection
    Images = <
      item
        Name = 'Add'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
              F80000004F49444154789C63FCFFFFFF7F061A02265A1A0E02A31650D7020505
              05301EBA3E20078C5A401030622B2A484D2930F0E0C10386C1E1035C4001EA33
              6C2E1DBE91CC346A015553D1C80C22A6216F0100D0F016DDD82EA9F900000000
              49454E44AE426082}
          end>
      end
      item
        Name = 'Edit'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
              F8000000DD49444154789CD595CD098430104647CBF0A2601DB123C163FAD00E
              BC6B0D7A481962025ED2C42CF1208A51B39908BB1F04F2FB1E7348122122C28B
              89DF84FF87406B0D599601E7DCBE0109599605D334DD5A5555A73DA40ABAAE3B
              8CFBBE87B22CE91528A5701886B55FD7F5A10AD3F6F95A20A5DC40E338AE734D
              D36C73D334F90BE40E6E93CCF37C3A13AD168728A5A0280AEB5ADBB6C018B3AE
              C554B8499EE77095980A17424092247E022AFC5610027E290805B70A42C24F82
              D07093C33D30AF6248B8F33D109E70278120C01F0554B889F35B049EF9FD3FF9
              291F0F5EA01D028E27E80000000049454E44AE426082}
          end>
      end
      item
        Name = 'Delete'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
              F80000006249444154789CED94CB09C0400844A36C21F6EFC98EECC434A0B839
              CC2601E7E8671EA848111117508C343F02583B452292C6DDBDEDA56C079561A7
              0C081F11A1AF685589A763F2621FFF3F531E40A701B41AC08701AABA6D6266EF
              BD6B469A1F01DCF90C1D3532F72AB30000000049454E44AE426082}
          end>
      end
      item
        Name = 'Refresh'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
              F80000016549444154789CE554BD8A8340101E436A5F210145D0325DCA542982
              69525A080A2904215676B686902E115208790B7B0B4B9F419F21458ACDCA1E91
              339CB7BA5A9822771F0C3BECFC7C333B8E1C2184C01B317A67F27F42F0783CC0
              B22C984EA735B16D9BF23D9D4ED41DC71AB2AEEB10C731B380D56A054110C0E5
              7281FD7E0F799EF723501405EEF77BA9ABAA4A55F7EC2A8AA252E7791E6EB75B
              A9F722D86C3690A66963C04F20844092A4DADD6FFF51D39B57C9B32C03160E87
              03D3DE48601846799AA6091CC7B506FABE0F61187612504FF4FC42BA9EE6783C
              C2F97C6EB475CEA00FC1672DDAE004CBE5B23C3DCFEB9DC4FADEF4DD6E47D9A8
              19608C4114C5DE73288A02044168F5A73A188FC7309FCF6B036FC37367AAE4EB
              F5BAD989B440966532994C4A711CA7662B8A82B8AEFBB2CF66B3B63484F9B3D3
              340D92240116168B055CAFD77607D2018410D96EB7AF6A2B314D93608CBBC2D9
              1D0C813FB8683030BE0068C629FC59342E600000000049454E44AE426082}
          end>
      end
      item
        Name = 'Filter'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
              F8000000C949444154789C63FCFFFFFF7F061A02265A1A3E3C2C604117505555
              65F8FDFB37598671707030DCB87183763EF88F25BD30624B450A0A0A6459F0E0
              C1030C31AC3E3878F020C9861F3F7E1CAB38560BE4E5E51912131389363C2F2F
              8F41525212AB1CD62082014B4B4B86E7CF9FE3355C49498961DFBE7D38E5F15A
              000284E2035BB893948A2E5FBE8C53EED6AD5B84B413B680979797A1AFAF0F43
              7CF1E2C50C6C6C6C042D201844B8828A50D00C9FB28869D402AA59C0CACA0A67
              13933C494EA6433F881806AB050082B340B3C294378A0000000049454E44AE42
              6082}
          end>
      end>
    Left = 20
    Top = 136
  end
  object ImageList: TVirtualImageList
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'Add'
        Name = 'Add'
      end
      item
        CollectionIndex = 1
        CollectionName = 'Edit'
        Name = 'Edit'
      end
      item
        CollectionIndex = 2
        CollectionName = 'Delete'
        Name = 'Delete'
      end
      item
        CollectionIndex = 3
        CollectionName = 'Refresh'
        Name = 'Refresh'
      end
      item
        CollectionIndex = 4
        CollectionName = 'Filter'
        Name = 'Filter'
      end>
    ImageCollection = IconCollection
    PreserveItems = True
    Width = 24
    Height = 24
    Left = 20
    Top = 80
  end
  object ListViewImageList: TImageList
    Height = 24
    Width = 1
    Left = 20
    Top = 108
  end
end
