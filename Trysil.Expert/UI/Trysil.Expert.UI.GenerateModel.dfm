object TGenerateModel: TTGenerateModel
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 381
  ClientWidth = 550
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object TrysilImage: TImage
    Left = 8
    Top = 8
    Width = 48
    Height = 48
  end
  object ModelDirectoryLabel: TLabel
    Left = 68
    Top = 16
    Width = 87
    Height = 15
    Caption = 'Model directory:'
  end
  object UnitFilenamesLabel: TLabel
    Left = 68
    Top = 66
    Width = 79
    Height = 15
    Caption = 'Unit filenames:'
  end
  object EntitiesLabel: TLabel
    Left = 68
    Top = 120
    Width = 41
    Height = 15
    Caption = 'Entities:'
  end
  object ModelDirectoryTextbox: TEdit
    Left = 68
    Top = 37
    Width = 470
    Height = 23
    TabOrder = 0
    Text = 'Model'
  end
  object UnitFilenamesTextbox: TEdit
    Left = 68
    Top = 87
    Width = 470
    Height = 23
    TabOrder = 1
    Text = '{ProjectName}.Model.{EntityName}'
  end
  object EntitiesListView: TListView
    Left = 68
    Top = 141
    Width = 470
    Height = 188
    Checkboxes = True
    Columns = <>
    ReadOnly = True
    PopupMenu = EntitiesPopupMenu
    TabOrder = 2
    ViewStyle = vsList
    OnCreateItemClass = EntitiesListViewCreateItemClass
  end
  object SaveButton: TButton
    AlignWithMargins = True
    Left = 384
    Top = 342
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 9
    Caption = '&OK'
    Default = True
    TabOrder = 3
    OnClick = SaveButtonClick
  end
  object CancelButton: TButton
    AlignWithMargins = True
    Left = 463
    Top = 342
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 9
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object EntitiesPopupMenu: TPopupMenu
    Left = 8
    Top = 64
    object SelectAllEntitiesMenuItem: TMenuItem
      Caption = 'Select all entities'
      ImageIndex = 2
      OnClick = SelectAllEntitiesMenuItemClick
    end
    object UnselectAllEntitiesMenuItem: TMenuItem
      Caption = 'Unselect all entities'
      ImageIndex = 3
      OnClick = UnselectallEntitiesMenuItemClick
    end
  end
end
