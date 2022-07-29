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
    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String;
      const ANestedException: Exception); overload;

    destructor Destroy; override;

    property NestedException: Exception read FNestedException;
  end;

implementation

{ ETException }

constructor ETException.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  CreateFmt(AMessage, AArgs, nil);
end;

constructor ETException.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  Create(Format(AMessage, AArgs), ANestedException);
end;

constructor ETException.Create(const AMessage: String);
begin
  Create(AMessage, nil);
end;

constructor ETException.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(AMessage);
  if Assigned(ANestedException) then
    FNestedException := Exception(AcquireExceptionObject);
end;

destructor ETException.Destroy;
begin
  if Assigned(FNestedException) then
    FNestedException.Free;
  inherited Destroy;
end;

end.
