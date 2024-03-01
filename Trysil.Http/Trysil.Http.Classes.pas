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
  System.JSon,
  IdCustomHttpServer,

  Trysil.Http.Consts,
  Trysil.Http.Types;

type

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

  TTHttpHeaders = class(TTHttpNameValues);

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
    FAreas: TTHttpUserAreas;
  public
    constructor Create;
    destructor Destroy; override;

    property Username: String read FUsername write FUsername;
    property Password: String read FPassword write FPassword;
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

    function GetContentText: String;
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
    property Headers: TTHttpHeaders read GetHeaders;
    property RemoteIP: String read GetRemoteIP;
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

    function GetStatusCode: Integer;
    procedure SetStatusCode(const AValue: Integer);
    function GetContentType: String;
    procedure SetContentType(const AValue: String);
    function GetContentEncoding: String;
    procedure SetContentEncoding(const AValue: String);
    procedure SetContent(const AValue: String);
    procedure SetContentStream(const AValue: TMemoryStream);
  public
    constructor Create(
      const ATaskID: TTHttpTaskID; const AResponseInfo: TIdHttpResponseInfo);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure GetContentStream(const AStream: TMemoryStream);

    procedure AddHeader(const AName: String; const AValue: String);

    property TaskID: TTHttpTaskID read FTaskID;
    property StatusCode: Integer read GetStatusCode write SetStatusCode;
    property ContentType: String read GetContentType write SetContentType;
    property ContentEncoding: String
      read GetContentEncoding write SetContentEncoding;
    property IsContentStream: Boolean read FIsContentStream;
    property Content: String read FContent write SetContent;
    property ContentStream: TMemoryStream write SetContentStream;
  end;

implementation

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
  FNameValues := TDictionary<String, String>.Create;
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

{ TTHttpEncoding }

function TTHttpEncoding.AreEquals(
  const ALeftCharSet: String; const ARightCharSet: String): Boolean;
begin
  result := (String.Compare(ALeftCharSet, ARightCharSet, True) = 0);
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
  FItems.Add(AArea.ToLower());
end;

function TTHttpUserAreas.Contains(const AArea: String): Boolean;
begin
  result := FItems.Contains(AArea.ToLower());
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

constructor TTHttpRequest.Create(
  const ATaskID: TTHttpTaskID; const ARequestInfo: TIdHttpRequestInfo);
begin
  inherited Create;
  FTaskID := ATaskID;
  FRequestInfo := ARequestInfo;
  FEncoding := TTHttpEncoding.Create;
  FControllerID := TTHttpControllerID.Create(
    FRequestInfo.Uri, FRequestInfo.CommandType);
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
begin
  if not Assigned(FJSonContent) then
  begin
    FJSonContent := TJSonObject.ParseJSONValue(GetContentText);
    if not Assigned(FJSonContent) then
      FJSonContent := TJSonObject.Create;
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
  end
  else if not FRequestInfo.FormParams.IsEmpty then
    result := FRequestInfo.FormParams
  else if not FRequestInfo.UnparsedParams.IsEmpty then
    result := FRequestInfo.UnparsedParams;
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
  FResponseInfo.Server :=
    'API REST made simple by Trysil Delphi ORM - https://github.com/davidlastrucci/Trysil';
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
  LBytes: TBytes;
begin
  if FIsContentStream then
    AStream.LoadFromStream(FContentStream)
  else
  begin
    AStream.Clear;
    LBytes := FEncoding.GetEncoding(
      FResponseInfo.ContentEncoding).GetBytes(FContent);
    AStream.Write(LBytes, Length(LBytes));
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
  result := FResponseInfo.ContentEncoding;
end;

procedure TTHttpResponse.SetContentEncoding(const AValue: String);
begin
  FResponseInfo.ContentEncoding := AValue;
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

end.
