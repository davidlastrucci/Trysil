inherited TInstallSkillsForm: TTInstallSkillsForm
  Caption = 'Install AI assistant skills'
  ClientHeight = 390
  ClientWidth = 555
  Color = clWhite
  StyleElements = [seFont, seClient, seBorder]
  OnShow = FormShow
  ExplicitWidth = 571
  ExplicitHeight = 429
  TextHeight = 15
  inherited ContentPanel: TPanel
    Width = 555
    Height = 341
    StyleElements = [seFont, seBorder]
    ExplicitWidth = 555
    ExplicitHeight = 348
    object InfoLabel: TLabel
      Left = 72
      Top = 16
      Width = 470
      Height = 30
      AutoSize = False
      Caption = 
        'Select the coding assistants you use. The selected skills will b' +
        'e written into your project folder.'
      WordWrap = True
    end
    object DownloadFromLabel: TLabel
      Left = 72
      Top = 304
      Width = 165
      Height = 15
      Caption = 'The skills are downloaded from'
    end
    object RepositoryLabel: TLabel
      Left = 240
      Top = 304
      Width = 254
      Height = 15
      Cursor = crHandPoint
      Caption = 'https://github.com/davidlastrucci/trysil-ai-skills'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = WebLabelClick
      OnMouseEnter = HyperLinkOn
      OnMouseLeave = HyperLinkOff
    end
    object ToolsListView: TListView
      Left = 72
      Top = 56
      Width = 470
      Height = 240
      Checkboxes = True
      Columns = <
        item
          Caption = 'Coding assistant'
          Width = 160
        end
        item
          Caption = 'Installs into your project'
          Width = 300
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnCreateItemClass = ToolsListViewCreateItemClass
    end
  end
  inherited ButtonsPanel: TPanel
    Top = 341
    Width = 555
    StyleElements = [seFont, seBorder]
    ExplicitTop = 348
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
    object InstallButton: TButton
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
      Caption = '&Install'
      Default = True
      TabOrder = 0
      OnClick = InstallButtonClick
    end
  end
end
