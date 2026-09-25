(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TypInfo,
  IdContext,
  IdStack,
  IdCustomHttpServer,
  IdHeaderList,
  IdGlobal,
  IdHttpServer,
  IdSocketHandle,
  Trysil.Consts,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Cors,
  Trysil.Http.Controller,
  Trysil.Http.Rtti,
  Trysil.Http.Listener,
  Trysil.Http.Authentication,
  Trysil.Http.Log.Consts,
  Trysil.Http.Log.Types,
  Trysil.Http.Log,
  Trysil.Http.Log.Writer;

type

{ TTHttpServer<C> }

  TTHttpServer<C: class, constructor> = class
  strict private
    const DefaultPort: Word = 8022;
    const DefaultMaxRequestContentLength: Int64 = 1048576;
  strict private
    FRttiLogWriter: TTHttpRttiLogWriter;
    FRttiAuthentication: TTHttpRttiAuthentication<C>;
    FRttiControllers: TTHttpRttiControllers<C>;
    FCors: TTHttpCors;
    FListener: TTHttpListener<C>;
    FLog: TTHttpLog;
    FBaseUri: String;
    FHttpServer: TIdHttpServer;
    FPort: Word;
    FBindAddresses: TList<TTHttpBindAddress>;
    FHasProtectedControllers: Boolean;
    FAllowAnonymous: Boolean;
    FMaxRequestContentLength: Int64;

    FControllers: TObjectList<TTHttpRttiController<C>>;

    procedure Log(const AText: String);
    procedure CheckNotStarted;
    procedure CheckAuthenticationIsRegistered;
    procedure CheckAreasNeedAuthentication;
    procedure CheckLogWriterCanBeCreated(const ATypeInfo: PTypeInfo);
    function ContainsBindAddress(const AAddress: TTHttpBindAddress): Boolean;
    procedure AddBinding(const AAddress: TTHttpBindAddress);
    procedure CreateBindings;

    function GetStarted: Boolean;
    procedure SetBaseUri(const AValue: String);
    procedure SetPort(const AValue: Word);
    function GetCorsConfig: TTHttpCorsConfig;
    function GetOnCanLog: TFunc<TTHttpRequest, Boolean>;
    procedure SetOnCanLog(const AValue: TFunc<TTHttpRequest, Boolean>);
    function GetOnRedactContent: TFunc<TTHttpRequest, String, String>;
    procedure SetOnRedactContent(
      const AValue: TFunc<TTHttpRequest, String, String>);
    procedure SetAllowAnonymous(const AValue: Boolean);
    function GetAllowMethodOverride: Boolean;
    procedure SetAllowMethodOverride(const AValue: Boolean);
    procedure SetMaxRequestContentLength(const AValue: Int64);

    procedure OnAfterRttiControllerAddedEvent(
      const AControllerID: TTHttpControllerID;
      const AAuthType: TTHttpAuthorizationType);

    procedure SetContentStream(
      const AResponse: TTHttpResponse; const AResponseInfo: TIdHttpResponseInfo);
    procedure InternalHandleCommand(
      const ATaskID: TTHttpTaskID;
      const ARequestInfo: TIdHttpRequestInfo;
      const AResponseInfo: TIdHttpResponseInfo);
    procedure ReleaseContentStream(
      const AResponseInfo: TIdHttpResponseInfo);
    procedure LogFallback(
      const ATaskID: TTHttpTaskID; const AException: Exception);
    procedure MakeFallbackResponse(
      const ATaskID: TTHttpTaskID;
      const AResponseInfo: TIdHttpResponseInfo;
      const AException: Exception);
    procedure OnHttpServerCommand(
      AContext: TIdContext;
      ARequestInfo: TIdHttpRequestInfo;
      AResponseInfo: TIdHttpResponseInfo);
    procedure OnHttpServerHeadersAvailable(
      AContext: TIdContext;
      const AUri: String;
      AHeaders: TIdHeaderList;
      var VContinueProcessing: Boolean);
    procedure OnHttpServerHeadersBlocked(
      AContext: TIdContext;
      AHeaders: TIdHeaderList;
      var VResponseNo: Integer;
      var VResponseText: String;
      var VContentText: String);
    procedure OnHttpServerCreatePostStream(
      AContext: TIdContext;
      AHeaders: TIdHeaderList;
      var VPostStream: TStream);
    procedure OnHttpServerParseAuthentication(
      AContext: TIdContext;
      const AAuthType, AAuthContext: string;
      var AUsername, APassword: string;
      var AHandled: Boolean);

    procedure InternalRegisterController(
      const ATypeInfo: PTypeInfo; const AUri: String);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RegisterLogWriter<W: TTHttpLogAbstractWriter>(); overload;
    procedure RegisterLogWriter<W: TTHttpLogAbstractWriter>(
      const ALogThreadPoolSize: Integer); overload;
    procedure RegisterLogWriter<W: TTHttpLogAbstractWriter>(
      const AParameters: TTHttpLogParameters); overload;
    procedure RegisterAuthentication<H: TTHttpAbstractAuthentication<C>>();
    procedure RegisterController<R: TTHttpController<C>>(); overload;
    procedure RegisterController<R: TTHttpController<C>>(
      const AUri: String); overload;

    procedure AddBindAddress(const AAddress: String);

    procedure Start;
    procedure Stop;

    property Started: Boolean read GetStarted;
    property BaseUri: String read FBaseUri write SetBaseUri;
    property Port: Word read FPort write SetPort;
    property CorsConfig: TTHttpCorsConfig read GetCorsConfig;
    property OnCanLog: TFunc<TTHttpRequest, Boolean>
      read GetOnCanLog write SetOnCanLog;
    property OnRedactContent: TFunc<TTHttpRequest, String, String>
      read GetOnRedactContent write SetOnRedactContent;
    property AllowAnonymous: Boolean
      read FAllowAnonymous write SetAllowAnonymous;
    property AllowMethodOverride: Boolean
      read GetAllowMethodOverride write SetAllowMethodOverride;
    property MaxRequestContentLength: Int64
      read FMaxRequestContentLength write SetMaxRequestContentLength;
  end;

implementation

{ TTHttpServer<C> }

constructor TTHttpServer<C>.Create;
begin
  inherited Create;
  FRttiLogWriter := nil;
  FRttiAuthentication := nil;
  FRttiControllers := TTHttpRttiControllers<C>.Create;
  FCors := TTHttpCors.Create;
  FLog := TTHttpLog.Create;
  FListener := TTHttpListener<C>.Create(FCors, FRttiControllers, FLog);
  FHttpServer := TIdHttpServer.Create(nil);
  FBindAddresses := TList<TTHttpBindAddress>.Create;
  FHasProtectedControllers := False;
  FAllowAnonymous := False;

  FControllers := TObjectList<TTHttpRttiController<C>>.Create(True);
end;

destructor TTHttpServer<C>.Destroy;
begin
  if Assigned(FHttpServer) then
  begin
    if FHttpServer.Active then
      try
        Stop;
      except
        on E: Exception do
          Log(E.Message);
      end;

    FHttpServer.Free;
  end;

  FListener.Free;
  FLog.Free;
  FCors.Free;
  FRttiControllers.Free;
  FControllers.Free;
  FBindAddresses.Free;
  if Assigned(FRttiAuthentication) then
    FRttiAuthentication.Free;
  if Assigned(FRttiLogWriter) then
    FRttiLogWriter.Free;
  inherited Destroy;
end;

procedure TTHttpServer<C>.AfterConstruction;
begin
  inherited AfterConstruction;
  FPort := DefaultPort;
  FMaxRequestContentLength := DefaultMaxRequestContentLength;

  FHttpServer.ListenQueue := 200;
  FHttpServer.UseNagle := False;

  FHttpServer.OnCommandGet := OnHttpServerCommand;
  FHttpServer.OnCommandOther := OnHttpServerCommand;

  FHttpServer.OnHeadersAvailable := OnHttpServerHeadersAvailable;
  FHttpServer.OnHeadersBlocked := OnHttpServerHeadersBlocked;
  FHttpServer.OnCreatePostStream := OnHttpServerCreatePostStream;

  FHttpServer.OnParseAuthentication := OnHttpServerParseAuthentication;
end;

procedure TTHttpServer<C>.Log(const AText: String);
begin
  try
    FLog.LogAction(TTHttpTaskID.NewID.ToString, AText);
  except
    // Logging must not break the operation being logged
  end;
end;

procedure TTHttpServer<C>.CheckLogWriterCanBeCreated(
  const ATypeInfo: PTypeInfo);
var
  LWriter: TTHttpLogAbstractWriter;
begin
  LWriter := FRttiLogWriter.CreateLogWriter;
  if not Assigned(LWriter) then
    raise ETHttpServerException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidLogWriter), [ATypeInfo^.Name]);
  LWriter.Free;
end;

procedure TTHttpServer<C>.RegisterLogWriter<W>;
begin
  RegisterLogWriter<W>(TTHttpLogParameters.DefaultThreadPoolSize);
end;

procedure TTHttpServer<C>.RegisterLogWriter<W>(
  const ALogThreadPoolSize: Integer);
begin
  RegisterLogWriter<W>(TTHttpLogParameters.Create(
    ALogThreadPoolSize,
    TTHttpLogParameters.DefaultQueueCapacity,
    TTHttpLogParameters.DefaultMaxContentLength,
    TTHttpLogParameters.DefaultMaxItemCount));
end;

procedure TTHttpServer<C>.RegisterLogWriter<W>(
  const AParameters: TTHttpLogParameters);
var
  LTypeInfo: PTypeInfo;
begin
  CheckNotStarted;
  if Assigned(FRttiLogWriter) then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SLogWriterAlreadyRegistered));

  LTypeInfo := TypeInfo(W);
  FRttiLogWriter := TTHttpRttiLogWriter.Create(LTypeInfo);
  try
    if not FRttiLogWriter.CheckValid then
      raise ETHttpServerException.CreateFmt(
        TTLanguage.Instance.Translate(SNotValidLogWriter), [LTypeInfo^.Name]);
    CheckLogWriterCanBeCreated(LTypeInfo);
  except
    FRttiLogWriter.Free;
    FRttiLogWriter := nil;
    raise;
  end;

  FLog.RegisterWriter(FRttiLogWriter, AParameters);
end;

procedure TTHttpServer<C>.RegisterAuthentication<H>;
var
  LTypeInfo: PTypeInfo;
begin
  try
    CheckNotStarted;
    if Assigned(FRttiAuthentication) then
      raise ETHttpServerException.Create(
        TTLanguage.Instance.Translate(SAuthAlreadyRegistered));

    LTypeInfo := TypeInfo(H);
    FRttiAuthentication := TTHttpRttiAuthentication<C>.Create(LTypeInfo);
    try
      if not FRttiAuthentication.CheckValid then
        raise ETHttpServerException.CreateFmt(
          TTLanguage.Instance.Translate(SNotValidAuthentication), [
            LTypeInfo^.Name]);
    except
      FRttiAuthentication.Free;
      FRttiAuthentication := nil;
      raise;
    end;

    FListener.SetRttiAuthentication(FRttiAuthentication);
    Log(Format(SRegisterAuth, [LTypeInfo^.Name]));
  except
    on E: Exception do
    begin
      Log(Format(SRegisterAuthError, [E.Message]));
      raise;
    end;
  end;
end;

procedure TTHttpServer<C>.OnAfterRttiControllerAddedEvent(
  const AControllerID: TTHttpControllerID;
  const AAuthType: TTHttpAuthorizationType);
begin
  if AAuthType <> TTHttpAuthorizationType.None then
    FHasProtectedControllers := True;
  FCors.RegisterController(AControllerID, AAuthType);
end;

procedure TTHttpServer<C>.InternalRegisterController(
  const ATypeInfo: PTypeInfo; const AUri: String);
var
  LUri: String;
  LRttiController: TTHttpRttiController<C>;
begin
  try
    CheckNotStarted;
    LUri := Format('%s%s', [FBaseUri, AUri]);
    LRttiController := TTHttpRttiController<C>.Create(ATypeInfo, LUri);
    try
      if not LRttiController.CheckValid then
        raise ETHttpServerException.CreateFmt(
          TTLanguage.Instance.Translate(SNotValidController), [
            ATypeInfo^.Name]);
    except
      LRttiController.Free;
      raise;
    end;

    FControllers.Add(LRttiController);
    FRttiControllers.Add(LRttiController, OnAfterRttiControllerAddedEvent);
    Log(Format(SRegisterController, [ATypeInfo^.Name]));
  except
    on E: Exception do
    begin
      Log(Format(SRegisterControllerError, [E.Message]));
      raise;
    end;
  end;
end;

procedure TTHttpServer<C>.RegisterController<R>;
begin
  InternalRegisterController(TypeInfo(R), String.Empty);
end;

procedure TTHttpServer<C>.RegisterController<R>(const AUri: String);
begin
  InternalRegisterController(TypeInfo(R), AUri);
end;

procedure TTHttpServer<C>.CheckNotStarted;
begin
  if FHttpServer.Active then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SAlreadyStarted));
end;

function TTHttpServer<C>.ContainsBindAddress(
  const AAddress: TTHttpBindAddress): Boolean;
var
  LAddress: TTHttpBindAddress;
begin
  result := False;
  for LAddress in FBindAddresses do
    result := result or LAddress.SameAs(AAddress);
end;

procedure TTHttpServer<C>.AddBindAddress(const AAddress: String);
var
  LAddress: TTHttpBindAddress;
begin
  CheckNotStarted;
  LAddress := TTHttpBindAddress.Create(AAddress);
  if ContainsBindAddress(LAddress) then
    raise ETHttpServerException.CreateFmt(
      TTLanguage.Instance.Translate(SDuplicateBindAddress), [AAddress]);
  FBindAddresses.Add(LAddress);
end;

procedure TTHttpServer<C>.AddBinding(const AAddress: TTHttpBindAddress);
var
  LBinding: TIdSocketHandle;
begin
  LBinding := FHttpServer.Bindings.Add;
  if AAddress.IsIPv6 then
    LBinding.IPVersion := Id_IPv6
  else
    LBinding.IPVersion := Id_IPv4;
  LBinding.IP := AAddress.Address;
  LBinding.Port := FPort;
end;

procedure TTHttpServer<C>.CreateBindings;
var
  LAddress: TTHttpBindAddress;
  LBinding: TIdSocketHandle;
begin
  FHttpServer.Bindings.Clear;
  if FBindAddresses.Count = 0 then
  begin
    LBinding := FHttpServer.Bindings.Add;
    LBinding.Port := FPort;
  end
  else
    for LAddress in FBindAddresses do
      AddBinding(LAddress);
end;

procedure TTHttpServer<C>.SetAllowAnonymous(const AValue: Boolean);
begin
  CheckNotStarted;
  FAllowAnonymous := AValue;
end;

function TTHttpServer<C>.GetAllowMethodOverride: Boolean;
begin
  result := FListener.AllowMethodOverride;
end;

procedure TTHttpServer<C>.SetAllowMethodOverride(const AValue: Boolean);
begin
  CheckNotStarted;
  FListener.AllowMethodOverride := AValue;
end;

procedure TTHttpServer<C>.SetMaxRequestContentLength(const AValue: Int64);
begin
  CheckNotStarted;
  FMaxRequestContentLength := AValue;
end;

procedure TTHttpServer<C>.OnHttpServerHeadersAvailable(
  AContext: TIdContext;
  const AUri: String;
  AHeaders: TIdHeaderList;
  var VContinueProcessing: Boolean);
begin
  VContinueProcessing := (FMaxRequestContentLength <= 0) or
    (StrToInt64Def(AHeaders.Values['Content-Length'], 0) <=
      FMaxRequestContentLength);
end;

procedure TTHttpServer<C>.OnHttpServerHeadersBlocked(
  AContext: TIdContext;
  AHeaders: TIdHeaderList;
  var VResponseNo: Integer;
  var VResponseText: String;
  var VContentText: String);
begin
  VResponseNo := TTHttpStatusCodeTypes.ContentTooLarge;
  VContentText := TTHttpErrorResponse.ToJSon(
    VResponseNo, TTHttpTaskID.NewID.ToString());
end;

procedure TTHttpServer<C>.OnHttpServerCreatePostStream(
  AContext: TIdContext;
  AHeaders: TIdHeaderList;
  var VPostStream: TStream);
begin
  if FMaxRequestContentLength > 0 then
    VPostStream := TTHttpCappedStream.Create(FMaxRequestContentLength);
end;

procedure TTHttpServer<C>.CheckAuthenticationIsRegistered;
begin
  if FHasProtectedControllers and (not FAllowAnonymous) and
    (not Assigned(FRttiAuthentication)) then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SAuthenticationNotRegistered));
end;

procedure TTHttpServer<C>.CheckAreasNeedAuthentication;
var
  LUri: String;
begin
  if (not Assigned(FRttiAuthentication)) and FRttiControllers.HasAreas then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SAreasNeedAuthentication));
  if FRttiControllers.FindAnonymousArea(LUri) then
    raise ETHttpServerException.CreateFmt(
      TTLanguage.Instance.Translate(SAreaOnAnonymousRoute), [LUri]);
end;

procedure TTHttpServer<C>.Start;
begin
  if FHttpServer.Active then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SAlreadyStarted));
  CheckAuthenticationIsRegistered;
  CheckAreasNeedAuthentication;
  CreateBindings;
  TTHttpLogRedactedNames.Instance.BeginServing;
  try
    FHttpServer.Active := True;
  except
    TTHttpLogRedactedNames.Instance.EndServing;
    raise;
  end;
  Log(SStarted);
end;

procedure TTHttpServer<C>.Stop;
begin
  if not FHttpServer.Active then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SNotStarted));
  try
    FHttpServer.Active := False;
  finally
    TTHttpLogRedactedNames.Instance.EndServing;
  end;
  Log(SStopped);
end;

function TTHttpServer<C>.GetStarted: Boolean;
begin
  result := FHttpServer.Active;
end;

procedure TTHttpServer<C>.SetBaseUri(const AValue: String);
begin
  if FHttpServer.Active then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SAlreadyStarted));
  if AValue.Contains('://') then
    raise ETHttpServerException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidBaseUri), [AValue]);
  if (not AValue.IsEmpty) and (not AValue.StartsWith('/')) then
    FBaseUri := Format('/%s', [AValue])
  else
    FBaseUri := AValue;
end;

procedure TTHttpServer<C>.SetPort(const AValue: Word);
begin
  if FHttpServer.Active then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SAlreadyStarted));
  FPort := AValue;
end;

function TTHttpServer<C>.GetCorsConfig: TTHttpCorsConfig;
begin
  result := FCors.Config;
end;

function TTHttpServer<C>.GetOnCanLog: TFunc<TTHttpRequest, Boolean>;
begin
  result := FLog.OnCanLog;
end;

procedure TTHttpServer<C>.SetOnCanLog(
  const AValue: TFunc<TTHttpRequest, Boolean>);
begin
  CheckNotStarted;
  FLog.OnCanLog := AValue;
end;

function TTHttpServer<C>.GetOnRedactContent:
  TFunc<TTHttpRequest, String, String>;
begin
  result := FLog.OnRedactContent;
end;

procedure TTHttpServer<C>.SetOnRedactContent(
  const AValue: TFunc<TTHttpRequest, String, String>);
begin
  CheckNotStarted;
  FLog.OnRedactContent := AValue;
end;

procedure TTHttpServer<C>.SetContentStream(
  const AResponse: TTHttpResponse; const AResponseInfo: TIdHttpResponseInfo);
var
  LContentStream: TMemoryStream;
begin
  LContentStream := TMemoryStream.Create;
  try
    AResponse.GetContentStream(LContentStream);
    AResponseInfo.ContentLength := LContentStream.Size;
  except
    LContentStream.Free;
    raise;
  end;
  AResponseInfo.ContentStream := LContentStream;
  AResponseInfo.FreeContentStream := True;
end;

procedure TTHttpServer<C>.ReleaseContentStream(
  const AResponseInfo: TIdHttpResponseInfo);
begin
  if Assigned(AResponseInfo.ContentStream) then
  begin
    if AResponseInfo.FreeContentStream then
      AResponseInfo.ContentStream.Free;
    AResponseInfo.ContentStream := nil;
  end;
  AResponseInfo.ContentLength := -1;
end;

procedure TTHttpServer<C>.LogFallback(
  const ATaskID: TTHttpTaskID; const AException: Exception);
begin
  try
    FLog.LogAction(
      ATaskID.ToString(),
      Format(
        TTLanguage.Instance.Translate(SUnhandledRequestError),
        [AException.ClassName, AException.Message]));
  except
    // Logging must not undo the response already built
  end;
end;

procedure TTHttpServer<C>.MakeFallbackResponse(
  const ATaskID: TTHttpTaskID;
  const AResponseInfo: TIdHttpResponseInfo;
  const AException: Exception);
begin
  AResponseInfo.ResponseNo := TTHttpStatusCodeTypes.InternalServerError;
  try
    ReleaseContentStream(AResponseInfo);
    FCors.AddAllowOrigin(AResponseInfo.CustomHeaders);

    AResponseInfo.ContentType := TTHttpContentTypes.JSon;
    AResponseInfo.CharSet := TTHttpContentEncodingTypes.Utf8;
    AResponseInfo.ContentText := TTHttpErrorResponse.ToJSon(
      ATaskID.ToString());
  except
    // A 500 with no body is still a 500: the status is already set
  end;

  LogFallback(ATaskID, AException);
end;

procedure TTHttpServer<C>.OnHttpServerCommand(
  AContext: TIdContext;
  ARequestInfo: TIdHttpRequestInfo;
  AResponseInfo: TIdHttpResponseInfo);
var
  LTaskID: TTHttpTaskID;
begin
  LTaskID := Default(TTHttpTaskID);
  try
    LTaskID := TTHttpTaskID.NewID;
    InternalHandleCommand(LTaskID, ARequestInfo, AResponseInfo);
  except
    on EIdSocketError do
      raise;
    on E: Exception do
      MakeFallbackResponse(LTaskID, AResponseInfo, E);
  end;
end;

procedure TTHttpServer<C>.InternalHandleCommand(
  const ATaskID: TTHttpTaskID;
  const ARequestInfo: TIdHttpRequestInfo;
  const AResponseInfo: TIdHttpResponseInfo);
var
  LRequest: TTHttpRequest;
  LResponse: TTHttpResponse;
begin
  LRequest := TTHttpRequest.Create(ATaskID, ARequestInfo);
  try
    TTHttpLanguage.Instance.SetThreadLanguage(
      LRequest.Headers.Value['Accept-Language']);
    try
      LResponse := TTHttpResponse.Create(ATaskID, AResponseInfo);
      try
        FLog.LogRequest(LRequest);
        FListener.HandleRequest(LRequest, LResponse);
        SetContentStream(LResponse, AResponseInfo);

        FLog.LogResponse(LRequest, LResponse);
      finally
        LResponse.Free;
      end;
    finally
      TTHttpLanguage.Instance.RemoveThreadLanguage;
    end;
  finally
    LRequest.Free;
  end;
end;

procedure TTHttpServer<C>.OnHttpServerParseAuthentication(
  AContext: TIdContext;
  const AAuthType, AAuthContext: string;
  var AUsername, APassword: string;
  var AHandled: Boolean);
begin
  AHandled := True;
end;

end.