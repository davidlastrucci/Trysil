(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.SourceWriter;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TTSourceWriter }

  TTSourceWriter = class
  strict private
    FSource: TStringBuilder;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Append(const AValue: String); overload;
    procedure Append(
      const AFormat: string; const AArgs: array of const); overload;
    procedure AppendLine;

    procedure Clear;

    function ToString: String; override;
  end;

implementation

{ TTSourceWriter }

constructor TTSourceWriter.Create;
begin
  inherited Create;
  FSource := TStringBuilder.Create;
end;

destructor TTSourceWriter.Destroy;
begin
  FSource.Free;
  inherited Destroy;
end;

procedure TTSourceWriter.Append(const AValue: String);
begin
  FSource.AppendLine(AValue);
end;

procedure TTSourceWriter.Append(
  const AFormat: string; const AArgs: array of const);
begin
  FSource.AppendFormat(AFormat, AArgs);
  FSource.AppendLine;
end;

procedure TTSourceWriter.AppendLine;
begin
  FSource.AppendLine;
end;

procedure TTSourceWriter.Clear;
begin
  FSource.Clear;
end;

function TTSourceWriter.ToString: String;
begin
  result := FSource.ToString;
end;

end.
