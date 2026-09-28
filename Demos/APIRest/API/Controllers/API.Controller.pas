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
  Trysil.Types,
  Trysil.Http.Classes,
  Trysil.Http.Attributes,
  Trysil.Http.Context,
  Trysil.Http.Controller,
  Trysil.Http.Entity,

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

    [TGet('/?')]
    [TArea('read')]
    procedure Get(const AID: TTPrimaryKey);

    [TGet]
    [TArea('read')]
    procedure SelectAll;

    [TPost('/select')]
    [TArea('read')]
    procedure Select;

    [TGet('/find/?')]
    [TArea('read')]
    procedure Find(const AID: TTPrimaryKey);

    [TGet('/metadata')]
    [TArea('read')]
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
    procedure Insert;

    [TPut]
    [TArea('write')]
    procedure Update;

    [TDelete('/?/?')]
    [TArea('write')]
    procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);

    [TGet('/createnew')]
    [TArea('write')]
    procedure CreateNew;
  end;

implementation

{ TAPIController }

function TAPIController.GetContext: TTHttpContext;
begin
  result := FContext.Context;
end;

{ TAPIReadOnlyController<T> }

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
