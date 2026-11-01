(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Probe;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,

  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.MSBuild;

type

{ TTProbe }

  TTProbe = class
  strict private
    FLog: TTSetupLog;

    function CreateDirectory: String;
    procedure SaveResource(const AName: String; const AFileName: String);
    function Build(const ARootDir: String; const ADirectory: String): Boolean;
  public
    constructor Create(const ALog: TTSetupLog);

    function Run(const ARootDir: String): Boolean;
  end;

implementation

{ TTProbe }

constructor TTProbe.Create(const ALog: TTSetupLog);
begin
  inherited Create;
  FLog := ALog;
end;

function TTProbe.Run(const ARootDir: String): Boolean;
var
  LDirectory: String;
begin
  LDirectory := CreateDirectory;
  try
    SaveResource(SProbeDprResource, TPath.Combine(LDirectory, SProbeDpr));
    SaveResource(
      SProbeDprojResource, TPath.Combine(LDirectory, SProbeDproj));
    result := Build(ARootDir, LDirectory);
  finally
    TDirectory.Delete(LDirectory, True);
  end;
end;

function TTProbe.CreateDirectory: String;
begin
  result := TPath.Combine(
    TPath.GetTempPath, Format(SProbeDirectory, [TGUID.NewGuid.ToString]));
  TDirectory.CreateDirectory(result);
end;

procedure TTProbe.SaveResource(const AName: String; const AFileName: String);
var
  LStream: TResourceStream;
begin
  LStream := TResourceStream.Create(HInstance, AName, RT_RCDATA);
  try
    LStream.SaveToFile(AFileName);
  finally
    LStream.Free;
  end;
end;

function TTProbe.Build(
  const ARootDir: String; const ADirectory: String): Boolean;
var
  LMSBuild: TTMSBuild;
begin
  LMSBuild := TTMSBuild.Create(ARootDir, FLog);
  try
    result := LMSBuild.Build(
      TPath.Combine(ADirectory, SProbeDproj), SRelease, SWin32);
  finally
    LMSBuild.Free;
  end;
end;

end.
