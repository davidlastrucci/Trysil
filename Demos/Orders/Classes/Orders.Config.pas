(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.IOUtils,
  Trysil.Data.FireDAC;

type

{ TConfig }

  TConfig = class
  strict private
    FParameters: TTFireDACConnectionParameters;

    function CreateJSonConfig: TJSonValue;
    function CreateParameters(
      const AConfig: TJSonValue): TTFireDACConnectionParameters;
    procedure LoadConfig;
  public
    procedure AfterConstruction; override;

    property Parameters: TTFireDACConnectionParameters read FParameters;
  end;

resourcestring
  SConfigNotFound = 'Configuration file "%s" not found.';
  SConfigNotValid = 'Configuration file "%s" not valid.';
  SActiveNotDefined = 'Active configuration not defined.';
  SConfigurationsNotDefined = 'Configurations object not defined.';
  SActiveConfigNotFound = 'Configuration "%s" not found.';

implementation

{ TConfig }

procedure TConfig.AfterConstruction;
begin
  inherited AfterConstruction;
  LoadConfig();
end;

function TConfig.CreateJSonConfig: TJSonValue;
var
  LFileName: String;
  LJSon: TJSonValue;
begin
  LFileName := TPath.ChangeExtension(ParamStr(0), '.Config.json');
  if not TFile.Exists(LFileName, False) then
    raise EFileNotFoundException.CreateFmt(SConfigNotFound, [LFileName]);

  LJSon := TJSonObject.ParseJSONValue(TFile.ReadAllText(LFileName));
  if not (LJSon is TJSonObject) then
  begin
    LJSon.Free;
    raise EJSonException.CreateFmt(SConfigNotValid, [LFileName]);
  end;

  result := TJSonObject(LJSon);
end;

function TConfig.CreateParameters(
  const AConfig: TJSonValue): TTFireDACConnectionParameters;
begin
  result := TTFireDACConnectionParameters.Create(
    AConfig.GetValue<String>('driver', String.Empty),
    AConfig.GetValue<String>('server', String.Empty),
    AConfig.GetValue<String>('username', String.Empty),
    AConfig.GetValue<String>('password', String.Empty),
    AConfig.GetValue<String>('databasename', String.Empty));
end;

procedure TConfig.LoadConfig;
var
  LJSon, LConfigurations, LActiveConfig: TJSonValue;
  LActive: String;
begin
  LJSon := CreateJSonConfig();
  try
    LActive := LJSon.GetValue<String>('active', String.Empty);
    if LActive.IsEmpty then
      raise EJSonException.Create(SActiveNotDefined);

    LConfigurations := LJSon.GetValue<TJSonObject>('configurations', nil);
    if not Assigned(LConfigurations) then
      raise EJSonException.Create(SConfigurationsNotDefined);

    LActiveConfig := LConfigurations.GetValue<TJSonObject>(LActive, nil);
    if not Assigned(LActiveConfig) then
      raise EJSonException.CreateFmt(SActiveConfigNotFound, [LActive]);

    FParameters := CreateParameters(LActiveConfig);
  finally
    LJSon.Free;
  end;
end;

end.
