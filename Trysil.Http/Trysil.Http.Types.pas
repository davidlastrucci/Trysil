(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Types;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  IdCustomHttpServer,
  Trysil.Consts,
  Trysil.JSon.Sqids,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions;

type

{$SCOPEDENUMS ON}

{ TTHttpMethodType }

  TTHttpMethodType = (GET, POST, DELETE, PUT, OPTIONS);

{ TTHttpControllerType }

  TTHttpAuthorizationType = (None, Authentication);

{ TTHttpUriParts }

  TTHttpUriParts = record
  strict private
    FParts: TArray<String>;
    FParamsCount: Integer;

    function GetIntegerParam(
      const AParam: String; out AValue: Integer): Boolean;
    function IsParamPartCompatible(
      const AIndex: Integer;
      const AOther: TTHttpUriParts;
      const AParams: TList<Integer>): Boolean;
  public
    constructor Create(const AUri: String);

    function Equals(
      const AOther: TTHttpUriParts; const AParams: TList<Integer>): Boolean;
    function HasParamsOnlyAtTheEnd: Boolean;

    property Parts: TArray<String> read FParts;
    property ParamsCount: Integer read FParamsCount;
  end;

{ TTHttpControllerID }

  TTHttpControllerID = record
  strict private
    FUri: String;
    FCommandType: THttpCommandType;

    function MethodTypeToCommandType(
      const AMethodType: TTHttpMethodType): THttpCommandType;
    function TryGetMethodType(out AMethodType: TTHttpMethodType): Boolean;
    function GetMethodType: TTHttpMethodType;
    function GetMethod: String;
  public
    constructor Create(
      const AUri: String;
      const ACommandType: THttpCommandType); overload;

    constructor Create(
      const AUri: String;
      const AMethodType: TTHttpMethodType); overload;

    function Equals(const AControllerID: TTHttpControllerID): Boolean;

    property Uri: String read FUri;
    property CommandType: THttpCommandType read FCommandType;
    property MethodType: TTHttpMethodType read GetMethodType;
    property Method: String read GetMethod;
  end;

{ TTHttpTaskID }

  TTHttpTaskID = record
  strict private
    FID: String;
    FThreadID: TThreadID;

    class function NewIDValue: String; static;
  public
    class function NewID: TTHttpTaskID; static;

    function ToString: String;

    property ID: String read FID;
    property ThreadID: TThreadID read FThreadID;
  end;

implementation

{ TTHttpUriParts }

constructor TTHttpUriParts.Create(const AUri: String);
var
  LPart: String;
begin
  FParts := AUri.Split(['/']);
  FParamsCount := 0;
  for LPart in FParts do
    if LPart.Equals('?') then
      Inc(FParamsCount);
end;

function TTHttpUriParts.HasParamsOnlyAtTheEnd: Boolean;
var
  LIndex: Integer;
begin
  result := True;
  for LIndex := Low(FParts) to High(FParts) - FParamsCount do
    if FParts[LIndex].Equals('?') then
      result := False;
end;

function TTHttpUriParts.IsParamPartCompatible(
  const AIndex: Integer;
  const AOther: TTHttpUriParts;
  const AParams: TList<Integer>): Boolean;
var
  LParam: Integer;
begin
  result := False;
  if Self.FParts[AIndex].Equals('?') then
    result := GetIntegerParam(AOther.FParts[AIndex], LParam)
  else if AOther.FParts[AIndex].Equals('?') then
    result := GetIntegerParam(Self.FParts[AIndex], LParam);

  if result and Assigned(AParams) then
    AParams.Add(LParam);
end;

function TTHttpUriParts.Equals(
  const AOther: TTHttpUriParts; const AParams: TList<Integer>): Boolean;
var
  LIndex: Integer;
begin
  if Assigned(AParams) then
    AParams.Clear;

  result := (Low(Self.FParts) = Low(AOther.FParts)) and
    (High(Self.FParts) = High(AOther.FParts));
  if result then
    for LIndex := Low(Self.FParts) to High(Self.FParts) do
    begin
      result := (Self.FParts[LIndex].Equals(AOther.FParts[LIndex]));
      if not result then
        result := IsParamPartCompatible(LIndex, AOther, AParams);

      if not result then
      begin
        if Assigned(AParams) then
          AParams.Clear;
        Break;
      end;
    end;
end;

function TTHttpUriParts.GetIntegerParam(
  const AParam: String; out AValue: Integer): Boolean;
begin
  result := TTJSonSqids.Instance.TryDecode(AParam, AValue);
end;

{ TTHttpControllerID }

constructor TTHttpControllerID.Create(
  const AUri: String; const ACommandType: THttpCommandType);
begin
  FUri := AUri.ToLowerInvariant;
  FCommandType := ACommandType;
end;

constructor TTHttpControllerID.Create(
  const AUri: String;
  const AMethodType: TTHttpMethodType);
begin
  FUri := AUri.ToLowerInvariant;
  FCommandType := MethodTypeToCommandType(AMethodType);
end;

function TTHttpControllerID.Equals(const AControllerID: TTHttpControllerID): Boolean;
var
  LSelfParts, LOtherParts: TTHttpUriParts;
begin
  result := Self.FCommandType = AControllerID.FCommandType;
  if result then
  begin
    LSelfParts := TTHttpUriParts.Create(Self.FUri);
    LOtherParts := TTHttpUriParts.Create(AControllerID.FUri);
    result := LSelfParts.Equals(LOtherParts, nil);
  end;
end;

function TTHttpControllerID.MethodTypeToCommandType(
  const AMethodType: TTHttpMethodType): THttpCommandType;
begin
  case AMethodType of
    TTHttpMethodType.GET:
      result := THttpCommandType.hcGET;
    TTHttpMethodType.POST:
      result := THttpCommandType.hcPOST;
    TTHttpMethodType.DELETE:
      result := THttpCommandType.hcDELETE;
    TTHttpMethodType.PUT:
      result := THttpCommandType.hcPUT;
    TTHttpMethodType.OPTIONS:
      result := THttpCommandType.hcOPTION;
    else
      result := THttpCommandType.hcUnknown;
  end;
end;

function TTHttpControllerID.GetMethod: String;
var
  LMethodType: TTHttpMethodType;
begin
  if TryGetMethodType(LMethodType) then
    result := TRttiEnumerationType.GetName<TTHttpMethodType>(LMethodType)
  else
    result := TRttiEnumerationType.GetName<THttpCommandType>(
      FCommandType).Substring(2).ToUpperInvariant;
end;

function TTHttpControllerID.TryGetMethodType(
  out AMethodType: TTHttpMethodType): Boolean;
begin
  result := True;
  case FCommandType of
    THttpCommandType.hcGET:
      AMethodType := TTHttpMethodType.GET;
    THttpCommandType.hcPOST:
      AMethodType := TTHttpMethodType.POST;
    THttpCommandType.hcDELETE:
      AMethodType := TTHttpMethodType.DELETE;
    THttpCommandType.hcPUT:
      AMethodType := TTHttpMethodType.PUT;
    THttpCommandType.hcOPTION:
      AMethodType := TTHttpMethodType.OPTIONS;
    else
      result := False;
  end;
end;

function TTHttpControllerID.GetMethodType: TTHttpMethodType;
begin
  if not TryGetMethodType(result) then
    raise ETHttpMethodNotAllowed.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidCommandType), [
        TRttiEnumerationType.GetName<THttpCommandType>(FCommandType)]);
end;

{ TTHttpTaskID }

class function TTHttpTaskID.NewIDValue: String;
var
  LGuid: TGuid;
  LValue: String;
begin
  LGuid := TGuid.NewGuid();
  LValue := LGuid.ToString();
  result := LValue.Substring(1, LValue.Length - 2).Replace(
    '-', String.Empty, [rfReplaceAll]).ToLower();
end;

class function TTHttpTaskID.NewID: TTHttpTaskID;
begin
  result.FID := TTHttpTaskID.NewIDValue;
  result.FThreadID := TThread.Current.ThreadID;
end;

function TTHttpTaskID.ToString: String;
begin
  result := FID;
end;

end.
