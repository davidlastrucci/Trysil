object EditDialog: TEditDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'MasterData'
  ClientHeight = 210
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object IDTextbox: TEdit
    Left = 8
    Top = 8
    Width = 53
    Height = 21
    Enabled = False
    MaxLength = 30
    TabOrder = 0
    TextHint = 'ID'
  end
  object FirstnameTextbox: TEdit
    Left = 8
    Top = 35
    Width = 285
    Height = 21
    MaxLength = 30
    TabOrder = 1
    TextHint = 'First name'
  end
  object LastnameTextbox: TEdit
    Left = 8
    Top = 62
    Width = 285
    Height = 21
    MaxLength = 30
    TabOrder = 2
    TextHint = 'Last name'
  end
  object CompanyTextbox: TEdit
    Left = 8
    Top = 89
    Width = 285
    Height = 21
    MaxLength = 50
    TabOrder = 3
    TextHint = 'Company'
  end
  object EmailTextbox: TEdit
    Left = 8
    Top = 116
    Width = 285
    Height = 21
    MaxLength = 255
    TabOrder = 4
    TextHint = 'E-Mail'
  end
  object PhoneTextbox: TEdit
    Left = 8
    Top = 143
    Width = 285
    Height = 21
    MaxLength = 20
    TabOrder = 5
    TextHint = 'Phone'
  end
  object SaveButton: TButton
    Left = 137
    Top = 170
    Width = 75
    Height = 25
    Caption = 'Save'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object CancelButton: TButton
    Left = 218
    Top = 170
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
end
