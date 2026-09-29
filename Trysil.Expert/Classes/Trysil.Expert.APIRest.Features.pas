(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRest.Features;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.RegularExpressions,
  System.Generics.Collections,

  Trysil.Expert.Classes,
  Trysil.Expert.Consts,
  Trysil.Expert.APIRest.Parameters;

type

{ TTApiRestCondition }

  TTApiRestCondition = class
  strict private
    const Names: array[TTApiRestFeature] of String = (
      'multitenant', 'auth', 'log', 'rs256');
  public
    class function Holds(
      const AFeatures: TTApiRestFeatures;
      const ACondition: String): Boolean; static;
  end;

{ TTApiRestTextFile }

  TTApiRestTextFile = class
  strict private
    const Bom: array[0..2] of Byte = ($EF, $BB, $BF);
  strict private
    FFileName: String;
    FHasBom: Boolean;
    FNewLine: String;
    FLines: TStrings;

    function CreateEncoding: TEncoding;
    function ReadText: String;
  public
    constructor Create(const AFileName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure Save;

    property Lines: TStrings read FLines;
  end;

{ TTApiRestBlock }

  TTApiRestBlock = record
  strict private
    FCommented: Boolean;
    FCondition: String;
    FKeep: Boolean;
  public
    constructor Create(
      const ACommented: Boolean;
      const ACondition: String;
      const AKeep: Boolean);

    property Commented: Boolean read FCommented;
    property Condition: String read FCondition;
    property Keep: Boolean read FKeep;
  end;

{ TTApiRestSource }

  TTApiRestSource = class
  strict private
    FFeatures: TTApiRestFeatures;
    FFileName: String;
    FBlocks: TList<TTApiRestBlock>;
    FPascalHeader: TRegEx;
    FSqlHeader: TRegEx;
    FOpen: TRegEx;
    FClose: TRegEx;
    FCommentedOpen: TRegEx;
    FCommentedClose: TRegEx;
    FInline: TRegEx;
    FMarker: TRegEx;

    function FirstLine(const ALines: TStrings): String;
    function TryHeader(const ALine: String; out ACondition: String): Boolean;
    function ReadHeader(const ALines: TStrings): Boolean;
    function InCommented: Boolean;
    function KeepLine: Boolean;
    procedure Push(const ACommented: Boolean; const ACondition: String);
    procedure Pop;
    function TryCommentedClose(const ALine: String): Boolean;
    function TryCommentedOpen(const ALine: String): Boolean;
    function TryOpen(const ALine: String): Boolean;
    function TryClose(const ALine: String; const ANumber: Integer): Boolean;
    function EvaluateInline(const AMatch: TMatch): String;
    function ProcessInline(const ALine: String; const ANumber: Integer): String;
    procedure ProcessLines(const ALines: TStrings);
    procedure RaiseMarker(const ANumber: Integer);
  public
    constructor Create(const AFeatures: TTApiRestFeatures);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Process(const AFileName: String): Boolean;
  end;

implementation

{ TTApiRestCondition }

class function TTApiRestCondition.Holds(
  const AFeatures: TTApiRestFeatures; const ACondition: String): Boolean;
var
  LName: String;
  LFeature: TTApiRestFeature;
  LFound: Boolean;
begin
  LName := ACondition.TrimLeft(['!']).ToLower;
  LFound := False;
  result := False;
  for LFeature := Low(TTApiRestFeature) to High(TTApiRestFeature) do
    if Names[LFeature].Equals(LName) then
    begin
      LFound := True;
      result := (LFeature in AFeatures) <> ACondition.StartsWith('!');
    end;

  if not LFound then
    raise ETExpertException.CreateFmt(SUnknownFeature, [ACondition]);
end;

{ TTApiRestTextFile }

constructor TTApiRestTextFile.Create(const AFileName: String);
begin
  inherited Create;
  FFileName := AFileName;
  FLines := TStringList.Create;
end;

destructor TTApiRestTextFile.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TTApiRestTextFile.AfterConstruction;
var
  LText: String;
  LLine: String;
begin
  inherited AfterConstruction;
  LText := ReadText;
  if LText.Contains(#13#10) then
    FNewLine := #13#10
  else
    FNewLine := #10;

  for LLine in LText.Split([FNewLine]) do
    FLines.Add(LLine);
end;

function TTApiRestTextFile.CreateEncoding: TEncoding;
begin
  if FHasBom then
    result := TUTF8Encoding.Create
  else
    result := TEncoding.GetEncoding(28591);
end;

function TTApiRestTextFile.ReadText: String;
var
  LBytes: TBytes;
  LOffset: Integer;
  LEncoding: TEncoding;
begin
  LBytes := TFile.ReadAllBytes(FFileName);
  FHasBom := (Length(LBytes) >= 3) and
    (LBytes[0] = Bom[0]) and (LBytes[1] = Bom[1]) and (LBytes[2] = Bom[2]);
  LOffset := 0;
  if FHasBom then
    LOffset := 3;

  LEncoding := CreateEncoding;
  try
    result := LEncoding.GetString(LBytes, LOffset, Length(LBytes) - LOffset);
  finally
    LEncoding.Free;
  end;
end;

procedure TTApiRestTextFile.Save;
var
  LEncoding: TEncoding;
  LBytes: TBytes;
begin
  LEncoding := CreateEncoding;
  try
    LBytes := LEncoding.GetBytes(
      String.Join(FNewLine, FLines.ToStringArray));
  finally
    LEncoding.Free;
  end;

  if FHasBom then
    LBytes := [Bom[0], Bom[1], Bom[2]] + LBytes;
  TFile.WriteAllBytes(FFileName, LBytes);
end;

{ TTApiRestBlock }

constructor TTApiRestBlock.Create(
  const ACommented: Boolean;
  const ACondition: String;
  const AKeep: Boolean);
begin
  FCommented := ACommented;
  FCondition := ACondition;
  FKeep := AKeep;
end;

{ TTApiRestSource }

constructor TTApiRestSource.Create(const AFeatures: TTApiRestFeatures);
begin
  inherited Create;
  FFeatures := AFeatures;
  FBlocks := TList<TTApiRestBlock>.Create;
end;

destructor TTApiRestSource.Destroy;
begin
  FBlocks.Free;
  inherited Destroy;
end;

procedure TTApiRestSource.AfterConstruction;
begin
  inherited AfterConstruction;
  FPascalHeader := TRegEx.Create(
    '^\s*\{\s*TFeature:(!?\w+)\s*\}\s*$', [roIgnoreCase]);
  FSqlHeader := TRegEx.Create(
    '^\s*--\s*TFeature:(!?\w+)\s*$', [roIgnoreCase]);
  FOpen := FPascalHeader;
  FClose := TRegEx.Create(
    '^\s*\{\s*/TFeature:(!?\w+)\s*\}\s*$', [roIgnoreCase]);
  FCommentedOpen := TRegEx.Create(
    '^\s*\(\*\s*TFeature:(!\w+)\s*$', [roIgnoreCase]);
  FCommentedClose := TRegEx.Create('^\s*\*\)\s*$');
  FInline := TRegEx.Create(
    '\{\s*TFeature:(!?\w+)\s*\}(.*?)\{\s*/TFeature:\1\s*\}', [roIgnoreCase]);
  FMarker := TRegEx.Create('TFeature:', [roIgnoreCase]);
end;

function TTApiRestSource.FirstLine(const ALines: TStrings): String;
begin
  if ALines.Count > 0 then
    result := ALines[0]
  else
    result := String.Empty;
end;

function TTApiRestSource.TryHeader(
  const ALine: String; out ACondition: String): Boolean;
var
  LMatch: TMatch;
begin
  LMatch := FPascalHeader.Match(ALine);
  if not LMatch.Success then
    LMatch := FSqlHeader.Match(ALine);

  result := LMatch.Success;
  if result then
    ACondition := LMatch.Groups[1].Value;
end;

function TTApiRestSource.ReadHeader(const ALines: TStrings): Boolean;
var
  LCondition: String;
begin
  result := True;
  while TryHeader(FirstLine(ALines), LCondition) do
  begin
    result := result and TTApiRestCondition.Holds(FFeatures, LCondition);
    ALines.Delete(0);
  end;
end;

function TTApiRestSource.InCommented: Boolean;
begin
  result := (FBlocks.Count > 0) and FBlocks.Last.Commented;
end;

function TTApiRestSource.KeepLine: Boolean;
var
  LBlock: TTApiRestBlock;
begin
  result := True;
  for LBlock in FBlocks do
    result := result and LBlock.Keep;
end;

procedure TTApiRestSource.Push(
  const ACommented: Boolean; const ACondition: String);
begin
  FBlocks.Add(TTApiRestBlock.Create(
    ACommented,
    ACondition.ToLower,
    TTApiRestCondition.Holds(FFeatures, ACondition)));
end;

procedure TTApiRestSource.Pop;
begin
  FBlocks.Delete(FBlocks.Count - 1);
end;

function TTApiRestSource.TryCommentedClose(const ALine: String): Boolean;
begin
  result := InCommented and FCommentedClose.IsMatch(ALine);
  if result then
    Pop;
end;

function TTApiRestSource.TryCommentedOpen(const ALine: String): Boolean;
var
  LMatch: TMatch;
begin
  LMatch := FCommentedOpen.Match(ALine);
  result := LMatch.Success;
  if result then
    Push(True, LMatch.Groups[1].Value);
end;

function TTApiRestSource.TryOpen(const ALine: String): Boolean;
var
  LMatch: TMatch;
begin
  LMatch := FOpen.Match(ALine);
  result := LMatch.Success;
  if result then
    Push(False, LMatch.Groups[1].Value);
end;

function TTApiRestSource.TryClose(
  const ALine: String; const ANumber: Integer): Boolean;
var
  LMatch: TMatch;
begin
  LMatch := FClose.Match(ALine);
  result := LMatch.Success;
  if result then
  begin
    if (FBlocks.Count = 0) or FBlocks.Last.Commented or
      (not FBlocks.Last.Condition.Equals(LMatch.Groups[1].Value.ToLower)) then
      RaiseMarker(ANumber);
    Pop;
  end;
end;

function TTApiRestSource.EvaluateInline(const AMatch: TMatch): String;
begin
  if TTApiRestCondition.Holds(FFeatures, AMatch.Groups[1].Value) then
    result := AMatch.Groups[2].Value
  else
    result := String.Empty;
end;

function TTApiRestSource.ProcessInline(
  const ALine: String; const ANumber: Integer): String;
begin
  result := FInline.Replace(ALine, EvaluateInline);
  if FMarker.IsMatch(result) then
    RaiseMarker(ANumber);
end;

procedure TTApiRestSource.RaiseMarker(const ANumber: Integer);
begin
  raise ETExpertException.CreateFmt(
    SUnexpectedMarker, [TPath.GetFileName(FFileName), ANumber]);
end;

procedure TTApiRestSource.ProcessLines(const ALines: TStrings);
var
  LSource: TArray<String>;
  LIndex: Integer;
begin
  FBlocks.Clear;
  LSource := ALines.ToStringArray;
  ALines.Clear;
  for LIndex := 0 to High(LSource) do
    if not (TryCommentedClose(LSource[LIndex]) or
      TryCommentedOpen(LSource[LIndex]) or
      TryOpen(LSource[LIndex]) or
      TryClose(LSource[LIndex], LIndex + 1)) and KeepLine then
      ALines.Add(ProcessInline(LSource[LIndex], LIndex + 1));

  if FBlocks.Count > 0 then
    raise ETExpertException.CreateFmt(
      SUnclosedMarker, [TPath.GetFileName(FFileName)]);
end;

function TTApiRestSource.Process(const AFileName: String): Boolean;
var
  LFile: TTApiRestTextFile;
begin
  FFileName := AFileName;
  LFile := TTApiRestTextFile.Create(AFileName);
  try
    result := ReadHeader(LFile.Lines);
    if result then
    begin
      ProcessLines(LFile.Lines);
      LFile.Save;
    end;
  finally
    LFile.Free;
  end;
end;

end.
