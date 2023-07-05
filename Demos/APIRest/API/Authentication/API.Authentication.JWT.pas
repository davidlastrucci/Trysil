(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit API.Authentication.JWT;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.JSon,
  System.DateUtils,
  Trysil.Http.Exceptions,
  Trysil.Http.JWT;

type

{ TAPIJWTPayload }

  TAPIJWTPayload = class(TTHttpJWTAbstractPayload)
  strict private
    const Secret: String ='958o77!9#37c9@447€%b142^557d5382B756';
  strict private
    FUsername: String;
    FExpireTime: Int64;
  strict protected
    function GetSecret: String; override;
  public
    function IsValid: Boolean;

    procedure Assign(const APayload: TAPIJWTPayload);
    function ToJSon: String; override;
    procedure FromJSon(const AData: String); override;

    property Username: String read FUsername write FUsername;
    property ExpireTime: Int64 read FExpireTime;
  end;

resourcestring
  NotValidJSon = 'JWT: Payload is not a valid JSon value.';

implementation

{ TAPIJWTPayload }

function TAPIJWTPayload.GetSecret: String;
begin
  result := Secret;
end;

function TAPIJWTPayload.IsValid: Boolean;
var
  LCurrentTime: Int64;
begin
  LCurrentTime := Int64.Parse(FormatDateTime('yyyymmddhhnnss', now));
  result := (FExpireTime > LCurrentTime);
end;

procedure TAPIJWTPayload.Assign(const APayload: TAPIJWTPayload);
begin
  FUsername := APayload.FUsername;
  FExpireTime := APayload.FExpireTime;
end;

procedure TAPIJWTPayload.FromJSon(const AData: String);
var
  LJSon: TJSonValue;
begin
  LJSon := TJSonObject.ParseJSONValue(AData, False, True);
  try
    FUsername := LJSon.GetValue<String>('username', String.Empty);
    FExpireTime := LJSon.GetValue<Int64>('expireTime', 0);
  finally
    LJSon.Free;
  end;
end;

function TAPIJWTPayload.ToJSon: String;
var
  LExpireTime: TDateTime;
  LJSon: TJSonObject;
begin
  LExpireTime := IncMinute(now, 30);
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('username', FUsername);
    LJSon.AddPair('expireTime',
      TJSonNumber.Create(Int64.Parse(
        FormatDateTime('yyyymmddhhnnss', LExpireTime))));

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

end.


