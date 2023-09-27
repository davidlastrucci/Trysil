(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
library Trysil.Expert280;

uses
  System.SysUtils,
  System.Classes,
  Trysil.Expert.Consts in 'Classes\Trysil.Expert.Consts.pas',
  Trysil.Expert.Classes in 'Classes\Trysil.Expert.Classes.pas',
  Trysil.Expert.Validator in 'Classes\Trysil.Expert.Validator.pas',
  Trysil.Expert.EntryPoint in 'Trysil.Expert.EntryPoint.pas',
  Trysil.Expert in 'Trysil.Expert.pas',
  Trysil.Expert.AboutBoxServices in 'Trysil.Expert.AboutBoxServices.pas',
  Trysil.Expert.ActionsMenu in 'Trysil.Expert.ActionsMenu.pas' {TActionsMenuDatamodule: TDataModule},
  Trysil.Expert.SourceFile in 'Classes\Trysil.Expert.SourceFile.pas',
  Trysil.Expert.ModuleCreator in 'Classes\Trysil.Expert.ModuleCreator.pas',
  Trysil.Expert.SourceWriter in 'Classes\Trysil.Expert.SourceWriter.pas',
  Trysil.Expert.SQLCreator in 'Classes\Trysil.Expert.SQLCreator.pas',
  Trysil.Expert.PascalCreator in 'Classes\Trysil.Expert.PascalCreator.pas',
  Trysil.Expert.Config in 'Model\Trysil.Expert.Config.pas',
  Trysil.Expert.Model in 'Model\Trysil.Expert.Model.pas',
  Trysil.Expert.Project in 'Model\Trysil.Expert.Project.pas',
  Trysil.Expert.UI.Themes in 'UI\Trysil.Expert.UI.Themes.pas',
  Trysil.Expert.UI.Images in 'UI\Trysil.Expert.UI.Images.pas' {TImagesDataModule: TDataModule},
  Trysil.Expert.UI.Themed in 'UI\Trysil.Expert.UI.Themed.pas' {TThemedForm},
  Trysil.Expert.UI.Classes in 'UI\Trysil.Expert.UI.Classes.pas',
  Trysil.Expert.UI.Design in 'UI\Trysil.Expert.UI.Design.pas' {TDesignForm},
  Trysil.Expert.UI.DesignEntity in 'UI\Trysil.Expert.UI.DesignEntity.pas' {TDesignEntityForm},
  Trysil.Expert.UI.DesignColumn in 'UI\Trysil.Expert.UI.DesignColumn.pas' {TDesignColumnForm},
  Trysil.Expert.UI.DesignColumn.DataTypeColumn in 'UI\Trysil.Expert.UI.DesignColumn.DataTypeColumn.pas' {TDesignDataTypeColumnForm: TFrame},
  Trysil.Expert.UI.DesignColumn.EntityTypeColumn in 'UI\Trysil.Expert.UI.DesignColumn.EntityTypeColumn.pas' {TDesignEntityTypeColumnForm: TFrame},
  Trysil.Expert.UI.DesignColumn.EntityListTypeColumn in 'UI\Trysil.Expert.UI.DesignColumn.EntityListTypeColumn.pas' {TDesignEntityListTypeColumnForm: TFrame},
  Trysil.Expert.UI.GenerateSQL in 'UI\Trysil.Expert.UI.GenerateSQL.pas' {TGenerateSQL},
  Trysil.Expert.UI.GenerateModel in 'UI\Trysil.Expert.UI.GenerateModel.pas' {TGenerateModel},
  Trysil.Expert.UI.Settings in 'UI\Trysil.Expert.UI.Settings.pas' {TSettingsForm},
  Trysil.Expert.UI.About in 'UI\Trysil.Expert.UI.About.pas' {TAboutForm};

{$R *.res}

begin
end.
