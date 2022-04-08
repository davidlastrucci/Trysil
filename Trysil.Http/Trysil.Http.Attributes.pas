(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.Attributes;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Http.Types;

type

{ TUriAttribute }

  TUriAttribute = class(TCustomAttribute)
  strict private
    FUri: String;
  public
    constructor Create(const AUri: String);
    property Uri: String read FUri;
  end;

{ THttpMethodAttribute }

  THttpMethodAttribute = class(TCustomAttribute)
  strict private
    FMethodType: TTHttpMethodType;
    FUri: String;
  public
    constructor Create(
      const AMethodType: TTHttpMethodType; const AUri: String); virtual;

    property MethodType: TTHttpMethodType read FMethodType;
    property Uri: String read FUri;
  end;

{ TGetAttribute }

  TGetAttribute = class(THttpMethodAttribute)
  public
    constructor Create; reintroduce; overload;
    constructor Create(const AUri: String); reintroduce; overload;
  end;

{ TPostAttribute }

  TPostAttribute = class(THttpMethodAttribute)
  public
    constructor Create; reintroduce; overload;
    constructor Create(const AUri: String); reintroduce; overload;
  end;

{ TPutAttribute }

  TPutAttribute = class(THttpMethodAttribute)
  public
    constructor Create; reintroduce; overload;
    constructor Create(const AUri: String); reintroduce; overload;
  end;

{ TDeleteAttribute }

  TDeleteAttribute = class(THttpMethodAttribute)
  public
    constructor Create; reintroduce; overload;
    constructor Create(const AUri: String); reintroduce; overload;
  end;

{ TAuthorizationTypeAttribute }

  TAuthorizationTypeAttribute = class(TCustomAttribute)
  strict private
    FAuthorizationType: TTHttpAuthorizationType;
  public
    constructor Create(const AAuthorizationType: TTHttpAuthorizationType);

    property AuthorizationType: TTHttpAuthorizationType read FAuthorizationType;
  end;

{ TAreaAttribute }

  TAreaAttribute = class(TCustomAttribute)
  strict private
    FArea: String;
  public
    constructor Create(const AArea: String);

    property Area: String read FArea;
  end;

implementation

{ TUriAttribute }

constructor TUriAttribute.Create(const AUri: String);
begin
  inherited Create;
  FUri := AUri;
end;

{ THttpMethodAttribute }

constructor THttpMethodAttribute.Create(
  const AMethodType: TTHttpMethodType; const AUri: String);
begin
  inherited Create;
  FMethodType := AMethodType;
  FUri := AUri;
end;

{ TGetAttribute }

constructor TGetAttribute.Create;
begin
  Create(String.Empty);
end;

constructor TGetAttribute.Create(const AUri: String);
begin
  inherited Create(TTHttpMethodType.GET, AUri);
end;

{ TPostAttribute }

constructor TPostAttribute.Create;
begin
  Create(String.Empty);
end;

constructor TPostAttribute.Create(const AUri: String);
begin
  inherited Create(TTHttpMethodType.POST, AUri);
end;

{ TPutAttribute }

constructor TPutAttribute.Create;
begin
  Create(String.Empty);
end;

constructor TPutAttribute.Create(const AUri: String);
begin
  inherited Create(TTHttpMethodType.PUT, AUri);
end;

{ TDeleteAttribute }

constructor TDeleteAttribute.Create;
begin
  Create(String.Empty);
end;

constructor TDeleteAttribute.Create(const AUri: String);
begin
  inherited Create(TTHttpMethodType.DELETE, AUri);
end;

{ TAuthorizationTypeAttribute }

constructor TAuthorizationTypeAttribute.Create(
  const AAuthorizationType: TTHttpAuthorizationType);
begin
  inherited Create;
  FAuthorizationType := AAuthorizationType;
end;

{ TAreaAttribute }

constructor TAreaAttribute.Create(const AArea: String);
begin
  inherited Create;
  FArea := AArea;
end;

end.
