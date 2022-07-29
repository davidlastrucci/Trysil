(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Exceptions;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ ETException }

  ETException = class(Exception)
  strict private
    FNestedException: Exception;
  public
    constructor CreateFmt(const AMessage: String;const AArgs: array of const);
    constructor Create(const AMessage: String);

    destructor Destroy; override;

    property NestedException: Exception read FNestedException;
  end;

implementation

{ ETException }

constructor ETException.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  Create(Format(AMessage, AArgs));
end;

constructor ETException.Create(const AMessage: String);
var
  LExceptionObject: TObject;
begin
  inherited Create(AMessage);
  FNestedException := nil;
  LExceptionObject := AcquireExceptionObject();
  if Assigned(LExceptionObject) and (LExceptionObject is Exception) then
    FNestedException := Exception(LExceptionObject);
end;

destructor ETException.Destroy;
begin
  if Assigned(FNestedException) then
    FNestedException.Free;
  inherited Destroy;
end;

end.
