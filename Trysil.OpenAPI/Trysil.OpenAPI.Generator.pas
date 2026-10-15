(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI.Generator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,
  System.JSon,
  System.Generics.Collections,
  Trysil.Consts,
  Trysil.Classes,
  Trysil.Rtti,

  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Rtti,

  Trysil.OpenAPI.Consts,
  Trysil.OpenAPI.Exceptions,
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Attributes,
  Trysil.OpenAPI.Schema;

type

{ TTOpenApiMethod }

  TTOpenApiMethod = class
  strict private
    FControllerType: TRttiType;
    FMethod: TRttiMethod;
    FMethods: TList<TRttiMethod>;

    function SameSignature(
      const ALeft: TRttiMethod; const ARight: TRttiMethod): Boolean;
    procedure SearchOverrides(const AType: TRttiType);
    function AttributesOf<T: TCustomAttribute>(
      const AMethod: TRttiMethod): TArray<T>;
  public
    constructor Create(
      const AControllerType: TRttiType; const AMethod: TRttiMethod);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Find<T: TCustomAttribute>(): TArray<T>;
    function FindFirst<T: TCustomAttribute>(): T;
  end;

{ TTOpenApiUri }

  TTOpenApiUri = record
  strict private
    FRelative: String;
    FSegment: String;
  public
    constructor Create(const AUri: String; const ABaseUri: String);

    property Relative: String read FRelative;
    property Segment: String read FSegment;
  end;

{ TTOpenApiPathNames }

  TTOpenApiPathNames = class
  strict private
    FNames: TDictionary<String, TArray<String>>;
  public
    constructor Create;
    destructor Destroy; override;

    function Resolve(
      const AUri: String; const ANames: TArray<String>): TArray<String>;
  end;

{ TTOpenApiPath }

  TTOpenApiPath = class
  strict private
    FRoute: TTHttpRoute;
    FPathNames: TTOpenApiPathNames;
    FUri: TTOpenApiUri;
    FParameters: TArray<TRttiParameter>;
    FNames: TArray<String>;

    function GetCount: Integer;
    function GetSegment: String;
    function ParameterName(const AIndex: Integer): String;
    function CreateNames: TArray<String>;
  public
    constructor Create(
      const ARoute: TTHttpRoute;
      const APathNames: TTOpenApiPathNames;
      const ABaseUri: String);

    procedure AfterConstruction; override;

    function Template: String;
    function Name(const AIndex: Integer): String;

    property Count: Integer read GetCount;
    property Segment: String read GetSegment;
  end;

{ TTOpenApiBody }

  TTOpenApiBody = class(TTOpenApiJSonWriter)
  strict private
    FSchemas: TTOpenApiSchemas;
    FRoute: TTHttpRoute;
    FEntityClass: TClass;

    function ResolveClass(const AAttribute: TOpenApiBodyAttribute): TClass;
    procedure WriteShape(
      const AClass: TClass;
      const AShape: TTOpenApiShape;
      const AJSon: TJSonObject);
    procedure WriteList(const AClass: TClass; const AJSon: TJSonObject);
    procedure WritePage(const AClass: TClass; const AJSon: TJSonObject);
  public
    constructor Create(
      const ASchemas: TTOpenApiSchemas;
      const ARoute: TTHttpRoute;
      const AEntityClass: TClass);

    procedure Write(
      const AAttribute: TOpenApiBodyAttribute; const AJSon: TJSonObject);
  end;

{ TTOpenApiResponses }

  TTOpenApiResponses = class(TTOpenApiJSonWriter)
  strict private
    FSchemas: TTOpenApiSchemas;
    FBody: TTOpenApiBody;
    FRoute: TTHttpRoute;
    FHasRequestBody: Boolean;
    FHasAuthentication: Boolean;
    FJSon: TJSonObject;

    procedure WriteResponse(const AAttribute: TResponseAttribute);
    procedure WriteImplicitErrors;
    procedure WriteRouteErrors;
    procedure WriteBodyErrors;
    procedure WriteErrorWhen(
      const ACondition: Boolean;
      const AStatusCode: Integer;
      const ADescription: String);
    procedure WriteError(
      const AStatusCode: Integer; const ADescription: String);
    procedure WriteErrorExample(
      const AMedia: TJSonObject;
      const AStatusCode: Integer;
      const ADescription: String);
  public
    constructor Create(
      const ASchemas: TTOpenApiSchemas;
      const ABody: TTOpenApiBody;
      const ARoute: TTHttpRoute;
      const AHasRequestBody: Boolean;
      const AHasAuthentication: Boolean;
      const AJSon: TJSonObject);

    procedure Write(const AAttributes: TArray<TResponseAttribute>);
  end;

{ TTOpenApiOperation }

  TTOpenApiOperation = class(TTOpenApiJSonWriter)
  strict private
    const ParameterSources: array[TTOpenApiParameterSource] of String = (
      'query', 'header');
  strict private
    FSchemas: TTOpenApiSchemas;
    FRoute: TTHttpRoute;
    FControllerType: TRttiType;
    FSchemeName: String;
    FMethod: TTOpenApiMethod;
    FPath: TTOpenApiPath;
    FBody: TTOpenApiBody;
    FHasRequestBody: Boolean;

    function IsEntityClassMethod(const AMethod: TRttiMethod): Boolean;
    function SearchEntityClass: TClass;
    function TagName: String;
    procedure CheckRequestBody(const AAttribute: TRequestBodyAttribute);
    procedure WriteHeader(const AJSon: TJSonObject);
    procedure WriteParameters(const AJSon: TJSonObject);
    procedure WritePathParameter(
      const AParameters: TJSonArray; const AIndex: Integer);
    procedure WriteParameter(
      const AParameters: TJSonArray; const AAttribute: TParameterAttribute);
    procedure WriteRequestBody(const AJSon: TJSonObject);
    procedure WriteResponses(const AJSon: TJSonObject);
    procedure WriteSecurity(const AJSon: TJSonObject);
  public
    constructor Create(
      const ASchemas: TTOpenApiSchemas;
      const ARoute: TTHttpRoute;
      const AControllerType: TRttiType;
      const ASchemeName: String;
      const APathNames: TTOpenApiPathNames;
      const ABaseUri: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Template: String;
    procedure Write(const AJSon: TJSonObject);
  end;

{ TTOpenApiTags }

  TTOpenApiTags = class(TTOpenApiJSonWriter)
  strict private
    FContext: TRttiContext;
    FNames: TList<String>;
    FDescriptions: TDictionary<String, String>;

    function DescriptionOf(const AType: TRttiType): String;
    procedure Include(const AName: String; const ADescription: String);
    procedure WriteTag(const ATags: TJSonArray; const AName: String);
  public
    constructor Create(const AContext: TRttiContext);
    destructor Destroy; override;

    procedure Add(const AClass: TClass; const ASegment: String);
    procedure Write(const AJSon: TJSonObject);
  end;

{ TTOpenApiGenerator }

  TTOpenApiGenerator = class(TTOpenApiJSonWriter)
  strict private
    FInfo: TTOpenApiInfo;
    FRoutes: TArray<TTHttpRoute>;
    FBaseUri: String;
    FAuthenticationClass: TClass;
    FContext: TRttiContext;
    FSchemeName: String;
    FPathNames: TTOpenApiPathNames;
    FQualifiedNames: TArray<String>;
    FCollisions: TArray<String>;

    function IsSchemeNameMethod(const AMethod: TRttiMethod): Boolean;
    function SearchSchemeName: String;
    function VerbOf(const ARoute: TTHttpRoute): String;
    function CreateDocument: String;
    function PathOf(
      const APaths: TJSonObject; const ATemplate: String): TJSonObject;
    procedure WriteDocument(const AJSon: TJSonObject);
    procedure WriteInfo(const AJSon: TJSonObject);
    procedure WriteServers(const AJSon: TJSonObject);
    procedure WritePaths(
      const AJSon: TJSonObject; const ASchemas: TTOpenApiSchemas);
    procedure WriteRoute(
      const APaths: TJSonObject;
      const ASchemas: TTOpenApiSchemas;
      const ARoute: TTHttpRoute);
    procedure WriteSecuritySchemes(const AComponents: TJSonObject);
    procedure WriteTags(const AJSon: TJSonObject);
  public
    constructor Create(
      const AInfo: TTOpenApiInfo;
      const ARoutes: TArray<TTHttpRoute>;
      const ABaseUri: String;
      const AAuthenticationClass: TClass);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Generate: String;
  end;

implementation

{ TTOpenApiMethod }

constructor TTOpenApiMethod.Create(
  const AControllerType: TRttiType; const AMethod: TRttiMethod);
begin
  inherited Create;
  FControllerType := AControllerType;
  FMethod := AMethod;
  FMethods := TList<TRttiMethod>.Create;
end;

destructor TTOpenApiMethod.Destroy;
begin
  FMethods.Free;
  inherited Destroy;
end;

procedure TTOpenApiMethod.AfterConstruction;
var
  LType: TRttiType;
begin
  inherited AfterConstruction;
  LType := FControllerType;
  while Assigned(LType) do
  begin
    SearchOverrides(LType);
    LType := LType.BaseType;
  end;
  if FMethods.Count = 0 then
    FMethods.Add(FMethod);
end;

function TTOpenApiMethod.SameSignature(
  const ALeft: TRttiMethod; const ARight: TRttiMethod): Boolean;
var
  LLeft: TArray<TRttiParameter>;
  LRight: TArray<TRttiParameter>;
  LIndex: Integer;
begin
  LLeft := ALeft.GetParameters;
  LRight := ARight.GetParameters;
  result := Length(LLeft) = Length(LRight);
  LIndex := 0;
  while result and (LIndex < Length(LLeft)) do
  begin
    result := LLeft[LIndex].ParamType = LRight[LIndex].ParamType;
    Inc(LIndex);
  end;
end;

procedure TTOpenApiMethod.SearchOverrides(const AType: TRttiType);
var
  LMethod: TRttiMethod;
begin
  for LMethod in AType.GetDeclaredMethods do
    if TTIdentifier.Same(LMethod.Name, FMethod.Name) and
      (not LMethod.IsClassMethod) and
      SameSignature(LMethod, FMethod) then
      FMethods.Add(LMethod);
end;

function TTOpenApiMethod.AttributesOf<T>(
  const AMethod: TRttiMethod): TArray<T>;
var
  LAttribute: TCustomAttribute;
begin
  result := [];
  for LAttribute in AMethod.GetAttributes do
    if LAttribute is T then
    begin
      SetLength(result, Length(result) + 1);
      result[High(result)] := T(LAttribute);
    end;
end;

function TTOpenApiMethod.Find<T>(): TArray<T>;
var
  LIndex: Integer;
begin
  result := [];
  LIndex := 0;
  while (Length(result) = 0) and (LIndex < FMethods.Count) do
  begin
    result := AttributesOf<T>(FMethods[LIndex]);
    Inc(LIndex);
  end;
end;

function TTOpenApiMethod.FindFirst<T>(): T;
var
  LAttributes: TArray<T>;
begin
  result := Default(T);
  LAttributes := Find<T>();
  if Length(LAttributes) > 0 then
    result := LAttributes[0];
end;

{ TTOpenApiPath }

{ TTOpenApiUri }

constructor TTOpenApiUri.Create(const AUri: String; const ABaseUri: String);
var
  LBaseUri: String;
  LParts: TArray<String>;
begin
  LBaseUri := ABaseUri.ToLowerInvariant;
  FRelative := AUri;
  if (not LBaseUri.IsEmpty) and FRelative.StartsWith(LBaseUri) then
    FRelative := FRelative.Substring(LBaseUri.Length);
  if not FRelative.StartsWith('/') then
    FRelative := Format('/%s', [FRelative]);
  FSegment := String.Empty;
  LParts := FRelative.Split(['/'], TStringSplitOptions.ExcludeEmpty);
  if (Length(LParts) > 0) and (LParts[0] <> '?') then
    FSegment := LParts[0];
end;

{ TTOpenApiPathNames }

constructor TTOpenApiPathNames.Create;
begin
  inherited Create;
  FNames := TDictionary<String, TArray<String>>.Create;
end;

destructor TTOpenApiPathNames.Destroy;
begin
  FNames.Free;
  inherited Destroy;
end;

function TTOpenApiPathNames.Resolve(
  const AUri: String; const ANames: TArray<String>): TArray<String>;
begin
  if not FNames.TryGetValue(AUri, result) then
  begin
    result := ANames;
    FNames.Add(AUri, result);
  end;
end;

{ TTOpenApiPath }

constructor TTOpenApiPath.Create(
  const ARoute: TTHttpRoute;
  const APathNames: TTOpenApiPathNames;
  const ABaseUri: String);
begin
  inherited Create;
  FRoute := ARoute;
  FPathNames := APathNames;
  FUri := TTOpenApiUri.Create(ARoute.ControllerID.Uri, ABaseUri);
end;

procedure TTOpenApiPath.AfterConstruction;
begin
  inherited AfterConstruction;
  FParameters := FRoute.Method.GetParameters;
  FNames := FPathNames.Resolve(FRoute.ControllerID.Uri, CreateNames);
end;

function TTOpenApiPath.GetCount: Integer;
begin
  result := Length(FParameters);
end;

function TTOpenApiPath.GetSegment: String;
begin
  result := FUri.Segment;
end;

function TTOpenApiPath.CreateNames: TArray<String>;
var
  LIndex: Integer;
begin
  SetLength(result, Length(FParameters));
  for LIndex := 0 to High(FParameters) do
    result[LIndex] := ParameterName(LIndex);
end;

function TTOpenApiPath.Name(const AIndex: Integer): String;
begin
  result := FNames[AIndex];
end;

function TTOpenApiPath.ParameterName(const AIndex: Integer): String;
begin
  result := FParameters[AIndex].Name;
  if (result.Length > 1) and (result.Chars[0] = 'A') and
    CharInSet(result.Chars[1], ['A' .. 'Z']) then
    result := result.Substring(1);
  result := TTIdentifier.PublishedName(result);
end;

function TTOpenApiPath.Template: String;
var
  LParts: TArray<String>;
  LIndex: Integer;
  LParameter: Integer;
begin
  LParts := FUri.Relative.Split(['/']);
  LParameter := 0;
  for LIndex := Low(LParts) to High(LParts) do
    if LParts[LIndex] = '?' then
    begin
      LParts[LIndex] := Format('{%s}', [Name(LParameter)]);
      Inc(LParameter);
    end;
  result := String.Join('/', LParts);
  if result.IsEmpty then
    result := '/';
end;

{ TTOpenApiBody }

constructor TTOpenApiBody.Create(
  const ASchemas: TTOpenApiSchemas;
  const ARoute: TTHttpRoute;
  const AEntityClass: TClass);
begin
  inherited Create;
  FSchemas := ASchemas;
  FRoute := ARoute;
  FEntityClass := AEntityClass;
end;

function TTOpenApiBody.ResolveClass(
  const AAttribute: TOpenApiBodyAttribute): TClass;
begin
  result := AAttribute.EntityClass;
  if not Assigned(result) then
    result := FEntityClass;
  if not Assigned(result) then
    raise ETOpenApiException.CreateFmt(
      TTLanguage.Instance.Translate(SOpenApiNoEntityClass), [
        FRoute.ControllerClass.ClassName, FRoute.Method.Name]);
end;

procedure TTOpenApiBody.Write(
  const AAttribute: TOpenApiBodyAttribute; const AJSon: TJSonObject);
var
  LClass: TClass;
  LMedia: TJSonObject;
begin
  LClass := ResolveClass(AAttribute);
  LMedia := AddObject(AddObject(AJSon, 'content'), SOpenApiMediaType);
  WriteShape(LClass, AAttribute.Shape, AddObject(LMedia, 'schema'));
end;

procedure TTOpenApiBody.WriteShape(
  const AClass: TClass;
  const AShape: TTOpenApiShape;
  const AJSon: TJSonObject);
begin
  case AShape of
    TTOpenApiShape.Single: FSchemas.WriteReference(AClass, AJSon);
    TTOpenApiShape.List: WriteList(AClass, AJSon);
    TTOpenApiShape.Page: WritePage(AClass, AJSon);
  end;
end;

procedure TTOpenApiBody.WriteList(
  const AClass: TClass; const AJSon: TJSonObject);
begin
  AJSon.AddPair('type', 'array');
  FSchemas.WriteReference(AClass, AddObject(AJSon, 'items'));
end;

procedure TTOpenApiBody.WritePage(
  const AClass: TClass; const AJSon: TJSonObject);
var
  LProperties: TJSonObject;
begin
  AJSon.AddPair('type', 'object');
  LProperties := AddObject(AJSon, 'properties');
  AddTyped(LProperties, 'count', 'integer');
  WriteList(AClass, AddObject(LProperties, 'data'));
  AddStrings(AJSon, 'required', ['count', 'data']);
end;

{ TTOpenApiResponses }

constructor TTOpenApiResponses.Create(
  const ASchemas: TTOpenApiSchemas;
  const ABody: TTOpenApiBody;
  const ARoute: TTHttpRoute;
  const AHasRequestBody: Boolean;
  const AHasAuthentication: Boolean;
  const AJSon: TJSonObject);
begin
  inherited Create;
  FSchemas := ASchemas;
  FBody := ABody;
  FRoute := ARoute;
  FHasRequestBody := AHasRequestBody;
  FHasAuthentication := AHasAuthentication;
  FJSon := AJSon;
end;

procedure TTOpenApiResponses.Write(
  const AAttributes: TArray<TResponseAttribute>);
var
  LAttribute: TResponseAttribute;
begin
  for LAttribute in AAttributes do
    WriteResponse(LAttribute);
  WriteImplicitErrors;
end;

procedure TTOpenApiResponses.WriteResponse(
  const AAttribute: TResponseAttribute);
var
  LKey: String;
  LJSon: TJSonObject;
begin
  LKey := AAttribute.StatusCode.ToString;
  if not Assigned(FJSon.GetValue(LKey)) then
  begin
    LJSon := AddObject(FJSon, LKey);
    LJSon.AddPair('description', AAttribute.Description);
    if AAttribute.HasSchema then
      FBody.Write(AAttribute, LJSon);
  end;
end;

procedure TTOpenApiResponses.WriteImplicitErrors;
begin
  WriteBodyErrors;
  WriteRouteErrors;
  WriteError(
    TTHttpStatusCodeTypes.InternalServerError, SOpenApiInternalServerError);
end;

procedure TTOpenApiResponses.WriteRouteErrors;
begin
  WriteErrorWhen(
    FHasAuthentication and
      (FRoute.AuthorizationType = TTHttpAuthorizationType.Authentication),
    TTHttpStatusCodeTypes.Unauthorized,
    SOpenApiUnauthorized);
  WriteErrorWhen(
    Length(FRoute.Areas) > 0,
    TTHttpStatusCodeTypes.Forbidden,
    SOpenApiForbidden);
  WriteErrorWhen(
    FRoute.ControllerID.Uri.Contains('?'),
    TTHttpStatusCodeTypes.NotFound,
    SOpenApiNotFound);
end;

procedure TTOpenApiResponses.WriteBodyErrors;
begin
  WriteErrorWhen(
    FHasRequestBody, TTHttpStatusCodeTypes.BadRequest, SOpenApiBadRequest);
  WriteErrorWhen(
    FHasRequestBody,
    TTHttpStatusCodeTypes.ContentTooLarge,
    SOpenApiContentTooLarge);
  WriteErrorWhen(
    FHasRequestBody,
    TTHttpStatusCodeTypes.UnprocessableContent,
    SOpenApiUnprocessableContent);
end;

procedure TTOpenApiResponses.WriteErrorWhen(
  const ACondition: Boolean;
  const AStatusCode: Integer;
  const ADescription: String);
begin
  if ACondition then
    WriteError(AStatusCode, ADescription);
end;

procedure TTOpenApiResponses.WriteError(
  const AStatusCode: Integer; const ADescription: String);
var
  LKey: String;
  LJSon: TJSonObject;
  LMedia: TJSonObject;
begin
  LKey := AStatusCode.ToString;
  if not Assigned(FJSon.GetValue(LKey)) then
  begin
    LJSon := AddObject(FJSon, LKey);
    LJSon.AddPair('description', ADescription);
    LMedia := AddObject(AddObject(LJSon, 'content'), SOpenApiMediaType);
    FSchemas.WriteReference(TTOpenApiError, AddObject(LMedia, 'schema'));
    WriteErrorExample(LMedia, AStatusCode, ADescription);
  end;
end;

procedure TTOpenApiResponses.WriteErrorExample(
  const AMedia: TJSonObject;
  const AStatusCode: Integer;
  const ADescription: String);
var
  LExample: TJSonObject;
begin
  LExample := AddObject(AMedia, 'example');
  LExample.AddPair('status', TJSonNumber.Create(AStatusCode));
  LExample.AddPair('message', ADescription);
end;

{ TTOpenApiOperation }

constructor TTOpenApiOperation.Create(
  const ASchemas: TTOpenApiSchemas;
  const ARoute: TTHttpRoute;
  const AControllerType: TRttiType;
  const ASchemeName: String;
  const APathNames: TTOpenApiPathNames;
  const ABaseUri: String);
begin
  inherited Create;
  FSchemas := ASchemas;
  FRoute := ARoute;
  FControllerType := AControllerType;
  FSchemeName := ASchemeName;
  FMethod := TTOpenApiMethod.Create(AControllerType, ARoute.Method);
  FPath := TTOpenApiPath.Create(ARoute, APathNames, ABaseUri);
  FBody := nil;
  FHasRequestBody := False;
end;

destructor TTOpenApiOperation.Destroy;
begin
  if Assigned(FBody) then
    FBody.Free;
  FPath.Free;
  FMethod.Free;
  inherited Destroy;
end;

procedure TTOpenApiOperation.AfterConstruction;
begin
  inherited AfterConstruction;
  FBody := TTOpenApiBody.Create(FSchemas, FRoute, SearchEntityClass);
end;

function TTOpenApiOperation.IsEntityClassMethod(
  const AMethod: TRttiMethod): Boolean;
begin
  result := Assigned(AMethod) and
    AMethod.IsClassMethod and
    (Length(AMethod.GetParameters) = 0) and
    Assigned(AMethod.ReturnType) and
    (AMethod.ReturnType.TypeKind = TTypeKind.tkClassRef);
end;

function TTOpenApiOperation.SearchEntityClass: TClass;
var
  LMethod: TRttiMethod;
begin
  result := nil;
  LMethod := FControllerType.GetMethod('EntityClass');
  if IsEntityClassMethod(LMethod) then
    result := LMethod.Invoke(FRoute.ControllerClass, []).AsClass;
end;

function TTOpenApiOperation.TagName: String;
var
  LTag: TTagAttribute;
begin
  result := FPath.Segment;
  LTag := FControllerType.GetInheritedAttribute<TTagAttribute>();
  if Assigned(LTag) then
    result := LTag.Name;
end;

function TTOpenApiOperation.Template: String;
begin
  result := FPath.Template;
end;

procedure TTOpenApiOperation.Write(const AJSon: TJSonObject);
begin
  WriteHeader(AJSon);
  WriteParameters(AJSon);
  WriteRequestBody(AJSon);
  WriteResponses(AJSon);
  WriteSecurity(AJSon);
end;

procedure TTOpenApiOperation.WriteHeader(const AJSon: TJSonObject);
var
  LTagName: String;
  LSummary: TSummaryAttribute;
  LDescription: TDescriptionAttribute;
begin
  LTagName := TagName;
  if not LTagName.IsEmpty then
    AddStrings(AJSon, 'tags', [LTagName]);
  LSummary := FMethod.FindFirst<TSummaryAttribute>();
  if Assigned(LSummary) then
    AJSon.AddPair('summary', LSummary.Text);
  LDescription := FMethod.FindFirst<TDescriptionAttribute>();
  if Assigned(LDescription) then
    AJSon.AddPair('description', LDescription.Text);
end;

procedure TTOpenApiOperation.WriteParameters(const AJSon: TJSonObject);
var
  LAttributes: TArray<TParameterAttribute>;
  LAttribute: TParameterAttribute;
  LParameters: TJSonArray;
  LIndex: Integer;
begin
  LAttributes := FMethod.Find<TParameterAttribute>();
  if (FPath.Count + Length(LAttributes)) > 0 then
  begin
    LParameters := AddArray(AJSon, 'parameters');
    for LIndex := 0 to FPath.Count - 1 do
      WritePathParameter(LParameters, LIndex);
    for LAttribute in LAttributes do
      WriteParameter(LParameters, LAttribute);
  end;
end;

procedure TTOpenApiOperation.WritePathParameter(
  const AParameters: TJSonArray; const AIndex: Integer);
var
  LJSon: TJSonObject;
  LSchema: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  AParameters.AddElement(LJSon);
  LJSon.AddPair('name', FPath.Name(AIndex));
  LJSon.AddPair('in', 'path');
  LJSon.AddPair('required', TJSonBool.Create(True));
  LSchema := AddObject(LJSon, 'schema');
  if FRoute.NotSqids[AIndex] then
    FSchemas.Primitives.Write(TypeInfo(Integer), LSchema)
  else
    FSchemas.WriteId(LSchema);
end;

procedure TTOpenApiOperation.WriteParameter(
  const AParameters: TJSonArray; const AAttribute: TParameterAttribute);
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  AParameters.AddElement(LJSon);
  LJSon.AddPair('name', AAttribute.Name);
  LJSon.AddPair('in', ParameterSources[AAttribute.Source]);
  if not AAttribute.Description.IsEmpty then
    LJSon.AddPair('description', AAttribute.Description);
  AddTyped(LJSon, 'schema', 'string');
end;

procedure TTOpenApiOperation.CheckRequestBody(
  const AAttribute: TRequestBodyAttribute);
begin
  if AAttribute.Shape = TTOpenApiShape.Page then
    raise ETOpenApiException.CreateFmt(
      TTLanguage.Instance.Translate(SOpenApiPageRequestBody), [
        FRoute.ControllerClass.ClassName, FRoute.Method.Name]);
end;

procedure TTOpenApiOperation.WriteRequestBody(const AJSon: TJSonObject);
var
  LAttribute: TRequestBodyAttribute;
  LJSon: TJSonObject;
begin
  LAttribute := FMethod.FindFirst<TRequestBodyAttribute>();
  FHasRequestBody := Assigned(LAttribute);
  if FHasRequestBody then
  begin
    CheckRequestBody(LAttribute);
    LJSon := AddObject(AJSon, 'requestBody');
    if not LAttribute.Description.IsEmpty then
      LJSon.AddPair('description', LAttribute.Description);
    LJSon.AddPair('required', TJSonBool.Create(True));
    FBody.Write(LAttribute, LJSon);
  end;
end;

procedure TTOpenApiOperation.WriteResponses(const AJSon: TJSonObject);
var
  LResponses: TTOpenApiResponses;
begin
  LResponses := TTOpenApiResponses.Create(
    FSchemas,
    FBody,
    FRoute,
    FHasRequestBody,
    not FSchemeName.IsEmpty,
    AddObject(AJSon, 'responses'));
  try
    LResponses.Write(FMethod.Find<TResponseAttribute>());
  finally
    LResponses.Free;
  end;
end;

procedure TTOpenApiOperation.WriteSecurity(const AJSon: TJSonObject);
var
  LSecurity: TJSonArray;
  LRequirement: TJSonObject;
begin
  if FRoute.AuthorizationType = TTHttpAuthorizationType.None then
    AddArray(AJSon, 'security')
  else if not FSchemeName.IsEmpty then
  begin
    LSecurity := AddArray(AJSon, 'security');
    LRequirement := TJSonObject.Create;
    LSecurity.AddElement(LRequirement);
    AddArray(LRequirement, FSchemeName);
  end;
end;

{ TTOpenApiTags }

constructor TTOpenApiTags.Create(const AContext: TRttiContext);
begin
  inherited Create;
  FContext := AContext;
  FNames := TList<String>.Create;
  FDescriptions := TDictionary<String, String>.Create;
end;

destructor TTOpenApiTags.Destroy;
begin
  FDescriptions.Free;
  FNames.Free;
  inherited Destroy;
end;

function TTOpenApiTags.DescriptionOf(const AType: TRttiType): String;
var
  LDescription: TDescriptionAttribute;
begin
  result := String.Empty;
  LDescription := AType.GetInheritedAttribute<TDescriptionAttribute>();
  if Assigned(LDescription) then
    result := LDescription.Text;
end;

procedure TTOpenApiTags.Add(const AClass: TClass; const ASegment: String);
var
  LType: TRttiType;
  LTag: TTagAttribute;
begin
  LType := FContext.GetType(AClass);
  LTag := LType.GetInheritedAttribute<TTagAttribute>();
  if Assigned(LTag) then
    Include(LTag.Name, DescriptionOf(LType))
  else if not ASegment.IsEmpty then
    Include(ASegment, String.Empty);
end;

procedure TTOpenApiTags.Include(
  const AName: String; const ADescription: String);
begin
  if not FNames.Contains(AName) then
  begin
    FNames.Add(AName);
    FDescriptions.Add(AName, ADescription);
  end;
end;

procedure TTOpenApiTags.Write(const AJSon: TJSonObject);
var
  LTags: TJSonArray;
  LName: String;
begin
  if FNames.Count > 0 then
  begin
    LTags := AddArray(AJSon, 'tags');
    for LName in FNames do
      WriteTag(LTags, LName);
  end;
end;

procedure TTOpenApiTags.WriteTag(const ATags: TJSonArray; const AName: String);
var
  LJSon: TJSonObject;
  LDescription: String;
begin
  LJSon := TJSonObject.Create;
  ATags.AddElement(LJSon);
  LJSon.AddPair('name', AName);
  LDescription := FDescriptions[AName];
  if not LDescription.IsEmpty then
    LJSon.AddPair('description', LDescription);
end;

{ TTOpenApiGenerator }

constructor TTOpenApiGenerator.Create(
  const AInfo: TTOpenApiInfo;
  const ARoutes: TArray<TTHttpRoute>;
  const ABaseUri: String;
  const AAuthenticationClass: TClass);
begin
  inherited Create;
  FInfo := AInfo;
  FRoutes := ARoutes;
  FBaseUri := ABaseUri;
  FAuthenticationClass := AAuthenticationClass;
  FContext := TRttiContext.Create;
  FPathNames := TTOpenApiPathNames.Create;
end;

destructor TTOpenApiGenerator.Destroy;
begin
  FPathNames.Free;
  FContext.Free;
  inherited Destroy;
end;

procedure TTOpenApiGenerator.AfterConstruction;
begin
  inherited AfterConstruction;
  FSchemeName := SearchSchemeName;
end;

function TTOpenApiGenerator.IsSchemeNameMethod(
  const AMethod: TRttiMethod): Boolean;
begin
  result := Assigned(AMethod) and
    AMethod.IsClassMethod and
    (Length(AMethod.GetParameters) = 0) and
    Assigned(AMethod.ReturnType) and
    (AMethod.ReturnType.TypeKind = TTypeKind.tkUString);
end;

function TTOpenApiGenerator.SearchSchemeName: String;
var
  LMethod: TRttiMethod;
begin
  result := String.Empty;
  if Assigned(FAuthenticationClass) then
  begin
    LMethod := FContext.GetType(FAuthenticationClass).GetMethod('SchemeName');
    if IsSchemeNameMethod(LMethod) then
      result := LMethod.Invoke(
        FAuthenticationClass, []).AsString.ToLowerInvariant;
  end;
end;

function TTOpenApiGenerator.Generate: String;
begin
  FQualifiedNames := nil;
  result := CreateDocument;
  if Length(FCollisions) > 0 then
  begin
    FQualifiedNames := FCollisions;
    result := CreateDocument;
  end;
end;

function TTOpenApiGenerator.CreateDocument: String;
var
  LDocument: TJSonObject;
begin
  LDocument := TJSonObject.Create;
  try
    WriteDocument(LDocument);
    result := LDocument.ToJSon();
  finally
    LDocument.Free;
  end;
end;

procedure TTOpenApiGenerator.WriteDocument(const AJSon: TJSonObject);
var
  LComponents: TJSonObject;
  LSchemas: TTOpenApiSchemas;
begin
  AJSon.AddPair('openapi', SOpenApiVersion);
  WriteInfo(AddObject(AJSon, 'info'));
  WriteServers(AJSon);
  WriteTags(AJSon);
  LComponents := AddObject(AJSon, 'components');
  LSchemas := TTOpenApiSchemas.Create(
    AddObject(LComponents, 'schemas'), FQualifiedNames);
  try
    WritePaths(AddObject(AJSon, 'paths'), LSchemas);
    FCollisions := LSchemas.Collisions;
  finally
    LSchemas.Free;
  end;
  WriteSecuritySchemes(LComponents);
end;

procedure TTOpenApiGenerator.WriteInfo(const AJSon: TJSonObject);
begin
  AJSon.AddPair('title', FInfo.Title);
  AJSon.AddPair('version', FInfo.Version);
  if not FInfo.Description.IsEmpty then
    AJSon.AddPair('description', FInfo.Description);
end;

procedure TTOpenApiGenerator.WriteServers(const AJSon: TJSonObject);
var
  LServer: TJSonObject;
begin
  if not FBaseUri.IsEmpty then
  begin
    LServer := TJSonObject.Create;
    AddArray(AJSon, 'servers').AddElement(LServer);
    LServer.AddPair('url', FBaseUri);
  end;
end;

procedure TTOpenApiGenerator.WriteTags(const AJSon: TJSonObject);
var
  LTags: TTOpenApiTags;
  LRoute: TTHttpRoute;
begin
  LTags := TTOpenApiTags.Create(FContext);
  try
    for LRoute in FRoutes do
      LTags.Add(
        LRoute.ControllerClass,
        TTOpenApiUri.Create(LRoute.ControllerID.Uri, FBaseUri).Segment);
    LTags.Write(AJSon);
  finally
    LTags.Free;
  end;
end;

procedure TTOpenApiGenerator.WritePaths(
  const AJSon: TJSonObject; const ASchemas: TTOpenApiSchemas);
var
  LRoute: TTHttpRoute;
begin
  for LRoute in FRoutes do
    WriteRoute(AJSon, ASchemas, LRoute);
end;

procedure TTOpenApiGenerator.WriteRoute(
  const APaths: TJSonObject;
  const ASchemas: TTOpenApiSchemas;
  const ARoute: TTHttpRoute);
var
  LOperation: TTOpenApiOperation;
begin
  LOperation := TTOpenApiOperation.Create(
    ASchemas,
    ARoute,
    FContext.GetType(ARoute.ControllerClass),
    FSchemeName,
    FPathNames,
    FBaseUri);
  try
    LOperation.Write(
      AddObject(PathOf(APaths, LOperation.Template), VerbOf(ARoute)));
  finally
    LOperation.Free;
  end;
end;

function TTOpenApiGenerator.PathOf(
  const APaths: TJSonObject; const ATemplate: String): TJSonObject;
begin
  result := APaths.GetValue(ATemplate) as TJSonObject;
  if not Assigned(result) then
    result := AddObject(APaths, ATemplate);
end;

function TTOpenApiGenerator.VerbOf(const ARoute: TTHttpRoute): String;
begin
  result := TRttiEnumerationType.GetName<TTHttpMethodType>(
    ARoute.ControllerID.MethodType).ToLowerInvariant;
end;

procedure TTOpenApiGenerator.WriteSecuritySchemes(
  const AComponents: TJSonObject);
var
  LScheme: TJSonObject;
begin
  if not FSchemeName.IsEmpty then
  begin
    LScheme := AddObject(
      AddObject(AComponents, 'securitySchemes'), FSchemeName);
    LScheme.AddPair('type', 'http');
    LScheme.AddPair('scheme', FSchemeName);
  end;
end;

end.
