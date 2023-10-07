(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.Validator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Expert.Consts;

type

{ TTValidator }

  TTValidator = class
  strict private
    FMessage: String;
    FErrors: TList<String>;
    function GetIsValid: Boolean;
    function GetMessages: String;
  public
    constructor Create; overload;
    constructor Create(const AMessage: String); overload;
    destructor Destroy; override;

    procedure Clear;
    procedure Check(const ACondition: Boolean; const AMessage: String);

    property IsValid: Boolean read GetIsValid;
    property Messages: String read GetMessages;
  end;

implementation

{ TTValidator }

constructor TTValidator.Create;
begin
  Create(SErrors);
end;

constructor TTValidator.Create(const AMessage: String);
begin
  inherited Create;
  FMessage := AMessage;
  FErrors := TList<String>.Create;;
end;

destructor TTValidator.Destroy;
begin
  FErrors.Free;
  inherited Destroy;
end;

procedure TTValidator.Clear;
begin
  FErrors.Clear;
end;

procedure TTValidator.Check(const ACondition: Boolean; const AMessage: String);
begin
  if ACondition then
    FErrors.Add(AMessage);
end;

function TTValidator.GetIsValid: Boolean;
begin
  result := (FErrors.Count = 0);
end;

function TTValidator.GetMessages: String;
var
  LResult: TStringBuilder;
  LError: String;
begin
  if FErrors.Count > 0 then
  begin
    LResult := TStringBuilder.Create;
    try
      LResult.AppendLine(FMessage).AppendLine;
      for LError in FErrors do
        LResult.AppendFormat('- %s', [LError]).AppendLine;
      result := LResult.ToString;
    finally
      LResult.Free;
    end;
  end
  else
    result := String.Empty;
end;

end.
