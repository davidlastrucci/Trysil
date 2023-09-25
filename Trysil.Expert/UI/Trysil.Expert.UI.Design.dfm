object TDesignForm: TTDesignForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Trysil - Delphi ORM'
  ClientHeight = 651
  ClientWidth = 1044
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnDblClick = EditEntityButtonClick
  OnShow = FormShow
  TextHeight = 15
  object TrysilImage: TImage
    Left = 8
    Top = 8
    Width = 48
    Height = 48
    AutoSize = True
  end
  object TreeViewPanel: TPanel
    AlignWithMargins = True
    Left = 64
    Top = 8
    Width = 250
    Height = 597
    Margins.Left = 64
    Margins.Top = 8
    Margins.Right = 2
    Margins.Bottom = 8
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'TreeViewPanel'
    ShowCaption = False
    TabOrder = 0
    object TreeView: TTreeView
      Left = 0
      Top = 54
      Width = 250
      Height = 543
      Align = alClient
      HideSelection = False
      Indent = 27
      ReadOnly = True
      ShowButtons = False
      ShowLines = False
      ShowRoot = False
      SortType = stText
      TabOrder = 0
      OnChange = TreeViewChange
      OnCreateNodeClass = TreeViewCreateNodeClass
      OnDblClick = EditEntityButtonClick
    end
    object TreeViewTitlePanel: TPanel
      AlignWithMargins = True
      Left = 6
      Top = 4
      Width = 244
      Height = 20
      Margins.Left = 6
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = 'Entities'
      TabOrder = 1
    end
    object TreeViewToolBarPanel: TPanel
      Left = 0
      Top = 24
      Width = 250
      Height = 30
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object AddNewEntityButton: TSpeedButton
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 28
        Height = 28
        Hint = 'Add new entity'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alLeft
        DisabledImageIndex = 1
        ImageIndex = 0
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = AddNewEntityButtonClick
        ExplicitLeft = 20
        ExplicitTop = 2
      end
      object DeleteEntityButton: TSpeedButton
        AlignWithMargins = True
        Left = 56
        Top = 0
        Width = 28
        Height = 28
        Hint = 'Delete entity'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alLeft
        DisabledImageIndex = 5
        ImageIndex = 4
        Enabled = False
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = DeleteEntityButtonClick
        ExplicitLeft = 20
        ExplicitTop = 2
      end
      object EditEntityButton: TSpeedButton
        AlignWithMargins = True
        Left = 28
        Top = 0
        Width = 28
        Height = 28
        Hint = 'Edit entity'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alLeft
        DisabledImageIndex = 3
        ImageIndex = 2
        Enabled = False
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = EditEntityButtonClick
        ExplicitLeft = 20
        ExplicitTop = 1
      end
    end
  end
  object ListViewPanel: TPanel
    AlignWithMargins = True
    Left = 318
    Top = 8
    Width = 718
    Height = 597
    Margins.Left = 2
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    BevelOuter = bvNone
    Caption = 'ListViewPanel'
    ShowCaption = False
    TabOrder = 1
    object ListView: TListView
      Left = 0
      Top = 54
      Width = 718
      Height = 543
      Align = alClient
      Columns = <
        item
          Caption = 'Name'
          Width = 200
        end
        item
          Caption = 'Name'
          Width = 200
        end
        item
          Caption = 'Type'
          Width = 200
        end
        item
          Alignment = taRightJustify
          Caption = 'Size'
          Width = 80
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnCreateItemClass = ListViewCreateItemClass
      OnDblClick = EditColumnButtonClick
    end
    object ListViewTitlePanel: TPanel
      AlignWithMargins = True
      Left = 6
      Top = 4
      Width = 712
      Height = 20
      Margins.Left = 6
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = 'Columns'
      TabOrder = 1
    end
    object ListViewToolBarPanel: TPanel
      Left = 0
      Top = 24
      Width = 718
      Height = 30
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      TabOrder = 2
      object AddNewColumnButton: TSpeedButton
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 28
        Height = 28
        Hint = 'Add new column'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alLeft
        DisabledImageIndex = 7
        ImageIndex = 6
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = AddNewColumnButtonClick
        ExplicitLeft = 574
        ExplicitTop = -2
      end
      object DeleteColumnButton: TSpeedButton
        AlignWithMargins = True
        Left = 56
        Top = 0
        Width = 28
        Height = 28
        Hint = 'Delete column'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alLeft
        DisabledImageIndex = 11
        ImageIndex = 10
        Enabled = False
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = DeleteColumnButtonClick
        ExplicitLeft = 562
        ExplicitTop = -2
      end
      object EditColumnButton: TSpeedButton
        AlignWithMargins = True
        Left = 28
        Top = 0
        Width = 28
        Height = 28
        Hint = 'Edit column'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alLeft
        DisabledImageIndex = 9
        ImageIndex = 8
        Enabled = False
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = EditColumnButtonClick
        ExplicitLeft = 24
        ExplicitTop = 1
      end
    end
  end
  object BottomPanel: TPanel
    AlignWithMargins = True
    Left = 64
    Top = 613
    Width = 972
    Height = 34
    Margins.Left = 64
    Margins.Top = 0
    Margins.Right = 8
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'BottomPanel'
    ShowCaption = False
    TabOrder = 2
    object SaveButton: TButton
      AlignWithMargins = True
      Left = 818
      Top = 0
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 9
      Align = alRight
      Caption = '&Save'
      Default = True
      TabOrder = 0
      OnClick = SaveButtonClick
    end
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 897
      Top = 0
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 9
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ApplicationEvents: TApplicationEvents
    OnIdle = ApplicationEventsIdle
    Left = 8
    Top = 64
  end
end
