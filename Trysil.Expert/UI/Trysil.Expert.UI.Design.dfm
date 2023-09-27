inherited TDesignForm: TTDesignForm
  ClientHeight = 651
  ClientWidth = 1044
  Color = clWhite
  OnDblClick = EditEntityButtonClick
  OnShow = FormShow
  ExplicitWidth = 1060
  ExplicitHeight = 690
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 1044
    Height = 602
    ExplicitLeft = 320
    ExplicitTop = 0
    ExplicitWidth = 724
    ExplicitHeight = 564
    object ListViewPanel: TPanel
      AlignWithMargins = True
      Left = 322
      Top = 8
      Width = 714
      Height = 586
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
        Width = 714
        Height = 532
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
        ExplicitHeight = 494
      end
      object ListViewTitlePanel: TPanel
        AlignWithMargins = True
        Left = 6
        Top = 4
        Width = 708
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
        Width = 714
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
    object TreeViewPanel: TPanel
      AlignWithMargins = True
      Left = 68
      Top = 8
      Width = 250
      Height = 586
      Margins.Left = 68
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
        Height = 532
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
  end
  inherited ButtonsPanel: TPanel
    Top = 602
    Width = 1044
    ExplicitTop = 564
    ExplicitWidth = 1044
    object SaveButton: TButton
      AlignWithMargins = True
      Left = 878
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Save'
      Default = True
      TabOrder = 0
      OnClick = SaveButtonClick
      ExplicitLeft = 773
      ExplicitTop = 3
      ExplicitHeight = 16
    end
    object CancelButton: TButton
      Left = 957
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 897
      ExplicitTop = 0
    end
  end
  object ApplicationEvents: TApplicationEvents
    OnIdle = ApplicationEventsIdle
    Left = 8
    Top = 64
  end
end
