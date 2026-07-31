(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.JWT.Payload;

interface

uses
  System.SysUtils;

type

{ ETHttpJWTException }

  ETHttpJWTException = class(Exception);

{ TTHttpJWTAbstractPayload }

  TTHttpJWTAbstractPayload = class abstract
  strict protected
    function GetSigningKeyID: String; virtual;
  public
    function Algorithm: String; virtual; abstract;

    function ToJSon: String; virtual; abstract;
    procedure FromJSon(const AContext: String); virtual; abstract;

    function Sign(const ASigningInput: TBytes): TBytes; virtual; abstract;
    function Verify(
      const ASigningInput: TBytes;
      const ASignature: TBytes;
      const AKeyID: String): Boolean; virtual; abstract;

    property SigningKeyID: String read GetSigningKeyID;
  end;

implementation

{ TTHttpJWTAbstractPayload }

function TTHttpJWTAbstractPayload.GetSigningKeyID: String;
begin
  result := String.Empty;
end;

end.
