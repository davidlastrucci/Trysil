(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Classes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.JSon,
  System.NetEncoding,
  IdCustomHttpServer,

  Trysil.Consts,
  Trysil.Classes,

  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Exceptions;

type

{ TTHttpCappedStream }

  TTHttpCappedStream = class(TMemoryStream)
  strict private
    FMaxSize: Int64;
  strict protected
    function Realloc(var ANewCapacity: NativeInt): Pointer; override;
  public
    constructor Create(const AMaxSize: Int64);

    property MaxSize: Int64 read FMaxSize;
  end;

{ TTHttpNameValue }

  TTHttpNameValue = record
  strict private
    FName: String;
    FValue: String;
  public
    constructor Create(const AName: String; const AValue: String);

    property Name: String read FName;
    property Value: String read FValue;
  end;

{ TTHttpNameValues }

  TTHttpNameValues = class
  strict private
    function GetCount: Integer;
    function GetNameValue(const AIndex: Integer): TTHttpNameValue;
    function GetValue(const AName: String): String;
  strict protected
    FValues: TList<TTHttpNameValue>;
    FNameValues: TDictionary<String, String>;

    function CreateNameValues: TDictionary<String, String>; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddStrings(const AStrings: TStrings);

    property Count: Integer read GetCount;
    property NameValue[const AIndex: Integer]: TTHttpNameValue read GetNameValue;
    property Value[const AName: String]: String read GetValue;
  end;

{ TTHttpParameters }

  TTHttpParameters = class(TTHttpNameValues);

{ TTHttpHeaders }

  TTHttpHeaders = class(TTHttpNameValues)
  strict private
    class var FComparer: IEqualityComparer<String>;

    class constructor ClassCreate;
  strict protected
    function CreateNameValues: TDictionary<String, String>; override;
  end;

{ TTHttpEncoding }

  TTHttpEncoding = class
  strict private
    function AreEquals(
      const ALeftCharSet: String; const ARightCharSet: String): Boolean;
  public
    function GetEncoding(const ACharSet: String): TEncoding;
  end;

{ TTHttpUserAreas }

  TTHttpUserAreas = class
  strict private
    FItems: TList<String>;

    function GetCount: Integer;
    function GetArea(const AIndex: Integer): String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AArea: String);
    function Contains(const AArea: String): Boolean;

    property Count: Integer read GetCount;
    property Area[const AIndex: Integer]: String read GetArea;
  end;

{ TTHttpUser }

  TTHttpUser = class
  strict private
    FUsername: String;
    FPassword: String;
    FTenant: String;
    FAreas: TTHttpUserAreas;
  public
    constructor Create;
    destructor Destroy; override;

    property Username: String read FUsername write FUsername;
    property Password: String read FPassword write FPassword;
    property Tenant: String read FTenant write FTenant;
    property Areas: TTHttpUserAreas read FAreas;
  end;

{ TTHttpRequest }

  TTHttpRequest = class
  strict private
    FTaskID: TTHttpTaskID;
    FRequestInfo: TIdHttpRequestInfo;
    FEncoding: TTHttpEncoding;
    FHost: String;
    FControllerID: TTHttpControllerID;
    FParameters: TTHttpParameters;
    FJSonContent: TJSonValue;
    FHeaders: TTHttpHeaders;
    FUser: TTHttpUser;

    function GetUrlParams: String;
    function GetParameters: TTHttpParameters;
    function GetJSonContent: TJSonValue;
    function GetHeaders: TTHttpHeaders;
    function GetRemoteIP: String;
    function GetClientIP: String;
    function FindHeader(const AName: String): String;
    function IsLoopback(const AValue: String): Boolean;
    function StripPort(const AValue: String): String;

    function HasContent: Boolean;
    function GetContentText: String;
    function GetContentLength: Int64;
    function GetIsMethodOverridden: Boolean;
    function GetMethod: String;
    function GetSentMethod: String;

    class function DecodeUri(const AUri: String): String; static;
  public
    constructor Create(
      const ATaskID: TTHttpTaskID; const ARequestInfo: TIdHttpRequestInfo);
    destructor Destroy; override;

    property TaskID: TTHttpTaskID read FTaskID;
    property Host: String read FHost;
    property ControllerID: TTHttpControllerID read FControllerID;
    property UrlParams: String read GetUrlParams;
    property Parameters: TTHttpParameters read GetParameters;
    property JSonContent: TJSonValue read GetJSonContent;
    property ContentLength: Int64 read GetContentLength;
    property Headers: TTHttpHeaders read GetHeaders;
    property RemoteIP: String read GetRemoteIP;
    property ClientIP: String read GetClientIP;
    property Method: String read GetMethod;
    property SentMethod: String read GetSentMethod;
    property IsMethodOverridden: Boolean read GetIsMethodOverridden;
    property User: TTHttpUser read FUser;
  end;

{ TTHttpResponse }

  TTHttpResponse = class
  strict private
    FTaskID: TTHttpTaskID;
    FResponseInfo: TIdHttpResponseInfo;
    FEncoding: TTHttpEncoding;
    FIsContentStream: Boolean;
    FContent: String;
    FContentStream: TMemoryStream;
    FHeaderMark: Integer;

    class var FServerHeader: String;
    class constructor ClassCreate;

    function GetStatusCode: Integer;
    procedure SetStatusCode(const AValue: Integer);
    function GetContentType: String;
    procedure SetContentType(const AValue: String);
    function GetContentEncoding: String;
    procedure SetContentEncoding(const AValue: String);
    procedure SetContent(const AValue: String);
    procedure SetContentStream(const AValue: TMemoryStream);
    function GetContentLength: Int64;
  public
    constructor Create(
      const ATaskID: TTHttpTaskID; const AResponseInfo: TIdHttpResponseInfo);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure GetContentStream(const AStream: TMemoryStream);

    procedure AddHeader(const AName: String; const AValue: String);
    procedure MarkHeaders;
    procedure ResetToMark;

    class property ServerHeader: String
      read FServerHeader write FServerHeader;

    property TaskID: TTHttpTaskID read FTaskID;
    property StatusCode: Integer read GetStatusCode write SetStatusCode;
    property ContentType: String read GetContentType write SetContentType;
    property ContentEncoding: String
      read GetContentEncoding write SetContentEncoding;
    property IsContentStream: Boolean read FIsContentStream;
    property Content: String read FContent write SetContent;
    property ContentLength: Int64 read GetContentLength;
    property ContentStream: TMemoryStream write SetContentStream;
  end;

implementation

const
  ByteOrderMark = #$FEFF;

{ TTHttpCappedStream }

constructor TTHttpCappedStream.Create(const AMaxSize: Int64);
begin
  inherited Create;
  FMaxSize := AMaxSize;
end;

function TTHttpCappedStream.Realloc(var ANewCapacity: NativeInt): Pointer;
begin
  if ANewCapacity > FMaxSize then
    raise ETHttpContentTooLarge.CreateFmt(
      TTLanguage.Instance.Translate(SContentTooLarge), [
        FMaxSize]);

  result := inherited Realloc(ANewCapacity);
end;

type

{ TTHttpEncodingHelper }

  TTHttpEncodingHelper = class helper for TEncoding
  public
    procedure GetBytesInto(
      const AValue: String;
      const ABuffer: Pointer;
      const AByteCount: Integer);
  end;

{ TTHttpEncodingHelper }

procedure TTHttpEncodingHelper.GetBytesInto(
  const AValue: String;
  const ABuffer: Pointer;
  const AByteCount: Integer);
begin
  GetBytes(PChar(AValue), AValue.Length, PByte(ABuffer), AByteCount);
end;

{ TTHttpNameValue }

constructor TTHttpNameValue.Create(const AName: String; const AValue: String);
begin
  FName := AName;
  FValue := AValue;
end;

{ TTHttpNameValues }

constructor TTHttpNameValues.Create;
begin
  inherited Create;
  FValues := TList<TTHttpNameValue>.Create;
  FNameValues := CreateNameValues;
end;

function TTHttpNameValues.CreateNameValues: TDictionary<String, String>;
begin
  result := TDictionary<String, String>.Create;
end;

destructor TTHttpNameValues.Destroy;
begin
  FNameValues.Free;
  FValues.Free;
  inherited Destroy;
end;

procedure TTHttpNameValues.AddStrings(const AStrings: TStrings);
var
  LIndex: Integer;
  LName: String;
begin
  for LIndex := 0 to AStrings.Count - 1 do
  begin
    LName := AStrings.KeyNames[LIndex];
    if FNameValues.ContainsKey(LName) then
      Continue;
    FValues.Add(TTHttpNameValue.Create(
      LName, AStrings.ValueFromIndex[LIndex]));
    FNameValues.Add(LName, AStrings.ValueFromIndex[LIndex]);
  end;
end;

function TTHttpNameValues.GetCount: Integer;
begin
  result := FValues.Count;
end;

function TTHttpNameValues.GetNameValue(const AIndex: Integer): TTHttpNameValue;
begin
  result := FValues[AIndex];
end;

function TTHttpNameValues.GetValue(const AName: String): String;
begin
  if not FNameValues.TryGetValue(AName, result) then
    result := String.Empty;
end;

{ TTHttpHeaders }

class constructor TTHttpHeaders.ClassCreate;
begin
  FComparer := TTIdentifier.Comparer;
end;

function TTHttpHeaders.CreateNameValues: TDictionary<String, String>;
begin
  result := TDictionary<String, String>.Create(FComparer);
end;

{ TTHttpEncoding }

function TTHttpEncoding.AreEquals(
  const ALeftCharSet: String; const ARightCharSet: String): Boolean;
begin
  result := TTIdentifier.Same(ALeftCharSet, ARightCharSet);
end;

function TTHttpEncoding.GetEncoding(const ACharSet: String): TEncoding;
begin
  result := TEncoding.UTF8;
  if AreEquals(ACharSet, TTHttpContentEncodingTypes.Utf8) then
    result := TEncoding.UTF8
  else if AreEquals(ACharSet, TTHttpContentEncodingTypes.Iso88591) or
    AreEquals(ACharSet, TTHttpContentEncodingTypes.Ansi) then
    result := TEncoding.ANSI
  else if AreEquals(ACharSet, TTHttpContentEncodingTypes.Ascii) then
    result := TEncoding.ASCII;
end;

{ TTHttpUserAreas }

constructor TTHttpUserAreas.Create;
begin
  inherited Create;
  FItems := TList<String>.Create;
end;

destructor TTHttpUserAreas.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TTHttpUserAreas.Add(const AArea: String);
begin
  FItems.Add(AArea.ToLowerInvariant);
end;

function TTHttpUserAreas.Contains(const AArea: String): Boolean;
begin
  result := FItems.Contains(AArea.ToLowerInvariant);
end;

function TTHttpUserAreas.GetCount: Integer;
begin
  result := FItems.Count;
end;

function TTHttpUserAreas.GetArea(const AIndex: Integer): String;
begin
  result := FItems[AIndex];
end;

{ TTHttpUser }

constructor TTHttpUser.Create;
begin
  inherited Create;
  FAreas := TTHttpUserAreas.Create;
end;

destructor TTHttpUser.Destroy;
begin
  FAreas.Free;
  inherited Destroy;
end;

{ TTHttpRequest }

class function TTHttpRequest.DecodeUri(const AUri: String): String;
var
  LParts: TArray<String>;
  LIndex: Integer;
  LDecoded: String;
begin
  LParts := AUri.Split(['/']);
  for LIndex := Low(LParts) to High(LParts) do
  begin
    LDecoded := TNetEncoding.URL.Decode(LParts[LIndex], []);
    if not LDecoded.Contains('/') then
      LParts[LIndex] := LDecoded;
  end;
  result := String.Join('/', LParts);
end;

constructor TTHttpRequest.Create(
  const ATaskID: TTHttpTaskID; const ARequestInfo: TIdHttpRequestInfo);
begin
  inherited Create;
  FTaskID := ATaskID;
  FRequestInfo := ARequestInfo;
  FEncoding := TTHttpEncoding.Create;
  FControllerID := TTHttpControllerID.Create(
    DecodeUri(FRequestInfo.Uri), FRequestInfo.CommandType);
  FHost := FRequestInfo.Host;
  FParameters := nil;
  FJSonContent := nil;
  FHeaders := nil;
  FUser := TTHttpUser.Create;
end;

destructor TTHttpRequest.Destroy;
begin
  FUser.Free;
  if Assigned(FHeaders) then
    FHeaders.Free;
  if Assigned(FJSonContent) then
    FJSonContent.Free;
  if Assigned(FParameters) then
    FParameters.Free;
  FEncoding.Free;
  inherited Destroy;
end;

function TTHttpRequest.GetUrlParams: String;
begin
  result := FRequestInfo.UnparsedParams;
end;

function TTHttpRequest.GetParameters: TTHttpParameters;
begin
  if not Assigned(FParameters) then
  begin
    FParameters := TTHttpParameters.Create;
    FParameters.AddStrings(FRequestInfo.Params);
  end;
  result := FParameters;
end;

function TTHttpRequest.GetJSonContent: TJSonValue;
var
  LContent: String;
begin
  if not Assigned(FJSonContent) then
  begin
    LContent := String.Empty;
    if HasContent then
      LContent := GetContentText;

    if LContent.Trim.IsEmpty then
      FJSonContent := TJSonObject.Create
    else
    begin
      FJSonContent := TJSonObject.ParseJSONValue(LContent);
      if not Assigned(FJSonContent) then
        raise ETHttpBadRequest.Create(
          TTLanguage.Instance.Translate(SNotValidJSonContent));
    end;
  end;
  result := FJSonContent;
end;

function TTHttpRequest.GetHeaders: TTHttpHeaders;
var
  LStrings: TStrings;
begin
  if not Assigned(FHeaders) then
  begin
    FHeaders := TTHttpHeaders.Create;
    LStrings := TStringList.Create;
    try
      FRequestInfo.RawHeaders.ConvertToStdValues(LStrings);
      FHeaders.AddStrings(LStrings);
    finally
      LStrings.Free;
    end;
  end;
  result := FHeaders;
end;

function TTHttpRequest.GetRemoteIP: String;
begin
  result := FRequestInfo.RemoteIP;
end;

function TTHttpRequest.StripPort(const AValue: String): String;
var
  LColon: Integer;
begin
  result := AValue.Trim();
  if result.StartsWith('[') then
  begin
    LColon := result.IndexOf(']');
    if LColon > 0 then
      result := result.Substring(1, LColon - 1);
  end
  else
  begin
    LColon := result.IndexOf(':');
    if (LColon > 0) and (result.IndexOf(':', LColon + 1) < 0) then
      result := result.Substring(0, LColon);
  end;
end;

function TTHttpRequest.FindHeader(const AName: String): String;
begin
  result := GetHeaders.Value[AName].Trim();
end;

function TTHttpRequest.IsLoopback(const AValue: String): Boolean;
var
  LValue: String;
begin
  LValue := AValue.Trim();
  if LValue.StartsWith('::ffff:', True) then
    LValue := LValue.Substring(7);

  result := LValue.StartsWith('127.') or
    LValue.Equals('::1') or
    LValue.Equals('0:0:0:0:0:0:0:1');
end;

function TTHttpRequest.GetClientIP: String;
var
  LForwarded: String;
  LComma: Integer;
begin
  result := GetRemoteIP;

  if IsLoopback(result) then
  begin
    LForwarded := FindHeader('X-Forwarded-For');
    if not LForwarded.IsEmpty then
    begin
      LComma := LForwarded.LastIndexOf(',');
      if LComma >= 0 then
        LForwarded := LForwarded.Substring(LComma + 1);

      LForwarded := StripPort(LForwarded);
      if not LForwarded.IsEmpty then
        result := LForwarded;
    end;
  end;
end;

function TTHttpRequest.HasContent: Boolean;
begin
  result :=
    (Assigned(FRequestInfo.PostStream) and
      (FRequestInfo.PostStream.Size > 0)) or
    (not FRequestInfo.FormParams.IsEmpty);
end;

function TTHttpRequest.GetContentText: String;
var
  LPosition: Int64;
  LBytes: TBytes;
begin
  result := string.Empty;
  if Assigned(FRequestInfo.PostStream) then
  begin
    LPosition := FRequestInfo.PostStream.Position;
    FRequestInfo.PostStream.Position := 0;
    try
      SetLength(LBytes, FRequestInfo.PostStream.Size);
      FRequestInfo.PostStream.Read(LBytes, 0, Length(LBytes));
    finally
      FRequestInfo.PostStream.Position := LPosition;
    end;

    result := FEncoding.GetEncoding(FRequestInfo.CharSet).GetString(LBytes);
    if result.StartsWith(ByteOrderMark) then
      result := result.Substring(1);
  end
  else if not FRequestInfo.FormParams.IsEmpty then
    result := FRequestInfo.FormParams
  else if not FRequestInfo.UnparsedParams.IsEmpty then
    result := FRequestInfo.UnparsedParams;
end;

function TTHttpRequest.GetMethod: String;
begin
  result := FRequestInfo.Command;
end;

function TTHttpRequest.GetSentMethod: String;
var
  LParts: TArray<String>;
begin
  result := String.Empty;
  LParts := FRequestInfo.RawHTTPCommand.Split([' ']);
  if Length(LParts) > 0 then
    result := LParts[0];
end;

function TTHttpRequest.GetIsMethodOverridden: Boolean;
var
  LSentMethod: String;
begin
  LSentMethod := GetSentMethod;
  result := (not LSentMethod.IsEmpty) and
    (not SameText(LSentMethod, FRequestInfo.Command));
end;

function TTHttpRequest.GetContentLength: Int64;
begin
  if Assigned(FRequestInfo.PostStream) then
    result := FRequestInfo.PostStream.Size
  else if not FRequestInfo.FormParams.IsEmpty then
    result := FRequestInfo.FormParams.Length
  else
    result := FRequestInfo.UnparsedParams.Length;
end;

{ TTHttpResponse }

constructor TTHttpResponse.Create(
  const ATaskID: TTHttpTaskID; const AResponseInfo: TIdHttpResponseInfo);
begin
  inherited Create;
  FTaskID := ATaskID;
  FResponseInfo := AResponseInfo;
  FEncoding := TTHttpEncoding.Create;
  FIsContentStream := False;
  FContent := String.Empty;
  FContentStream := TMemoryStream.Create;
  FHeaderMark := -1;
end;

destructor TTHttpResponse.Destroy;
begin
  FContentStream.Free;
  FEncoding.Free;
  inherited Destroy;
end;

procedure TTHttpResponse.AfterConstruction;
begin
  inherited AfterConstruction;
  FResponseInfo.Server := FServerHeader;
end;

class constructor TTHttpResponse.ClassCreate;
begin
  FServerHeader := TTHttpServerHeader.Default;
end;

procedure TTHttpResponse.MarkHeaders;
begin
  FHeaderMark := FResponseInfo.CustomHeaders.Count;
end;

procedure TTHttpResponse.ResetToMark;
begin
  while (FHeaderMark >= 0) and
    (FResponseInfo.CustomHeaders.Count > FHeaderMark) do
    FResponseInfo.CustomHeaders.Delete(
      FResponseInfo.CustomHeaders.Count - 1);

  FResponseInfo.ContentType := TTHttpContentTypes.JSon;
  FResponseInfo.CharSet := TTHttpContentEncodingTypes.Utf8;
  FIsContentStream := False;
end;

procedure TTHttpResponse.AddHeader(const AName, AValue: String);
begin
  if FResponseInfo.CustomHeaders.Values[AName].IsEmpty then
    FResponseInfo.CustomHeaders.AddValue(AName, AValue)
  else
    FResponseInfo.CustomHeaders.Values[AName] := AValue;
end;

procedure TTHttpResponse.GetContentStream(const AStream: TMemoryStream);
var
  LEncoding: TEncoding;
  LByteCount: Integer;
begin
  if FIsContentStream then
    AStream.LoadFromStream(FContentStream)
  else
  begin
    LEncoding := FEncoding.GetEncoding(FResponseInfo.CharSet);
    LByteCount := LEncoding.GetByteCount(FContent);
    AStream.Size := LByteCount;
    if LByteCount > 0 then
      LEncoding.GetBytesInto(FContent, AStream.Memory, LByteCount);
    AStream.Position := 0;
  end;
end;

function TTHttpResponse.GetStatusCode: Integer;
begin
  result := FResponseInfo.ResponseNo;
end;

procedure TTHttpResponse.SetStatusCode(const AValue: Integer);
begin
  FResponseInfo.ResponseNo := AValue;
end;

function TTHttpResponse.GetContentType: String;
begin
  result := FResponseInfo.ContentType;
end;

procedure TTHttpResponse.SetContentType(const AValue: String);
begin
  FResponseInfo.ContentType := AValue;
end;

function TTHttpResponse.GetContentEncoding: String;
begin
  result := FResponseInfo.CharSet;
end;

procedure TTHttpResponse.SetContentEncoding(const AValue: String);
begin
  FResponseInfo.CharSet := AValue;
end;

procedure TTHttpResponse.SetContent(const AValue: String);
begin
  FIsContentStream := False;
  FContent := AValue;
end;

procedure TTHttpResponse.SetContentStream(const AValue: TMemoryStream);
begin
  FIsContentStream := True;
  FContent := String.Empty;
  FContentStream.LoadFromStream(AValue);
end;

function TTHttpResponse.GetContentLength: Int64;
begin
  if FIsContentStream then
    result := FContentStream.Size
  else
    result := FEncoding.GetEncoding(
      FResponseInfo.CharSet).GetByteCount(FContent);
end;

end.
