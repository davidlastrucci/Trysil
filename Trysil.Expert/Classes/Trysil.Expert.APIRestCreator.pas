(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRestCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Zip,
  System.IOUtils,

  Trysil.Expert.IOTA;

type

{ TTApiRestProjectParameters }

  TTApiRestProjectParameters = class
  strict private
    FDirectory: String;
    FProjectName: String;
    FJWTSecret: String;

    function CalculateRandomSecret: String;
  public
    procedure AfterConstruction; override;

    property Directory: String read FDirectory write FDirectory;
    property ProjectName: String read FProjectName write FProjectName;
    property JWTSecret: String read FJWTSecret write FJWTSecret;
  end;

{ TTApiRestAPIParameters }

  TTApiRestAPIParameters = class
  strict private
    FBaseUri: String;
    FPort: Integer;
    FAuthorization: Boolean;
    FLog: Boolean;
  public
    property BaseUri: String read FBaseUri write FBaseUri;
    property Port: Integer read FPort write FPort;
    property Authorization: Boolean read FAuthorization write FAuthorization;
    property Log: Boolean read FLog write FLog;
  end;

{ TTApiRestServiceParameters }

  TTApiRestServiceParameters = class
  strict private
    FName: String;
    FDisplayName: String;
    FDescription: String;
  public
    property Name: String read FName write FName;
    property DisplayName: String read FDisplayName write FDisplayName;
    property Description: String read FDescription write FDescription;
  end;

{ TTApiRestDatabaseParameters }

  TTApiRestDatabaseParameters = class
  strict private
    FConnectionName: String;
    FHost: String;
    FUsername: String;
    FPassword: String;
    FDatabaseName: String;
  public
    property ConnectionName: String read FConnectionName write FConnectionName;
    property Host: String read FHost write FHost;
    property Username: String read FUsername write FUsername;
    property Password: String read FPassword write FPassword;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
  end;

{ TTApiRestParameters }

  TTApiRestParameters = class
  strict private
    FProject: TTApiRestProjectParameters;
    FAPI: TTApiRestAPIParameters;
    FService: TTApiRestServiceParameters;
    FDatabase: TTApiRestDatabaseParameters;
  public
    constructor Create;
    destructor Destroy; override;

    property Project: TTApiRestProjectParameters read FProject;
    property API: TTApiRestAPIParameters read FAPI;
    property Service: TTApiRestServiceParameters read FService;
    property Database: TTApiRestDatabaseParameters read FDatabase;
  end;

{ TTAPIRestCreator }

  TTAPIRestCreator = class
  strict private
    //FModel: String;
    FParameters: TTApiRestParameters;

    function CheckFileName(var AFileName: String): Boolean;
    function IsTextFile(const AFileName: String): Boolean;
    function ModifySourceLine(const ALine: String): String;
    function ModifySourceText(const ABytes: TBytes): String;
    procedure WriteFile(const AFileName: String; const ABytes: TBytes);
  public
    constructor Create(const AParameters: TTApiRestParameters);
    destructor Destroy; override;

    procedure CreateProject;
    procedure OpenProject;
  end;

implementation

{ TTApiRestProjectParameters }

procedure TTApiRestProjectParameters.AfterConstruction;
begin
  inherited AfterConstruction;
  FJWTSecret := CalculateRandomSecret;
end;

function TTApiRestProjectParameters.CalculateRandomSecret: String;
var
  LIndex, LChar: Integer;
begin
  result := String.Empty;
  for LIndex := 0 to 60 do
  begin
    LChar := 33 + Random(94);
    if LChar = 39 then
      LChar := LChar + Random(15) + 1;
    result := result + Char(LChar);
  end;
end;

{ TTApiRestParameters }

constructor TTApiRestParameters.Create;
begin
  inherited Create;
  FProject := TTApiRestProjectParameters.Create;
  FAPI := TTApiRestAPIParameters.Create;
  FService := TTApiRestServiceParameters.Create;
  FDatabase := TTApiRestDatabaseParameters.Create;
end;

destructor TTApiRestParameters.Destroy;
begin
  FDatabase.Free;
  FService.Free;
  FAPI.Free;
  FProject.Free;
  inherited Destroy;
end;

{ TTAPIRestCreator }

constructor TTAPIRestCreator.Create(const AParameters: TTApiRestParameters);
begin
  inherited Create;
  FParameters := AParameters;
end;

destructor TTAPIRestCreator.Destroy;
begin

  inherited Destroy;
end;

function TTAPIRestCreator.CheckFileName(var AFileName: String): Boolean;
begin
  result := True;

  if AFileName.Contains('{{Auth}}') then
  begin
    AFileName := AFileName.Replace('{{Auth}}', '', [rfReplaceAll]);
    result := FParameters.API.Authorization;
  end;

  if AFileName.Contains('{{Log}}') then
  begin
    AFileName := AFileName.Replace('{{Log}}', '', [rfReplaceAll]);
    result := FParameters.API.Log;
  end;

  AFileName := AFileName.Replace(
    '{{ProjectName}}', FParameters.Project.ProjectName, [rfReplaceAll]);
end;

function TTAPIRestCreator.IsTextFile(const AFileName: String): Boolean;
var
  LExtension: String;
begin
  LExtension := TPath.GetExtension(AFileName).ToLower();
  result := LExtension.Equals('.pas') or
    LExtension.Equals('.dfm') or
    LExtension.Equals('.dpr') or
    LExtension.Equals('.dproj') or
    LExtension.Equals('.groupproj') or
    LExtension.Equals('.json');
end;

function TTAPIRestCreator.ModifySourceLine(const ALine: String): String;
begin
  result := ALine
    .Replace('{{ProjectGuid}}', TGuid.NewGuid.ToString, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{ProjectName}}', FParameters.Project.ProjectName, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{ProjectName_}}', FParameters.Project.ProjectName.Replace('.', '_', [rfReplaceAll]), [rfReplaceAll, rfIgnoreCase])
    .Replace('{{JWTSecret}}', FParameters.Project.JWTSecret, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{BaseUri}}', FParameters.API.BaseUri, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{Port}}', FParameters.API.Port.ToString, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{ServiceName}}', FParameters.Service.Name, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{ServiceDisplayName}}', FParameters.Service.DisplayName, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{ServiceDescription}}', FParameters.Service.Description, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{Database_ConnectionName}}', FParameters.Database.ConnectionName, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{Database_Host}}', FParameters.Database.Host, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{Database_Username}}', FParameters.Database.Username, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{Database_Password}}', FParameters.Database.Password, [rfReplaceAll, rfIgnoreCase])
    .Replace('{{Database_DatabaseName}}', FParameters.Database.DatabaseName, [rfReplaceAll, rfIgnoreCase]);
end;

function TTAPIRestCreator.ModifySourceText(const ABytes: TBytes): String;
var
  LEncoding: TEncoding;
  LSource, LLine: String;
  LSrc, LDest: TStrings;
  LInIF: Boolean;
begin
  TEncoding.GetBufferEncoding(ABytes, LEncoding, TEncoding.ANSI);
  LSource := LEncoding.GetString(ABytes);
  LSrc := TStringList.Create;
  try
    LSrc.Text := LSource;
    LDest := TStringList.Create;
    try
      LInIf := False;
      for LLine in LSrc do
      begin
        if LLine.Trim().ToLower().Equals('{{tif auth}}') then
          LInIf := not FParameters.API.Authorization
        else if LLine.Trim().ToLower().Equals('{{tif log}}') then
          LInIf := not FParameters.API.Log
        else if LLine.Trim().ToLower().Equals('{{tendif}}') then
          LInIf := False
        else if not LInIf then
          LDest.Add(ModifySourceLine(LLine));
      end;
      result := LDest.Text;
    finally
      LDest.Free;
    end;
  finally
    LSrc.Free;
  end;
end;

procedure TTAPIRestCreator.WriteFile(
  const AFileName: String; const ABytes: TBytes);
begin
  if IsTextFile(AFileName) then
    TFile.WriteAllText(AFileName, ModifySourceText(ABytes))
  else
    TFile.WriteAllBytes(AFileName, ABytes);
end;

procedure TTAPIRestCreator.CreateProject;
var
  LModel: TZipFile;
  LStream: TStream;
  LIndex: Integer;
  LFileName: String;
  LBytes: TBytes;
begin
  LModel := TZipFile.Create;
  try
    LStream := TResourceStream.Create(HInstance, 'apirest', 'TMODEL');
    try
      LModel.Open(LStream, TZipMode.zmRead);
      for LIndex := 0 to LModel.FileCount - 1 do
      begin
        LFileName := LModel.FileNames[LIndex];
        if CheckFileName(LFileName) then
        begin
          LFileName := TPath.Combine(FParameters.Project.Directory, LFileName);
          TDirectory.CreateDirectory(TPath.GetDirectoryName(LFileName));
          if (not LFileName.EndsWith('/')) and (not LFileName.EndsWith('\')) then
          begin
            LModel.Read(LIndex, LBytes);
            WriteFile(LFileName, LBytes);
          end;
        end;
      end;
    finally
      LStream.Free;
    end;
  finally
    LModel.Free;
  end;
end;

procedure TTAPIRestCreator.OpenProject;
begin
  TTIOTA.OpenProject(
    Format('%sGroup.groupproj', [
      TPath.Combine(
        FParameters.Project.Directory,
        FParameters.Project.ProjectName)]));
end;

initialization
  Randomize;

end.

