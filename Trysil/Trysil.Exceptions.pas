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
    FNestedExceptionClassName: String;
    FNestedExceptionMessage: String;

    procedure CaptureNestedException;
    function GetHasNestedException: Boolean;
  public
    constructor CreateFmt(const AMessage: String;const AArgs: array of const);
    constructor Create(const AMessage: String);

    property HasNestedException: Boolean read GetHasNestedException;
    property NestedExceptionClassName: String read FNestedExceptionClassName;
    property NestedExceptionMessage: String read FNestedExceptionMessage;
  end;

{ ETValidationException }

  ETValidationException = class(ETException);

{ ETConcurrentUpdateException }

  ETConcurrentUpdateException = class(ETException);

{ ETDataIntegrityException }

  ETDataIntegrityException = class(ETException);

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
  CaptureNestedException;
end;

procedure ETException.CaptureNestedException;
var
  LObject: TObject;
begin
  FNestedExceptionClassName := String.Empty;
  FNestedExceptionMessage := String.Empty;
  LObject := ExceptObject();
  if Assigned(LObject) and (LObject is Exception) then
  begin
    FNestedExceptionClassName := LObject.ClassName;
    FNestedExceptionMessage := Exception(LObject).Message;
  end;
end;

function ETException.GetHasNestedException: Boolean;
begin
  result := not FNestedExceptionClassName.IsEmpty;
end;

end.
