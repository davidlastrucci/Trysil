(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
library Trysil.Expert290;

uses
  System.SysUtils,
  System.Classes,
  Trysil.Expert.Consts in 'Classes\Trysil.Expert.Consts.pas',
  Trysil.Expert.Classes in 'Classes\Trysil.Expert.Classes.pas',
  Trysil.Expert.IOTA.Services in 'IOTA\Trysil.Expert.IOTA.Services.pas',
  Trysil.Expert.IOTA.SourceFile in 'IOTA\Trysil.Expert.IOTA.SourceFile.pas',
  Trysil.Expert.IOTA.ModuleCreator in 'IOTA\Trysil.Expert.IOTA.ModuleCreator.pas',
  Trysil.Expert.IOTA in 'IOTA\Trysil.Expert.IOTA.pas',
  Trysil.Expert.Validator in 'Classes\Trysil.Expert.Validator.pas',
  Trysil.Expert.EntryPoint in 'Trysil.Expert.EntryPoint.pas',
  Trysil.Expert in 'Trysil.Expert.pas',
  Trysil.Expert.AboutBoxServices in 'Trysil.Expert.AboutBoxServices.pas',
  Trysil.Expert.ActionsMenu in 'Trysil.Expert.ActionsMenu.pas' {TActionsMenuDatamodule: TDataModule},
  Trysil.Expert.SourceWriter in 'Classes\Trysil.Expert.SourceWriter.pas',
  Trysil.Expert.SQLCreator in 'Classes\Trysil.Expert.SQLCreator.pas',
  Trysil.Expert.Schema in 'Classes\Trysil.Expert.Schema.pas',
  Trysil.Expert.SchemaReader in 'Classes\Trysil.Expert.SchemaReader.pas',
  Trysil.Expert.SQLUpdateCreator in 'Classes\Trysil.Expert.SQLUpdateCreator.pas',
  Trysil.Expert.ModelCreator in 'Classes\Trysil.Expert.ModelCreator.pas',
  Trysil.Expert.ControllerCreator in 'Classes\Trysil.Expert.ControllerCreator.pas',
  Trysil.Expert.RuleCreator in 'Classes\Trysil.Expert.RuleCreator.pas',
  Trysil.Expert.APIHttpModifier in 'Classes\Trysil.Expert.APIHttpModifier.pas',
  Trysil.Expert.APIRest.Parameters in 'Classes\Trysil.Expert.APIRest.Parameters.pas',
  Trysil.Expert.APIRest.Template in 'Classes\Trysil.Expert.APIRest.Template.pas',
  Trysil.Expert.APIRest.Features in 'Classes\Trysil.Expert.APIRest.Features.pas',
  Trysil.Expert.APIRest.Configuration in 'Classes\Trysil.Expert.APIRest.Configuration.pas',
  Trysil.Expert.APIRest.Project in 'Classes\Trysil.Expert.APIRest.Project.pas',
  Trysil.Expert.APIRestCreator in 'Classes\Trysil.Expert.APIRestCreator.pas',
  Trysil.Expert.SkillsInstaller in 'Classes\Trysil.Expert.SkillsInstaller.pas',
  Trysil.Expert.Config in 'Model\Trysil.Expert.Config.pas',
  Trysil.Expert.Model in 'Model\Trysil.Expert.Model.pas',
  Trysil.Expert.Project in 'Model\Trysil.Expert.Project.pas',
  Trysil.Expert.UI.Themes in 'UI\Trysil.Expert.UI.Themes.pas',
  Trysil.Expert.UI.Images in 'UI\Trysil.Expert.UI.Images.pas' {TImagesDataModule: TDataModule},
  Trysil.Expert.UI.Themed in 'UI\Trysil.Expert.UI.Themed.pas' {TThemedForm},
  Trysil.Expert.UI.Classes in 'UI\Trysil.Expert.UI.Classes.pas',
  Trysil.Expert.UI.Wizard in 'UI\Trysil.Expert.UI.Wizard.pas',
  Trysil.Expert.UI.Prompter in 'UI\Trysil.Expert.UI.Prompter.pas',
  Trysil.Expert.UI.Design in 'UI\Trysil.Expert.UI.Design.pas' {TDesignForm},
  Trysil.Expert.UI.DesignEntity in 'UI\Trysil.Expert.UI.DesignEntity.pas' {TDesignEntityForm},
  Trysil.Expert.UI.DesignColumn in 'UI\Trysil.Expert.UI.DesignColumn.pas' {TDesignColumnForm},
  Trysil.Expert.UI.DesignColumn.DataTypeColumn in 'UI\Trysil.Expert.UI.DesignColumn.DataTypeColumn.pas' {TDesignDataTypeColumnForm: TFrame},
  Trysil.Expert.UI.DesignColumn.EntityTypeColumn in 'UI\Trysil.Expert.UI.DesignColumn.EntityTypeColumn.pas' {TDesignEntityTypeColumnForm: TFrame},
  Trysil.Expert.UI.DesignColumn.EntityListTypeColumn in 'UI\Trysil.Expert.UI.DesignColumn.EntityListTypeColumn.pas' {TDesignEntityListTypeColumnForm: TFrame},
  Trysil.Expert.UI.GenerateSQL in 'UI\Trysil.Expert.UI.GenerateSQL.pas' {TGenerateSQL},
  Trysil.Expert.UI.ReferenceDatabase in 'UI\Trysil.Expert.UI.ReferenceDatabase.pas' {TReferenceDatabaseForm},
  Trysil.Expert.UI.GenerateModel in 'UI\Trysil.Expert.UI.GenerateModel.pas' {TGenerateModel},
  Trysil.Expert.UI.APIREST in 'UI\Trysil.Expert.UI.APIREST.pas' {TAPIRestForm},
  Trysil.Expert.UI.InstallSkills in 'UI\Trysil.Expert.UI.InstallSkills.pas' {TInstallSkillsForm},
  Trysil.Expert.UI.Settings in 'UI\Trysil.Expert.UI.Settings.pas' {TSettingsForm},
  Trysil.Expert.UI.About in 'UI\Trysil.Expert.UI.About.pas' {TAboutForm};

{$R *.res}

begin
end.
