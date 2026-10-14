(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.OpenAPI;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TypInfo,
  System.JSon,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Lazy,
  Trysil.JSon.Attributes,
  Trysil.JSon.Sqids,

  Trysil.Http,
  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Attributes,
  Trysil.Http.Controller,
  Trysil.Http.Authentication,
  Trysil.Http.Rtti,

  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Attributes,
  Trysil.OpenAPI.Exceptions,
  Trysil.OpenAPI.Generator,
  Trysil.OpenAPI.Controller,
  Trysil.OpenAPI;

type

{ TTestOpenApiContext }

  TTestOpenApiContext = class
  end;

{ TTestOpenApiCategory }

  [TTable('Categories')]
  [TSequence('CategoriesID')]
  TTestOpenApiCategory = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName;
  end;

{ TTestOpenApiProduct }

  [TTable('Products')]
  [TSequence('ProductsID')]
  TTestOpenApiProduct = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    [TDisplayName('Product name')]
    [TRequired]
    [TMinLength(2)]
    [TMaxLength(50)]
    FName: String;

    [TColumn('Email')]
    [TEMail]
    FEmail: String;

    [TColumn('Quantity')]
    [TRange(1, 100)]
    FQuantity: TTNullable<Integer>;

    [TColumn('Price')]
    [TGreater(0.5)]
    [TMaxValue(1000)]
    FPrice: Double;

    [TColumn('Secret')]
    [TJSonIgnore]
    FSecret: String;

    [TColumn('Token')]
    [TJSonIgnoreSerialize]
    [TRegex('^[A-Z]+$')]
    FToken: String;

    [TColumn('CategoryID')]
    FCategory: TTLazy<TTestOpenApiCategory>;

    [TColumn('CreatedAt')]
    [TCreatedAt]
    FCreatedAt: TTNullable<TDateTime>;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName;
    property Email: String read FEmail;
    property Quantity: TTNullable<Integer> read FQuantity;
    property Price: Double read FPrice;
    property Secret: String read FSecret;
    property Token: String read FToken;
    property Category: TTLazy<TTestOpenApiCategory> read FCategory;
    property CreatedAt: TTNullable<TDateTime> read FCreatedAt;
    property Version: TTVersion read FVersion;
  end;

{ TTestOpenApiBaseController<T> }

  TTestOpenApiBaseController<T: class> = class(
    TTHttpController<TTestOpenApiContext>)
  public
    class function EntityClass: TClass; override;

    [TGet('/?')]
    [TArea('read')]
    [TSummary('Get by ID')]
    [TResponse(200, TTOpenApiShape.Single, 'Found')]
    procedure Get(const AID: Integer); virtual;

    [TGet]
    [TArea('read')]
    [TSummary('Select all')]
    [TParameter('search', TTOpenApiParameterSource.Query, 'Text to search')]
    [TResponse(200, TTOpenApiShape.List, 'All the rows')]
    procedure SelectAll; virtual;

    [TPost('/select')]
    [TArea('read')]
    [TSummary('Select with filter')]
    [TRequestBody(TTOpenApiFilter, TTOpenApiShape.Single, 'Filter')]
    [TResponse(200, TTOpenApiShape.Page, 'Count and rows')]
    procedure Select; virtual;

    [TGet('/metadata')]
    [TArea('read')]
    [TResponse(200, TTOpenApiMetadata, TTOpenApiShape.Single, 'Metadata')]
    procedure Metadata; virtual;

    [TPost]
    [TArea('write')]
    [TRequestBody(TTOpenApiShape.Single, 'Entity to insert')]
    [TResponse(200, TTOpenApiShape.Single, 'Inserted')]
    procedure Insert; virtual;

    [TDelete('/?/?')]
    [TArea('write')]
    [TResponse(200, 'Deleted')]
    [TResponse(409, 'Version changed')]
    procedure Delete(
      const AID: Integer;
      [TNotSqid] const AVersionID: Integer); virtual;
  end;

{ TTestOpenApiProductController }

  [TTag('Products')]
  [TDescription('Product catalogue')]
  TTestOpenApiProductController = class(
    TTestOpenApiBaseController<TTestOpenApiProduct>)
  public
    [TSummary('Product by ID')]
    procedure Get(const AID: Integer); override;
  end;

{ TTestOpenApiPingController }

  TTestOpenApiPingController = class(TTHttpController<TTestOpenApiContext>)
  public
    [TGet]
    [TAuthorizationType(TTHttpAuthorizationType.None)]
    [TResponse(200, 'Pong')]
    procedure Ping;
  end;

{ TTestOpenApiOrphanController }

  TTestOpenApiOrphanController = class(TTHttpController<TTestOpenApiContext>)
  public
    [TGet]
    [TResponse(200, TTOpenApiShape.Single, 'Nothing to describe')]
    procedure Get;
  end;

{ TTestOpenApiPageBodyController }

  TTestOpenApiPageBodyController = class(
    TTestOpenApiBaseController<TTestOpenApiCategory>)
  public
    [TPost('/import')]
    [TRequestBody(TTOpenApiShape.Page, 'Not a request body')]
    procedure Import;
  end;

{ TTestOpenApiAuthentication }

  TTestOpenApiAuthentication = class(
    TTHttpAbstractAuthentication<TTestOpenApiContext>)
  strict protected
    class function GetName: String; override;
    function GetHeader: String; override;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

{ TTOpenApiDocumentTests }

  [TestFixture]
  TTOpenApiDocumentTests = class
  strict private
    FUseSqids: Boolean;
    FServer: TTHttpServer<TTestOpenApiContext>;
    FDocument: TJSonObject;

    function Generate: TJSonObject;
    function ValueAt(const APath: array of String): TJSonValue;
    function TextAt(const APath: array of String): String;
    function Exists(const APath: array of String): Boolean;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TheDocumentNamesItsVersionAndInfo;

    [Test]
    procedure APlaceholderBecomesANamedPathParameter;

    [Test]
    procedure EveryRouteIsAnOperationOfItsVerb;

    [Test]
    procedure TheDocumentDoesNotDescribeItself;

    [Test]
    procedure AnOverrideReplacesTheSummary;

    [Test]
    procedure AnInheritedSummaryIsKept;

    [Test]
    procedure TheTagComesFromTheConcreteController;

    [Test]
    procedure APathParameterIsAnIdUnlessMarkedNotSqid;

    [Test]
    procedure AQueryParameterIsAnOptionalString;

    [Test]
    procedure TheEntityOfTheControllerIsReferenced;

    [Test]
    procedure AListIsAnArrayOfTheEntity;

    [Test]
    procedure APageWrapsCountAndData;

    [Test]
    procedure TheFilterIsAPredefinedSchema;

    [Test]
    procedure TheMetadataIsAPredefinedSchema;

    [Test]
    procedure ImplicitErrorsFollowTheRoute;

    [Test]
    procedure ABodyAddsItsImplicitErrors;

    [Test]
    procedure AnExplicitResponseIsKept;

    [Test]
    procedure AnErrorReferencesTheErrorSchema;

    [Test]
    procedure TheSecurityFollowsTheAuthentication;

    [Test]
    procedure WithoutAuthenticationThereIsNoUnauthorized;

    [Test]
    procedure TheEntitySchemaNamesItsColumnsLikeTheSerializer;

    [Test]
    procedure TheEntitySchemaFollowsTheJSonAttributes;

    [Test]
    procedure TheEntitySchemaFollowsTheTypes;

    [Test]
    procedure TheEntitySchemaFollowsTheValidation;

    [Test]
    procedure TheEntitySchemaFollowsTheConstraints;

    [Test]
    procedure TheEntitySchemaFollowsTheRegex;

    [Test]
    procedure ALazyRelationIsAnIdAndAReference;

    [Test]
    procedure SqidsTurnIdsIntoStrings;
  end;

{ TTOpenApiRegisterTests }

  [TestFixture]
  TTOpenApiRegisterTests = class
  strict private
    FServer: TTHttpServer<TTestOpenApiContext>;

    function TryRegister: Boolean;
    function DocumentRoute: TTHttpRoute;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure RegisterServesTheDocument;

    [Test]
    procedure RegisterProtectsTheDocument;

    [Test]
    procedure RegisterAnonymousPublishesTheDocument;

    [Test]
    procedure RegisterTwiceIsRefused;

    [Test]
    procedure ASecondServerOfTheContextIsRefused;

    [Test]
    procedure AnEmptyTitleIsRefused;

    [Test]
    procedure AShapeWithoutEntityClassIsRefused;

    [Test]
    procedure APageRequestBodyIsRefused;
  end;

implementation

{ TTestOpenApiBaseController<T> }

class function TTestOpenApiBaseController<T>.EntityClass: TClass;
begin
  result := GetTypeData(TypeInfo(T)).ClassType;
end;

procedure TTestOpenApiBaseController<T>.Get(const AID: Integer);
begin
end;

procedure TTestOpenApiBaseController<T>.SelectAll;
begin
end;

procedure TTestOpenApiBaseController<T>.Select;
begin
end;

procedure TTestOpenApiBaseController<T>.Metadata;
begin
end;

procedure TTestOpenApiBaseController<T>.Insert;
begin
end;

procedure TTestOpenApiBaseController<T>.Delete(
  const AID: Integer;
  const AVersionID: Integer);
begin
end;

{ TTestOpenApiProductController }

procedure TTestOpenApiProductController.Get(const AID: Integer);
begin
end;

{ TTestOpenApiPingController }

procedure TTestOpenApiPingController.Ping;
begin
end;

{ TTestOpenApiOrphanController }

procedure TTestOpenApiOrphanController.Get;
begin
end;

{ TTestOpenApiPageBodyController }

procedure TTestOpenApiPageBodyController.Import;
begin
end;

{ TTestOpenApiAuthentication }

class function TTestOpenApiAuthentication.GetName: String;
begin
  result := 'Bearer';
end;

function TTestOpenApiAuthentication.GetHeader: String;
begin
  result := String.Empty;
end;

procedure TTestOpenApiAuthentication.Check(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
end;

{ TTOpenApiDocumentTests }

procedure TTOpenApiDocumentTests.Setup;
begin
  FUseSqids := TTJSonSqids.Instance.UseSqids;
  TTJSonSqids.Instance.UseSqids := False;
  FServer := TTHttpServer<TTestOpenApiContext>.Create;
  FServer.RegisterAuthentication<TTestOpenApiAuthentication>();
  FServer.RegisterController<TTestOpenApiProductController>('/product');
  FServer.RegisterController<TTestOpenApiPingController>('/ping');
  FDocument := Generate;
end;

procedure TTOpenApiDocumentTests.TearDown;
begin
  FDocument.Free;
  FServer.Free;
  TTJSonSqids.Instance.UseSqids := FUseSqids;
end;

function TTOpenApiDocumentTests.Generate: TJSonObject;
var
  LGenerator: TTOpenApiGenerator;
begin
  LGenerator := TTOpenApiGenerator.Create(
    TTOpenApiInfo.Create('Test API', '1.0', 'Products and pings'),
    FServer.Routes,
    FServer.AuthenticationClass);
  try
    result := TJSonObject.ParseJSONValue(LGenerator.Generate) as TJSonObject;
  finally
    LGenerator.Free;
  end;
end;

function TTOpenApiDocumentTests.ValueAt(
  const APath: array of String): TJSonValue;
var
  LName: String;
begin
  result := FDocument;
  for LName in APath do
    if result is TJSonObject then
      result := TJSonObject(result).GetValue(LName)
    else if result is TJSonArray then
      result := TJSonArray(result).Items[LName.ToInteger]
    else
      result := nil;
end;

function TTOpenApiDocumentTests.TextAt(const APath: array of String): String;
var
  LValue: TJSonValue;
begin
  result := String.Empty;
  LValue := ValueAt(APath);
  if Assigned(LValue) then
    result := LValue.Value;
end;

function TTOpenApiDocumentTests.Exists(const APath: array of String): Boolean;
begin
  result := Assigned(ValueAt(APath));
end;

procedure TTOpenApiDocumentTests.TheDocumentNamesItsVersionAndInfo;
begin
  Assert.AreEqual('3.1.0', TextAt(['openapi']), 'OpenAPI version');
  Assert.AreEqual('Test API', TextAt(['info', 'title']), 'Title');
  Assert.AreEqual('1.0', TextAt(['info', 'version']), 'Version');
  Assert.AreEqual(
    'Products and pings',
    TextAt(['info', 'description']),
    'Description');
end;

procedure TTOpenApiDocumentTests.APlaceholderBecomesANamedPathParameter;
begin
  Assert.IsTrue(
    Exists(['paths', '/product/{id}']),
    'The placeholder takes the name of the parameter, without its prefix');
  Assert.IsTrue(
    Exists(['paths', '/product/{id}/{versionID}']),
    'Every placeholder is named after its own parameter');
end;

procedure TTOpenApiDocumentTests.EveryRouteIsAnOperationOfItsVerb;
begin
  Assert.IsTrue(Exists(['paths', '/product', 'get']), 'SelectAll');
  Assert.IsTrue(Exists(['paths', '/product', 'post']), 'Insert');
  Assert.IsTrue(Exists(['paths', '/product/select', 'post']), 'Select');
  Assert.IsTrue(
    Exists(['paths', '/product/{id}/{versionID}', 'delete']), 'Delete');
  Assert.IsTrue(Exists(['paths', '/ping', 'get']), 'Ping');
end;

procedure TTOpenApiDocumentTests.TheDocumentDoesNotDescribeItself;
begin
  Assert.IsFalse(
    Exists(['paths', '/openapi.json']),
    'The document is generated before its own route exists');
end;

procedure TTOpenApiDocumentTests.AnOverrideReplacesTheSummary;
begin
  Assert.AreEqual(
    'Product by ID',
    TextAt(['paths', '/product/{id}', 'get', 'summary']),
    'The most derived method that declares a summary wins');
end;

procedure TTOpenApiDocumentTests.AnInheritedSummaryIsKept;
begin
  Assert.AreEqual(
    'Select with filter',
    TextAt(['paths', '/product/select', 'post', 'summary']),
    'A method that is not overridden keeps the summary of the base');
  Assert.AreEqual(
    'Found',
    TextAt(['paths', '/product/{id}', 'get', 'responses', '200',
      'description']),
    'The override declares no response, so the base responses stay');
end;

procedure TTOpenApiDocumentTests.TheTagComesFromTheConcreteController;
begin
  Assert.AreEqual(
    'Products',
    TextAt(['paths', '/product', 'get', 'tags', '0']),
    'The operation carries the tag of its controller');
  Assert.AreEqual('Products', TextAt(['tags', '0', 'name']), 'Tag list');
  Assert.AreEqual(
    'Product catalogue',
    TextAt(['tags', '0', 'description']),
    'The description of the controller describes its tag');
end;

procedure TTOpenApiDocumentTests.APathParameterIsAnIdUnlessMarkedNotSqid;
const
  DeletePath = '/product/{id}/{versionID}';
begin
  Assert.AreEqual(
    'id', TextAt(['paths', DeletePath, 'delete', 'parameters', '0', 'name']),
    'First placeholder');
  Assert.AreEqual(
    'path', TextAt(['paths', DeletePath, 'delete', 'parameters', '0', 'in']),
    'A placeholder is a path parameter');
  Assert.AreEqual(
    'versionID',
    TextAt(['paths', DeletePath, 'delete', 'parameters', '1', 'name']),
    'Second placeholder');
  Assert.AreEqual(
    'integer',
    TextAt(['paths', DeletePath, 'delete', 'parameters', '1', 'schema',
      'type']),
    'A [TNotSqid] placeholder is a plain number');
end;

procedure TTOpenApiDocumentTests.AQueryParameterIsAnOptionalString;
const
  SelectAllPath = '/product';
begin
  Assert.AreEqual(
    'search',
    TextAt(['paths', SelectAllPath, 'get', 'parameters', '0', 'name']),
    'Name');
  Assert.AreEqual(
    'query', TextAt(['paths', SelectAllPath, 'get', 'parameters', '0', 'in']),
    'Source');
  Assert.AreEqual(
    'string',
    TextAt(['paths', SelectAllPath, 'get', 'parameters', '0', 'schema',
      'type']),
    'The controller reads every parameter as text');
  Assert.IsFalse(
    Exists(['paths', SelectAllPath, 'get', 'parameters', '0', 'required']),
    'A missing parameter is never refused by the router');
end;

procedure TTOpenApiDocumentTests.TheEntityOfTheControllerIsReferenced;
begin
  Assert.AreEqual(
    '#/components/schemas/TTestOpenApiProduct',
    TextAt(['paths', '/product/{id}', 'get', 'responses', '200', 'content',
      'application/json', 'schema', '$ref']),
    'EntityClass of the controller names the entity');
  Assert.IsTrue(
    Exists(['components', 'schemas', 'TTestOpenApiProduct']),
    'The referenced schema is in the components');
end;

procedure TTOpenApiDocumentTests.AListIsAnArrayOfTheEntity;
begin
  Assert.AreEqual(
    'array',
    TextAt(['paths', '/product', 'get', 'responses', '200', 'content',
      'application/json', 'schema', 'type']),
    'A list is an array');
  Assert.AreEqual(
    '#/components/schemas/TTestOpenApiProduct',
    TextAt(['paths', '/product', 'get', 'responses', '200', 'content',
      'application/json', 'schema', 'items', '$ref']),
    'Of the entity of the controller');
end;

procedure TTOpenApiDocumentTests.APageWrapsCountAndData;
const
  SelectPath = '/product/select';
begin
  Assert.AreEqual(
    'integer',
    TextAt(['paths', SelectPath, 'post', 'responses', '200', 'content',
      'application/json', 'schema', 'properties', 'count', 'type']),
    'The count of the rows');
  Assert.AreEqual(
    '#/components/schemas/TTestOpenApiProduct',
    TextAt(['paths', SelectPath, 'post', 'responses', '200', 'content',
      'application/json', 'schema', 'properties', 'data', 'items', '$ref']),
    'The rows of the page');
end;

procedure TTOpenApiDocumentTests.TheFilterIsAPredefinedSchema;
begin
  Assert.AreEqual(
    '#/components/schemas/TTOpenApiFilter',
    TextAt(['paths', '/product/select', 'post', 'requestBody', 'content',
      'application/json', 'schema', '$ref']),
    'The body of Select is the HTTP filter');
  Assert.AreEqual(
    'array',
    TextAt(['components', 'schemas', 'TTOpenApiFilter', 'properties', 'where',
      'type']),
    'The filter carries its where conditions');
end;

procedure TTOpenApiDocumentTests.TheMetadataIsAPredefinedSchema;
begin
  Assert.AreEqual(
    '#/components/schemas/TTOpenApiMetadata',
    TextAt(['paths', '/product/metadata', 'get', 'responses', '200',
      'content', 'application/json', 'schema', '$ref']),
    'Metadata is described by its own schema');
  Assert.AreEqual(
    'array',
    TextAt(['components', 'schemas', 'TTOpenApiMetadata', 'properties',
      'properties', 'type']),
    'The metadata lists its properties');
end;

procedure TTOpenApiDocumentTests.ImplicitErrorsFollowTheRoute;
const
  GetPath = '/product/{id}';
begin
  Assert.IsTrue(
    Exists(['paths', GetPath, 'get', 'responses', '401']), 'Authenticated');
  Assert.IsTrue(Exists(['paths', GetPath, 'get', 'responses', '403']), 'Area');
  Assert.IsTrue(
    Exists(['paths', GetPath, 'get', 'responses', '404']), 'Placeholder');
  Assert.IsTrue(
    Exists(['paths', GetPath, 'get', 'responses', '500']), 'Always');
  Assert.IsFalse(
    Exists(['paths', GetPath, 'get', 'responses', '400']),
    'No body, no bad request');
end;

procedure TTOpenApiDocumentTests.ABodyAddsItsImplicitErrors;
const
  InsertPath = '/product';
begin
  Assert.IsTrue(
    Exists(['paths', InsertPath, 'post', 'responses', '400']), '400');
  Assert.IsTrue(
    Exists(['paths', InsertPath, 'post', 'responses', '413']), '413');
  Assert.IsTrue(
    Exists(['paths', InsertPath, 'post', 'responses', '422']), '422');
  Assert.IsFalse(
    Exists(['paths', InsertPath, 'post', 'responses', '404']),
    'No placeholder, no not found');
end;

procedure TTOpenApiDocumentTests.AnExplicitResponseIsKept;
begin
  Assert.AreEqual(
    'Version changed',
    TextAt(['paths', '/product/{id}/{versionID}', 'delete', 'responses',
      '409', 'description']),
    '409 is never implicit: it is declared');
  Assert.IsFalse(
    Exists(['paths', '/product/{id}/{versionID}', 'delete', 'responses',
      '200', 'content']),
    'A response declared without a type has no schema');
end;

procedure TTOpenApiDocumentTests.AnErrorReferencesTheErrorSchema;
begin
  Assert.AreEqual(
    '#/components/schemas/TTOpenApiError',
    TextAt(['paths', '/ping', 'get', 'responses', '500', 'content',
      'application/json', 'schema', '$ref']),
    'Every error has the body of ETHttpException');
  Assert.AreEqual(
    'integer',
    TextAt(['components', 'schemas', 'TTOpenApiError', 'properties',
      'status', 'type']),
    'The status of the error');
end;

procedure TTOpenApiDocumentTests.TheSecurityFollowsTheAuthentication;
begin
  Assert.AreEqual(
    'bearer',
    TextAt(['components', 'securitySchemes', 'bearer', 'scheme']),
    'The scheme comes from the registered authentication');
  Assert.IsTrue(
    Exists(['paths', '/product', 'get', 'security', '0', 'bearer']),
    'A protected route requires the scheme');
  Assert.AreEqual<Integer>(
    0,
    (ValueAt(['paths', '/ping', 'get', 'security']) as TJSonArray).Count,
    'An anonymous route says that it requires nothing');
end;

procedure TTOpenApiDocumentTests.WithoutAuthenticationThereIsNoUnauthorized;
begin
  FreeAndNil(FDocument);
  FServer.Free;
  FServer := TTHttpServer<TTestOpenApiContext>.Create;
  FServer.AllowAnonymous := True;
  FServer.RegisterController<TTestOpenApiProductController>('/product');
  FDocument := Generate;

  Assert.IsFalse(
    Exists(['paths', '/product/{id}', 'get', 'responses', '401']),
    'A server that checks no login never answers 401');
  Assert.IsFalse(
    Exists(['paths', '/product/{id}', 'get', 'security']),
    'Without authentication there is no scheme to require');
  Assert.IsFalse(
    Exists(['components', 'securitySchemes']),
    'Without authentication there is no scheme to describe');
end;

procedure
  TTOpenApiDocumentTests.TheEntitySchemaNamesItsColumnsLikeTheSerializer;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.IsTrue(
    Exists(['components', 'schemas', Product, 'properties', 'id']), 'id');
  Assert.IsTrue(
    Exists(['components', 'schemas', Product, 'properties', 'name']), 'name');
  Assert.IsTrue(
    Exists(['components', 'schemas', Product, 'properties', 'createdAt']),
    'createdAt');
end;

procedure TTOpenApiDocumentTests.TheEntitySchemaFollowsTheJSonAttributes;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.IsFalse(
    Exists(['components', 'schemas', Product, 'properties', 'secret']),
    '[TJSonIgnore] never reaches the JSON');
  Assert.AreEqual(
    'true',
    TextAt(['components', 'schemas', Product, 'properties', 'token',
      'writeOnly']),
    '[TJSonIgnoreSerialize] is only read');
  Assert.AreEqual(
    'true',
    TextAt(['components', 'schemas', Product, 'properties', 'createdAt',
      'readOnly']),
    'Change tracking is only written by Trysil');
  Assert.AreEqual(
    'integer',
    TextAt(['components', 'schemas', Product, 'properties', 'version',
      'type']),
    'The version column is part of the contract');
end;

procedure TTOpenApiDocumentTests.TheEntitySchemaFollowsTheTypes;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.AreEqual(
    'number',
    TextAt(['components', 'schemas', Product, 'properties', 'price',
      'type']),
    'Double');
  Assert.AreEqual(
    'integer',
    TextAt(['components', 'schemas', Product, 'properties', 'quantity',
      'type', '0']),
    'The type of a nullable');
  Assert.AreEqual(
    'null',
    TextAt(['components', 'schemas', Product, 'properties', 'quantity',
      'type', '1']),
    'A nullable can be null');
  Assert.AreEqual(
    'date-time',
    TextAt(['components', 'schemas', Product, 'properties', 'createdAt',
      'format']),
    'TDateTime');
end;

procedure TTOpenApiDocumentTests.TheEntitySchemaFollowsTheValidation;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.AreEqual(
    'name',
    TextAt(['components', 'schemas', Product, 'required', '0']),
    '[TRequired]');
  Assert.AreEqual(
    'Product name',
    TextAt(['components', 'schemas', Product, 'properties', 'name',
      'title']),
    '[TDisplayName]');
  Assert.AreEqual(
    'email',
    TextAt(['components', 'schemas', Product, 'properties', 'email',
      'format']),
    '[TEMail]');
end;

procedure TTOpenApiDocumentTests.TheEntitySchemaFollowsTheConstraints;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.AreEqual(
    '2',
    TextAt(['components', 'schemas', Product, 'properties', 'name',
      'minLength']),
    '[TMinLength]');
  Assert.AreEqual(
    '50',
    TextAt(['components', 'schemas', Product, 'properties', 'name',
      'maxLength']),
    '[TMaxLength]');
  Assert.AreEqual(
    '1',
    TextAt(['components', 'schemas', Product, 'properties', 'quantity',
      'minimum']),
    '[TRange] gives the inclusive minimum');
  Assert.AreEqual(
    '100',
    TextAt(['components', 'schemas', Product, 'properties', 'quantity',
      'maximum']),
    '[TRange] gives the inclusive maximum');
  Assert.AreEqual(
    '0.5',
    TextAt(['components', 'schemas', Product, 'properties', 'price',
      'exclusiveMinimum']),
    '[TGreater] is an exclusive minimum');
  Assert.AreEqual(
    '1000',
    TextAt(['components', 'schemas', Product, 'properties', 'price',
      'maximum']),
    '[TMaxValue]');
end;

procedure TTOpenApiDocumentTests.TheEntitySchemaFollowsTheRegex;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.AreEqual(
    '^[A-Z]+$',
    TextAt(['components', 'schemas', Product, 'properties', 'token',
      'pattern']),
    '[TRegex]');
  Assert.IsFalse(
    TextAt(['components', 'schemas', Product, 'properties', 'email',
      'pattern']).IsEmpty,
    '[TEMail] is a regex too, and its pattern goes with the format');
end;

procedure TTOpenApiDocumentTests.ALazyRelationIsAnIdAndAReference;
const
  Product = 'TTestOpenApiProduct';
begin
  Assert.AreEqual(
    'integer',
    TextAt(['components', 'schemas', Product, 'properties', 'categoryID',
      'type']),
    'The id of the relation is always there');
  Assert.AreEqual(
    '#/components/schemas/TTestOpenApiCategory',
    TextAt(['components', 'schemas', Product, 'properties', 'category',
      '$ref']),
    'The related entity, when the level allows it');
  Assert.IsTrue(
    Exists(['components', 'schemas', 'TTestOpenApiCategory']),
    'The related entity has its own schema');
end;

procedure TTOpenApiDocumentTests.SqidsTurnIdsIntoStrings;
var
  LExpected: String;
begin
  TTJSonSqids.Instance.UseSqids := True;
  FreeAndNil(FDocument);
  FDocument := Generate;
  LExpected := 'integer';
  if TTJSonSqids.Instance.UseSqids then
    LExpected := 'string';
  Assert.AreEqual(
    LExpected,
    TextAt(['components', 'schemas', 'TTestOpenApiProduct', 'properties',
      'id', 'type']),
    'The primary key follows Sqids');
  Assert.AreEqual(
    LExpected,
    TextAt(['paths', '/product/{id}', 'get', 'parameters', '0', 'schema',
      'type']),
    'An unmarked placeholder follows Sqids');
  Assert.AreEqual(
    'integer',
    TextAt(['paths', '/product/{id}/{versionID}', 'delete', 'parameters',
      '1', 'schema', 'type']),
    'A [TNotSqid] placeholder stays a number');
end;

{ TTOpenApiRegisterTests }

procedure TTOpenApiRegisterTests.Setup;
begin
  TTOpenApiController<TTestOpenApiContext>.Document := String.Empty;
  FServer := TTHttpServer<TTestOpenApiContext>.Create;
  FServer.RegisterController<TTestOpenApiPingController>('/ping');
end;

procedure TTOpenApiRegisterTests.TearDown;
begin
  FServer.Free;
  TTOpenApiController<TTestOpenApiContext>.Document := String.Empty;
end;

function TTOpenApiRegisterTests.TryRegister: Boolean;
begin
  result := True;
  try
    TTOpenApi<TTestOpenApiContext>.Register(
      FServer, TTOpenApiInfo.Create('Test API', '1.0'));
  except
    on E: ETOpenApiException do
      result := False;
  end;
end;

function TTOpenApiRegisterTests.DocumentRoute: TTHttpRoute;
var
  LRoute: TTHttpRoute;
begin
  result := Default(TTHttpRoute);
  for LRoute in FServer.Routes do
    if LRoute.ControllerID.Uri = '/openapi.json' then
      result := LRoute;
end;

procedure TTOpenApiRegisterTests.RegisterServesTheDocument;
begin
  Assert.IsTrue(TryRegister, 'Register succeeds');
  Assert.IsTrue(
    DocumentRoute.ControllerClass =
      TTOpenApiController<TTestOpenApiContext>,
    'The document has its own route');
  Assert.IsTrue(
    TTOpenApiController<TTestOpenApiContext>.Document.Contains('/ping'),
    'The document describes the routes registered before it');
end;

procedure TTOpenApiRegisterTests.RegisterProtectsTheDocument;
begin
  TryRegister;
  Assert.IsTrue(
    DocumentRoute.AuthorizationType = TTHttpAuthorizationType.Authentication,
    'By default the document requires authentication');
end;

procedure TTOpenApiRegisterTests.RegisterAnonymousPublishesTheDocument;
begin
  TTOpenApi<TTestOpenApiContext>.RegisterAnonymous(
    FServer, TTOpenApiInfo.Create('Test API', '1.0'));
  Assert.IsTrue(
    DocumentRoute.AuthorizationType = TTHttpAuthorizationType.None,
    'RegisterAnonymous makes the document public');
end;

procedure TTOpenApiRegisterTests.RegisterTwiceIsRefused;
begin
  Assert.IsTrue(TryRegister, 'The first registration succeeds');
  Assert.IsFalse(TryRegister, 'The second one is refused');
end;

procedure TTOpenApiRegisterTests.ASecondServerOfTheContextIsRefused;
var
  LServer: TTHttpServer<TTestOpenApiContext>;
  LRefused: Boolean;
begin
  Assert.IsTrue(TryRegister, 'The first server gets the document');
  LServer := TTHttpServer<TTestOpenApiContext>.Create;
  try
    LRefused := False;
    try
      TTOpenApi<TTestOpenApiContext>.Register(
        LServer, TTOpenApiInfo.Create('Admin API', '1.0'));
    except
      on E: ETOpenApiException do
        LRefused := True;
    end;
  finally
    LServer.Free;
  end;

  Assert.IsTrue(
    LRefused,
    'The document lives once per context, so a second server would ' +
    'replace the one of the first and publish its routes');
  Assert.IsFalse(
    TTOpenApiController<TTestOpenApiContext>.Document.Contains('Admin API'),
    'The document of the first server is left untouched');
end;

procedure TTOpenApiRegisterTests.AnEmptyTitleIsRefused;
var
  LRefused: Boolean;
begin
  LRefused := False;
  try
    TTOpenApi<TTestOpenApiContext>.Register(
      FServer, TTOpenApiInfo.Create(String.Empty, '1.0'));
  except
    on E: ETOpenApiException do
      LRefused := True;
  end;
  Assert.IsTrue(LRefused, 'OpenAPI requires a title');
end;

procedure TTOpenApiRegisterTests.AShapeWithoutEntityClassIsRefused;
begin
  FServer.RegisterController<TTestOpenApiOrphanController>('/orphan');
  Assert.IsFalse(
    TryRegister,
    'A shape without a type needs the EntityClass of the controller');
end;

procedure TTOpenApiRegisterTests.APageRequestBodyIsRefused;
begin
  FServer.RegisterController<TTestOpenApiPageBodyController>('/category');
  Assert.IsFalse(TryRegister, 'A request body is never a page');
end;

initialization
  TDUnitX.RegisterTestFixture(TTOpenApiDocumentTests);
  TDUnitX.RegisterTestFixture(TTOpenApiRegisterTests);

end.
