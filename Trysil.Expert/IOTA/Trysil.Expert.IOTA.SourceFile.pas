(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.IOTA.SourceFile;

interface

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI,
  DesignIntf;

type

{ TTSourceFile }

  TTSourceFile = class(TInterfacedObject, IOTAFile)
  strict private
    FSource: string;

    // IOTAFile
    function GetSource: string;
    function GetAge: TDateTime;
  public
    constructor Create(const ASource: string);
  end;

implementation

{ TTSourceFile }

constructor TTSourceFile.Create(const ASource: string);
begin
  inherited Create;
  FSource := ASource;
end;

function TTSourceFile.GetAge: TDateTime;
begin
  Result := -1;
end;

function TTSourceFile.GetSource: string;
begin
  Result := FSource;
end;

end.

