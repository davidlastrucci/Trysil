(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

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
    FAreas: TList<String>;
    FExpireTime: Int64;
  strict protected
    function GetSecret: String; override;
  public
    constructor Create;
    destructor Destroy; override;

    function IsValid: Boolean;

    procedure Assign(const APayload: TAPIJWTPayload);
    function ToJSon: String; override;
    procedure FromJSon(const AData: String); override;

    property Username: String read FUsername write FUsername;
    property Areas: TList<String> read FAreas;
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
var
  LArea: String;
begin
  FUsername := APayload.FUsername;

  FAreas.Clear;
  for LArea in APayload.Areas do
    FAreas.Add(LArea);

  FExpireTime := APayload.FExpireTime;
end;

constructor TAPIJWTPayload.Create;
begin
  inherited Create;
  FAreas := TList<String>.Create;
end;

destructor TAPIJWTPayload.Destroy;
begin
  FAreas.Free;
  inherited Destroy;
end;

procedure TAPIJWTPayload.FromJSon(const AData: String);
var
  LJSon, LArea: TJSonValue;
  LAreas: TJSonArray;
begin
  LJSon := TJSonObject.ParseJSONValue(AData, False, True);
  try
    FUsername := LJSon.GetValue<String>('username', String.Empty);

    FAreas.Clear;
    LAreas := LJSon.GetValue<TJSonArray>('areas', nil);
    if Assigned(LAreas) then
      for LArea in LAreas do
        if LArea is TJSonString then
          FAreas.Add(TJSonString(LArea).Value);

    FExpireTime := LJSon.GetValue<Int64>('expireTime', 0);
  finally
    LJSon.Free;
  end;
end;

function TAPIJWTPayload.ToJSon: String;
var
  LExpireTime: TDateTime;
  LJSon: TJSonObject;
  LAreas: TJSonArray;
  LArea: String;
begin
  LExpireTime := IncMinute(now, 30);
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('username', FUsername);

    LAreas := TJSonArray.Create;
    try
      for LArea in FAreas do
        LAreas.AddElement(TJSonString.Create(LArea));

      LJSon.AddPair('areas', LAreas);
    except
      LAreas.Free;
      raise;
    end;

    LJSon.AddPair('expireTime',
      TJSonNumber.Create(Int64.Parse(
        FormatDateTime('yyyymmddhhnnss', LExpireTime))));

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

end.


