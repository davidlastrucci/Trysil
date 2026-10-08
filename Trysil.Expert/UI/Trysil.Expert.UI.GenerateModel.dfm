inherited TGenerateModel: TTGenerateModel
  ClientWidth = 545
  Color = clWhite
  OnShow = FormShow
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 545
    object ControllersPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 477
      Height = 370
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 3
      object ControllersPageGroupbox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 473
        Height = 362
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Controllers  '
        TabOrder = 0
        object ControllersDirectoryLabel: TLabel
          Left = 24
          Top = 60
          Width = 51
          Height = 15
          Caption = 'Directory:'
        end
        object ControllerFilenamesLabel: TLabel
          Left = 24
          Top = 110
          Width = 79
          Height = 15
          Caption = 'Unit filenames:'
        end
        object APIControllersCheckbox: TCheckBox
          Left = 24
          Top = 28
          Width = 300
          Height = 17
          Caption = 'Generate && register controllers'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object ControllersDirectoryTextbox: TEdit
          Left = 24
          Top = 81
          Width = 437
          Height = 23
          TabOrder = 1
          Text = 'Controllers'
        end
        object ControllerFilenamesTextbox: TEdit
          Left = 24
          Top = 131
          Width = 437
          Height = 23
          TabOrder = 2
          Text = '{ProjectName}.Controller.{EntityName}'
        end
      end
    end
    object RulesPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 477
      Height = 370
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 2
      object RulesPageGroupbox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 473
        Height = 362
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Rules  '
        TabOrder = 0
        object RulesDirectoryLabel: TLabel
          Left = 24
          Top = 60
          Width = 51
          Height = 15
          Caption = 'Directory:'
        end
        object RuleFilenamesLabel: TLabel
          Left = 24
          Top = 110
          Width = 79
          Height = 15
          Caption = 'Unit filenames:'
        end
        object RulesCheckbox: TCheckBox
          Left = 24
          Top = 28
          Width = 200
          Height = 17
          Caption = 'Generate && register rules'
          TabOrder = 0
        end
        object RulesDirectoryTextbox: TEdit
          Left = 24
          Top = 81
          Width = 437
          Height = 23
          TabOrder = 1
          Text = 'Rules'
        end
        object RuleFilenamesTextbox: TEdit
          Left = 24
          Top = 131
          Width = 437
          Height = 23
          TabOrder = 2
          Text = '{ProjectName}.Rule.{EntityName}'
        end
      end
    end
    object ModelsPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 477
      Height = 370
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object ModelsPageGroupbox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 473
        Height = 362
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Models  '
        TabOrder = 0
        object ModelDirectoryLabel: TLabel
          Left = 24
          Top = 60
          Width = 51
          Height = 15
          Caption = 'Directory:'
        end
        object UnitFilenamesLabel: TLabel
          Left = 24
          Top = 110
          Width = 79
          Height = 15
          Caption = 'Unit filenames:'
        end
        object ModelsCheckbox: TCheckBox
          Left = 24
          Top = 28
          Width = 200
          Height = 17
          Caption = 'Generate models'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object ModelDirectoryTextbox: TEdit
          Left = 24
          Top = 81
          Width = 437
          Height = 23
          TabOrder = 1
          Text = 'Model'
        end
        object UnitFilenamesTextbox: TEdit
          Left = 24
          Top = 131
          Width = 437
          Height = 23
          TabOrder = 2
          Text = '{ProjectName}.Model.{EntityName}'
        end
        object FilterPropertiesCheckbox: TCheckBox
          Left = 24
          Top = 166
          Width = 260
          Height = 17
          Caption = 'Generate filter properties companion'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
      end
    end
    object EntitiesPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 477
      Height = 370
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object EntitiesPageGroupbox: TGroupBox
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 473
        Height = 362
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 4
        Align = alClient
        Caption = 'Entities  '
        TabOrder = 0
        DesignSize = (
          473
          362)
        object EntitiesListView: TListView
          Left = 24
          Top = 28
          Width = 437
          Height = 321
          Anchors = [akLeft, akTop, akRight, akBottom]
          Checkboxes = True
          Columns = <>
          ReadOnly = True
          PopupMenu = EntitiesPopupMenu
          TabOrder = 0
          ViewStyle = vsList
          OnCreateItemClass = EntitiesListViewCreateItemClass
        end
      end
    end
  end
  inherited ButtonsPanel: TPanel
    Width = 545
    object CancelButton: TButton
      Left = 458
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 3
      ExplicitLeft = 537
    end
    object FinishButton: TButton
      AlignWithMargins = True
      Left = 379
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Finish'
      Default = True
      Enabled = False
      TabOrder = 2
      OnClick = FinishButtonClick
      ExplicitLeft = 458
    end
    object BackButton: TButton
      AlignWithMargins = True
      Left = 221
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Back'
      Enabled = False
      TabOrder = 0
      OnClick = BackButtonClick
      ExplicitLeft = 300
    end
    object NextButton: TButton
      AlignWithMargins = True
      Left = 300
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Next'
      Default = True
      TabOrder = 1
      OnClick = NextButtonClick
      ExplicitLeft = 379
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
