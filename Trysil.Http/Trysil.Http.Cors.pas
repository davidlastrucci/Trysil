(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Cors;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,

  Trysil.Http.Types,
  Trysil.Http.Classes;

type

{ TTHttpCorsConfig }

  TTHttpCorsConfig = class
  strict private
    FAllowHeaders: String;
    FAllowOrigin: String;
  public
    property AllowHeaders: String read FAllowHeaders write FAllowHeaders;
    property AllowOrigin: String read FAllowOrigin write FAllowOrigin;
  end;

{ TTHttpCorsValues }

  TTHttpCorsValues = class
  strict private
    FValues: TList<String>;

    function Contains(const AValue: String): Boolean;

    function GetIsEmpty: Boolean;
    function GetValue: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AValue: String);
    procedure AddValues(const AValues: String);
    procedure AddList(const AList: TTHttpCorsValues);

    property IsEmpty: Boolean read GetIsEmpty;
    property Value: String read GetValue;
  end;

{ TTHttpCorsController }

  TTHttpCorsController = class
  strict private
    FHeaders: TTHttpCorsValues;
    FMethods: TTHttpCorsValues;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddHeader(const AHeader: String);
    procedure AddMethod(const AMethod: String);

    property Headers: TTHttpCorsValues read FHeaders;
    property Methods: TTHttpCorsValues read FMethods;
  end;

{ TTHttpCors }

  TTHttpCors = class
  strict private
    const CorsAllowHeaders: String = 'Access-Control-Allow-Headers';
    const CorsAllowMethods: String = 'Access-Control-Allow-Methods';
    const CorsAllowOrigin: String = 'Access-Control-Allow-Origin';
  strict private
    FConfig: TTHttpCorsConfig;
    FControllers: TObjectDictionary<String, TTHttpCorsController>;

    procedure AddAllowHeaders(
      const AController: TTHttpCorsController; const AResponse: TTHttpResponse);
    procedure AddAllowMethods(
      const AController: TTHttpCorsController; const AResponse: TTHttpResponse);
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterController(
      const AControllerID: TTHttpControllerID;
      const AAuthType: TTHttpAuthorizationType);

    procedure AddCorsHeaders(
      const AUri: String; const AResponse: TTHttpResponse);

    procedure AddAllowOrigin(const AResponse: TTHttpResponse);

    property Config: TTHttpCorsConfig read FConfig;
  end;

implementation

{ TTHttpCorsValues }

constructor TTHttpCorsValues.Create;
begin
  inherited Create;
  FValues := TList<String>.Create;
end;

destructor TTHttpCorsValues.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

function TTHttpCorsValues.Contains(const AValue: String): Boolean;
var
  LValue: String;
begin
  result := False;
  for LValue in FValues do
    if SameText(LValue, AValue) then
    begin
      result := True;
      Break;
    end;
end;

procedure TTHttpCorsValues.Add(const AValue: String);
var
  LValue: String;
begin
  LValue := AValue.Trim;
  if (not LValue.IsEmpty) and (not Contains(LValue)) then
    FValues.Add(LValue);
end;

procedure TTHttpCorsValues.AddValues(const AValues: String);
var
  LValue: String;
begin
  for LValue in AValues.Split([',']) do
    Add(LValue);
end;

procedure TTHttpCorsValues.AddList(const AList: TTHttpCorsValues);
var
  LValue: String;
begin
  for LValue in AList.FValues do
    Add(LValue);
end;

function TTHttpCorsValues.GetIsEmpty: Boolean;
begin
  result := FValues.Count = 0;
end;

function TTHttpCorsValues.GetValue: String;
var
  LValue: String;
begin
  result := String.Empty;
  for LValue in FValues do
    if result.IsEmpty then
      result := LValue
    else
      result := Format('%s, %s', [result, LValue]);
end;

{ TTHttpCorsController }

constructor TTHttpCorsController.Create;
begin
  inherited Create;
  FHeaders := TTHttpCorsValues.Create;
  FMethods := TTHttpCorsValues.Create;
end;

destructor TTHttpCorsController.Destroy;
begin
  FMethods.Free;
  FHeaders.Free;
  inherited Destroy;
end;

procedure TTHttpCorsController.AddHeader(const AHeader: String);
begin
  FHeaders.Add(AHeader);
end;

procedure TTHttpCorsController.AddMethod(const AMethod: String);
begin
  FMethods.Add(AMethod);
end;

{ TTHttpCors }

constructor TTHttpCors.Create;
begin
  inherited Create;
  FConfig := TTHttpCorsConfig.Create;
  FControllers := TObjectDictionary<
    String, TTHttpCorsController>.Create([doOwnsValues]);
end;

destructor TTHttpCors.Destroy;
begin
  FControllers.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TTHttpCors.RegisterController(
  const AControllerID: TTHttpControllerID;
  const AAuthType: TTHttpAuthorizationType);
var
  LController: TTHttpCorsController;
begin
  if not FControllers.TryGetValue(AControllerID.Uri, LController) then
  begin
    LController := TTHttpCorsController.Create;
    FControllers.Add(AControllerID.Uri, LController);
  end;

  LController.AddHeader('Content-Type');
  if AAuthType <> TTHttpAuthorizationType.None then
    LController.AddHeader('Authorization');

  LController.AddMethod(AControllerID.Method);
end;

procedure TTHttpCors.AddAllowHeaders(
  const AController: TTHttpCorsController; const AResponse: TTHttpResponse);
var
  LHeaders: TTHttpCorsValues;
begin
  LHeaders := TTHttpCorsValues.Create;
  try
    LHeaders.AddValues(FConfig.AllowHeaders);
    LHeaders.AddList(AController.Headers);
    if not LHeaders.IsEmpty then
      AResponse.AddHeader(CorsAllowHeaders, LHeaders.Value);
  finally
    LHeaders.Free;
  end;
end;

procedure TTHttpCors.AddAllowMethods(
  const AController: TTHttpCorsController; const AResponse: TTHttpResponse);
begin
  if not AController.Methods.IsEmpty then
    AResponse.AddHeader(CorsAllowMethods, AController.Methods.Value);
end;

procedure TTHttpCors.AddAllowOrigin(const AResponse: TTHttpResponse);
begin
  if not FConfig.AllowOrigin.IsEmpty then
    AResponse.AddHeader(CorsAllowOrigin, FConfig.AllowOrigin);
end;

procedure TTHttpCors.AddCorsHeaders(
  const AUri: String; const AResponse: TTHttpResponse);
var
  LUris: TArray<String>;
  LLength, LIndex, LIdx: Integer;
  LUri: String;
  LController: TTHttpCorsController;
begin
  LUris := AUri.Split(['/']);
  LLength := Length(LUris);
  LIndex := LLength - 1;

  LUri := AUri;
  while True do
  begin
    if FControllers.TryGetValue(LUri, LController) then
    begin
      AddAllowHeaders(LController, AResponse);
      AddAllowMethods(LController, AResponse);
      Break;
    end
    else
    begin
      LUris[LIndex] := '?';
      Dec(LIndex);
      if LIndex < 0 then
        Break;

      LUri := String.Empty;
      for LIdx := 1 to LLength - 1 do
        LUri := Format('%s/%s', [LUri, LUris[LIdx]]);
    end;
  end;
end;

end.
