object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Trysil - Blob demo'
  ClientHeight = 355
  ClientWidth = 234
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object ImageImage: TImage
    Left = 8
    Top = 97
    Width = 216
    Height = 216
    Center = True
  end
  object WriteImagesButton: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = 'Write Images'
    TabOrder = 0
    OnClick = WriteImagesButtonClick
  end
  object ReadImagesButton: TButton
    Left = 119
    Top = 8
    Width = 105
    Height = 25
    Caption = 'Read Images'
    TabOrder = 1
    OnClick = ReadImagesButtonClick
  end
  object IDTextbox: TEdit
    Left = 8
    Top = 39
    Width = 53
    Height = 23
    ReadOnly = True
    TabOrder = 2
  end
  object NameTextbox: TEdit
    Left = 8
    Top = 68
    Width = 216
    Height = 23
    TabOrder = 3
  end
  object PriorButton: TButton
    Left = 38
    Top = 319
    Width = 75
    Height = 25
    Caption = '<'
    TabOrder = 4
    OnClick = PriorButtonClick
  end
  object NextButton: TButton
    Left = 119
    Top = 319
    Width = 75
    Height = 25
    Caption = '>'
    TabOrder = 5
    OnClick = NextButtonClick
  end
end
