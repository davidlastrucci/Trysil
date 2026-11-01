object TSetupForm: TTSetupForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = '"Trysil - Delphi ORM" Setup'
  ClientHeight = 480
  ClientWidth = 720
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  TextHeight = 15
  object SidebarPanel: TPanel
    Left = 0
    Top = 0
    Width = 214
    Height = 480
    Align = alLeft
    BevelOuter = bvNone
    Color = 1446158
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object TrysilImage: TImage
      Left = 14
      Top = 24
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
    object ProductLabel: TLabel
      Left = 74
      Top = 26
      Width = 47
      Height = 25
      Caption = 'Trysil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ProductInfoLabel: TLabel
      Left = 74
      Top = 52
      Width = 97
      Height = 15
      Caption = 'Delphi ORM Setup'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10392715
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object StepsPanel: TPanel
      Left = 20
      Top = 104
      Width = 160
      Height = 180
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      ShowCaption = False
      TabOrder = 0
      object ModeStepPanel: TPanel
        Left = 0
        Top = 0
        Width = 160
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 0
        object ModeStepBadgeLabel: TLabel
          Left = 0
          Top = 7
          Width = 20
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Color = 2958881
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -11
          Font.Name = 'Segoe UI Symbol'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object ModeStepLabel: TLabel
          Left = 30
          Top = 9
          Width = 56
          Height = 15
          Caption = 'Setup type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object FolderStepPanel: TPanel
        Left = 0
        Top = 34
        Width = 160
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 1
        object FolderStepBadgeLabel: TLabel
          Left = 0
          Top = 7
          Width = 20
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Color = 2958881
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -11
          Font.Name = 'Segoe UI Symbol'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object FolderStepLabel: TLabel
          Left = 30
          Top = 9
          Width = 33
          Height = 15
          Caption = 'Folder'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object VersionsStepPanel: TPanel
        Left = 0
        Top = 68
        Width = 160
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 2
        object VersionsStepBadgeLabel: TLabel
          Left = 0
          Top = 7
          Width = 20
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Color = 2958881
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -11
          Font.Name = 'Segoe UI Symbol'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object VersionsStepLabel: TLabel
          Left = 30
          Top = 9
          Width = 80
          Height = 15
          Caption = 'Delphi versions'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object SummaryStepPanel: TPanel
        Left = 0
        Top = 102
        Width = 160
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 3
        object SummaryStepBadgeLabel: TLabel
          Left = 0
          Top = 7
          Width = 20
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Color = 2958881
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -11
          Font.Name = 'Segoe UI Symbol'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object SummaryStepLabel: TLabel
          Left = 30
          Top = 9
          Width = 51
          Height = 15
          Caption = 'Summary'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object InstallationStepPanel: TPanel
        Left = 0
        Top = 136
        Width = 160
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 4
        object InstallationStepBadgeLabel: TLabel
          Left = 0
          Top = 7
          Width = 20
          Height = 20
          Alignment = taCenter
          AutoSize = False
          Color = 2958881
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -11
          Font.Name = 'Segoe UI Symbol'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object InstallationStepLabel: TLabel
          Left = 30
          Top = 9
          Width = 58
          Height = 15
          Caption = 'Installation'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 10392715
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
    end
  end
  object MainPanel: TPanel
    Left = 214
    Top = 0
    Width = 506
    Height = 480
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = 200
    ExplicitWidth = 520
    object ButtonsLineShape: TShape
      Left = 0
      Top = 423
      Width = 506
      Height = 1
      Align = alBottom
      Brush.Color = 15460325
      Pen.Color = 15460325
      ExplicitWidth = 520
    end
    object ContentPanel: TPanel
      Left = 0
      Top = 0
      Width = 506
      Height = 423
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      ExplicitWidth = 520
      object ModePagePanel: TPanel
        AlignWithMargins = True
        Left = 32
        Top = 26
        Width = 456
        Height = 367
        Margins.Left = 32
        Margins.Top = 26
        Margins.Right = 32
        Margins.Bottom = 28
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 0
        DesignSize = (
          456
          367)
        object ModeTitleLabel: TLabel
          Left = 0
          Top = 0
          Width = 232
          Height = 28
          Caption = 'ModeTitleLabel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object ModeSubtitleLabel: TLabel
          Left = 0
          Top = 38
          Width = 140
          Height = 15
          Caption = 'What do you want to do?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object InstallCardPanel: TPanel
          Left = 0
          Top = 68
          Width = 456
          Height = 62
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = 15460325
          Padding.Left = 1
          Padding.Top = 1
          Padding.Right = 1
          Padding.Bottom = 1
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object InstallContentPanel: TPanel
            Left = 1
            Top = 1
            Width = 454
            Height = 60
            Align = alClient
            BevelOuter = bvNone
            Color = clWhite
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object InstallDescriptionLabel: TLabel
              Left = 31
              Top = 33
              Width = 410
              Height = 15
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'InstallDescriptionLabel'
              EllipsisPosition = epEndEllipsis
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 6509899
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object ModeInstallRadioButton: TRadioButton
              Left = 13
              Top = 10
              Width = 420
              Height = 19
              Caption = 'Install Trysil'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
              OnClick = ModeRadioButtonClick
            end
          end
        end
        object UpdateCardPanel: TPanel
          Left = 0
          Top = 134
          Width = 456
          Height = 62
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = 15460325
          Padding.Left = 1
          Padding.Top = 1
          Padding.Right = 1
          Padding.Bottom = 1
          ParentBackground = False
          ShowCaption = False
          TabOrder = 1
          object UpdateContentPanel: TPanel
            Left = 1
            Top = 1
            Width = 454
            Height = 60
            Align = alClient
            BevelOuter = bvNone
            Color = clWhite
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object UpdateDescriptionLabel: TLabel
              Left = 31
              Top = 33
              Width = 410
              Height = 15
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'UpdateDescriptionLabel'
              EllipsisPosition = epEndEllipsis
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 6509899
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object ModeUpdateRadioButton: TRadioButton
              Left = 13
              Top = 10
              Width = 420
              Height = 19
              Caption = 'Update Trysil to the latest release'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
              OnClick = ModeRadioButtonClick
            end
          end
        end
        object UninstallCardPanel: TPanel
          Left = 0
          Top = 200
          Width = 456
          Height = 62
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = 15460325
          Padding.Left = 1
          Padding.Top = 1
          Padding.Right = 1
          Padding.Bottom = 1
          ParentBackground = False
          ShowCaption = False
          TabOrder = 2
          object UninstallContentPanel: TPanel
            Left = 1
            Top = 1
            Width = 454
            Height = 60
            Align = alClient
            BevelOuter = bvNone
            Color = clWhite
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object UninstallDescriptionLabel: TLabel
              Left = 31
              Top = 33
              Width = 410
              Height = 15
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'UninstallDescriptionLabel'
              EllipsisPosition = epEndEllipsis
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 6509899
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object ModeUninstallRadioButton: TRadioButton
              Left = 13
              Top = 10
              Width = 420
              Height = 19
              Caption = 'Uninstall Trysil'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
              OnClick = ModeRadioButtonClick
            end
          end
        end
        object MasterCardPanel: TPanel
          Left = 0
          Top = 282
          Width = 456
          Height = 62
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = 15460325
          Padding.Left = 1
          Padding.Top = 1
          Padding.Right = 1
          Padding.Bottom = 1
          ParentBackground = False
          ShowCaption = False
          TabOrder = 3
          object MasterContentPanel: TPanel
            Left = 1
            Top = 1
            Width = 454
            Height = 60
            Align = alClient
            BevelOuter = bvNone
            Color = clWhite
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object MasterDescriptionLabel: TLabel
              Left = 31
              Top = 33
              Width = 145
              Height = 15
              Caption = 'Instead of the latest release.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 6509899
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object MasterCheckbox: TCheckBox
              Left = 13
              Top = 10
              Width = 420
              Height = 19
              Caption = 'Install the development version (master)'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
            end
          end
        end
      end
      object FolderPagePanel: TPanel
        AlignWithMargins = True
        Left = 32
        Top = 26
        Width = 456
        Height = 367
        Margins.Left = 32
        Margins.Top = 26
        Margins.Right = 32
        Margins.Bottom = 28
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 1
        DesignSize = (
          456
          367)
        object FolderTitleLabel: TLabel
          Left = 0
          Top = 0
          Width = 160
          Height = 28
          Caption = 'Installation folder'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object FolderSubtitleLabel: TLabel
          Left = 0
          Top = 38
          Width = 302
          Height = 15
          Caption = 'Sources and compiled packages of Trysil go in this folder.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object FolderLabel: TLabel
          Left = 0
          Top = 72
          Width = 35
          Height = 15
          Caption = 'Folder:'
          FocusControl = FolderTextbox
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object FolderHintLabel: TLabel
          Left = 0
          Top = 122
          Width = 335
          Height = 15
          Caption = 'The folder must be empty, or created by a previous Trysil Setup.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object FolderTextbox: TEdit
          Left = 0
          Top = 92
          Width = 360
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
        object FolderButton: TButton
          Left = 366
          Top = 91
          Width = 90
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Browse...'
          TabOrder = 1
          OnClick = FolderButtonClick
        end
        object FolderInfoPanel: TPanel
          Left = 0
          Top = 152
          Width = 456
          Height = 54
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Color = 7722738
          Padding.Left = 1
          Padding.Top = 1
          Padding.Right = 1
          Padding.Bottom = 1
          ParentBackground = False
          ShowCaption = False
          TabOrder = 2
          object FolderInfoContentPanel: TPanel
            Left = 1
            Top = 1
            Width = 454
            Height = 52
            Align = alClient
            BevelOuter = bvNone
            Color = 15137791
            Padding.Left = 10
            Padding.Top = 10
            Padding.Right = 12
            Padding.Bottom = 10
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object FolderInfoIconLabel: TLabel
              Left = 10
              Top = 10
              Width = 30
              Height = 32
              Align = alLeft
              AutoSize = False
              Caption = #9888
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 24970
              Font.Height = -20
              Font.Name = 'Segoe UI Symbol'
              Font.Style = []
              ParentFont = False
            end
            object FolderInfoLabel: TLabel
              Left = 36
              Top = 10
              Width = 406
              Height = 32
              Align = alClient
              Caption = 
                'Each Delphi version gets a $(Trysil) environment variable that p' +
                'oints inside this folder.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 5325111
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
              WordWrap = True
            end
          end
        end
      end
      object VersionsPagePanel: TPanel
        AlignWithMargins = True
        Left = 32
        Top = 26
        Width = 456
        Height = 367
        Margins.Left = 32
        Margins.Top = 26
        Margins.Right = 32
        Margins.Bottom = 28
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 2
        DesignSize = (
          456
          367)
        object VersionsTitleLabel: TLabel
          Left = 0
          Top = 0
          Width = 140
          Height = 28
          Caption = 'Delphi versions'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object VersionsLabel: TLabel
          Left = 0
          Top = 38
          Width = 205
          Height = 15
          Caption = 'Install Trysil in these versions of Delphi:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object VersionsBodyPanel: TPanel
          Left = 0
          Top = 64
          Width = 456
          Height = 305
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelOuter = bvNone
          ParentBackground = False
          ParentColor = True
          ShowCaption = False
          TabOrder = 0
          object VersionsPanel: TPanel
            Left = 0
            Top = 0
            Width = 456
            Height = 210
            Align = alTop
            AutoSize = True
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 0
            object Version1CardPanel: TPanel
              AlignWithMargins = True
              Left = 0
              Top = 0
              Width = 456
              Height = 38
              Margins.Left = 0
              Margins.Top = 0
              Margins.Right = 0
              Margins.Bottom = 4
              Align = alTop
              BevelOuter = bvNone
              Color = 15460325
              Padding.Left = 1
              Padding.Top = 1
              Padding.Right = 1
              Padding.Bottom = 1
              ParentBackground = False
              ShowCaption = False
              TabOrder = 0
              object Version1ContentPanel: TPanel
                Left = 1
                Top = 1
                Width = 454
                Height = 36
                Align = alClient
                BevelOuter = bvNone
                Color = clWhite
                ParentBackground = False
                ShowCaption = False
                TabOrder = 0
                DesignSize = (
                  454
                  36)
                object Version1PaintBox: TPaintBox
                  Left = 220
                  Top = 0
                  Width = 234
                  Height = 36
                  Anchors = [akLeft, akTop, akRight, akBottom]
                end
                object Version1Checkbox: TCheckBox
                  Left = 11
                  Top = 9
                  Width = 200
                  Height = 19
                  Caption = 'Version1Checkbox'
                  Checked = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'Segoe UI'
                  Font.Style = [fsBold]
                  ParentFont = False
                  State = cbChecked
                  TabOrder = 0
                end
              end
            end
            object Version2CardPanel: TPanel
              AlignWithMargins = True
              Left = 0
              Top = 42
              Width = 456
              Height = 38
              Margins.Left = 0
              Margins.Top = 0
              Margins.Right = 0
              Margins.Bottom = 4
              Align = alTop
              BevelOuter = bvNone
              Color = 15460325
              Padding.Left = 1
              Padding.Top = 1
              Padding.Right = 1
              Padding.Bottom = 1
              ParentBackground = False
              ShowCaption = False
              TabOrder = 1
              object Version2ContentPanel: TPanel
                Left = 1
                Top = 1
                Width = 454
                Height = 36
                Align = alClient
                BevelOuter = bvNone
                Color = clWhite
                ParentBackground = False
                ShowCaption = False
                TabOrder = 0
                DesignSize = (
                  454
                  36)
                object Version2PaintBox: TPaintBox
                  Left = 220
                  Top = 0
                  Width = 234
                  Height = 36
                  Anchors = [akLeft, akTop, akRight, akBottom]
                end
                object Version2Checkbox: TCheckBox
                  Left = 11
                  Top = 9
                  Width = 200
                  Height = 19
                  Caption = 'Version2Checkbox'
                  Checked = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'Segoe UI'
                  Font.Style = [fsBold]
                  ParentFont = False
                  State = cbChecked
                  TabOrder = 0
                end
              end
            end
            object Version3CardPanel: TPanel
              AlignWithMargins = True
              Left = 0
              Top = 84
              Width = 456
              Height = 38
              Margins.Left = 0
              Margins.Top = 0
              Margins.Right = 0
              Margins.Bottom = 4
              Align = alTop
              BevelOuter = bvNone
              Color = 15460325
              Padding.Left = 1
              Padding.Top = 1
              Padding.Right = 1
              Padding.Bottom = 1
              ParentBackground = False
              ShowCaption = False
              TabOrder = 2
              object Version3ContentPanel: TPanel
                Left = 1
                Top = 1
                Width = 454
                Height = 36
                Align = alClient
                BevelOuter = bvNone
                Color = clWhite
                ParentBackground = False
                ShowCaption = False
                TabOrder = 0
                DesignSize = (
                  454
                  36)
                object Version3PaintBox: TPaintBox
                  Left = 220
                  Top = 0
                  Width = 234
                  Height = 36
                  Anchors = [akLeft, akTop, akRight, akBottom]
                end
                object Version3Checkbox: TCheckBox
                  Left = 11
                  Top = 9
                  Width = 200
                  Height = 19
                  Caption = 'Version3Checkbox'
                  Checked = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'Segoe UI'
                  Font.Style = [fsBold]
                  ParentFont = False
                  State = cbChecked
                  TabOrder = 0
                end
              end
            end
            object Version4CardPanel: TPanel
              AlignWithMargins = True
              Left = 0
              Top = 126
              Width = 456
              Height = 38
              Margins.Left = 0
              Margins.Top = 0
              Margins.Right = 0
              Margins.Bottom = 4
              Align = alTop
              BevelOuter = bvNone
              Color = 15460325
              Padding.Left = 1
              Padding.Top = 1
              Padding.Right = 1
              Padding.Bottom = 1
              ParentBackground = False
              ShowCaption = False
              TabOrder = 3
              object Version4ContentPanel: TPanel
                Left = 1
                Top = 1
                Width = 454
                Height = 36
                Align = alClient
                BevelOuter = bvNone
                Color = clWhite
                ParentBackground = False
                ShowCaption = False
                TabOrder = 0
                DesignSize = (
                  454
                  36)
                object Version4PaintBox: TPaintBox
                  Left = 220
                  Top = 0
                  Width = 234
                  Height = 36
                  Anchors = [akLeft, akTop, akRight, akBottom]
                end
                object Version4Checkbox: TCheckBox
                  Left = 11
                  Top = 9
                  Width = 200
                  Height = 19
                  Caption = 'Version4Checkbox'
                  Checked = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'Segoe UI'
                  Font.Style = [fsBold]
                  ParentFont = False
                  State = cbChecked
                  TabOrder = 0
                end
              end
            end
            object Version5CardPanel: TPanel
              AlignWithMargins = True
              Left = 0
              Top = 168
              Width = 456
              Height = 38
              Margins.Left = 0
              Margins.Top = 0
              Margins.Right = 0
              Margins.Bottom = 4
              Align = alTop
              BevelOuter = bvNone
              Color = 15460325
              Padding.Left = 1
              Padding.Top = 1
              Padding.Right = 1
              Padding.Bottom = 1
              ParentBackground = False
              ShowCaption = False
              TabOrder = 4
              object Version5ContentPanel: TPanel
                Left = 1
                Top = 1
                Width = 454
                Height = 36
                Align = alClient
                BevelOuter = bvNone
                Color = clWhite
                ParentBackground = False
                ShowCaption = False
                TabOrder = 0
                DesignSize = (
                  454
                  36)
                object Version5PaintBox: TPaintBox
                  Left = 220
                  Top = 0
                  Width = 234
                  Height = 36
                  Anchors = [akLeft, akTop, akRight, akBottom]
                end
                object Version5Checkbox: TCheckBox
                  Left = 11
                  Top = 9
                  Width = 200
                  Height = 19
                  Caption = 'Version5Checkbox'
                  Checked = True
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'Segoe UI'
                  Font.Style = [fsBold]
                  ParentFont = False
                  State = cbChecked
                  TabOrder = 0
                end
              end
            end
          end
          object VersionsLegendPanel: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 214
            Width = 456
            Height = 44
            Margins.Left = 0
            Margins.Top = 4
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 1
            object PackagesChipLabel: TLabel
              Left = 0
              Top = 2
              Width = 70
              Height = 18
              Alignment = taCenter
              AutoSize = False
              Caption = 'Packages'
              Color = 16710351
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 7691797
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentColor = False
              ParentFont = False
              Transparent = False
              Layout = tlCenter
            end
            object PackagesLegendLabel: TLabel
              Left = 80
              Top = 3
              Width = 160
              Height = 15
              Caption = 'Built from the command line.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 6509899
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object SourcesChipLabel: TLabel
              Left = 0
              Top = 24
              Width = 70
              Height = 18
              Alignment = taCenter
              AutoSize = False
              Caption = 'Sources'
              Color = 13104126
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 934034
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentColor = False
              ParentFont = False
              Transparent = False
              Layout = tlCenter
            end
            object SourcesLegendLabel: TLabel
              Left = 80
              Top = 25
              Width = 360
              Height = 15
              Caption = 
                'The command line build is not available: the sources go in the' +
                ' search path.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 6509899
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
          end
          object ExpertCardPanel: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 278
            Width = 456
            Height = 62
            Margins.Left = 0
            Margins.Top = 20
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alTop
            BevelOuter = bvNone
            Color = 15460325
            Padding.Left = 1
            Padding.Top = 1
            Padding.Right = 1
            Padding.Bottom = 1
            ParentBackground = False
            ShowCaption = False
            TabOrder = 2
            object ExpertContentPanel: TPanel
              Left = 1
              Top = 1
              Width = 454
              Height = 60
              Align = alClient
              BevelOuter = bvNone
              Color = clWhite
              ParentBackground = False
              ShowCaption = False
              TabOrder = 0
              object ExpertDescriptionLabel: TLabel
                Left = 31
                Top = 33
                Width = 334
                Height = 15
                Caption = 
                  'Visual designer for entities, SQL and REST, inside the Delphi ID' +
                  'E.'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = 6509899
                Font.Height = -12
                Font.Name = 'Segoe UI'
                Font.Style = []
                ParentFont = False
              end
              object ExpertCheckbox: TCheckBox
                Left = 13
                Top = 10
                Width = 420
                Height = 19
                Caption = 'Install Trysil Expert'
                Checked = True
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -13
                Font.Name = 'Segoe UI'
                Font.Style = [fsBold]
                ParentFont = False
                State = cbChecked
                TabOrder = 0
              end
            end
          end
        end
      end
      object SummaryPagePanel: TPanel
        AlignWithMargins = True
        Left = 32
        Top = 26
        Width = 456
        Height = 367
        Margins.Left = 32
        Margins.Top = 26
        Margins.Right = 32
        Margins.Bottom = 28
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 3
        DesignSize = (
          456
          367)
        object SummaryTitleLabel: TLabel
          Left = 0
          Top = 0
          Width = 138
          Height = 28
          Caption = 'Ready to install'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object SummarySubtitleLabel: TLabel
          Left = 0
          Top = 38
          Width = 456
          Height = 15
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'SummarySubtitleLabel'
          EllipsisPosition = epEndEllipsis
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object SummaryListView: TListView
          Left = 0
          Top = 68
          Width = 456
          Height = 299
          Anchors = [akLeft, akTop, akRight, akBottom]
          Columns = <
            item
              Width = 130
            end
            item
              AutoSize = True
            end>
          ReadOnly = True
          ShowColumnHeaders = False
          SmallImages = SummaryImageList
          TabOrder = 0
          ViewStyle = vsReport
          OnCustomDrawItem = SummaryListViewCustomDrawItem
          OnCustomDrawSubItem = SummaryListViewCustomDrawSubItem
          OnSelectItem = SummaryListViewSelectItem
        end
      end
      object ProgressPagePanel: TPanel
        AlignWithMargins = True
        Left = 32
        Top = 26
        Width = 456
        Height = 367
        Margins.Left = 32
        Margins.Top = 26
        Margins.Right = 32
        Margins.Bottom = 28
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 4
        DesignSize = (
          456
          367)
        object ProgressTitleLabel: TLabel
          Left = 0
          Top = 0
          Width = 135
          Height = 28
          Caption = 'Installing Trysil'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object ProgressCurrentLabel: TLabel
          Left = 0
          Top = 38
          Width = 456
          Height = 15
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          EllipsisPosition = epEndEllipsis
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object ProgressBodyPanel: TPanel
          Left = 0
          Top = 60
          Width = 456
          Height = 307
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelOuter = bvNone
          ParentBackground = False
          ParentColor = True
          ShowCaption = False
          TabOrder = 0
          object ProgressBarPanel: TPanel
            Left = 0
            Top = 0
            Width = 456
            Height = 16
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 0
            object ProgressPercentLabel: TLabel
              Left = 416
              Top = 0
              Width = 40
              Height = 16
              Align = alRight
              Alignment = taRightJustify
              AutoSize = False
              Caption = '0%'
              Layout = tlCenter
            end
            object ProgressTrackPanel: TPanel
              AlignWithMargins = True
              Left = 0
              Top = 5
              Width = 408
              Height = 6
              Margins.Left = 0
              Margins.Top = 5
              Margins.Right = 8
              Margins.Bottom = 5
              Align = alClient
              BevelOuter = bvNone
              Color = 15460325
              ParentBackground = False
              ShowCaption = False
              TabOrder = 0
              object ProgressFillPanel: TPanel
                Left = 0
                Top = 0
                Width = 0
                Height = 6
                Align = alLeft
                BevelOuter = bvNone
                Color = 9466894
                ParentBackground = False
                ShowCaption = False
                TabOrder = 0
              end
            end
          end
          object ProgressVersionsPanel: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 30
            Width = 456
            Height = 120
            Margins.Left = 0
            Margins.Top = 14
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alTop
            AutoSize = True
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 1
          object ProgressVersion1Panel: TPanel
            Left = 0
            Top = 0
            Width = 456
            Height = 24
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 0
            Visible = False
            object ProgressVersion1GlyphLabel: TLabel
              Left = 0
              Top = 0
              Width = 22
              Height = 24
              Align = alLeft
              AutoSize = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI Symbol'
              Font.Style = []
              ParentFont = False
              Layout = tlCenter
            end
            object ProgressVersion1StateLabel: TLabel
              Left = 366
              Top = 0
              Width = 90
              Height = 24
              Align = alRight
              Alignment = taRightJustify
              AutoSize = False
              Layout = tlCenter
            end
            object ProgressVersion1NameLabel: TLabel
              Left = 22
              Top = 0
              Width = 344
              Height = 24
              Align = alClient
              AutoSize = False
              EllipsisPosition = epEndEllipsis
              Layout = tlCenter
            end
          end
          object ProgressVersion2Panel: TPanel
            Left = 0
            Top = 24
            Width = 456
            Height = 24
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 1
            Visible = False
            object ProgressVersion2GlyphLabel: TLabel
              Left = 0
              Top = 0
              Width = 22
              Height = 24
              Align = alLeft
              AutoSize = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI Symbol'
              Font.Style = []
              ParentFont = False
              Layout = tlCenter
            end
            object ProgressVersion2StateLabel: TLabel
              Left = 366
              Top = 0
              Width = 90
              Height = 24
              Align = alRight
              Alignment = taRightJustify
              AutoSize = False
              Layout = tlCenter
            end
            object ProgressVersion2NameLabel: TLabel
              Left = 22
              Top = 0
              Width = 344
              Height = 24
              Align = alClient
              AutoSize = False
              EllipsisPosition = epEndEllipsis
              Layout = tlCenter
            end
          end
          object ProgressVersion3Panel: TPanel
            Left = 0
            Top = 48
            Width = 456
            Height = 24
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 2
            Visible = False
            object ProgressVersion3GlyphLabel: TLabel
              Left = 0
              Top = 0
              Width = 22
              Height = 24
              Align = alLeft
              AutoSize = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI Symbol'
              Font.Style = []
              ParentFont = False
              Layout = tlCenter
            end
            object ProgressVersion3StateLabel: TLabel
              Left = 366
              Top = 0
              Width = 90
              Height = 24
              Align = alRight
              Alignment = taRightJustify
              AutoSize = False
              Layout = tlCenter
            end
            object ProgressVersion3NameLabel: TLabel
              Left = 22
              Top = 0
              Width = 344
              Height = 24
              Align = alClient
              AutoSize = False
              EllipsisPosition = epEndEllipsis
              Layout = tlCenter
            end
          end
          object ProgressVersion4Panel: TPanel
            Left = 0
            Top = 72
            Width = 456
            Height = 24
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 3
            Visible = False
            object ProgressVersion4GlyphLabel: TLabel
              Left = 0
              Top = 0
              Width = 22
              Height = 24
              Align = alLeft
              AutoSize = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI Symbol'
              Font.Style = []
              ParentFont = False
              Layout = tlCenter
            end
            object ProgressVersion4StateLabel: TLabel
              Left = 366
              Top = 0
              Width = 90
              Height = 24
              Align = alRight
              Alignment = taRightJustify
              AutoSize = False
              Layout = tlCenter
            end
            object ProgressVersion4NameLabel: TLabel
              Left = 22
              Top = 0
              Width = 344
              Height = 24
              Align = alClient
              AutoSize = False
              EllipsisPosition = epEndEllipsis
              Layout = tlCenter
            end
          end
          object ProgressVersion5Panel: TPanel
            Left = 0
            Top = 96
            Width = 456
            Height = 24
            Align = alTop
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 4
            Visible = False
            object ProgressVersion5GlyphLabel: TLabel
              Left = 0
              Top = 0
              Width = 22
              Height = 24
              Align = alLeft
              AutoSize = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Segoe UI Symbol'
              Font.Style = []
              ParentFont = False
              Layout = tlCenter
            end
            object ProgressVersion5StateLabel: TLabel
              Left = 366
              Top = 0
              Width = 90
              Height = 24
              Align = alRight
              Alignment = taRightJustify
              AutoSize = False
              Layout = tlCenter
            end
            object ProgressVersion5NameLabel: TLabel
              Left = 22
              Top = 0
              Width = 344
              Height = 24
              Align = alClient
              AutoSize = False
              EllipsisPosition = epEndEllipsis
              Layout = tlCenter
            end
          end
          end
          object ProgressLogBoxPanel: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 164
            Width = 456
            Height = 143
            Margins.Left = 0
            Margins.Top = 14
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alClient
            BevelOuter = bvNone
            ParentBackground = False
            ParentColor = True
            ShowCaption = False
            TabOrder = 2
            Visible = False
            object ProgressLogLabel: TLabel
              AlignWithMargins = True
              Left = 0
              Top = 0
              Width = 456
              Height = 15
              Margins.Left = 0
              Margins.Top = 0
              Margins.Right = 0
              Margins.Bottom = 6
              Align = alTop
              Caption = 'Log'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 5325111
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object ProgressLogPanel: TPanel
              Left = 0
              Top = 21
              Width = 456
              Height = 122
              Align = alClient
              BevelOuter = bvNone
              Color = 1446158
              Padding.Left = 10
              Padding.Top = 8
              Padding.Right = 4
              Padding.Bottom = 4
              ParentBackground = False
              ShowCaption = False
              TabOrder = 0
              object ProgressMemo: TMemo
                Left = 10
                Top = 8
                Width = 442
                Height = 110
                Align = alClient
                BorderStyle = bsNone
                Color = 1446158
                Font.Charset = DEFAULT_CHARSET
                Font.Color = 14275017
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
          end
        end
      end
      object CompletedPagePanel: TPanel
        AlignWithMargins = True
        Left = 32
        Top = 26
        Width = 456
        Height = 367
        Margins.Left = 32
        Margins.Top = 26
        Margins.Right = 32
        Margins.Bottom = 28
        BevelOuter = bvNone
        ParentBackground = False
        ParentColor = True
        ShowCaption = False
        TabOrder = 5
        DesignSize = (
          456
          367)
        object CompletedTitleLabel: TLabel
          Left = 0
          Top = 0
          Width = 208
          Height = 28
          Caption = 'Trysil Setup completed'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object CompletedInfoLabel: TLabel
          Left = 0
          Top = 38
          Width = 456
          Height = 15
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          EllipsisPosition = epEndEllipsis
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 6509899
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object CompletedDocsLinkLabel: TLinkLabel
          Left = 0
          Top = 72
          Width = 195
          Height = 19
          Caption = 
            'Get started with the <a href="https://davidlastrucci.github.io/T' +
            'rysil">documentation</a>.'
          TabOrder = 0
          OnLinkClick = CompletedDocsLinkLabelLinkClick
        end
        object CompletedLogLinkLabel: TLinkLabel
          Left = 0
          Top = 72
          Width = 170
          Height = 19
          Caption = 'See the <a>log</a> for the details.'
          TabOrder = 1
          Visible = False
          OnLinkClick = CompletedLogLinkLabelLinkClick
        end
      end
    end
    object ButtonsPanel: TPanel
      Left = 0
      Top = 424
      Width = 506
      Height = 56
      Align = alBottom
      BevelOuter = bvNone
      Color = 16513785
      Padding.Left = 20
      Padding.Top = 15
      Padding.Right = 20
      Padding.Bottom = 15
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      ExplicitWidth = 520
      object LogButton: TButton
        Left = 20
        Top = 15
        Width = 90
        Height = 26
        Align = alLeft
        Caption = '&Show log'
        TabOrder = 0
        Visible = False
        OnClick = LogButtonClick
      end
      object BackButton: TButton
        AlignWithMargins = True
        Left = 243
        Top = 15
        Width = 75
        Height = 26
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 6
        Margins.Bottom = 0
        Align = alRight
        Caption = '&Back'
        Enabled = False
        TabOrder = 1
        OnClick = BackButtonClick
        ExplicitLeft = 257
      end
      object NextButton: TButton
        AlignWithMargins = True
        Left = 324
        Top = 15
        Width = 75
        Height = 26
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 12
        Margins.Bottom = 0
        Align = alRight
        Caption = '&Next'
        Default = True
        TabOrder = 2
        OnClick = NextButtonClick
        ExplicitLeft = 338
      end
      object CancelButton: TButton
        Left = 411
        Top = 15
        Width = 75
        Height = 26
        Align = alRight
        Cancel = True
        Caption = 'Cancel'
        TabOrder = 3
        OnClick = CancelButtonClick
        ExplicitLeft = 425
      end
    end
  end
  object FolderDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoForceFileSystem]
    Title = 'Installation folder'
    Left = 112
    Top = 400
  end
  object SummaryImageList: TImageList
    Height = 22
    Width = 1
    Left = 112
    Top = 344
  end
end
