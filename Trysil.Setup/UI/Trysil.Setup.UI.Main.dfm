object TSetupForm: TTSetupForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Trysil Setup'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  TextHeight = 15
  object ContentPanel: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 392
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object TrysilImage: TImage
      Left = 12
      Top = 12
      Width = 48
      Height = 48
      Picture.Data = {
        0954506E67496D61676589504E470D0A1A0A0000000D49484452000000300000
        003008060000005702F987000000017352474200AECE1CE90000000467414D41
        0000B18F0BFC6105000000097048597300000B1200000B1201D2DD7EFC000002
        F84944415478DAED994B68134118C7FFB3DB3CDAA43DD483A8D57A125F20457B
        D193828A078B505ABD282895D28BF471A878B2075111531FE0A11E8450118C08
        2222148FA20751112C78F0506D11046B6993344DDADDF1BF49ACE6619BA49BA4
        9119D864767626DFFFF7CD378F9D08547812E516A000CA2D4001945B8002F8E7
        93B0EC80C416C4627ED4BB3E9645DDE4EC46B85DA7E2F9B9A81F6B6AC6730308
        9B5FF868D3E2BDC44178C58B928B77B95F418886A486294423BBD22132016665
        2B2B3F4A2993F229BC5A4B490142860F42EB492BBD0C8FB8B01C401B011EA602
        60843D70B8A40041E30E34AD2BA5CC346FA256EF5E1A204E6F8E2F76DD1F88AB
        84385F1AF18C02216F646800F6B007DE2E0FF0637603074F1FBBB0012602D0D0
        CFD2DDBC3E632E7220DB60B24FBCF1809E3FC1B0FD46AF5DA3866D90A613BA36
        806A31965E3DF76934685CE20FFF8EBF4E7A62C856E1D3B219BA7C9CF4FA081D
        D5918BA3F25B07A6E6F7C3A1FBF335B26C0AC97E2AB912CF4BB30F5EDD976BD3
        FC17B2EFA1B5F07AFCCC1DE235C910EB42AD0814247C2AD208A7DB6ADB4CE55F
        29E7187BF67D3E3F51F84A1C327A199FD7935EF323A69D43BD98CEA37D37DB0F
        26EF0230E8883A3199AF8C956D257E4677C2E9781E0F292927601AEDA873BC5E
        B24D7C75ADB684B7923C42F8B3F056DD2F54C2CAF742A3A34E346EBD4B6F2696
        7CD3BCC8B97A206BDDC4F4788BC0EB79370623760475AE4F2B316FDF666E66E1
        34672982089D776F208DDB807686F97534738FDF4DB4763C597B88B1DE698759
        7B77A3D6A074B89E116247D6E7D6DC2E4577C183BEE80056B2426AF3F661E6DA
        D2C44F203AB7D7EE45B038EF03330B2DD0F527A900E630E7F793769B2ADE0B4D
        585A1BC2442F14C9FBC5054840C8A49576D4D817F70A4001280005A000148002
        5000AB1EE0EF9335293F703377B472367333F3FBA057BD4C29CB722CB87A01B2
        9DAF5A270F1ED15E190061D9C4CF7769A51927CBAB17C04A41F68290BEC4918B
        39C8B7B1DE6298F98FFF62AA90A400CA9D1440B953C503FC0234E919409EF243
        A10000000049454E44AE426082}
    end
    object FolderPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 546
      Height = 376
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 1
      object FolderTitleLabel: TLabel
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 542
        Height = 28
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Installation folder'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 170
      end
      object FolderLabel: TLabel
        Left = 2
        Top = 44
        Width = 36
        Height = 15
        Caption = 'Folder:'
      end
      object FolderTextbox: TEdit
        Left = 2
        Top = 65
        Width = 505
        Height = 23
        TabOrder = 0
      end
      object FolderButton: TButton
        Left = 513
        Top = 64
        Width = 27
        Height = 25
        Hint = 'Select the installation folder'
        Caption = '...'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = FolderButtonClick
      end
    end
    object VersionsPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 546
      Height = 376
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 2
      object VersionsTitleLabel: TLabel
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 542
        Height = 28
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Delphi versions'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 146
      end
      object VersionsLabel: TLabel
        Left = 2
        Top = 44
        Width = 205
        Height = 15
        Caption = 'Install Trysil in these versions of Delphi:'
      end
      object VersionsListBox: TCheckListBox
        Left = 2
        Top = 65
        Width = 538
        Height = 284
        ItemHeight = 24
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnDrawItem = VersionsListBoxDrawItem
      end
      object ExpertCheckbox: TCheckBox
        Left = 2
        Top = 355
        Width = 300
        Height = 17
        Caption = 'Install Trysil Expert'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
    end
    object SummaryPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 546
      Height = 376
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 3
      object SummaryTitleLabel: TLabel
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 542
        Height = 28
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Summary'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 90
      end
      object SummaryMemo: TMemo
        AlignWithMargins = True
        Left = 2
        Top = 44
        Width = 542
        Height = 330
        Margins.Left = 2
        Margins.Top = 12
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alClient
        BorderStyle = bsNone
        ReadOnly = True
        TabOrder = 0
      end
    end
    object ProgressPagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 546
      Height = 376
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 4
      object ProgressTitleLabel: TLabel
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 542
        Height = 28
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Progress'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 81
      end
      object ProgressMemo: TMemo
        AlignWithMargins = True
        Left = 2
        Top = 44
        Width = 542
        Height = 330
        Margins.Left = 2
        Margins.Top = 12
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object ModePagePanel: TPanel
      AlignWithMargins = True
      Left = 70
      Top = 8
      Width = 546
      Height = 376
      Margins.Left = 70
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 0
      object ModeTitleLabel: TLabel
        AlignWithMargins = True
        Left = 2
        Top = 4
        Width = 542
        Height = 28
        Margins.Left = 2
        Margins.Top = 4
        Margins.Right = 2
        Margins.Bottom = 0
        Align = alTop
        Caption = 'Trysil Setup'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 111
      end
      object ModeInfoLabel: TLabel
        Left = 2
        Top = 44
        Width = 3
        Height = 15
      end
      object ModeInstallRadioButton: TRadioButton
        Left = 5
        Top = 73
        Width = 300
        Height = 17
        Caption = 'Install Trysil'
        TabOrder = 0
      end
      object ModeUpdateRadioButton: TRadioButton
        Left = 5
        Top = 99
        Width = 300
        Height = 17
        Caption = 'Update Trysil to the latest release'
        TabOrder = 1
      end
      object ModeUninstallRadioButton: TRadioButton
        Left = 5
        Top = 125
        Width = 300
        Height = 17
        Caption = 'Uninstall Trysil'
        TabOrder = 2
      end
    end
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 392
    Width = 624
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Top = 12
    Padding.Right = 12
    Padding.Bottom = 12
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    object BackButton: TButton
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
      Caption = '&Back'
      Enabled = False
      TabOrder = 0
      OnClick = BackButtonClick
    end
    object NextButton: TButton
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
      Caption = '&Next'
      Default = True
      TabOrder = 1
      OnClick = NextButtonClick
    end
    object FinishButton: TButton
      AlignWithMargins = True
      Left = 458
      Top = 12
      Width = 75
      Height = 25
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 4
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Finish'
      Enabled = False
      TabOrder = 2
      OnClick = FinishButtonClick
    end
    object CancelButton: TButton
      Left = 537
      Top = 12
      Width = 75
      Height = 25
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = CancelButtonClick
    end
  end
  object FolderDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoForceFileSystem]
    Title = 'Installation folder'
    Left = 12
    Top = 72
  end
end
