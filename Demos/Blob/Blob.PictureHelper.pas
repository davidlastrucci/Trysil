(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Blob.PictureHelper;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics;

type

{ TPictureHelper }

  TPictureHelper = class helper for TPicture
  public
    procedure LoadFromBytes(const AValue: TBytes);
  end;

implementation

{ TPictureHelper }

procedure TPictureHelper.LoadFromBytes(const AValue: TBytes);
var
  LStream: TMemoryStream;
begin
  LStream := TMemoryStream.Create;
  try
    LStream.Write(AValue, Length(AValue));
    LStream.Position := 0;
    Self.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

end.
