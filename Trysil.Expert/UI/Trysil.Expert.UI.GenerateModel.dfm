inherited TGenerateModel: TTGenerateModel
  ClientHeight = 414
  ClientWidth = 555
  Color = clWhite
  OnShow = FormShow
  ExplicitWidth = 571
  ExplicitHeight = 453
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 555
    Height = 365
    ExplicitLeft = 0
    ExplicitTop = 0
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
      Top = 335
      Width = 237
      Height = 17
      Caption = 'Generate && register API REST controllers'
      TabOrder = 3
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 365
    Width = 555
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
