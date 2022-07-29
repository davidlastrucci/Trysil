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

    function GetNestedException: Exception;
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
begin
  inherited Create(AMessage);
  FNestedException := GetNestedException();
end;

destructor ETException.Destroy;
begin
  if Assigned(FNestedException) then
    FNestedException.Free;
  inherited Destroy;
end;

function ETException.GetNestedException: Exception;
var
  LResult: TObject;
begin
  result := nil;
  LResult := AcquireExceptionObject();
  if Assigned(LResult) and (LResult is Exception) then
    result := Exception(LResult);
end;

end.
