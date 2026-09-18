(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Rtti;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,
  Trysil.Consts,
  Trysil.Rtti,
  Trysil.JSon.Sqids,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Classes,
  Trysil.Http.Log.Writer,
  Trysil.Http.Controller,
  Trysil.Http.Authentication;

type

{ TTHttpAbstractRtti }

  TTHttpAbstractRtti = class abstract
  strict protected
    FContext: TRttiContext;
    FType: TRttiType;
    FConstructor: TRttiMethod;
    FInstanceType: TRttiInstanceType;
    function GetConstructorParamTypes: TArray<PTypeInfo>; virtual;
    procedure FindConstructor;
    function CheckConstructorParameters(
      const AConstructor: TRttiMethod): Boolean;
  public
    constructor Create(const ATypeInfo: PTypeInfo);
    destructor Destroy; override;

    function CheckValid: Boolean; virtual;
  end;

{ TTHttpRttiLogWriter }

  TTHttpRttiLogWriter = class(TTHttpAbstractRtti)
  public
    function CreateLogWriter: TTHttpLogAbstractWriter;
  end;

{ TTHttpAbstractRtti<C> }

  TTHttpAbstractRtti<C: class> = class abstract(TTHttpAbstractRtti)
  strict protected
    function GetConstructorParamTypes: TArray<PTypeInfo>; override;
  end;

{ TTHttpRttiAuthentication<C> }

  TTHttpRttiAuthentication<C: class> = class(TTHttpAbstractRtti<C>)
  public
    function CreateAuthentication(
      const AContext: C): TTHttpAbstractAuthentication<C>;
  end;

{ TTHttpRttiMethod }

  TTHttpRttiMethod = class
  strict private
    FMethod: TRttiMethod;
    FBaseUri: String;
    FUriAttribute: TUriAttribute;
    FMethodAttribute: THttpMethodAttribute;
    FControllerID: TTHttpControllerID;
    FAuthorizationType: TTHttpAuthorizationType;
    FAreas: TList<String>;

    function GetName: String;
  private // internal
    property Name: String read GetName;
    property RttiMethod: TRttiMethod read FMethod;
  public
    constructor Create(
      const AMethod: TRttiMethod;
      const ABaseUri: String;
      const AUriAttribute: TUriAttribute;
      const AMethodAttribute: THttpMethodAttribute;
      const AAreas: TList<String>);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure SetAuthorizationType(
      const AAuthType: TAuthorizationTypeAttribute);

    procedure Execute(const AObject: TObject; const AParams: TArray<Integer>);

    property ControllerID: TTHttpControllerID read FControllerID;
    property AuthorizationType: TTHttpAuthorizationType read FAuthorizationType;
    property Areas: TList<String> read FAreas;
  end;

{ TTHttpRttiController<C> }

  TTHttpRttiController<C: class> = class(TTHttpAbstractRtti<C>)
  strict private
    FControllerName: String;
    FBaseUri: String;
    FMethods: TObjectList<TTHttpRttiMethod>;

    function CheckParameters(
      const AMethod: TRttiMethod;
      const AUriAttribute: TUriAttribute;
      const AMethodAttribute: THttpMethodAttribute): Boolean;

    procedure SearchHttpMethodAttribute(
      const AUriAttribute: TUriAttribute;
      const AAuthAttribute: TAuthorizationTypeAttribute;
      const AAreas: TList<String>;
      const AMethod: TRttiMethod);

    procedure SearchMethodsAreasAttributes;
    procedure SearchAreasAttributes(const AMethod: TTHttpRttiMethod);
    function SameSignature(
      const ALeft: TRttiMethod; const ARight: TRttiMethod): Boolean;

    procedure SearchMethods;
  strict protected
    function GetConstructorParamTypes: TArray<PTypeInfo>; override;
  public
    constructor Create(const ATypeInfo: PTypeInfo; const ABaseUri: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;
    function CreateController(
      const AContext: C;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse): TTHttpController<C>;

    property ControllerName: String read FControllerName;
    property Methods: TObjectList<TTHttpRttiMethod> read FMethods;
  end;

{ TTHttpRttiControllerMethod<C> }

  TTHttpRttiControllerMethod<C: class> = class
  strict private
    FController: TTHttpRttiController<C>;
    FMethod: TTHttpRttiMethod;
  public
    constructor Create(
      const AController: TTHttpRttiController<C>;
      const AMethod: TTHttpRttiMethod);

    property Controller: TTHttpRttiController<C> read FController;
    property Method: TTHttpRttiMethod read FMethod;
  end;

{ TTHttpRttiControllerAddedEvent }

  TTHttpRttiControllerAddedEvent = procedure(
    const AControllerID: TTHttpControllerID;
    const AAuthorizationType: TTHttpAuthorizationType) of object;

{ TTHttpRttiControllers<C> }

  TTHttpRttiControllers<C: class> = class
  strict private
    FControllerMethods: TObjectDictionary<String, TDictionary<
      TTHttpMethodType, TTHttpRttiControllerMethod<C>>>;
    FControllerUriParts: TDictionary<String, TTHttpUriParts>;

    function TrySearchParametrizedUri(
      const AUri: String;
      const AMethodType: TTHttpMethodType;
      const AParams: TList<Integer>;
      out ADictionary: TDictionary<
        TTHttpMethodType, TTHttpRttiControllerMethod<C>>): Boolean;
    function TryGetDictionary(
      const AControllerID: TTHttpControllerID;
      const AParams: TList<Integer>;
      out ADictionary: TDictionary<
        TTHttpMethodType, TTHttpRttiControllerMethod<C>>): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(
      const ARttiController: TTHttpRttiController<C>;
      const AAddedEvent: TTHttpRttiControllerAddedEvent);

    function HasAreas: Boolean;
    function FindAnonymousArea(out AUri: String): Boolean;

    function CreateMethodNotAllowed(
      const AControllerID: TTHttpControllerID;
      const ADictionary: TDictionary<
        TTHttpMethodType,
        TTHttpRttiControllerMethod<C>>): ETHttpMethodNotAllowed;

    function Get(
      const AControllerID: TTHttpControllerID;
      const AParams: TList<Integer>):
      TTHttpRttiControllerMethod<C>;
  end;

implementation

{ TTHttpAbstractRtti }

constructor TTHttpAbstractRtti.Create(const ATypeInfo: PTypeInfo);
begin
  inherited Create;
  FContext := TRttiContext.Create;
  FType := FContext.GetType(ATypeInfo);
  FConstructor := nil;
  FInstanceType := nil;
end;

destructor TTHttpAbstractRtti.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

function TTHttpAbstractRtti.CheckValid: Boolean;
begin
  if FType.IsInstance then
  begin
    FInstanceType := FType.AsInstance;
    FindConstructor;
  end;
  result := Assigned(FInstanceType) and Assigned(FConstructor);
end;

procedure TTHttpAbstractRtti.FindConstructor;
var
  LMethod: TRttiMethod;
begin
  FConstructor := nil;
  for LMethod in FType.GetMethods do
    if LMethod.IsConstructor and CheckConstructorParameters(LMethod) then
    begin
      FConstructor := LMethod;
      Break;
    end;
end;

function TTHttpAbstractRtti.GetConstructorParamTypes: TArray<PTypeInfo>;
begin
  result := [];
end;

function TTHttpAbstractRtti.CheckConstructorParameters(
  const AConstructor: TRttiMethod): Boolean;
var
  LParamTypes: TArray<PTypeInfo>;
  LParameters: TArray<TRttiParameter>;
  LIndex: Integer;
begin
  LParamTypes := GetConstructorParamTypes;
  LParameters := AConstructor.GetParameters;
  result := Length(LParameters) = Length(LParamTypes);
  if result then
    for LIndex := Low(LParameters) to High(LParameters) do
    begin
      result := (LParameters[LIndex].ParamType.Handle =
        LParamTypes[LIndex]);
      if not result then
        Break;
    end;
end;

{ TTHttpRttiLogWriter }

function TTHttpRttiLogWriter.CreateLogWriter: TTHttpLogAbstractWriter;
var
  LResult: TValue;
begin
  result := nil;
  LResult := FConstructor.Invoke(FInstanceType.MetaclassType, []);
  if LResult.IsType<TTHttpLogAbstractWriter>() then
    result := LResult.AsType<TTHttpLogAbstractWriter>
  else
    LResult.AsObject.Free;
end;

{ TTHttpAbstractRtti<C> }

function TTHttpAbstractRtti<C>.GetConstructorParamTypes: TArray<PTypeInfo>;
begin
  result := inherited GetConstructorParamTypes + [TypeInfo(C)];
end;

{ TTHttpRttiAuthentication<C> }

function TTHttpRttiAuthentication<C>.CreateAuthentication(
  const AContext: C): TTHttpAbstractAuthentication<C>;
var
  LResult: TValue;
begin
  result := nil;
  LResult := FConstructor.Invoke(
    FInstanceType.MetaclassType, [AContext]);
  if LResult.IsType<TTHttpAbstractAuthentication<C>>() then
    result := LResult.AsType<TTHttpAbstractAuthentication<C>>
  else
    LResult.AsObject.Free;
end;

{ TTHttpRttiMethod }

constructor TTHttpRttiMethod.Create(
  const AMethod: TRttiMethod;
  const ABaseUri: String;
  const AUriAttribute: TUriAttribute;
  const AMethodAttribute: THttpMethodAttribute;
  const AAreas: TList<String>);
begin
  inherited Create;
  FMethod := AMethod;
  FBaseUri := ABaseUri;
  FUriAttribute := AUriAttribute;
  FMethodAttribute := AMethodAttribute;
  FAuthorizationType := TTHttpAuthorizationType.Authentication;
  FAreas := TList<String>.Create(AAreas);
end;

destructor TTHttpRttiMethod.Destroy;
begin
  FAreas.Free;
  inherited Destroy;
end;

procedure TTHttpRttiMethod.AfterConstruction;
var
  LAttributeUri, LUri: String;
begin
  inherited AfterConstruction;
  LAttributeUri := String.Empty;
  if Assigned(FUriAttribute) then
    LAttributeUri := FUriAttribute.Uri;
  LUri := Format('%s%s%s', [FBaseUri, LAttributeUri, FMethodAttribute.Uri]);
  FControllerID := TTHttpControllerID.Create(
    LUri, FMethodAttribute.MethodType);
end;

function TTHttpRttiMethod.GetName: String;
begin
  result := FMethod.Name;
end;

procedure TTHttpRttiMethod.Execute(
  const AObject: TObject; const AParams: TArray<Integer>);
var
  LParams: TArray<TValue>;
  LIndex: Integer;
begin
  SetLength(LParams, Length(AParams));
  for LIndex := Low(AParams) to High(AParams) do
    LParams[LIndex] := TValue.From<Integer>(AParams[LIndex]);
  FMethod.Invoke(AObject, LParams);
end;

procedure TTHttpRttiMethod.SetAuthorizationType(
  const AAuthType: TAuthorizationTypeAttribute);
begin
  FAuthorizationType := AAuthType.AuthorizationType;
end;

{ TTHttpRttiController<C> }

constructor TTHttpRttiController<C>.Create(
  const ATypeInfo: PTypeInfo; const ABaseUri: String);
begin
  inherited Create(ATypeInfo);
  FControllerName := String(ATypeInfo^.Name);
  FBaseUri := ABaseUri;
  FMethods := TObjectList<TTHttpRttiMethod>.Create(True);
end;

destructor TTHttpRttiController<C>.Destroy;
begin
  FMethods.Free;
  inherited Destroy;
end;

procedure TTHttpRttiController<C>.AfterConstruction;
begin
  inherited AfterConstruction;
  SearchMethods;
  SearchMethodsAreasAttributes;
end;

function TTHttpRttiController<C>.CheckParameters(
  const AMethod: TRttiMethod;
  const AUriAttribute: TUriAttribute;
  const AMethodAttribute: THttpMethodAttribute): Boolean;
var
  LAttributeUri, LUri: String;
  LUriParts: TTHttpUriParts;
  LParameters: TArray<TRttiParameter>;
  LParameter: TRttiParameter;
begin
  LAttributeUri := String.Empty;
  if Assigned(AUriAttribute) then
    LAttributeUri := AUriAttribute.Uri;

  LUri := Format('%s%s%s', [FBaseUri, LAttributeUri, AMethodAttribute.Uri]);
  LUriParts := TTHttpUriParts.Create(LUri);
  LParameters := AMethod.GetParameters;
  result := Length(LParameters) = LUriParts.ParamsCount;
  if result then
    for LParameter in LParameters do
    begin
      result := (LParameter.ParamType.TypeKind = TTypeKind.tkInteger);
      if not result then
        Break;
    end;
end;

procedure TTHttpRttiController<C>.SearchHttpMethodAttribute(
  const AUriAttribute: TUriAttribute;
  const AAuthAttribute: TAuthorizationTypeAttribute;
  const AAreas: TList<String>;
  const AMethod: TRttiMethod);
var
  LMethodAttribute: THttpMethodAttribute;
  LAuthAttribute: TAuthorizationTypeAttribute;
  LRttiMethod: TTHttpRttiMethod;
begin
  LMethodAttribute := AMethod.GetAttribute<THttpMethodAttribute>();
  if Assigned(LMethodAttribute) then
    if CheckParameters(AMethod, AUriAttribute, LMethodAttribute) then
    begin
      LAuthAttribute := AMethod.GetAttribute<TAuthorizationTypeAttribute>();
      if not Assigned(LAuthAttribute) then
        LAuthAttribute := AAuthAttribute;

      LRttiMethod := TTHttpRttiMethod.Create(
        AMethod, FBaseUri, AUriAttribute, LMethodAttribute, AAreas);
      try
        begin
          if Assigned(LAuthAttribute) then
            LRttiMethod.SetAuthorizationType(LAuthAttribute);
          FMethods.Add(LRttiMethod);
        end;
      except
        LRttiMethod.Free;
        raise;
      end;
    end;
end;

procedure TTHttpRttiController<C>.SearchMethods;
var
  LUriAttribute: TUriAttribute;
  LAreas: TList<String>;
  LAuthAttribute: TAuthorizationTypeAttribute;
  LAttribute: TCustomAttribute;
  LMethod: TRttiMethod;
begin
  LUriAttribute := FType.GetInheritedAttribute<TUriAttribute>();
  LAuthAttribute := FType.GetInheritedAttribute<
    TAuthorizationTypeAttribute>();
  LAreas := TList<String>.Create;
  try
    for LAttribute in FType.GetInheritedAttributes do
      if LAttribute is TAreaAttribute then
        LAreas.Add(TAreaAttribute(LAttribute).Area.ToLowerInvariant);

    for LMethod in FType.GetMethods do
      if not LMethod.IsClassMethod then
        SearchHttpMethodAttribute(
          LUriAttribute, LAuthAttribute, LAreas, LMethod);
  finally
    LAreas.Free;
  end;
end;

procedure TTHttpRttiController<C>.SearchMethodsAreasAttributes;
var
  LMethod: TTHttpRttiMethod;
begin
  for LMethod in FMethods do
    SearchAreasAttributes(LMethod);
end;

function TTHttpRttiController<C>.SameSignature(
  const ALeft: TRttiMethod; const ARight: TRttiMethod): Boolean;
var
  LLeft: TArray<TRttiParameter>;
  LRight: TArray<TRttiParameter>;
  LIndex: Integer;
begin
  LLeft := ALeft.GetParameters;
  LRight := ARight.GetParameters;
  result := Length(LLeft) = Length(LRight);
  if result then
    for LIndex := Low(LLeft) to High(LLeft) do
    begin
      result := LLeft[LIndex].ParamType = LRight[LIndex].ParamType;
      if not result then
        Break;
    end;
end;

procedure TTHttpRttiController<C>.SearchAreasAttributes(
  const AMethod: TTHttpRttiMethod);
var
  LMethod: TRttiMethod;
  LAttribute: TCustomAttribute;
begin
  for LMethod in FType.GetMethods(AMethod.Name) do
    if SameSignature(LMethod, AMethod.RttiMethod) then
      for LAttribute in LMethod.GetAttributes do
        if LAttribute is TAreaAttribute then
          AMethod.Areas.Add(TAreaAttribute(LAttribute).Area.ToLowerInvariant);
end;

function TTHttpRttiController<C>.GetConstructorParamTypes: TArray<PTypeInfo>;
begin
  result := inherited GetConstructorParamTypes + [
    TypeInfo(TTHttpRequest), TypeInfo(TTHttpResponse)];
end;

function TTHttpRttiController<C>.CreateController(
  const AContext: C;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse): TTHttpController<C>;
var
  LResult: TValue;
begin
  result := nil;
  LResult := FConstructor.Invoke(
    FInstanceType.MetaclassType, [AContext, ARequest, AResponse]);
  if LResult.IsType<TTHttpController<C>>() then
    result := LResult.AsType<TTHttpController<C>>
  else
    LResult.AsObject.Free;
end;

{ TTHttpRttiControllerMethod<C> }

constructor TTHttpRttiControllerMethod<C>.Create(
  const AController: TTHttpRttiController<C>;
  const AMethod: TTHttpRttiMethod);
begin
  inherited Create;
  FController := AController;
  FMethod := AMethod;
end;

{ TTHttpRttiControllers<C> }

constructor TTHttpRttiControllers<C>.Create;
begin
  inherited Create;
  FControllerMethods := TObjectDictionary<String, TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>>.Create([doOwnsValues]);
  FControllerUriParts := TDictionary<String, TTHttpUriParts>.Create;
end;

destructor TTHttpRttiControllers<C>.Destroy;
begin
  FControllerUriParts.Free;
  FControllerMethods.Free;
  inherited Destroy;
end;

procedure TTHttpRttiControllers<C>.Add(
  const ARttiController: TTHttpRttiController<C>;
  const AAddedEvent: TTHttpRttiControllerAddedEvent);
var
  LMethod: TTHttpRttiMethod;
  LUriParts: TTHttpUriParts;
  LDictionary: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>;
begin
  for LMethod in ARttiController.Methods do
  begin
    LUriParts := TTHttpUriParts.Create(LMethod.ControllerID.Uri);
    if not LUriParts.HasParamsOnlyAtTheEnd then
      raise ETHttpServerException.CreateFmt(
        TTLanguage.Instance.Translate(SNotValidParametrizedUri), [
          LMethod.ControllerID.Uri]);

    if not FControllerMethods.TryGetValue(
      LMethod.ControllerID.Uri, LDictionary) then
    begin
      LDictionary := TObjectDictionary<TTHttpMethodType,
        TTHttpRttiControllerMethod<C>>.Create([doOwnsValues]);
      try
        FControllerMethods.Add(LMethod.ControllerID.Uri, LDictionary);
      except
        LDictionary.Free;
        raise;
      end;
      FControllerUriParts.Add(LMethod.ControllerID.Uri, LUriParts);
    end;

    if LDictionary.ContainsKey(LMethod.ControllerID.MethodType) then
      raise ETHttpServerException.CreateFmt(
        TTLanguage.Instance.Translate(SDuplicateController), [
          ARttiController.ControllerName]);

    LDictionary.Add(
      LMethod.ControllerID.MethodType,
      TTHttpRttiControllerMethod<C>.Create(ARttiController, LMethod));

    if Assigned(AAddedEvent) then
      AAddedEvent(LMethod.ControllerID, LMethod.AuthorizationType);
  end;
end;

function TTHttpRttiControllers<C>.HasAreas: Boolean;
var
  LDictionary: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>;
  LControllerMethod: TTHttpRttiControllerMethod<C>;
begin
  result := False;
  for LDictionary in FControllerMethods.Values do
    for LControllerMethod in LDictionary.Values do
      if LControllerMethod.Method.Areas.Count > 0 then
      begin
        result := True;
        Break;
      end;
end;

function TTHttpRttiControllers<C>.FindAnonymousArea(
  out AUri: String): Boolean;
var
  LDictionary: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>;
  LControllerMethod: TTHttpRttiControllerMethod<C>;
begin
  result := False;
  AUri := String.Empty;
  for LDictionary in FControllerMethods.Values do
    for LControllerMethod in LDictionary.Values do
      if (not result) and (LControllerMethod.Method.Areas.Count > 0) and
        (LControllerMethod.Method.AuthorizationType =
          TTHttpAuthorizationType.None) then
      begin
        AUri := LControllerMethod.Method.ControllerID.Uri;
        result := True;
      end;
end;

function TTHttpRttiControllers<C>.TrySearchParametrizedUri(
  const AUri: String;
  const AMethodType: TTHttpMethodType;
  const AParams: TList<Integer>;
  out ADictionary: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>): Boolean;
var
  LRequestUri: TTHttpUriParts;
  LControllerUri: TPair<String, TTHttpUriParts>;
  LCandidate: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>;
  LAllowed: Boolean;
begin
  result := False;
  LAllowed := False;
  LRequestUri := TTHttpUriParts.Create(AUri);
  for LControllerUri in FControllerUriParts do
    if (not LAllowed) and LRequestUri.Equals(LControllerUri.Value, AParams) then
    begin
      LCandidate := FControllerMethods.Items[LControllerUri.Key];
      LAllowed := LCandidate.ContainsKey(AMethodType);
      if LAllowed or (not result) then
        ADictionary := LCandidate;
      result := True;
    end;
end;

function TTHttpRttiControllers<C>.TryGetDictionary(
  const AControllerID: TTHttpControllerID;
  const AParams: TList<Integer>;
  out ADictionary: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>): Boolean;
var
  LParametrized: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>;
begin
  result := False;
  ADictionary := nil;
  if FControllerMethods.TryGetValue(AControllerID.Uri, ADictionary) then
    result := ADictionary.ContainsKey(AControllerID.MethodType);

  if not result then
    if TrySearchParametrizedUri(
      AControllerID.Uri,
      AControllerID.MethodType,
      AParams,
      LParametrized) then
    begin
      result := LParametrized.ContainsKey(AControllerID.MethodType);
      if result or (not Assigned(ADictionary)) then
        ADictionary := LParametrized;
    end;

  if (not result) and (not Assigned(ADictionary)) then
    if FControllerMethods.TryGetValue('*', ADictionary) then
      result := ADictionary.ContainsKey(AControllerID.MethodType);
end;

function TTHttpRttiControllers<C>.Get(
  const AControllerID: TTHttpControllerID;
  const AParams: TList<Integer>): TTHttpRttiControllerMethod<C>;
var
  LDictionary: TDictionary<
    TTHttpMethodType, TTHttpRttiControllerMethod<C>>;
begin
  result := nil;
  if not TryGetDictionary(AControllerID, AParams, LDictionary) then
  begin
    if not Assigned(LDictionary) then
      raise ETHttpNotFound.CreateFmt(
        TTLanguage.Instance.Translate(SNotFound), [AControllerID.Uri]);

    raise CreateMethodNotAllowed(AControllerID, LDictionary);
  end;

  LDictionary.TryGetValue(AControllerID.MethodType, result);
end;

function TTHttpRttiControllers<C>.CreateMethodNotAllowed(
  const AControllerID: TTHttpControllerID;
  const ADictionary: TDictionary<
    TTHttpMethodType,
    TTHttpRttiControllerMethod<C>>): ETHttpMethodNotAllowed;
var
  LMethodType: TTHttpMethodType;
  LAllowed: String;
begin
  LAllowed := String.Empty;
  for LMethodType in ADictionary.Keys do
  begin
    if not LAllowed.IsEmpty then
      LAllowed := LAllowed + ', ';
    LAllowed := LAllowed +
      TRttiEnumerationType.GetName<TTHttpMethodType>(LMethodType);
  end;

  result := ETHttpMethodNotAllowed.CreateFmt(
    TTLanguage.Instance.Translate(SMethodNotAllowed), [
      AControllerID.Method, AControllerID.Uri]);
  result.AllowedMethods := LAllowed;
end;

end.
