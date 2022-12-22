(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.Resolver;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Validation,
  Trysil.Resolver;

type

{ TTHttpResolver }

  TTHttpResolver = class(TTResolver)
  strict protected
    function GetValidationErrorMessage(
      const AErrors: TTValidationErrors): String; override;
  end;

implementation

{ TTHttpResolver }

function TTHttpResolver.GetValidationErrorMessage(
  const AErrors: TTValidationErrors): String;
begin
  result := AErrors.ToJSon();
end;

end.
