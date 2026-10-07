inherited TSettingsForm: TTSettingsForm
  ClientHeight = 255
  ClientWidth = 529
  Color = clWhite
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 529
    Height = 206
    object SettingsTreeView: TTreeView
      Left = 72
      Top = 12
      Width = 145
      Height = 185
      HideSelection = False
      Indent = 19
      ReadOnly = True
      ShowButtons = False
      ShowLines = False
      ShowRoot = False
      TabOrder = 0
      OnChange = SettingsTreeViewChange
    end
    object TrysilPanel: TPanel
      Left = 227
      Top = 12
      Width = 292
      Height = 130
      BevelOuter = bvNone
      ParentColor = True
      ShowCaption = False
      TabOrder = 1
      StyleElements = [seFont, seBorder]
      object TrysilDirectoryLabel: TLabel
        Left = 0
        Top = 0
        Width = 51
        Height = 15
        Caption = 'Directory:'
      end
      object TrysilDirectoryTextbox: TEdit
        Left = 0
        Top = 21
        Width = 292
        Height = 23
        TabOrder = 0
        Text = '__trysil'
      end
    end
    object ModelsPanel: TPanel
      Left = 227
      Top = 12
      Width = 292
      Height = 130
      BevelOuter = bvNone
      ParentColor = True
      ShowCaption = False
      TabOrder = 2
      Visible = False
      StyleElements = [seFont, seBorder]
      object ModelDirectoryLabel: TLabel
        Left = 0
        Top = 0
        Width = 51
        Height = 15
        Caption = 'Directory:'
      end
      object UnitFilenamesLabel: TLabel
        Left = 0
        Top = 50
        Width = 79
        Height = 15
        Caption = 'Unit filenames:'
      end
      object ModelDirectoryTextbox: TEdit
        Left = 0
        Top = 21
        Width = 292
        Height = 23
        TabOrder = 0
        Text = 'Model'
      end
      object UnitFilenamesTextbox: TEdit
        Left = 0
        Top = 71
        Width = 292
        Height = 23
        TabOrder = 1
        Text = '{ProjectName}.Model.{EntityName}'
      end
    end
    object EventsPanel: TPanel
      Left = 227
      Top = 12
      Width = 292
      Height = 130
      BevelOuter = bvNone
      ParentColor = True
      ShowCaption = False
      TabOrder = 3
      Visible = False
      StyleElements = [seFont, seBorder]
      object EventsDirectoryLabel: TLabel
        Left = 0
        Top = 0
        Width = 51
        Height = 15
        Caption = 'Directory:'
      end
      object EventFilenamesLabel: TLabel
        Left = 0
        Top = 50
        Width = 79
        Height = 15
        Caption = 'Unit filenames:'
      end
      object EventsDirectoryTextbox: TEdit
        Left = 0
        Top = 21
        Width = 292
        Height = 23
        TabOrder = 0
        Text = 'Events'
      end
      object EventFilenamesTextbox: TEdit
        Left = 0
        Top = 71
        Width = 292
        Height = 23
        TabOrder = 1
        Text = '{ProjectName}.Event.{EntityName}'
      end
    end
    object ControllersPanel: TPanel
      Left = 227
      Top = 12
      Width = 292
      Height = 130
      BevelOuter = bvNone
      ParentColor = True
      ShowCaption = False
      TabOrder = 4
      Visible = False
      StyleElements = [seFont, seBorder]
      object ControllersDirectoryLabel: TLabel
        Left = 0
        Top = 0
        Width = 51
        Height = 15
        Caption = 'Directory:'
      end
      object ControllerFilenamesLabel: TLabel
        Left = 0
        Top = 50
        Width = 79
        Height = 15
        Caption = 'Unit filenames:'
      end
      object ControllersDirectoryTextbox: TEdit
        Left = 0
        Top = 21
        Width = 292
        Height = 23
        TabOrder = 0
        Text = 'Controllers'
      end
      object ControllerFilenamesTextbox: TEdit
        Left = 0
        Top = 71
        Width = 292
        Height = 23
        TabOrder = 1
        Text = '{ProjectName}.Controller.{EntityName}'
      end
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 206
    Width = 529
    object CancelButton: TButton
      Left = 442
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
      Left = 363
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
    end
  end
end
