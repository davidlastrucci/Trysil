(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Log;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TTSetupLogEvent }

  TTSetupLogEvent = procedure(const ALine: String) of object;

{ TTSetupLog }

  TTSetupLog = class
  strict private
    FLines: TStringList;
    FOnLine: TTSetupLogEvent;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const ALine: String);
    procedure AddFormat(const AFormat: String; const AArgs: array of const);
    procedure SaveToFile(const AFileName: String);

    property OnLine: TTSetupLogEvent read FOnLine write FOnLine;
  end;

implementation

{ TTSetupLog }

constructor TTSetupLog.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
end;

destructor TTSetupLog.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TTSetupLog.Add(const ALine: String);
begin
  FLines.Add(ALine);
  if Assigned(FOnLine) then
    FOnLine(ALine);
end;

procedure TTSetupLog.AddFormat(
  const AFormat: String; const AArgs: array of const);
begin
  Add(Format(AFormat, AArgs));
end;

procedure TTSetupLog.SaveToFile(const AFileName: String);
begin
  FLines.SaveToFile(AFileName, TEncoding.UTF8);
end;

end.
