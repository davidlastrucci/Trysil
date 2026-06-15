inherited TGenerateModel: TTGenerateModel
  ClientHeight = 435
  ClientWidth = 555
  Color = clWhite
  StyleElements = [seFont, seClient, seBorder]
  OnShow = FormShow
  ExplicitWidth = 571
  ExplicitHeight = 474
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 555
    Height = 386
    StyleElements = [seFont, seBorder]
    ExplicitWidth = 555
    ExplicitHeight = 365
    object EntitiesLabel: TLabel
      Left = 72
      Top = 120
      Width = 41
      Height = 15
      Caption = 'Entities:'
    end
    object ModelDirectoryLabel: TLabel
      Left = 72
      Top = 16
      Width = 87
      Height = 15
      Caption = 'Model directory:'
    end
    object UnitFilenamesLabel: TLabel
      Left = 72
      Top = 66
      Width = 79
      Height = 15
      Caption = 'Unit filenames:'
    end
    object EntitiesListView: TListView
      Left = 72
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
    object ModelDirectoryTextbox: TEdit
      Left = 72
      Top = 37
      Width = 470
      Height = 23
      TabOrder = 0
      Text = 'Model'
    end
    object UnitFilenamesTextbox: TEdit
      Left = 72
      Top = 87
      Width = 470
      Height = 23
      TabOrder = 1
      Text = '{ProjectName}.Model.{EntityName}'
    end
    object APIControllersCheckbox: TCheckBox
      Left = 72
      Top = 355
      Width = 237
      Height = 17
      Caption = 'Generate && register API REST controllers'
      TabOrder = 4
    end
    object FilterPropertiesCheckbox: TCheckBox
      Left = 72
      Top = 335
      Width = 227
      Height = 17
      Caption = 'Generate filter properties companion'
      TabOrder = 3
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 386
    Width = 555
    StyleElements = [seFont, seBorder]
    ExplicitTop = 365
    ExplicitWidth = 555
    object CancelButton: TButton
      Left = 468
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object SaveButton: TButton
      AlignWithMargins = True
      Left = 389
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = SaveButtonClick
    end
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
