(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Validation;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSon;

type

{ TTValidationError }

  TTValidationError = record
  strict private
    FColumnName: String;
    FErrorMessage: String;
  public
    constructor Create(const AColumnName: String; const AErrorMessage: String);

    property ColumnName: String read FColumnName;
    property ErrorMessage: String read FErrorMessage;
  end;

{ TTValidationErrors }

  TTValidationErrors = class
  strict private
    FErrors: TList<TTValidationError>;

    function GetIsEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AColumnName: String; const AErrorMessage: String);

    function ToString(): String; override;
    function ToJSon(): String;

    property IsEmpty: Boolean read GetIsEmpty;
  end;

implementation

{ TTValidationError }

constructor TTValidationError.Create(
  const AColumnName: String; const AErrorMessage: String);
begin
  FColumnName := AColumnName;
  FErrorMessage := AErrorMessage;
end;

{ TTValidationErrors }

constructor TTValidationErrors.Create;
begin
  inherited Create;
  FErrors := TList<TTValidationError>.Create;
end;

destructor TTValidationErrors.Destroy;
begin
  FErrors.Free;
  inherited Destroy;
end;

procedure TTValidationErrors.Add(
  const AColumnName: String; const AErrorMessage: String);
begin
  FErrors.Add(TTValidationError.Create(AColumnName, AErrorMessage));
end;

function TTValidationErrors.GetIsEmpty: Boolean;
begin
  result := (FErrors.Count = 0);
end;

function TTValidationErrors.ToString: String;
var
  LResult: TStringBuilder;
  LError: TTValidationError;
begin
  LResult := TStringBuilder.Create;
  try
    for LError in FErrors do
      LResult.AppendLine(Format('- %s: %s', [
        LError.ColumnName, LError.ErrorMessage]));
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTValidationErrors.ToJSon: String;
var
  LResult: TJSonObject;
  LError: TTValidationError;
begin
  LResult := TJSonObject.Create;
  try
    for LError in FErrors do
    begin
      LResult.AddPair('columnName', LError.ColumnName);
      LResult.AddPair('errorMessage', LError.ErrorMessage);
    end;
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

end.
