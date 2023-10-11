(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.IOTA;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.AnsiStrings,
  ToolsAPI,

  Trysil.Expert.IOTA.Services,
  Trysil.Expert.IOTA.ModuleCreator;

type

{ TTIOTA }

  TTIOTA = class
  public
    class function ActiveProject: IOTAProject;
    class function ActiveProjectName: String;
    class function IsActiveProject: Boolean;

    class function SearchModule(const AFileName: String): IOTAModuleInfo;

    class procedure OpenProject(const AFileName: String);
    class function ShowSourceEditor(const AFileName: String): IOTASourceEditor;
    class function GetSourceFile(const ASourceEditor: IOTASourceEditor): String;
    class procedure RewriteSourceFile(
      const ASourceEditor: IOTASourceEditor; const ASource: String);
    class procedure CreateUnit(const AFileName: String; const ASource: String);
  end;

implementation

{ TTIOTA }

class function TTIOTA.ActiveProject: IOTAProject;
begin
  result := nil;
  if BorlandIDEServices.SupportsService(IOTAModuleServices) then
    result := (BorlandIDEServices as IOTAModuleServices).GetActiveProject;
end;

class function TTIOTA.ActiveProjectName: String;
var
  LProject: IOTAProject;
begin
  result := String.Empty;
  LProject := ActiveProject;
  if Assigned(LProject) then
    result := TPath.GetFileNameWithoutExtension(LProject.FileName);
end;

class function TTIOTA.IsActiveProject: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := ActiveProject;
  result := Assigned(LProject);
  if result then
    result := TFile.Exists(LProject.FileName);
end;

class function TTIOTA.SearchModule(const AFileName: String): IOTAModuleInfo;
var
  LProject: IOTAProject;
  LFileName: String;
  LIndex: Integer;
  LResult: IOTAModuleInfo;
begin
  result := nil;
  LProject := ActiveProject;
  if Assigned(LProject) then
  begin
    LFileName := Format('%s.pas', [
      TPath.Combine(TPath.GetDirectoryName(LProject.FileName), AFileName)]);

    for LIndex := 0 to LProject.GetModuleCount - 1 do
    begin
      LResult := LProject.GetModule(LIndex);
      if String.Compare(LFileName, LResult.FileName, True) = 0 then
      begin
        result := LResult;
        Break;
      end;
    end;
  end;
end;

class procedure TTIOTA.OpenProject(const AFileName: String);
var
  LActionServices: IOTAActionServices;
begin
  LActionServices := TTIOTAServices.ActionServices;
  if Assigned(LActionServices) then
    LActionServices.OpenProject(AFileName, False);
end;

class function TTIOTA.ShowSourceEditor(const AFileName: String): IOTASourceEditor;
var
  LModuleInfo: IOTAModuleInfo;
  LModule: IOTAModule;
  LIndex: Integer;
  LFileEditor: IOTAEditor;
begin
  result := nil;
  LModuleInfo := SearchModule(AFileName);
  if Assigned(LModuleInfo) then
  begin
    LModule := LModuleInfo.OpenModule;
    if Assigned(LModule) then
    begin
      for LIndex := 0 to LModule.GetModuleFileCount - 1 do
      begin
        LFileEditor := LModule.GetModuleFileEditor(LIndex);
        if Assigned(LFileEditor) then
        begin
          if LFileEditor.QueryInterface(
            IOTASourceEditor, result) = S_OK then
          begin
            if result.EditViewCount = 0 then
              result.Show;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

class function TTIOTA.GetSourceFile(
  const ASourceEditor: IOTASourceEditor): String;
const
  BufferSize = 4096;
var
  LReader: IOTAEditReader;
  LPosition, LReaded: Integer;
  LBuffer: AnsiString;
begin
  result := String.Empty;
  LReader := ASourceEditor.CreateReader;
  if Assigned(LReader) then
  begin
    LPosition := 0;
    repeat
      SetLength(LBuffer, BufferSize);
      LReaded := LReader.GetText(LPosition, PAnsiChar(LBuffer), BufferSize);

      if LReaded < BufferSize then
        SetLength(LBuffer, LReaded);
      result := result + String(LBuffer);

      Inc(LPosition, LReaded);
    until LReaded < BufferSize;
  end;
end;

class procedure TTIOTA.RewriteSourceFile(
  const ASourceEditor: IOTASourceEditor; const ASource: String);
const
  BufferSize = 4096;
var
  LWriter: IOTAEditWriter;
  LLength: Integer;
  LSource: PAnsiChar;
begin
  LWriter := ASourceEditor.CreateUndoableWriter;
  if Assigned(LWriter) then
  begin
    LLength := Length(ASource);

    LWriter.CopyTo(0);
    LWriter.DeleteTo(LLength);

    GetMem(LSource, LLength + 1);
    try
      System.AnsiStrings.StrPCopy(LSource, AnsiString(ASource));
      LWriter.Insert(LSource);
    finally
      FreeMem(LSource, LLength + 1);
    end;
  end;
end;

class procedure TTIOTA.CreateUnit(
  const AFileName: String; const ASource: String);
var
  LProject: IOTAProject;
  LModuleServices: IOTAModuleServices;
  LModule: IOTAModule;
begin
  LProject := ActiveProject;
  if Assigned(LProject) then
  begin
    LModuleServices := TTIOTAServices.ModuleServices;
    if Assigned(LModuleServices) then
    begin
      LModule := LModuleServices.CreateModule(
        TTModuleCreator.Create(AFileName, ASource));
      if Assigned(LModule) then
        LProject.AddFile(LModule.FileName, True);
    end;
  end;
end;

end.
