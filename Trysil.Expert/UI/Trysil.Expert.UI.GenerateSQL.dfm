object TGenerateSQL: TTGenerateSQL
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 334
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
  object DatabaseTypeLabel: TLabel
    Left = 68
    Top = 16
    Width = 77
    Height = 15
    Caption = 'Database type:'
  end
  object EntitiesLabel: TLabel
    Left = 68
    Top = 70
    Width = 41
    Height = 15
    Caption = 'Entities:'
  end
  object DatabaseTypeCombobox: TComboBox
    Left = 68
    Top = 37
    Width = 470
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 0
    Text = 'Firebird SQL'
    Items.Strings = (
      'Firebird SQL'
      'Microsoft SQL Server'
      'PostgreSQL'
      'SQLite')
  end
  object SaveButton: TButton
    AlignWithMargins = True
    Left = 384
    Top = 294
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 4
    Margins.Bottom = 9
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = SaveButtonClick
  end
  object CancelButton: TButton
    AlignWithMargins = True
    Left = 463
    Top = 294
    Width = 75
    Height = 25
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 9
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object EntitiesListView: TListView
    Left = 68
    Top = 91
    Width = 470
    Height = 188
    Checkboxes = True
    Columns = <>
    ReadOnly = True
    PopupMenu = EntitiesPopupMenu
    TabOrder = 1
    ViewStyle = vsList
    OnCreateItemClass = EntitiesListViewCreateItemClass
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'sql'
    Filter = 'SQL Files|*.sql|All files|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 36
    Top = 64
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
