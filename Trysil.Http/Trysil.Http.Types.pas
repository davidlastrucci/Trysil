﻿(*

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
      const AIndex: Integer;
      const AParam: String;
      out AValue: Integer): Boolean;
  public
    constructor Create(const AUri: String);

    function Equals(
      const AOther: TTHttpUriParts; const AParams: TList<Integer>): Boolean;

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
    property MethodType: TTHttpMethodType read GetMethodType;
    property Method: String read GetMethod;
  end;

{ TTHttpTaskID }

  TTHttpTaskID = record
  strict private
    FID: String;
    FThreadID: TThreadID;
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

function TTHttpUriParts.Equals(
  const AOther: TTHttpUriParts; const AParams: TList<Integer>): Boolean;
var
  LParamIndex, LIndex: Integer;
  LParam: Integer;
begin
  if Assigned(AParams) then
    AParams.Clear;
  LParamIndex := 0;
  result := (Low(Self.FParts) = Low(AOther.FParts)) and
    (High(Self.FParts) = High(AOther.FParts));
  if result then
    for LIndex := Low(Self.FParts) to High(Self.FParts) do
    begin
      result := (Self.FParts[LIndex].Equals(AOther.FParts[LIndex]));
      if not result then
      begin
        if Self.FParts[LIndex].Equals('?') then
          result := GetIntegerParam(LParamIndex, AOther.FParts[LIndex], LParam)
        else if AOther.FParts[LIndex].Equals('?') then
          result := GetIntegerParam(LParamIndex, Self.FParts[LIndex], LParam);
        if result and Assigned(AParams) then
          AParams.Add(LParam);

        Inc(LParamIndex);
      end;
      if not result then
        Break;
    end;
end;

function TTHttpUriParts.GetIntegerParam(
  const AIndex: Integer; const AParam: String; out AValue: Integer): Boolean;
begin
  if (AIndex = 0) and TTJSonSqids.Instance.UseSqids then
    result := TTJSonSqids.Instance.TryDecode(AParam, AValue)
  else
    result := Integer.TryParse(AParam, AValue);
end;

{ TTHttpControllerID }

constructor TTHttpControllerID.Create(
  const AUri: String; const ACommandType: THttpCommandType);
begin
  FUri := AUri.ToLower();
  FCommandType := ACommandType;
end;

constructor TTHttpControllerID.Create(
  const AUri: String;
  const AMethodType: TTHttpMethodType);
begin
  FUri := AUri.ToLower();
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
begin
  result := TRttiEnumerationType.GetName<TTHttpMethodType>(MethodType);
end;

function TTHttpControllerID.GetMethodType: TTHttpMethodType;
begin
  case FCommandType of
    THttpCommandType.hcGET:
      result := TTHttpMethodType.GET;
    THttpCommandType.hcPOST:
      result := TTHttpMethodType.POST;
    THttpCommandType.hcDELETE:
      result := TTHttpMethodType.DELETE;
    THttpCommandType.hcPUT:
      result := TTHttpMethodType.PUT;
    THttpCommandType.hcOPTION:
      result := TTHttpMethodType.OPTIONS;
    else
      raise ETHttpServerException.CreateFmt(SNotValidCommandType, [
        TRttiEnumerationType.GetName<THttpCommandType>(FCommandType)]);
  end;
end;

{ TTHttpTaskID }

class function TTHttpTaskID.NewID: TTHttpTaskID;
begin
  result.FID := FormatDateTime('yyyymmddhhnnsszzzz', Now());
  result.FThreadID := TThread.Current.ThreadID;
end;

function TTHttpTaskID.ToString: String;
begin
  result := Format('%s-%d', [FID, FThreadID]);
end;

end.
