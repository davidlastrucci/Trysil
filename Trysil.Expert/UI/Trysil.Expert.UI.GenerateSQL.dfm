inherited TGenerateSQL: TTGenerateSQL
  ClientHeight = 340
  ClientWidth = 554
  Color = clWhite
  OnShow = FormShow
  ExplicitWidth = 570
  ExplicitHeight = 379
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 554
    Height = 291
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 554
    ExplicitHeight = 291
    object DatabaseTypeLabel: TLabel
      Left = 72
      Top = 16
      Width = 77
      Height = 15
      Caption = 'Database type:'
    end
    object EntitiesLabel: TLabel
      Left = 72
      Top = 70
      Width = 41
      Height = 15
      Caption = 'Entities:'
    end
    object DatabaseTypeCombobox: TComboBox
      Left = 72
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
    object EntitiesListView: TListView
      Left = 72
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
  end
  inherited ButtonsPanel: TPanel
    Top = 291
    Width = 554
    ExplicitTop = 291
    ExplicitWidth = 554
    object CancelButton: TButton
      Left = 467
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
      Left = 388
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
