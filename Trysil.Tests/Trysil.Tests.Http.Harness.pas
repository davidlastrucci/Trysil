(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Harness;

interface

uses
  System.SysUtils,
  System.Classes,
  IdCustomHTTPServer,

  Trysil.Http.Types,
  Trysil.Http.Classes;

type

{ TTestHttpRequestInfo }

  TTestHttpRequestInfo = class(TIdHTTPRequestInfo)
  public
    constructor Create; reintroduce;

    procedure SetRoute(
      const AUri: String; const ACommandType: THTTPCommandType);
    procedure SetContent(const AContent: String);
    procedure SetQueryString(const AValue: String);
    procedure SetSentMethod(const AValue: String);
    procedure SetHeader(const AName: String; const AValue: String);
  end;

{ TTestHttpMessage }

  TTestHttpMessage = class
  strict private
    FRequestInfo: TTestHttpRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
    FRequest: TTHttpRequest;
    FResponse: TTHttpResponse;
  public
    constructor Create(
      const AUri: String;
      const ACommandType: THTTPCommandType;
      const AContent: String); overload;
    constructor Create(
      const AUri: String;
      const ACommandType: THTTPCommandType;
      const AContent: String;
      const ASentMethod: String); overload;
    destructor Destroy; override;

    procedure SetRequestHeader(
      const AName: String; const AValue: String);
    procedure SetQueryString(const AValue: String);

    property Request: TTHttpRequest read FRequest;
    property Response: TTHttpResponse read FResponse;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo;
  end;

implementation

{ TTestHttpRequestInfo }

constructor TTestHttpRequestInfo.Create;
begin
  inherited Create(nil);
  CharSet := 'utf-8';
  ContentType := 'application/json';
end;

procedure TTestHttpRequestInfo.SetRoute(
  const AUri: String; const ACommandType: THTTPCommandType);
begin
  FURI := AUri;
  FDocument := AUri;
  FCommandType := ACommandType;
  FRemoteIP := '127.0.0.1';
  FCommand := TTHttpControllerID.Create(AUri, ACommandType).Method;
  FRawHTTPCommand := Format('%0:s %1:s HTTP/1.1', [FCommand, AUri]);
end;

procedure TTestHttpRequestInfo.SetQueryString(const AValue: String);
begin
  if Assigned(FPostStream) then
    FreeAndNil(FPostStream);
  UnparsedParams := AValue;
  DecodeAndSetParams(AValue);
end;

procedure TTestHttpRequestInfo.SetSentMethod(const AValue: String);
begin
  FRawHTTPCommand := Format('%0:s %1:s HTTP/1.1', [AValue, FURI]);
end;

procedure TTestHttpRequestInfo.SetHeader(
  const AName: String; const AValue: String);
begin
  RawHeaders.Values[AName] := AValue;
end;

procedure TTestHttpRequestInfo.SetContent(const AContent: String);
begin
  if Assigned(FPostStream) then
    FPostStream.Free;
  FPostStream := TStringStream.Create(AContent, TEncoding.UTF8);
end;

{ TTestHttpMessage }

constructor TTestHttpMessage.Create(
  const AUri: String;
  const ACommandType: THTTPCommandType;
  const AContent: String);
begin
  Create(AUri, ACommandType, AContent, String.Empty);
end;

constructor TTestHttpMessage.Create(
  const AUri: String;
  const ACommandType: THTTPCommandType;
  const AContent: String;
  const ASentMethod: String);
var
  LTaskID: TTHttpTaskID;
begin
  inherited Create;
  FRequestInfo := nil;
  FResponseInfo := nil;
  FRequest := nil;
  FResponse := nil;

  LTaskID := TTHttpTaskID.NewID;
  FRequestInfo := TTestHttpRequestInfo.Create;
  FRequestInfo.SetRoute(AUri, ACommandType);
  FRequestInfo.SetContent(AContent);
  if not ASentMethod.IsEmpty then
    FRequestInfo.SetSentMethod(ASentMethod);

  FResponseInfo := TIdHTTPResponseInfo.Create(nil, FRequestInfo, nil);
  FResponseInfo.CharSet := 'utf-8';
  FResponseInfo.ContentType := 'application/json';

  FRequest := TTHttpRequest.Create(LTaskID, FRequestInfo);
  FResponse := TTHttpResponse.Create(LTaskID, FResponseInfo);
end;

procedure TTestHttpMessage.SetRequestHeader(
  const AName: String; const AValue: String);
begin
  FRequestInfo.SetHeader(AName, AValue);
end;

procedure TTestHttpMessage.SetQueryString(const AValue: String);
begin
  FRequestInfo.SetQueryString(AValue);
end;

destructor TTestHttpMessage.Destroy;
begin
  if Assigned(FResponse) then
    FResponse.Free;
  if Assigned(FRequest) then
    FRequest.Free;
  if Assigned(FResponseInfo) then
    FResponseInfo.Free;
  if Assigned(FRequestInfo) then
    FRequestInfo.Free;
  inherited Destroy;
end;

end.
