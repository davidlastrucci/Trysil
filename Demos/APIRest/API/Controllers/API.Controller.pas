(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Controller;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  Trysil.Types,
  Trysil.Http.Classes,
  Trysil.Http.Attributes,
  Trysil.Http.Context,
  Trysil.Http.Controller,
  Trysil.Http.Entity,
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Attributes,

  API.Context;

type

{ TAPIController }

  TAPIController = class(TTHttpController<TAPIContext>)
  strict private
    function GetContext: TTHttpContext;
  strict protected
    property Context: TTHttpContext read GetContext;
  end;

{ TAPIReadOnlyController<T> }

  TAPIReadOnlyController<T: class> = class(TAPIController)
  strict private
    FReader: TTHttpEntityReader<T>;
  public
    constructor Create(
      const AContext: TAPIContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    class function EntityClass: TClass; override;

    [TGet('/?')]
    [TArea('read')]
    [TSummary('Read by ID')]
    [TResponse(200, TTOpenApiShape.Single, 'The entity, with its details')]
    procedure Get(const AID: TTPrimaryKey);

    [TGet]
    [TArea('read')]
    [TSummary('Read all')]
    [TResponse(200, TTOpenApiShape.Page, 'Count and rows')]
    procedure SelectAll;

    [TPost('/select')]
    [TArea('read')]
    [TSummary('Read with a filter')]
    [TRequestBody(TTOpenApiFilter, TTOpenApiShape.Single, 'Filter')]
    [TResponse(200, TTOpenApiShape.Page, 'Count and rows')]
    procedure Select;

    [TGet('/find/?')]
    [TArea('read')]
    [TSummary('Read by ID, without details')]
    [TResponse(200, TTOpenApiShape.Single, 'The entity')]
    procedure Find(const AID: TTPrimaryKey);

    [TGet('/metadata')]
    [TArea('read')]
    [TSummary('Metadata')]
    [TResponse(
      200, TTOpenApiMetadata, TTOpenApiShape.Single, 'Columns and keys')]
    procedure Metadata;
  end;

{ TAPIReadWriteController<T> }

  TAPIReadWriteController<T: class> = class(TAPIReadOnlyController<T>)
  strict private
    FWriter: TTHttpEntityWriter<T>;
  public
    constructor Create(
      const AContext: TAPIContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    [TPost]
    [TArea('write')]
    [TSummary('Insert')]
    [TRequestBody(TTOpenApiShape.Single, 'The entity to insert')]
    [TResponse(200, TTOpenApiShape.Single, 'The inserted entity')]
    procedure Insert;

    [TPut]
    [TArea('write')]
    [TSummary('Update')]
    [TRequestBody(TTOpenApiShape.Single, 'The entity to update')]
    [TResponse(200, TTOpenApiShape.Single, 'The updated entity')]
    [TResponse(404, 'The entity does not exist')]
    [TResponse(409, 'The version changed in the meantime')]
    procedure Update;

    [TDelete('/?/?')]
    [TArea('write')]
    [TSummary('Delete')]
    [TResponse(200, 'Deleted')]
    [TResponse(409, 'The version changed in the meantime')]
    procedure Delete(
      const AID: TTPrimaryKey;
      [TNotSqid] const AVersionID: TTVersion);

    [TGet('/createnew')]
    [TArea('write')]
    [TSummary('A new entity with its defaults')]
    [TResponse(200, TTOpenApiShape.Single, 'The new entity')]
    procedure CreateNew;
  end;

implementation

{ TAPIController }

function TAPIController.GetContext: TTHttpContext;
begin
  result := FContext.Context;
end;

{ TAPIReadOnlyController<T> }

class function TAPIReadOnlyController<T>.EntityClass: TClass;
begin
  result := GetTypeData(TypeInfo(T))^.ClassType;
end;

constructor TAPIReadOnlyController<T>.Create(
  const AContext: TAPIContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
  FReader := TTHttpEntityReader<T>.Create(Context);
end;

destructor TAPIReadOnlyController<T>.Destroy;
begin
  FReader.Free;
  inherited Destroy;
end;

procedure TAPIReadOnlyController<T>.Get(const AID: TTPrimaryKey);
begin
  FResponse.Content := FReader.Get(AID);
end;

procedure TAPIReadOnlyController<T>.SelectAll;
begin
  FResponse.Content := FReader.SelectAll;
end;

procedure TAPIReadOnlyController<T>.Select;
begin
  FResponse.Content := FReader.Select(FRequest.JSonContent);
end;

procedure TAPIReadOnlyController<T>.Find(const AID: TTPrimaryKey);
begin
  FResponse.Content := FReader.Find(AID);
end;

procedure TAPIReadOnlyController<T>.Metadata;
begin
  FResponse.Content := FReader.Metadata;
end;

{ TAPIReadWriteController<T> }

constructor TAPIReadWriteController<T>.Create(
  const AContext: TAPIContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
  FWriter := TTHttpEntityWriter<T>.Create(Context);
end;

destructor TAPIReadWriteController<T>.Destroy;
begin
  FWriter.Free;
  inherited Destroy;
end;

procedure TAPIReadWriteController<T>.Insert;
begin
  FResponse.Content := FWriter.Insert(FRequest.JSonContent);
end;

procedure TAPIReadWriteController<T>.Update;
begin
  FResponse.Content := FWriter.Update(FRequest.JSonContent);
end;

procedure TAPIReadWriteController<T>.Delete(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
begin
  FWriter.Delete(AID, AVersionID);
end;

procedure TAPIReadWriteController<T>.CreateNew;
begin
  FResponse.Content := FWriter.CreateNew;
end;

end.
