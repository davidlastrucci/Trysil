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
  System.JSon,
  System.NetEncoding,

  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Classes;

type

{$SCOPEDENUMS ON}

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
    constructor Create(const ANameValue: TTHttpNameValue);

    property Name: String read FName;
    property Value: String read FValue;
  end;

{ TTHttpLogNameValues }

  TTHttpLogNameValues = record
  strict private
    FValues: TArray<TTHttpLogNameValue>;
  public
    constructor Create(const ANameValues: TTHttpNameValues);

    function ToJSonArray(): TJSonArray;
  end;

{ TTHttpLogRequest }

  TTHttpLogRequest = record
  strict private
    FTaskID: TTHttpTaskID;
    FDateTime: TDateTime;
    FUri: String;
    FParams: TTHttpLogNameValues;
    FMethodType: String;
    FContent: String;
    FHeaders: TTHttpLogNameValues;
    FRemoteIP: String;
  public
    constructor Create(const ARequest: TTHttpRequest);

    function ToJSon: String;

    property TaskID: TTHttpTaskID read FTaskID;
    property DateTime: TDateTime read FDateTime;
    property Uri: String read FUri;
    property Params: TTHttpLogNameValues read FParams;
    property MethodType: String read FMethodType;
    property Content: String read FContent;
    property Headers: TTHttpLogNameValues read FHeaders;
    property RemoteIP: String read FRemoteIP;
  end;

{ TTHttpLogUserAreas }

  TTHttpLogUserAreas = record
  strict private
    FAreas: TArray<String>;
  public
    constructor Create(const AAreas: TTHttpUserAreas);

    function ToJSonArray: TJSonArray;
  end;

{ TTHttpLogUser }

  TTHttpLogUser = record
  strict private
    FUsername: String;
    FAreas: TTHttpLogUserAreas;
  public
    constructor Create(const AUser: TTHttpUser);

    function ToJSon: TJSonObject;

    property Username: String read FUsername;
    property Areas: TTHttpLogUserAreas read FAreas;
  end;

{ TTHttpLogResponse }

  TTHttpLogResponse = record
  strict private
    FTaskID: TTHttpTaskID;
    FDateTime: TDateTime;
    FUser: TTHttpLogUser;
    FStatusCode: Integer;
    FContentType: String;
    FContentEncoding: String;
    FIsBinary: Boolean;
    FContent: String;
    FBinaryContent: String;

    function GetBinaryContent(const AResponse: TTHttpResponse): String;
  public
    constructor Create(const AUser: TTHttpUser; const AResponse: TTHttpResponse);

    function ToJSon: String;

    property TaskID: TTHttpTaskID read FTaskID;
    property DateTime: TDateTime read FDateTime;
    property User: TTHttpLogUser read FUser;
    property StatusCode: Integer read FStatusCode;
    property ContentType: String read FContentType;
    property ContentEncoding: String read FContentEncoding;
    property Content: String read FContent;
    property BinaryContent: String read FBinaryContent;
  end;

{ TTHttpLogQueueType }

  TTHttpLogQueueType = (Request, Response);

{ TTHttpLogQueueValue }

  TTHttpLogQueueValue = record
  strict private
    FQueueType: TTHttpLogQueueType;
    FRequest: TTHttpLogRequest;
    FResponse: TTHttpLogResponse;
  public
    constructor Create(const ARequest: TTHttpLogRequest); overload;
    constructor Create(const AResponse: TTHttpLogResponse); overload;

    property QueueType: TTHttpLogQueueType read FQueueType;
    property Request: TTHttpLogRequest read FRequest;
    property Response: TTHttpLogResponse read FResponse;
  end;

implementation

{ TTHttpLogAction }

constructor TTHttpLogAction.Create(const ATaskID: String; const AAction: String);
begin
  FTaskID := ATaskID;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);
  FAction := AAction;
  Sleep(10);
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
  FName := ANameValue.Name;
  FValue := ANameValue.Value;
end;

{ TTHttpLogNameValues }

constructor TTHttpLogNameValues.Create(const ANameValues: TTHttpNameValues);
var
  LCount, LIndex: Integer;
begin
  LCount := ANameValues.Count;
  SetLength(FValues, LCount);
  for LIndex := 0 to LCount - 1 do
    FValues[LIndex] :=
      TTHttpLogNameValue.Create(ANameValues.NameValue[LIndex]);
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

{ TTHttpLogRequest }

constructor TTHttpLogRequest.Create(const ARequest: TTHttpRequest);
begin
  FTaskID := ARequest.TaskID;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);
  FUri := ARequest.ControllerID.Uri;
  FParams := TTHttpLogNameValues.Create(ARequest.Parameters);
  FMethodType := ARequest.ControllerID.Method;
  FContent := ARequest.JSonContent.ToJSon();

  FHeaders := TTHttpLogNameValues.Create(ARequest.Headers);
  FRemoteIP := ARequest.RemoteIP;
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
    LJSon.AddPair('Params', FParams.ToJSonArray());
    LJSon.AddPair('Headers', FHeaders.ToJSonArray());
    LJSon.AddPair('MethodType', FMethodType);
    LJSon.AddPair('Content', TJSonObject.ParseJSONValue(FContent));
    LJSon.AddPair('RemoteIP', FRemoteIP);

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

{ TTHttpLogUser }

constructor TTHttpLogUser.Create(const AUser: TTHttpUser);
begin
  FUsername := AUser.Username;
  FAreas := TTHttpLogUserAreas.Create(AUser.Areas);
end;

function TTHttpLogUser.ToJSon: TJSonObject;
begin
  result := TJSonObject.Create;
  try
    result.AddPair('Username', FUsername);
    result.AddPair('Areas', FAreas.ToJSonArray());
  except
    result.Free;
    raise;
  end;
end;

{ TTHttpLogResponse }

constructor TTHttpLogResponse.Create(
  const AUser: TTHttpUser; const AResponse: TTHttpResponse);
begin
  FTaskID := AResponse.TaskID;
  FDateTime := TTimeZone.Local.ToUniversalTime(Now);;
  FUser := TTHttpLogUser.Create(AUser);
  FStatusCode := AResponse.StatusCode;
  FContentType := AResponse.ContentType;
  FContentEncoding := AResponse.ContentEncoding;
  FIsBinary := AResponse.IsContentStream;
  FContent := AResponse.Content;
  if FIsBinary then
    FBinaryContent := GetBinaryContent(AResponse);
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
    LJSon.AddPair('User', FUser.ToJSon());
    LJSon.AddPair('StatusCode', TJSonNumber.Create(FStatusCode));
    LJSon.AddPair('ContentType', FContentType);
    if FIsBinary then
      LJSon.AddPair('BinaryContent', TJSonString.Create(FBinaryContent))
  else
    begin
      LJSon.AddPair('ContentEncoding', FContentEncoding);
      if FContentType.Equals(TTHttpContentTypes.JSon) then
        LJSon.AddPair('Content', TJSonObject.ParseJSONValue(FContent))
      else
        LJSon.AddPair('Content', FContent);
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

end.
