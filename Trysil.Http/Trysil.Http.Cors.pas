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

{ TTHttpCorsController }

  TTHttpCorsController = class
  strict private
    FHeaders: TList<String>;
    FMethods: TList<String>;

    function InternalGetValues(const AList: TList<String>): String;

    function GetHeaders: String;
    function GetMethods: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddHeader(const AHeader: String);
    procedure AddMethod(const AMethod: String);

    property Headers: String read GetHeaders;
    property Methods: String read GetMethods;
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

{ TTHttpCorsController }

constructor TTHttpCorsController.Create;
begin
  inherited Create;
  FHeaders := TList<String>.Create;
  FMethods := TList<String>.Create;
end;

destructor TTHttpCorsController.Destroy;
begin
  FMethods.Free;
  FHeaders.Free;
  inherited Destroy;
end;

procedure TTHttpCorsController.AddHeader(const AHeader: String);
begin
  if not FHeaders.Contains(AHeader) then
    FHeaders.Add(AHeader);
end;

procedure TTHttpCorsController.AddMethod(const AMethod: String);
begin
  if not FMethods.Contains(AMethod) then
    FMethods.Add(AMethod);
end;

function TTHttpCorsController.InternalGetValues(
  const AList: TList<String>): String;
var
  LValue: String;
begin
  result := String.Empty;
  for LValue in AList do
    if result.IsEmpty then
      result := LValue
    else
      result := Format('%s, %s', [result, LValue]);
end;

function TTHttpCorsController.GetHeaders: String;
begin
  result := InternalGetValues(FHeaders);
end;

function TTHttpCorsController.GetMethods: String;
begin
  result := InternalGetValues(FMethods);
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

  if AAuthType <> TTHttpAuthorizationType.None then
    LController.AddHeader('Authorization');

  LController.AddMethod(AControllerID.Method);
end;

procedure TTHttpCors.AddAllowHeaders(
  const AController: TTHttpCorsController; const AResponse: TTHttpResponse);
var
  LHeaders: String;
begin
  LHeaders := AController.Headers;
  if not FConfig.AllowHeaders.IsEmpty then
    if LHeaders.IsEmpty then
      LHeaders := FConfig.AllowHeaders
    else
      LHeaders := Format('%s, %s', [FConfig.AllowHeaders, LHeaders]);

  if not LHeaders.IsEmpty then
    AResponse.AddHeader(CorsAllowHeaders, LHeaders);
end;

procedure TTHttpCors.AddAllowMethods(
  const AController: TTHttpCorsController; const AResponse: TTHttpResponse);
var
  LMethods: String;
begin
  LMethods := AController.Methods;
  if not LMethods.IsEmpty then
    AResponse.AddHeader(CorsAllowMethods, LMethods);
end;

procedure TTHttpCors.AddAllowOrigin(const AResponse: TTHttpResponse);
begin
  AResponse.AddHeader(CorsAllowHeaders, 'content-type');
  if not FConfig.AllowOrigin.IsEmpty then
    AResponse.AddHeader(CorsAllowOrigin, FConfig.AllowOrigin);
end;

procedure TTHttpCors.AddCorsHeaders(
  const AUri: String; const AResponse: TTHttpResponse);
var
  LController: TTHttpCorsController;
begin
  if FControllers.TryGetValue(AUri, LController) then
  begin
    AddAllowHeaders(LController, AResponse);
    AddAllowMethods(LController, AResponse);
  end;
end;

end.
