(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Log.Writer;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Http.Log.Types;

type

{ TTHttpLogAbstractWriter }

  TTHttpLogAbstractWriter = class abstract
  public
    procedure WriteAction(const AAction: TTHttpLogAction); virtual; abstract;
    procedure WriteRequest(
      const ALogRequest: TTHttpLogRequest); virtual; abstract;
    procedure WriteResponse(
      const ALogResponse: TTHttpLogResponse); virtual; abstract;
  end;

implementation

end.
