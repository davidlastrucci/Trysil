(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Release;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Zip,
  System.Net.URLClient,
  System.Net.HttpClient,

  Trysil.Setup.Consts,
  Trysil.Setup.Log;

type

{ TTReleaseDownloader }

  TTReleaseDownloader = class
  strict private
    const HttpOK = 200;
  strict private
    FLog: TTSetupLog;
    FMaster: Boolean;
    FTag: String;
    FCommit: String;
    FArchiveUrl: String;

    procedure Get(const AUrl: String; const AStream: TStream);
    function GetText(const AUrl: String): String;
    function ReadValue(
      const AJSon: String;
      const AName: String;
      const AError: String): String;
    function GetVersion: String;
    procedure FetchLatest;
    procedure FetchMaster;
  public
    constructor Create(const ALog: TTSetupLog; const AMaster: Boolean);

    procedure Fetch;
    function IsUpToDate(
      const AVersion: String; const ACommit: String): Boolean;
    procedure Download(const AFileName: String);

    property Tag: String read FTag;
    property Commit: String read FCommit;
    property Version: String read GetVersion;
  end;

{ TTReleaseArchive }

  TTReleaseArchive = class
  strict private
    FDirectory: String;

    function RemoveRoot(const AFileName: String): String;
    function TargetFileName(const AEntryName: String): String;
    procedure ExtractEntry(const AZipFile: TZipFile; const AIndex: Integer);
  public
    constructor Create(const ADirectory: String);

    procedure Extract(const AFileName: String);
  end;

implementation

{ TTReleaseDownloader }

constructor TTReleaseDownloader.Create(
  const ALog: TTSetupLog; const AMaster: Boolean);
begin
  inherited Create;
  FLog := ALog;
  FMaster := AMaster;
  FTag := String.Empty;
  FCommit := String.Empty;
  FArchiveUrl := String.Empty;
end;

procedure TTReleaseDownloader.Get(const AUrl: String; const AStream: TStream);
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  try
    LClient.UserAgent := SUserAgent;
    LResponse := LClient.Get(AUrl, AStream);
    if LResponse.StatusCode <> HttpOK then
      raise ETSetupException.CreateFmt(
        SHttpError, [LResponse.StatusCode, AUrl]);
  finally
    LClient.Free;
  end;
end;

function TTReleaseDownloader.GetText(const AUrl: String): String;
var
  LStream: TStringStream;
begin
  LStream := TStringStream.Create(String.Empty, TEncoding.UTF8);
  try
    Get(AUrl, LStream);
    result := LStream.DataString;
  finally
    LStream.Free;
  end;
end;

function TTReleaseDownloader.ReadValue(
  const AJSon: String;
  const AName: String;
  const AError: String): String;
var
  LValue: TJSONValue;
begin
  LValue := TJSONObject.ParseJSONValue(AJSon);
  try
    if not (Assigned(LValue) and
      LValue.TryGetValue<String>(AName, result)) then
      raise ETSetupException.Create(AError);
  finally
    LValue.Free;
  end;
end;

function TTReleaseDownloader.GetVersion: String;
begin
  if FTag.StartsWith('v') then
    result := FTag.Substring(1)
  else
    result := FTag;
end;

procedure TTReleaseDownloader.FetchLatest;
begin
  FTag := ReadValue(GetText(SReleaseUrl), STagName, SReleaseNotFound);
  FArchiveUrl := Format(SArchiveUrl, [FTag]);
  FLog.AddFormat(SLatestRelease, [GetVersion]);
end;

procedure TTReleaseDownloader.FetchMaster;
begin
  FTag := SMasterBranch;
  FCommit := ReadValue(GetText(SMasterCommitUrl), SShaName, SCommitNotFound);
  FArchiveUrl := Format(SCommitArchiveUrl, [FCommit]);
  FLog.AddFormat(SMasterVersion, [GetVersion]);
  FLog.AddFormat(SMasterCommit, [FCommit]);
end;

procedure TTReleaseDownloader.Fetch;
begin
  if FMaster then
    FetchMaster
  else
    FetchLatest;
end;

function TTReleaseDownloader.IsUpToDate(
  const AVersion: String; const ACommit: String): Boolean;
begin
  if FMaster then
    result := SameText(AVersion, SMasterBranch) and SameText(FCommit, ACommit)
  else
    result := SameText(GetVersion, AVersion);
end;

procedure TTReleaseDownloader.Download(const AFileName: String);
var
  LStream: TFileStream;
begin
  FLog.AddFormat(SDownloading, [GetVersion]);
  LStream := TFileStream.Create(AFileName, fmCreate);
  try
    Get(FArchiveUrl, LStream);
  finally
    LStream.Free;
  end;
end;

{ TTReleaseArchive }

constructor TTReleaseArchive.Create(const ADirectory: String);
begin
  inherited Create;
  FDirectory := ADirectory;
end;

function TTReleaseArchive.RemoveRoot(const AFileName: String): String;
var
  LIndex: Integer;
begin
  LIndex := AFileName.IndexOf('/');
  if LIndex >= 0 then
    result := AFileName.Substring(LIndex + 1)
  else
    result := String.Empty;
end;

function TTReleaseArchive.TargetFileName(const AEntryName: String): String;
var
  LDirectory: String;
begin
  result := RemoveRoot(AEntryName);
  if (not result.IsEmpty) and (not result.EndsWith('/')) then
  begin
    LDirectory := IncludeTrailingPathDelimiter(FDirectory).ToLower;
    result := TPath.GetFullPath(
      TPath.Combine(FDirectory, result.Replace('/', '\')));
    if not result.ToLower.StartsWith(LDirectory) then
      raise ETSetupException.CreateFmt(SInvalidArchiveEntry, [AEntryName]);
  end
  else
    result := String.Empty;
end;

procedure TTReleaseArchive.ExtractEntry(
  const AZipFile: TZipFile; const AIndex: Integer);
var
  LFileName: String;
  LBytes: TBytes;
begin
  LFileName := TargetFileName(AZipFile.FileName[AIndex]);
  if not LFileName.IsEmpty then
  begin
    TDirectory.CreateDirectory(TPath.GetDirectoryName(LFileName));
    AZipFile.Read(AIndex, LBytes);
    TFile.WriteAllBytes(LFileName, LBytes);
  end;
end;

procedure TTReleaseArchive.Extract(const AFileName: String);
var
  LZipFile: TZipFile;
  LIndex: Integer;
begin
  LZipFile := TZipFile.Create;
  try
    LZipFile.Open(AFileName, TZipMode.zmRead);
    for LIndex := 0 to LZipFile.FileCount - 1 do
      ExtractEntry(LZipFile, LIndex);
  finally
    LZipFile.Free;
  end;
end;

end.
