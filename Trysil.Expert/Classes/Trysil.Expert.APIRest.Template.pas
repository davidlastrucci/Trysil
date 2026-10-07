(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRest.Template;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Zip,
  System.Net.HttpClient,

  Trysil.Expert.Classes,
  Trysil.Expert.Consts;

type

{ TTApiRestTemplate }

  TTApiRestTemplate = class
  strict private
    const ArchiveUrl =
      'https://github.com/TTContext/TApiRest/archive/refs/heads/2.1.1.zip';
    const TemplateFolder = 'Template/';
    const RulesFileName = 'TFeatures.json';
  strict private
    FStream: TMemoryStream;
    FRules: String;

    function EntryName(const AZip: TZipFile; const AIndex: Integer): String;
    function CommonRoot(const AZip: TZipFile): String;
    procedure ExtractEntry(
      const AZip: TZipFile;
      const AIndex: Integer;
      const ARoot: String;
      const ADirectory: String);
    procedure WriteEntry(
      const ADirectory: String;
      const AName: String;
      const ABytes: TBytes);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Download;
    procedure ExtractTo(const ADirectory: String);

    property Rules: String read FRules;
  end;

implementation

{ TTApiRestTemplate }

constructor TTApiRestTemplate.Create;
begin
  inherited Create;
  FStream := TMemoryStream.Create;
end;

destructor TTApiRestTemplate.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

procedure TTApiRestTemplate.Download;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
begin
  FStream.Clear;
  LClient := THTTPClient.Create;
  try
    LClient.HandleRedirects := True;
    LResponse := LClient.Get(ArchiveUrl, FStream);
    if LResponse.StatusCode <> 200 then
      raise ETExpertException.CreateFmt(SHttpError, [LResponse.StatusCode]);
  finally
    LClient.Free;
  end;
end;

function TTApiRestTemplate.EntryName(
  const AZip: TZipFile; const AIndex: Integer): String;
begin
  result := AZip.FileNames[AIndex].Replace('\', '/', [rfReplaceAll]);
end;

function TTApiRestTemplate.CommonRoot(const AZip: TZipFile): String;
var
  LName: String;
begin
  result := String.Empty;
  if AZip.FileCount > 0 then
  begin
    LName := EntryName(AZip, 0);
    if LName.IndexOf('/') > 0 then
      result := LName.Substring(0, LName.IndexOf('/') + 1);
  end;
end;

procedure TTApiRestTemplate.WriteEntry(
  const ADirectory: String;
  const AName: String;
  const ABytes: TBytes);
var
  LFileName: String;
begin
  LFileName := TPath.Combine(
    ADirectory, AName.Replace('/', PathDelim, [rfReplaceAll]));
  TDirectory.CreateDirectory(TPath.GetDirectoryName(LFileName));
  TFile.WriteAllBytes(LFileName, ABytes);
end;

procedure TTApiRestTemplate.ExtractEntry(
  const AZip: TZipFile;
  const AIndex: Integer;
  const ARoot: String;
  const ADirectory: String);
var
  LName: String;
  LBytes: TBytes;
begin
  LName := EntryName(AZip, AIndex);
  if (not LName.EndsWith('/')) and LName.StartsWith(ARoot) then
  begin
    LName := LName.Substring(ARoot.Length);
    AZip.Read(AIndex, LBytes);
    if LName.Equals(RulesFileName) then
      FRules := TEncoding.UTF8.GetString(LBytes)
    else if LName.StartsWith(TemplateFolder) then
      WriteEntry(
        ADirectory, LName.Substring(TemplateFolder.Length), LBytes);
  end;
end;

procedure TTApiRestTemplate.ExtractTo(const ADirectory: String);
var
  LZip: TZipFile;
  LRoot: String;
  LIndex: Integer;
begin
  LZip := TZipFile.Create;
  try
    FStream.Position := 0;
    LZip.Open(FStream, TZipMode.zmRead);
    LRoot := CommonRoot(LZip);
    for LIndex := 0 to LZip.FileCount - 1 do
      ExtractEntry(LZip, LIndex, LRoot, ADirectory);
    LZip.Close;
  finally
    LZip.Free;
  end;
end;

end.
