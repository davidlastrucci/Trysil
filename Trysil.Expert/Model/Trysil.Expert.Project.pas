(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.Project;

interface

uses
  System.Sysutils,
  System.Classes,
  System.IOUtils;

type

{ TTProject }

  TTProject = record
  strict private
    FName: String;
    FDirectory: String;
  public
    constructor Create(const AFileName: String);

    property Name: String read FName;
    property Directory: String read FDirectory;
  end;

implementation

{ TTProject }

constructor TTProject.Create(const AFileName: String);
begin
  FName := TPath.GetFileNameWithoutExtension(AFileName);
  FDirectory := TPath.GetDirectoryName(AFileName);
end;

end.
