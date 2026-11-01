(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Process;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,

  Trysil.Setup.Consts,
  Trysil.Setup.Log;

type

{ TTProcess }

  TTProcess = class
  strict private
    const BufferSize = 4096;
  strict private
    FCommandLine: String;
    FOnOutput: TTSetupLogEvent;
    FEncoding: TEncoding;
    FReadPipe: THandle;
    FWritePipe: THandle;
    FPending: String;

    procedure CreatePipes;
    procedure CloseWritePipe;
    procedure ClosePipes;
    function StartProcess(out AProcessInfo: TProcessInformation): Boolean;
    procedure ReadOutput;
    procedure EmitLines(const AText: String);
    procedure FlushPending;
    function WaitForExit(const AProcessInfo: TProcessInformation): Integer;
  public
    constructor Create(
      const ACommandLine: String; const AOnOutput: TTSetupLogEvent);
    destructor Destroy; override;

    function Execute: Integer;
  end;

implementation

{ TTProcess }

constructor TTProcess.Create(
  const ACommandLine: String; const AOnOutput: TTSetupLogEvent);
begin
  inherited Create;
  FCommandLine := ACommandLine;
  FOnOutput := AOnOutput;
  FEncoding := TEncoding.GetEncoding(GetOEMCP);
  FReadPipe := 0;
  FWritePipe := 0;
end;

destructor TTProcess.Destroy;
begin
  FEncoding.Free;
  inherited Destroy;
end;

function TTProcess.Execute: Integer;
var
  LProcessInfo: TProcessInformation;
begin
  result := -1;
  CreatePipes;
  try
    if StartProcess(LProcessInfo) then
    begin
      CloseWritePipe;
      ReadOutput;
      result := WaitForExit(LProcessInfo);
    end
    else
      FOnOutput(Format(SProcessFailed, [SysErrorMessage(GetLastError)]));
  finally
    ClosePipes;
  end;
end;

procedure TTProcess.CreatePipes;
var
  LSecurity: TSecurityAttributes;
begin
  LSecurity := Default(TSecurityAttributes);
  LSecurity.nLength := SizeOf(LSecurity);
  LSecurity.bInheritHandle := True;
  if not CreatePipe(FReadPipe, FWritePipe, @LSecurity, 0) then
    RaiseLastOSError;
  SetHandleInformation(FReadPipe, HANDLE_FLAG_INHERIT, 0);
end;

procedure TTProcess.CloseWritePipe;
begin
  if FWritePipe <> 0 then
    CloseHandle(FWritePipe);
  FWritePipe := 0;
end;

procedure TTProcess.ClosePipes;
begin
  CloseWritePipe;
  if FReadPipe <> 0 then
    CloseHandle(FReadPipe);
  FReadPipe := 0;
end;

function TTProcess.StartProcess(
  out AProcessInfo: TProcessInformation): Boolean;
var
  LStartupInfo: TStartupInfo;
  LCommandLine: String;
begin
  LStartupInfo := Default(TStartupInfo);
  LStartupInfo.cb := SizeOf(LStartupInfo);
  LStartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  LStartupInfo.wShowWindow := SW_HIDE;
  LStartupInfo.hStdOutput := FWritePipe;
  LStartupInfo.hStdError := FWritePipe;
  LCommandLine := FCommandLine;
  UniqueString(LCommandLine);
  result := CreateProcess(
    nil, PChar(LCommandLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil,
    LStartupInfo, AProcessInfo);
end;

procedure TTProcess.ReadOutput;
var
  LBuffer: TBytes;
  LRead: Cardinal;
begin
  SetLength(LBuffer, BufferSize);
  while ReadFile(FReadPipe, LBuffer[0], BufferSize, LRead, nil) and
    (LRead > 0) do
    EmitLines(FEncoding.GetString(LBuffer, 0, Integer(LRead)));
  FlushPending;
end;

procedure TTProcess.EmitLines(const AText: String);
var
  LIndex: Integer;
begin
  FPending := Format('%s%s', [FPending, AText]);
  LIndex := FPending.IndexOf(#10);
  while LIndex >= 0 do
  begin
    FOnOutput(FPending.Substring(0, LIndex).TrimRight);
    FPending := FPending.Substring(LIndex + 1);
    LIndex := FPending.IndexOf(#10);
  end;
end;

procedure TTProcess.FlushPending;
begin
  if not FPending.Trim.IsEmpty then
    FOnOutput(FPending.TrimRight);
  FPending := String.Empty;
end;

function TTProcess.WaitForExit(
  const AProcessInfo: TProcessInformation): Integer;
var
  LExitCode: Cardinal;
begin
  try
    WaitForSingleObject(AProcessInfo.hProcess, INFINITE);
    if not GetExitCodeProcess(AProcessInfo.hProcess, LExitCode) then
      LExitCode := Cardinal(-1);
    result := Integer(LExitCode);
  finally
    CloseHandle(AProcessInfo.hThread);
    CloseHandle(AProcessInfo.hProcess);
  end;
end;

end.
