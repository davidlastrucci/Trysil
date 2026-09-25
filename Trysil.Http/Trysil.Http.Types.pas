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

{ TTHttpBindAddress }

  TTHttpBindAddress = record
  strict private
    const MaxIPv6Groups: Integer = 8;
  strict private
    FAddress: String;
    FIsIPv6: Boolean;

    class function IsOctet(const AOctet: String): Boolean; static;
    class function IsIPv4Address(const AValue: String): Boolean; static;
    class function IsHexGroup(const AGroup: String): Boolean; static;
    class function GroupWidth(
      const AGroup: String; const AAllowIPv4: Boolean): Integer; static;
    class function TryCountGroups(
      const AValue: String;
      const AAllowIPv4: Boolean;
      out ACount: Integer): Boolean; static;
    class function IsCompressedIPv6Address(
      const AValue: String; const AIndex: Integer): Boolean; static;
    class function IsIPv6Address(const AValue: String): Boolean; static;
  public
    constructor Create(const AAddress: String);

    function SameAs(const AOther: TTHttpBindAddress): Boolean;

    property Address: String read FAddress;
    property IsIPv6: Boolean read FIsIPv6;
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

{ TTHttpBindAddress }

constructor TTHttpBindAddress.Create(const AAddress: String);
begin
  FIsIPv6 := IsIPv6Address(AAddress);
  if not (FIsIPv6 or IsIPv4Address(AAddress)) then
    raise ETHttpServerException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidBindAddress), [AAddress]);
  FAddress := AAddress.ToLower();
end;

class function TTHttpBindAddress.IsOctet(const AOctet: String): Boolean;
var
  LChar: Char;
begin
  result := (AOctet.Length >= 1) and (AOctet.Length <= 3) and
    ((AOctet.Length = 1) or (not AOctet.StartsWith('0')));
  for LChar in AOctet do
    result := result and CharInSet(LChar, ['0'..'9']);
  result := result and (AOctet.ToInteger() <= 255);
end;

class function TTHttpBindAddress.IsIPv4Address(const AValue: String): Boolean;
var
  LOctets: TArray<String>;
  LOctet: String;
begin
  LOctets := AValue.Split(['.']);
  result := (Length(LOctets) = 4) and (not AValue.EndsWith('.'));
  for LOctet in LOctets do
    result := result and IsOctet(LOctet);
end;

class function TTHttpBindAddress.IsHexGroup(const AGroup: String): Boolean;
var
  LChar: Char;
begin
  result := (AGroup.Length >= 1) and (AGroup.Length <= 4);
  for LChar in AGroup do
    result := result and CharInSet(LChar, ['0'..'9', 'a'..'f', 'A'..'F']);
end;

class function TTHttpBindAddress.GroupWidth(
  const AGroup: String; const AAllowIPv4: Boolean): Integer;
begin
  result := 0;
  if IsHexGroup(AGroup) then
    result := 1
  else if AAllowIPv4 and IsIPv4Address(AGroup) then
    result := 2;
end;

class function TTHttpBindAddress.TryCountGroups(
  const AValue: String;
  const AAllowIPv4: Boolean;
  out ACount: Integer): Boolean;
var
  LGroups: TArray<String>;
  LIndex: Integer;
  LWidth: Integer;
begin
  ACount := 0;
  result := True;
  if not AValue.IsEmpty then
  begin
    LGroups := AValue.Split([':']);
    result := not AValue.EndsWith(':');
    for LIndex := 0 to High(LGroups) do
    begin
      LWidth := GroupWidth(
        LGroups[LIndex], AAllowIPv4 and (LIndex = High(LGroups)));
      result := result and (LWidth > 0);
      Inc(ACount, LWidth);
    end;
  end;
end;

class function TTHttpBindAddress.IsCompressedIPv6Address(
  const AValue: String; const AIndex: Integer): Boolean;
var
  LHead: String;
  LTail: String;
  LHeadCount: Integer;
  LTailCount: Integer;
begin
  LHead := AValue.Substring(0, AIndex);
  LTail := AValue.Substring(AIndex + 2);
  result := (not LTail.Contains('::')) and
    TryCountGroups(LHead, False, LHeadCount) and
    TryCountGroups(LTail, True, LTailCount) and
    (LHeadCount + LTailCount < MaxIPv6Groups);
end;

class function TTHttpBindAddress.IsIPv6Address(const AValue: String): Boolean;
var
  LIndex: Integer;
  LCount: Integer;
begin
  LIndex := AValue.IndexOf('::');
  if LIndex >= 0 then
    result := IsCompressedIPv6Address(AValue, LIndex)
  else
    result := TryCountGroups(AValue, True, LCount) and
      (LCount = MaxIPv6Groups);
end;

function TTHttpBindAddress.SameAs(const AOther: TTHttpBindAddress): Boolean;
begin
  result := FAddress.Equals(AOther.Address);
end;

end.
