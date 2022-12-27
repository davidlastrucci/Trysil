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
  IdCustomHttpServer,
  IdHttpServer,
  IdSocketHandle,

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
  Trysil.Http.Log,
  Trysil.Http.Log.Writer;

type

{ TTHttpServer<C> }

  TTHttpServer<C: class, constructor> = class
  strict private
    const DefaultPort = 8022;
    const DefaultLogThreadPoolSize: Integer = 1;
  strict private
    FRttiLogWriter: TTHttpRttiLogWriter;
    FRttiAuthentication: TTHttpRttiAuthentication<C>;
    FRttiControllers: TTHttpRttiControllers<C>;
    FFreeControllerIDs: TList<TTHttpControllerID>;
    FCors: TTHttpCors;
    FListener: TTHttpListener<C>;
    FLog: TTHttpLog;
    FBaseUri: String;
    FHttpServer: TIdHttpServer;
    FPort: Word;

    FControllers: TObjectList<TTHttpRttiController<C>>;

    procedure Log(const AText: String);

    function GetStarted: Boolean;
    procedure SetPort(const AValue: Word);
    function GetCorsConfig: TTHttpCorsConfig;

    procedure OnAfterRttiControllerAddedEvent(
      const AControllerID: TTHttpControllerID;
      const AAuthType: TTHttpAuthorizationType);

    procedure SetContentStream(
      const AResponse: TTHttpResponse; const AResponseInfo: TIdHttpResponseInfo);
    procedure OnHttpServerCommand(
      AContext: TIdContext;
      ARequestInfo: TIdHttpRequestInfo;
      AResponseInfo: TIdHttpResponseInfo);
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
    procedure RegisterAuthentication<H: TTHttpAbstractAuthentication<C>>();
    procedure RegisterController<R: TTHttpController<C>>(); overload;
    procedure RegisterController<R: TTHttpController<C>>(
      const AUri: String); overload;

    procedure Start;
    procedure Stop;

    property Started: Boolean read GetStarted;
    property BaseUri: String read FBaseUri write FBaseUri;
    property Port: Word read FPort write SetPort;
    property CorsConfig: TTHttpCorsConfig read GetCorsConfig;
  end;

implementation

{ TTHttpServer<C> }

constructor TTHttpServer<C>.Create;
begin
  inherited Create;
  FRttiLogWriter := nil;
  FRttiAuthentication := nil;
  FRttiControllers := TTHttpRttiControllers<C>.Create;
  FFreeControllerIDs := TList<TTHttpControllerID>.Create;
  FCors := TTHttpCors.Create;
  FListener := TTHttpListener<C>.Create(
    FCors, FRttiControllers, FFreeControllerIDs);
  FLog := TTHttpLog.Create;
  FHttpServer := TIdHttpServer.Create(nil);

  FControllers := TObjectList<TTHttpRttiController<C>>.Create(True);
end;

destructor TTHttpServer<C>.Destroy;
begin
  FControllers.Free;

  if FHttpServer.Active then
    Stop;
  FHttpServer.Free;
  FLog.Free;
  FListener.Free;
  FCors.Free;
  FRttiControllers.Free;
  FFreeControllerIDs.Free;
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

  FHttpServer.ListenQueue := 200;
  FHttpServer.UseNagle := False;

  FHttpServer.OnCommandGet := OnHttpServerCommand;
  FHttpServer.OnCommandOther := OnHttpServerCommand;

  FHttpServer.OnParseAuthentication := OnHttpServerParseAuthentication;
end;

procedure TTHttpServer<C>.Log(const AText: String);
begin
  FLog.LogAction(TTHttpTaskID.NewID.ToString, AText);
end;

procedure TTHttpServer<C>.RegisterLogWriter<W>;
begin
  RegisterLogWriter<W>(DefaultLogThreadPoolSize);
end;

procedure TTHttpServer<C>.RegisterLogWriter<W>(
  const ALogThreadPoolSize: Integer);
var
  LTypeInfo: PTypeInfo;
begin
  if Assigned(FRttiLogWriter) then
    raise ETHttpServerException.Create(SLogWriterAlreadyRegistered);

  LTypeInfo := TypeInfo(W);
  FRttiLogWriter := TTHttpRttiLogWriter.Create(LTypeInfo);
  try
    if not FRttiLogWriter.CheckValid then
      raise ETHttpServerException.CreateFmt(
        SNotValidLogWriter, [LTypeInfo^.Name]);
  except
    FRttiLogWriter.Free;
    FRttiLogWriter := nil;
    raise;
  end;

  FLog.RegisterWriter(FRttiLogWriter, DefaultLogThreadPoolSize);
end;

procedure TTHttpServer<C>.RegisterAuthentication<H>;
var
  LTypeInfo: PTypeInfo;
begin
  try
    if Assigned(FRttiAuthentication) then
      raise ETHttpServerException.Create(SAuthAlreadyRegistered);

    LTypeInfo := TypeInfo(H);
    FRttiAuthentication := TTHttpRttiAuthentication<C>.Create(LTypeInfo);
    try
      if not FRttiAuthentication.CheckValid then
        raise ETHttpServerException.CreateFmt(
          SNotValidAuthentication, [LTypeInfo^.Name]);
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
  if AAuthType = TTHttpAuthorizationType.None then
    FFreeControllerIDs.Add(AControllerID);
  FCors.RegisterController(AControllerID, AAuthType);
end;

procedure TTHttpServer<C>.InternalRegisterController(
  const ATypeInfo: PTypeInfo; const AUri: String);
var
  LUri: String;
  LRttiController: TTHttpRttiController<C>;
begin
  try
    LUri := Format('%s%s', [FBaseUri, AUri]);
    LRttiController := TTHttpRttiController<C>.Create(ATypeInfo, LUri);
    try
      if not LRttiController.CheckValid then
        raise ETHttpServerException.CreateFmt(
          SNotValidController, [ATypeInfo^.Name]);
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

procedure TTHttpServer<C>.Start;
var
  LBinding: TIdSocketHandle;
begin
  if FHttpServer.Active then
    raise ETHttpServerException.Create(SAlreadyStarted);
  FHttpServer.Bindings.Clear;
  LBinding := FHttpServer.Bindings.Add;
  LBinding.Port := FPort;
  FHttpServer.Active := True;
  Log(SStarted);
end;

procedure TTHttpServer<C>.Stop;
begin
  if not FHttpServer.Active then
    raise ETHttpServerException.Create(SNotStarted);
  FHttpServer.Active := False;
  Log(SStopped);
end;

function TTHttpServer<C>.GetStarted: Boolean;
begin
  result := FHttpServer.Active;
end;

procedure TTHttpServer<C>.SetPort(const AValue: Word);
begin
  if FHttpServer.Active then
    raise ETHttpServerException.Create(SAlreadyStarted);
  FPort := AValue;
end;

function TTHttpServer<C>.GetCorsConfig: TTHttpCorsConfig;
begin
  result := FCors.Config;
end;

procedure TTHttpServer<C>.SetContentStream(
  const AResponse: TTHttpResponse; const AResponseInfo: TIdHttpResponseInfo);
var
  LContentStream: TMemoryStream;
begin
  LContentStream := TMemoryStream.Create;
  try
    AResponse.GetContentStream(LContentStream);
    AResponseInfo.ContentStream := LContentStream;
    AResponseInfo.ContentLength := LContentStream.Size;
  except
    AResponseInfo.ContentStream.Free;
    raise;
  end;
end;

procedure TTHttpServer<C>.OnHttpServerCommand(
  AContext: TIdContext;
  ARequestInfo: TIdHttpRequestInfo;
  AResponseInfo: TIdHttpResponseInfo);
var
  LTaskID: TTHttpTaskID;
  LRequest: TTHttpRequest;
  LResponse: TTHttpResponse;
begin
  LTaskID := TTHttpTaskID.NewID;
  LRequest := TTHttpRequest.Create(LTaskID, ARequestInfo);
  try
    LResponse := TTHttpResponse.Create(LTaskID, AResponseInfo);
    try
      FLog.LogRequest(LRequest);
      FListener.HandleRequest(LRequest, LResponse);
      SetContentStream(LResponse, AResponseInfo);

      FLog.LogResponse(LRequest.User, LResponse);
    finally
      LResponse.Free;
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