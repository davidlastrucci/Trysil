(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI.Types;

interface

uses
  System.SysUtils,
  System.Classes;

type

{$SCOPEDENUMS ON}

{ TTOpenApiShape }

  TTOpenApiShape = (Single, List, Page);

{ TTOpenApiParameterSource }

  TTOpenApiParameterSource = (Query, Header);

{ TTOpenApiInfo }

  TTOpenApiInfo = record
  strict private
    FTitle: String;
    FVersion: String;
    FDescription: String;
  public
    constructor Create(
      const ATitle: String;
      const AVersion: String); overload;
    constructor Create(
      const ATitle: String;
      const AVersion: String;
      const ADescription: String); overload;

    property Title: String read FTitle;
    property Version: String read FVersion;
    property Description: String read FDescription;
  end;

{ TTOpenApiFilter }

  TTOpenApiFilter = class(TObject);

{ TTOpenApiMetadata }

  TTOpenApiMetadata = class(TObject);

{ TTOpenApiError }

  TTOpenApiError = class(TObject);

implementation

{ TTOpenApiInfo }

constructor TTOpenApiInfo.Create(
  const ATitle: String;
  const AVersion: String);
begin
  Create(ATitle, AVersion, String.Empty);
end;

constructor TTOpenApiInfo.Create(
  const ATitle: String;
  const AVersion: String;
  const ADescription: String);
begin
  FTitle := ATitle;
  FVersion := AVersion;
  FDescription := ADescription;
end;

end.
