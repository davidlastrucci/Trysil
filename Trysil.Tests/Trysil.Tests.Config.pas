(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Config;

interface

uses
  System.Generics.Collections;

type

{ TTTestConfig }

  TTTestConfig = class
  strict private
    class var FEnabled: TDictionary<String, Boolean>;
    class var FParams: TDictionary<String, String>;

    class procedure LoadConfig;

    class destructor ClassDestroy;
  public
    class procedure PrintConfig;

    class function GetConfigFile: String;
    class function EnabledDatabaseCount: Integer;

    class function IsDatabaseEnabled(
      const ADatabaseName: String): Boolean;

    class function CharacterSetSuffix(
      const ADatabaseName: String): String;

    class function GetDatabaseParam(
      const ADatabaseName: String;
      const AParamName: String): String;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.JSON;

{ TTTestConfig }

class destructor TTTestConfig.ClassDestroy;
begin
  FParams.Free;
  FEnabled.Free;
end;

class function TTTestConfig.GetConfigFile: String;
const
  ConfigFileName = 'Trysil.Tests.json';
  MaxParentLevels = 4;
var
  LFolder: String;
  LCandidate: String;
  LLevel: Integer;
begin
  result := String.Empty;
  LFolder := ExtractFilePath(ParamStr(0));
  LLevel := 0;
  while result.IsEmpty and (LLevel <= MaxParentLevels) and
    (not LFolder.IsEmpty) do
  begin
    LCandidate := TPath.Combine(LFolder, ConfigFileName);
    if TFile.Exists(LCandidate) then
      result := LCandidate
    else
    begin
      LFolder := ExtractFilePath(ExcludeTrailingPathDelimiter(LFolder));
      Inc(LLevel);
    end;
  end;
end;

class function TTTestConfig.EnabledDatabaseCount: Integer;
var
  LEnabled: Boolean;
begin
  if not Assigned(FEnabled) then
    LoadConfig;

  result := 0;
  for LEnabled in FEnabled.Values do
    if LEnabled then
      Inc(result);
end;

class procedure TTTestConfig.LoadConfig;
var
  LContent: String;
  LRoot: TJSONValue;
  LDatabases: TJSONValue;
  LDbPair: TJSONPair;
  LDbName: String;
  LDbConfig: TJSONObject;
  LEnabledValue: TJSONValue;
  LParamPair: TJSONPair;
begin
  FEnabled := TDictionary<String, Boolean>.Create;
  FParams := TDictionary<String, String>.Create;

  if TFile.Exists(GetConfigFile) then
  begin
    LContent := TFile.ReadAllText(GetConfigFile);
    LRoot := TJSONObject.ParseJSONValue(LContent);
    try
      if LRoot is TJSONObject then
      begin
        LDatabases := TJSONObject(LRoot).GetValue('databases');
        if LDatabases is TJSONObject then
          for LDbPair in TJSONObject(LDatabases) do
            if LDbPair.JsonValue is TJSONObject then
            begin
              LDbName := LDbPair.JsonString.Value.ToLowerInvariant;
              LDbConfig := TJSONObject(LDbPair.JsonValue);
              LEnabledValue := LDbConfig.GetValue('enabled');
              if LEnabledValue is TJSONBool then
                FEnabled.Add(LDbName,
                  TJSONBool(LEnabledValue).AsBoolean);
              for LParamPair in LDbConfig do
                if not SameText(LParamPair.JsonString.Value, 'enabled') then
                  FParams.Add(
                    Format('%s.%s', [LDbName, LParamPair.JsonString.Value.ToLower]),
                    LParamPair.JsonValue.Value);
            end;
      end;
    finally
      LRoot.Free;
    end;
  end;
end;

class procedure TTTestConfig.PrintConfig;
var
  LPair: TPair<String, Boolean>;
begin
  if not Assigned(FEnabled) then
    LoadConfig;

  Writeln('(*');
  Writeln;
  Writeln('  Trysil');
  Writeln('  Copyright (c) David Lastrucci');
  Writeln('  All rights reserved');
  Writeln;
  Writeln('  Trysil - Operation ORM (World War II)');
  Writeln('  http://codenames.info/operation/orm/');
  Writeln;
  Writeln('*)');
  Writeln;

  Writeln('Configuration');
  Writeln('-------------------------');
  for LPair in FEnabled do
    if LPair.Value then
      Writeln(Format('  %s: enabled%s', [
        LPair.Key, CharacterSetSuffix(LPair.Key)]))
    else
      Writeln(Format('  %s: disabled', [LPair.Key]));
  Writeln;
end;

class function TTTestConfig.CharacterSetSuffix(
  const ADatabaseName: String): String;
var
  LCharacterSet: String;
begin
  result := String.Empty;
  if FParams.TryGetValue(
    Format('%s.characterset', [ADatabaseName]), LCharacterSet) then
    if not LCharacterSet.IsEmpty then
      result := Format(' (CharacterSet=%s)', [LCharacterSet]);
end;

class function TTTestConfig.IsDatabaseEnabled(
  const ADatabaseName: String): Boolean;
begin
  if not Assigned(FEnabled) then
    LoadConfig;

  if not FEnabled.TryGetValue(
    ADatabaseName.ToLowerInvariant, Result) then
    result := False;
end;

class function TTTestConfig.GetDatabaseParam(
  const ADatabaseName: String;
  const AParamName: String): String;
begin
  if not Assigned(FEnabled) then
    LoadConfig;

  if not FParams.TryGetValue(
    Format('%s.%s', [
      ADatabaseName.ToLowerInvariant,
      AParamName.ToLowerInvariant]), result) then
    result := '';
end;

end.
