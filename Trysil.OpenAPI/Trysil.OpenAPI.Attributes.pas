(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI.Attributes;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.OpenAPI.Types;

type

{ TTagAttribute }

  TTagAttribute = class(TCustomAttribute)
  strict private
    FName: String;
  public
    constructor Create(const AName: String);

    property Name: String read FName;
  end;

{ TDescriptionAttribute }

  TDescriptionAttribute = class(TCustomAttribute)
  strict private
    FText: String;
  public
    constructor Create(const AText: String);

    property Text: String read FText;
  end;

{ TSummaryAttribute }

  TSummaryAttribute = class(TCustomAttribute)
  strict private
    FText: String;
  public
    constructor Create(const AText: String);

    property Text: String read FText;
  end;

{ TParameterAttribute }

  TParameterAttribute = class(TCustomAttribute)
  strict private
    FName: String;
    FSource: TTOpenApiParameterSource;
    FDescription: String;
  public
    constructor Create(
      const AName: String;
      const ASource: TTOpenApiParameterSource;
      const ADescription: String);

    property Name: String read FName;
    property Source: TTOpenApiParameterSource read FSource;
    property Description: String read FDescription;
  end;

{ TOpenApiBodyAttribute }

  TOpenApiBodyAttribute = class abstract(TCustomAttribute)
  strict private
    FEntityClass: TClass;
    FShape: TTOpenApiShape;
    FDescription: String;
  strict protected
    constructor CreateBody(
      const AEntityClass: TClass;
      const AShape: TTOpenApiShape;
      const ADescription: String);
  public
    property EntityClass: TClass read FEntityClass;
    property Shape: TTOpenApiShape read FShape;
    property Description: String read FDescription;
  end;

{ TRequestBodyAttribute }

  TRequestBodyAttribute = class(TOpenApiBodyAttribute)
  public
    constructor Create(
      const AShape: TTOpenApiShape;
      const ADescription: String); overload;
    constructor Create(
      const AEntityClass: TClass;
      const AShape: TTOpenApiShape;
      const ADescription: String); overload;
  end;

{ TResponseAttribute }

  TResponseAttribute = class(TOpenApiBodyAttribute)
  strict private
    FStatusCode: Integer;
    FHasSchema: Boolean;
  public
    constructor Create(
      const AStatusCode: Integer;
      const ADescription: String); overload;
    constructor Create(
      const AStatusCode: Integer;
      const AShape: TTOpenApiShape;
      const ADescription: String); overload;
    constructor Create(
      const AStatusCode: Integer;
      const AEntityClass: TClass;
      const AShape: TTOpenApiShape;
      const ADescription: String); overload;

    property StatusCode: Integer read FStatusCode;
    property HasSchema: Boolean read FHasSchema;
  end;

implementation

{ TTagAttribute }

constructor TTagAttribute.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
end;

{ TDescriptionAttribute }

constructor TDescriptionAttribute.Create(const AText: String);
begin
  inherited Create;
  FText := AText;
end;

{ TSummaryAttribute }

constructor TSummaryAttribute.Create(const AText: String);
begin
  inherited Create;
  FText := AText;
end;

{ TParameterAttribute }

constructor TParameterAttribute.Create(
  const AName: String;
  const ASource: TTOpenApiParameterSource;
  const ADescription: String);
begin
  inherited Create;
  FName := AName;
  FSource := ASource;
  FDescription := ADescription;
end;

{ TOpenApiBodyAttribute }

constructor TOpenApiBodyAttribute.CreateBody(
  const AEntityClass: TClass;
  const AShape: TTOpenApiShape;
  const ADescription: String);
begin
  inherited Create;
  FEntityClass := AEntityClass;
  FShape := AShape;
  FDescription := ADescription;
end;

{ TRequestBodyAttribute }

constructor TRequestBodyAttribute.Create(
  const AShape: TTOpenApiShape;
  const ADescription: String);
begin
  Create(nil, AShape, ADescription);
end;

constructor TRequestBodyAttribute.Create(
  const AEntityClass: TClass;
  const AShape: TTOpenApiShape;
  const ADescription: String);
begin
  inherited CreateBody(AEntityClass, AShape, ADescription);
end;

{ TResponseAttribute }

constructor TResponseAttribute.Create(
  const AStatusCode: Integer;
  const ADescription: String);
begin
  Create(AStatusCode, nil, TTOpenApiShape.Single, ADescription);
  FHasSchema := False;
end;

constructor TResponseAttribute.Create(
  const AStatusCode: Integer;
  const AShape: TTOpenApiShape;
  const ADescription: String);
begin
  Create(AStatusCode, nil, AShape, ADescription);
end;

constructor TResponseAttribute.Create(
  const AStatusCode: Integer;
  const AEntityClass: TClass;
  const AShape: TTOpenApiShape;
  const ADescription: String);
begin
  inherited CreateBody(AEntityClass, AShape, ADescription);
  FStatusCode := AStatusCode;
  FHasSchema := True;
end;

end.
