(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI.Consts;

interface

uses
  System.SysUtils,
  System.Classes;

resourcestring
  SOpenApiServerStarted =
    'OpenAPI: the document cannot be registered on a started server.';
  SOpenApiAlreadyRegistered =
    'OpenAPI: the document is already registered on this server.';
  SOpenApiContextAlreadyRegistered =
    'OpenAPI: the document of this context is already registered ' +
    'on another server.';
  SOpenApiEmptyTitle = 'OpenAPI: the title of the document is empty.';
  SOpenApiEmptyVersion = 'OpenAPI: the version of the document is empty.';
  SOpenApiNoEntityClass =
    'OpenAPI: %0:s.%1:s describes the entity of its controller, ' +
    'but the controller has no EntityClass.';
  SOpenApiPageRequestBody =
    'OpenAPI: %0:s.%1:s declares a request body with the Page shape.';

const
  SOpenApiVersion = '3.1.0';
  SOpenApiDocumentUri = '/openapi.json';
  SOpenApiMediaType = 'application/json';

  SOpenApiBadRequest = 'Bad request';
  SOpenApiUnauthorized = 'Unauthorized';
  SOpenApiForbidden = 'Forbidden';
  SOpenApiNotFound = 'Not found';
  SOpenApiContentTooLarge = 'Content too large';
  SOpenApiUnprocessableContent = 'Unprocessable content';
  SOpenApiInternalServerError = 'Internal server error';

implementation

end.
