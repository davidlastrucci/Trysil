inherited OrderDialog: TOrderDialog
  Caption = 'Order'
  ClientHeight = 474
  ClientWidth = 635
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 651
  ExplicitHeight = 513
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 635
    Height = 429
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 623
    ExplicitHeight = 389
    object OrderDateLabel: TLabel
      Left = 16
      Top = 18
      Width = 56
      Height = 15
      Caption = 'Order date'
    end
    object CustomerLabel: TLabel
      Left = 16
      Top = 66
      Width = 52
      Height = 15
      Caption = 'Customer'
    end
    object DetailsLabel: TLabel
      Left = 16
      Top = 160
      Width = 72
      Height = 15
      Caption = 'Order details'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object OrderDatePicker: TDateTimePicker
      Left = 16
      Top = 36
      Width = 137
      Height = 23
      Date = 46155.000000000000000000
      Time = 0.478046550924773300
      TabOrder = 0
    end
    object CustomerCombo: TComboBox
      Left = 16
      Top = 84
      Width = 400
      Height = 23
      Style = csDropDownList
      TabOrder = 1
    end
    object CashedCheck: TCheckBox
      Left = 16
      Top = 120
      Width = 120
      Height = 17
      Caption = 'Cashed'
      TabOrder = 2
    end
    object DetailListView: TListView
      Left = 16
      Top = 185
      Width = 609
      Height = 240
      Columns = <
        item
          Caption = 'ID'
          Width = 60
        end
        item
          Caption = 'Product'
          Width = 280
        end
        item
          Alignment = taRightJustify
          Caption = 'Quantity'
          Width = 80
        end
        item
          Alignment = taRightJustify
          Caption = 'Price'
          Width = 80
        end
        item
          Alignment = taRightJustify
          Caption = 'Amount'
          Width = 80
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 3
      ViewStyle = vsReport
      OnCreateItemClass = DetailListViewCreateItemClass
      OnDblClick = DetailListViewDblClick
    end
    object ToolbarPanel: TPanel
      Left = 510
      Top = 145
      Width = 117
      Height = 30
      BevelOuter = bvNone
      Caption = 'ToolbarPanel'
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 4
      object NewButton: TSpeedButton
        AlignWithMargins = True
        Left = 15
        Top = 0
        Width = 30
        Height = 30
        Cursor = crHandPoint
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 4
        Margins.Bottom = 0
        Action = NewAction
        Align = alRight
        Flat = True
        ParentShowHint = False
        ShowHint = True
        ExplicitLeft = 534
        ExplicitTop = 6
      end
      object EditButton: TSpeedButton
        AlignWithMargins = True
        Left = 49
        Top = 0
        Width = 30
        Height = 30
        Cursor = crHandPoint
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 4
        Margins.Bottom = 0
        Action = EditAction
        Align = alRight
        Flat = True
        ParentShowHint = False
        ShowHint = True
        ExplicitLeft = 618
        ExplicitTop = 6
      end
      object DeleteButton: TSpeedButton
        AlignWithMargins = True
        Left = 83
        Top = 0
        Width = 30
        Height = 30
        Cursor = crHandPoint
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 4
        Margins.Bottom = 0
        Action = DeleteAction
        Align = alRight
        Flat = True
        ParentShowHint = False
        ShowHint = True
        ExplicitLeft = 514
        ExplicitTop = 9
      end
    end
  end
  inherited ButtonPanel: TPanel
    Top = 429
    Width = 635
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 389
    ExplicitWidth = 623
    inherited OkButton: TButton
      Left = 449
      ExplicitLeft = 437
    end
    inherited CancelButton: TButton
      Left = 542
      ExplicitLeft = 530
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
      end>
    ImageCollection = IconCollection
    PreserveItems = True
    Width = 24
    Height = 24
    Left = 20
    Top = 80
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 592
    Top = 108
    object NewAction: TAction
      Hint = 'New'
      ImageIndex = 0
      ImageName = 'Add'
      OnExecute = NewActionExecute
    end
    object EditAction: TAction
      Hint = 'Edit'
      ImageIndex = 1
      ImageName = 'Edit'
      OnExecute = EditActionExecute
    end
    object DeleteAction: TAction
      Hint = 'Delete'
      ImageIndex = 2
      ImageName = 'Delete'
      OnExecute = DeleteActionExecute
    end
  end
end
