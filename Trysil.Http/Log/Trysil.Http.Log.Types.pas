(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Log.Types;

interface

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.SyncObjs,
  System.Generics.Collections,
  System.JSon,
  System.NetEncoding,
  Trysil.Consts,
  Trysil.Classes,
  Trysil.Exceptions,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Types,
  Trysil.Http.Classes;

type

{$SCOPEDENUMS ON}

{ TTHttpLogParameters }

  TTHttpLogParameters = record
  public
    const DefaultThreadPoolSize: Integer = 1;
    const DefaultQueueCapacity: Integer = 10000;
    const DefaultMaxContentLength: Integer = 0;
    const DefaultMaxItemCount: Integer = 128;
  strict private
    FThreadPoolSize: Integer;
    FQueueCapacity: Integer;
    FMaxContentLength: Integer;
    FMaxItemCount: Integer;

    function GetThreadPoolSize: Integer;
    function GetQueueCapacity: Integer;
    function GetMaxItemCount: Integer;
  public
    constructor Create(
      const AThreadPoolSize: Integer;
      const AQueueCapacity: Integer); overload;

    constructor Create(
      const AThreadPoolSize: Integer;
      const AQueueCapacity: Integer;
      const AMaxContentLength: Integer); overload;

    constructor Create(
      const AThreadPoolSize: Integer;
      const AQueueCapacity: Integer;
      const AMaxContentLength: Integer;
      const AMaxItemCount: Integer); overload;

    function CanLogContent(const ALength: Int64): Boolean;
    function CanLogItems(const ACount: Integer): Boolean;

    property ThreadPoolSize: Integer read GetThreadPoolSize;
    property QueueCapacity: Integer read GetQueueCapacity;
    property MaxContentLength: Integer read FMaxContentLength;
    property MaxItemCount: Integer read GetMaxItemCount;
  end;

{ TTHttpLogDiscarded }

  TTHttpLogDiscarded = record
  strict private
    FHost: String;
    FCount: Integer;
  public
    constructor Create(const AHost: String; const ACount: Integer);

    property Host: String read FHost;
    property Count: Integer read FCount;
  end;

{ TTHttpLogAction }

  TTHttpLogAction = record
  strict private
    FTaskID: String;
    FDateTime: TDateTime;
    FAction: String;
  public
    constructor Create(const ATaskID: String; const AAction: String);

    function ToJSon: String;

    property TaskID: String read FTaskID;
    property DateTime: TDateTime read FDateTime;
    property Action: String read FAction;
  end;

{ TTHttpLogNameValue }

  TTHttpLogNameValue = record
  strict private
    FName: String;
    FValue: String;
  public
    constructor Create(const ANameValue: TTHttpNameValue); overload;
    constructor Create(
      const AName: String; const AValue: String); overload;

    property Name: String read FName;
    property Value: String read FValue;
  end;

{ TTHttpLogRedactedNames }

  TTHttpLogRedactedNames = class
  strict private
    class var FInstance: TTHttpLogRedactedNames;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    const DefaultNames: array[0..12] of String = (
      'Authorization',
      'Proxy-Authorization',
      'Cookie',
      'Set-Cookie',
      'X-Api-Key',
      'token',
      'access_token',
      'refresh_token',
      'id_token',
      'api_key',
      'key',
      'password',
      'signature');
  strict private
    FServing: Integer;
    FNames: TList<String>;

    function IndexOf(const AName: String): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure BeginServing;
    procedure EndServing;

    procedure Add(const AName: String);
    function Contains(const AName: String): Boolean;

    class property Instance: TTHttpLogRedactedNames read FInstance;
  end;

{ TTHttpLogNameValues }

  TTHttpLogNameValues = record
  strict private
    const RedactedValue = '<redacted>';
  strict private
    FValues: TArray<TTHttpLogNameValue>;

    class function IsRedacted(const AName: String): Boolean; static;
  public
    constructor Create(
      const ANameValues: TTHttpNameValues;
      const ARedact: Boolean);

    function ToJSonArray(): TJSonArray;
    function ToString: String;
  end;

{ TTHttpLogRequest }

  TTHttpLogRequest = record
  strict private
    FTaskID: TTHttpTaskID;
    FHost: String;
    FDateTime: TDateTime;
    FUri: String;
    FParamsCount: Integer;
    FParamsOmitted: Boolean;
    FParams: TTHttpLogNameValues;
    FMethodType: String;
    FContentLength: Int64;
    FContentOmitted: Boolean;
    FContent: String;
    FHeadersCount: Integer;
    FHeadersOmitted: Boolean;
    FHeaders: TTHttpLogNameValues;
    FRemoteIP: String;
    FClientIP: String;

    procedure SetContent(
      const ARequest: TTHttpRequest;
      const AParameters: TTHttpLogParameters;
      const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
    procedure SetReadableContent(
      const ARequest: TTHttpRequest;
      const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
  public
    constructor Create(
      const ARequest: TTHttpRequest;
      const AParameters: TTHttpLogParameters;
      const AOnRedactContent: TFunc<TTHttpRequest, String, String>);

    function ToJSon: String;

    property TaskID: TTHttpTaskID read FTaskID;
    property Host: String read FHost;
    property DateTime: TDateTime read FDateTime;
    property Uri: String read FUri;
    property ParamsCount: Integer read FParamsCount;
    property ParamsOmitted: Boolean read FParamsOmitted;
    property Params: TTHttpLogNameValues read FParams;
    property MethodType: String read FMethodType;
    property ContentLength: Int64 read FContentLength;
    property ContentOmitted: Boolean read FContentOmitted;
    property Content: String read FContent;
    property HeadersCount: Integer read FHeadersCount;
    property HeadersOmitted: Boolean read FHeadersOmitted;
    property Headers: TTHttpLogNameValues read FHeaders;
    property RemoteIP: String read FRemoteIP;
    property ClientIP: String read FClientIP;
  end;

{ TTHttpLogUserAreas }

  TTHttpLogUserAreas = record
  strict private
    FAreas: TArray<String>;
  public
    constructor Create(const AAreas: TTHttpUserAreas);

    function ToJSonArray: TJSonArray;
    function ToString: String;
  end;

{ TTHttpLogUser }

  TTHttpLogUser = record
  strict private
    FUsername: String;
    FTenant: String;
    FAreas: TTHttpLogUserAreas;
  public
    constructor Create(const AUser: TTHttpUser);

    function ToJSon: TJSonObject;

    property Username: String read FUsername;
    property Tenant: String read FTenant;
    property Areas: TTHttpLogUserAreas read FAreas;
  end;

{ TTHttpLogResponse }

  TTHttpLogResponse = record
  strict private
    FTaskID: TTHttpTaskID;
    FDateTime: TDateTime;
    FHost: String;
    FUri: String;
    FUser: TTHttpLogUser;
    FStatusCode: Integer;
    FContentType: String;
    FContentEncoding: String;
    FIsBinary: Boolean;
    FContentLength: Int64;
    FContentOmitted: Boolean;
    FContent: String;
    FBinaryContent: String;

    function GetBinaryContent(const AResponse: TTHttpResponse): String;
    procedure SetContent(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const AParameters: TTHttpLogParameters;
      const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
  public
    constructor Create(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const AParameters: TTHttpLogParameters;
      const AOnRedactContent: TFunc<TTHttpRequest, String, String>);

    function ToJSon: String;

    property TaskID: TTHttpTaskID read FTaskID;
    property DateTime: TDateTime read FDateTime;
    property Host: String read FHost;
    property Uri: String read FUri;
    property User: TTHttpLogUser read FUser;
    property StatusCode: Integer read FStatusCode;
    property ContentType: String read FContentType;
    property ContentEncoding: String read FContentEncoding;
    property ContentLength: Int64 read FContentLength;
    property ContentOmitted: Boolean read FContentOmitted;
    property Content: String read FContent;
    property BinaryContent: String read FBinaryContent;
  end;

{ TTHttpLogError }

  TTHttpLogError = record
  strict private
    FTaskID: TTHttpTaskID;
    FDateTime: TDateTime;
    FHost: String;
    FUri: String;
    FExceptionClassName: String;
    FExceptionMessage: String;
    FNestedExceptionClassName: String;
    FNestedExceptionMessage: String;

    procedure SetNestedException(const AException: Exception);
  public
    constructor Create(
      const ARequest: TTHttpRequest; const AException: Exception);

    function ToJSon: String;

    property TaskID: TTHttpTaskID read FTaskID;
    property DateTime: TDateTime read FDateTime;
    property Host: String read FHost;
    property Uri: String read FUri;
    property ExceptionClassName: String read FExceptionClassName;
    property ExceptionMessage: String read FExceptionMessage;
    property NestedExceptionClassName: String
      read FNestedExceptionClassName;
    property NestedExceptionMessage: String read FNestedExceptionMessage;
  end;

{ TTHttpLogQueueType }

  TTHttpLogQueueType = (Request, Response, Error);

{ TTHttpLogQueueValue }

  TTHttpLogQueueValue = record
  strict private
    FQueueType: TTHttpLogQueueType;
    FRequest: TTHttpLogRequest;
    FResponse: TTHttpLogResponse;
    FError: TTHttpLogError;
  public
    constructor Create(const ARequest: TTHttpLogRequest); overload;
    constructor Create(const AResponse: TTHttpLogResponse); overload;
    constructor Create(const AError: TTHttpLogError); overload;

    property QueueType: TTHttpLogQueueType read FQueueType;
    property Request: TTHttpLogRequest read FRequest;
    property Response: TTHttpLogResponse read FResponse;
    property Error: TTHttpLogError read FError;
  end;

implementation

type

{ TTHttpLogContent }

  TTHttpLogContent = record
  public
    class function ToJSonValue(const AContent: String): TJSonValue; static;
  end;

{ TTHttpLogContent }

class function TTHttpLogContent.ToJSonValue(
  const AContent: String): TJSonValue;
begin
  result := TJSonObject.ParseJSONValue(AContent);
  if not Assigned(result) then
    result := TJSonString.Create(AContent);
end;

{ TTHttpLogParameters }

constructor TTHttpLogParameters.Create(
  const AThreadPoolSize: Integer;
  const AQueueCapacity: Integer);
begin
  Create(
    AThreadPoolSize,
    AQueueCapacity,
    DefaultMaxContentLength,
    DefaultMaxItemCount);
end;

constructor TTHttpLogParameters.Create(
  const AThreadPoolSize: Integer;
  const AQueueCapacity: Integer;
  const AMaxContentLength: Integer);
begin
  Create(
    AThreadPoolSize, AQueueCapacity, AMaxContentLength, DefaultMaxItemCount);
end;

constructor TTHttpLogParameters.Create(
  const AThreadPoolSize: Integer;
  const AQueueCapacity: Integer;
  const AMaxContentLength: Integer;
  const AMaxItemCount: Integer);
begin
  FThreadPoolSize := AThreadPoolSize;
  FQueueCapacity := AQueueCapacity;
  FMaxContentLength := AMaxContentLength;
  FMaxItemCount := AMaxItemCount;
end;

function TTHttpLogParameters.GetThreadPoolSize: Integer;
begin
  if FThreadPoolSize > 0 then
    result := FThreadPoolSize
  else
    result := DefaultThreadPoolSize;
end;

function TTHttpLogParameters.GetQueueCapacity: Integer;
begin
  if FQueueCapacity = 0 then
    result := DefaultQueueCapacity
  else
    result := FQueueCapacity;
end;

function TTHttpLogParameters.GetMaxItemCount: Integer;
begin
  if FMaxItemCount = 0 then
    result := DefaultMaxItemCount
  else
    result := FMaxItemCount;
end;

function TTHttpLogParameters.CanLogContent(
  const ALength: Int64): Boolean;
begin
  result := (FMaxContentLength < 0) or (ALength <= FMaxContentLength);
end;

function TTHttpLogParameters.CanLogItems(const ACount: Integer): Boolean;
begin
  result := (MaxItemCount < 0) or (ACount <= MaxItemCount);
end;

{ TTHttpLogDiscarded }

constructor TTHttpLogDiscarded.Create(
  const AHost: String; const ACount: Integer);
begin
  FHost := AHost;
  FCount := ACount;
end;

{ TTHttpLogAction }

constructor TTHttpLogAction.Create(const ATaskID: String; const AAction: String);
begin
  FTaskID := ATaskID;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);
  FAction := AAction;
end;

function TTHttpLogAction.ToJSon: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('TaskID', FTaskID);
    LJSon.AddPair('DateTime', DateToISO8601(FDateTime, True));
    LJSon.AddPair('Action', FAction);

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

{ TTHttpLogNameValue }

constructor TTHttpLogNameValue.Create(const ANameValue: TTHttpNameValue);
begin
  Create(ANameValue.Name, ANameValue.Value);
end;

constructor TTHttpLogNameValue.Create(
  const AName: String; const AValue: String);
begin
  FName := AName;
  FValue := AValue;
end;

{ TTHttpLogNameValues }

constructor TTHttpLogNameValues.Create(
  const ANameValues: TTHttpNameValues;
  const ARedact: Boolean);
var
  LCount, LIndex: Integer;
  LNameValue: TTHttpNameValue;
begin
  LCount := ANameValues.Count;
  SetLength(FValues, LCount);
  for LIndex := 0 to LCount - 1 do
  begin
    LNameValue := ANameValues.NameValue[LIndex];
    if ARedact and IsRedacted(LNameValue.Name) then
      FValues[LIndex] := TTHttpLogNameValue.Create(
        LNameValue.Name, RedactedValue)
    else
      FValues[LIndex] := TTHttpLogNameValue.Create(LNameValue);
  end;
end;

class function TTHttpLogNameValues.IsRedacted(const AName: String): Boolean;
begin
  result := TTHttpLogRedactedNames.Instance.Contains(AName);
end;

function TTHttpLogNameValues.ToJSonArray: TJSonArray;
var
  LNameValue: TTHttpLogNameValue;
  LObject: TJSonObject;
begin
  result := TJSonArray.Create;
  try
    for LNameValue in FValues do
    begin
      LObject := TJSonObject.Create;
      try
        LObject.AddPair('Name', LNameValue.Name);
        LObject.AddPair('Value', LNameValue.Value);
      except
        LObject.Free;
        raise;
      end;
      result.AddElement(LObject);
    end;
  except
    result.Free;
    raise;
  end;
end;

function TTHttpLogNameValues.ToString: String;
var
  LJSon: TJSonArray;
begin
  LJSon := ToJSonArray;
  try
    result := LJSon.ToJSon;
  finally
    LJSon.Free;
  end;
end;

{ TTHttpLogRedactedNames }

class constructor TTHttpLogRedactedNames.ClassCreate;
begin
  FInstance := TTHttpLogRedactedNames.Create;
end;

class destructor TTHttpLogRedactedNames.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTHttpLogRedactedNames.Create;
begin
  inherited Create;
  FServing := 0;
  FNames := TList<String>.Create;
end;

destructor TTHttpLogRedactedNames.Destroy;
begin
  FNames.Free;
  inherited Destroy;
end;

procedure TTHttpLogRedactedNames.BeginServing;
begin
  TInterlocked.Increment(FServing);
end;

procedure TTHttpLogRedactedNames.EndServing;
begin
  TInterlocked.Decrement(FServing);
end;

procedure TTHttpLogRedactedNames.AfterConstruction;
var
  LIndex: Integer;
begin
  inherited AfterConstruction;
  for LIndex := Low(DefaultNames) to High(DefaultNames) do
    FNames.Add(DefaultNames[LIndex]);
end;

function TTHttpLogRedactedNames.IndexOf(const AName: String): Integer;
var
  LIndex: Integer;
begin
  result := -1;
  for LIndex := 0 to FNames.Count - 1 do
    if TTIdentifier.Same(FNames[LIndex], AName) then
    begin
      result := LIndex;
      Break;
    end;
end;

procedure TTHttpLogRedactedNames.Add(const AName: String);
begin
  if FServing > 0 then
    raise ETHttpServerException.Create(
      TTLanguage.Instance.Translate(SRedactedNamesWhileServing));

  if IndexOf(AName) < 0 then
    FNames.Add(AName);
end;

function TTHttpLogRedactedNames.Contains(const AName: String): Boolean;
begin
  result := IndexOf(AName) >= 0;
end;

{ TTHttpLogRequest }

procedure TTHttpLogRequest.SetContent(
  const ARequest: TTHttpRequest;
  const AParameters: TTHttpLogParameters;
  const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
begin
  FContentLength := ARequest.ContentLength;
  FContentOmitted := not AParameters.CanLogContent(FContentLength);
  FContent := String.Empty;
  if not FContentOmitted then
    SetReadableContent(ARequest, AOnRedactContent);
end;

procedure TTHttpLogRequest.SetReadableContent(
  const ARequest: TTHttpRequest;
  const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
begin
  try
    FContent := ARequest.JSonContent.ToJSon();
    if Assigned(AOnRedactContent) then
      FContent := AOnRedactContent(ARequest, FContent);
  except
    FContent := String.Empty;
    FContentOmitted := True;
  end;
end;

constructor TTHttpLogRequest.Create(
  const ARequest: TTHttpRequest;
  const AParameters: TTHttpLogParameters;
  const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
begin
  FTaskID := ARequest.TaskID;
  FHost := ARequest.Host;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);
  FUri := ARequest.ControllerID.Uri;
  FMethodType := ARequest.ControllerID.Method;
  SetContent(ARequest, AParameters, AOnRedactContent);

  FParamsCount := ARequest.Parameters.Count;
  FParamsOmitted := FContentOmitted or
    (not AParameters.CanLogItems(FParamsCount));
  if not FParamsOmitted then
    FParams := TTHttpLogNameValues.Create(ARequest.Parameters, True);

  FHeadersCount := ARequest.Headers.Count;
  FHeadersOmitted := not AParameters.CanLogItems(FHeadersCount);
  if not FHeadersOmitted then
    FHeaders := TTHttpLogNameValues.Create(ARequest.Headers, True);

  FRemoteIP := ARequest.RemoteIP;
  FClientIP := ARequest.ClientIP;
end;

function TTHttpLogRequest.ToJSon: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('TaskID', FTaskID.ToString());
    LJSon.AddPair('DateTime', DateToISO8601(FDateTime, True));
    LJSon.AddPair('Uri', FUri);
    LJSon.AddPair('ParamsCount', TJSonNumber.Create(FParamsCount));
    if FParamsOmitted then
      LJSon.AddPair('ParamsOmitted', TJSonBool.Create(True))
    else
      LJSon.AddPair('Params', FParams.ToJSonArray());
    LJSon.AddPair('HeadersCount', TJSonNumber.Create(FHeadersCount));
    if FHeadersOmitted then
      LJSon.AddPair('HeadersOmitted', TJSonBool.Create(True))
    else
      LJSon.AddPair('Headers', FHeaders.ToJSonArray());
    LJSon.AddPair('MethodType', FMethodType);
    LJSon.AddPair('ContentLength', TJSonNumber.Create(FContentLength));
    if FContentOmitted then
      LJSon.AddPair('ContentOmitted', TJSonBool.Create(True))
    else
      LJSon.AddPair('Content', TTHttpLogContent.ToJSonValue(FContent));
    LJSon.AddPair('RemoteIP', FRemoteIP);
    LJSon.AddPair('ClientIP', FClientIP);

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

{ TTHttpLogUserAreas }

constructor TTHttpLogUserAreas.Create(const AAreas: TTHttpUserAreas);
var
  LCount, LIndex: Integer;
begin
  LCount := AAreas.Count;
  SetLength(FAreas, LCount);
  for LIndex := 0 to LCount - 1 do
    FAreas[LIndex] := AAreas.Area[LIndex];
end;

function TTHttpLogUserAreas.ToJSonArray: TJSonArray;
var
  LArea: String;
begin
  result := TJSonArray.Create;
  try
    for LArea in FAreas do
      result.AddElement(TJSonString.Create(LArea));
  except
    result.Free;
    raise;
  end;
end;

function TTHttpLogUserAreas.ToString: String;
var
  LJSon: TJSonArray;
begin
  LJSon := ToJSonArray;
  try
    result := LJSon.ToJSon;
  finally
    LJSon.Free;
  end;
end;

{ TTHttpLogUser }

constructor TTHttpLogUser.Create(const AUser: TTHttpUser);
begin
  FUsername := AUser.Username;
  FTenant := AUser.Tenant;
  FAreas := TTHttpLogUserAreas.Create(AUser.Areas);
end;

function TTHttpLogUser.ToJSon: TJSonObject;
begin
  result := TJSonObject.Create;
  try
    result.AddPair('Username', FUsername);
    result.AddPair('Tenant', FTenant);
    result.AddPair('Areas', FAreas.ToJSonArray());
  except
    result.Free;
    raise;
  end;
end;

{ TTHttpLogResponse }

procedure TTHttpLogResponse.SetContent(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const AParameters: TTHttpLogParameters;
  const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
begin
  FContentLength := AResponse.ContentLength;
  FContentOmitted := not AParameters.CanLogContent(FContentLength);
  if FContentOmitted then
  begin
    FContent := String.Empty;
    FBinaryContent := String.Empty;
  end
  else
  begin
    FContent := AResponse.Content;
    if Assigned(AOnRedactContent) then
      FContent := AOnRedactContent(ARequest, FContent);
    if FIsBinary then
      FBinaryContent := GetBinaryContent(AResponse);
  end;
end;

constructor TTHttpLogResponse.Create(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const AParameters: TTHttpLogParameters;
  const AOnRedactContent: TFunc<TTHttpRequest, String, String>);
begin
  FTaskID := AResponse.TaskID;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);
  FHost := ARequest.Host;
  FUri := ARequest.ControllerID.Uri;
  FUser := TTHttpLogUser.Create(ARequest.User);
  FStatusCode := AResponse.StatusCode;
  FContentType := AResponse.ContentType;
  FContentEncoding := AResponse.ContentEncoding;
  FIsBinary := AResponse.IsContentStream;
  SetContent(ARequest, AResponse, AParameters, AOnRedactContent);
end;

function TTHttpLogResponse.GetBinaryContent(
  const AResponse: TTHttpResponse): String;
var
  LStream: TMemoryStream;
  LBytes: TBytes;
begin
  LStream := TMemoryStream.Create;
  try
    AResponse.GetContentStream(LStream);
    LStream.Position := 0;
    SetLength(LBytes, LStream.Size);
    LStream.Read(LBytes, LStream.Size);
    result := TNetEncoding.Base64.EncodeBytesToString(LBytes);
  finally
    LStream.Free;
  end;
end;

function TTHttpLogResponse.ToJSon: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('TaskID', FTaskID.ToString());
    LJSon.AddPair('DateTime', DateToISO8601(FDateTime, True));
    LJSon.AddPair('Uri', FUri);
    LJSon.AddPair('User', FUser.ToJSon());
    LJSon.AddPair('StatusCode', TJSonNumber.Create(FStatusCode));
    LJSon.AddPair('ContentType', FContentType);
    LJSon.AddPair('ContentLength', TJSonNumber.Create(FContentLength));
    if not FIsBinary then
      LJSon.AddPair('ContentEncoding', FContentEncoding);
    if FContentOmitted then
      LJSon.AddPair('ContentOmitted', TJSonBool.Create(True))
    else if FIsBinary then
      LJSon.AddPair('BinaryContent', TJSonString.Create(FBinaryContent))
    else if FContentType.Equals(TTHttpContentTypes.JSon) then
      LJSon.AddPair('Content', TTHttpLogContent.ToJSonValue(FContent))
    else
      LJSon.AddPair('Content', FContent);

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

{ TTHttpLogError }

constructor TTHttpLogError.Create(
  const ARequest: TTHttpRequest; const AException: Exception);
begin
  FTaskID := ARequest.TaskID;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);
  FHost := ARequest.Host;
  FUri := ARequest.ControllerID.Uri;
  FExceptionClassName := AException.ClassName;
  FExceptionMessage := AException.Message;
  SetNestedException(AException);
end;

procedure TTHttpLogError.SetNestedException(const AException: Exception);
var
  LException: ETException;
begin
  FNestedExceptionClassName := String.Empty;
  FNestedExceptionMessage := String.Empty;
  if AException is ETException then
  begin
    LException := ETException(AException);
    FNestedExceptionClassName := LException.NestedExceptionClassName;
    FNestedExceptionMessage := LException.NestedExceptionMessage;
  end;
end;

function TTHttpLogError.ToJSon: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('TaskID', FTaskID.ToString());
    LJSon.AddPair('DateTime', DateToISO8601(FDateTime, True));
    LJSon.AddPair('Host', FHost);
    LJSon.AddPair('Uri', FUri);
    LJSon.AddPair('ExceptionClassName', FExceptionClassName);
    LJSon.AddPair('ExceptionMessage', FExceptionMessage);
    if not FNestedExceptionClassName.IsEmpty then
    begin
      LJSon.AddPair('NestedExceptionClassName', FNestedExceptionClassName);
      LJSon.AddPair('NestedExceptionMessage', FNestedExceptionMessage);
    end;

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

{ TTHttpLogQueueValue }

constructor TTHttpLogQueueValue.Create(const ARequest: TTHttpLogRequest);
begin
  FQueueType := TTHttpLogQueueType.Request;
  FRequest := ARequest;
end;

constructor TTHttpLogQueueValue.Create(const AResponse: TTHttpLogResponse);
begin
  FQueueType := TTHttpLogQueueType.Response;
  FResponse := AResponse;
end;

constructor TTHttpLogQueueValue.Create(const AError: TTHttpLogError);
begin
  FQueueType := TTHttpLogQueueType.Error;
  FError := AError;
end;

end.
