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
  Trysil.Consts,

  Trysil.Http.Log.Consts,
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
    procedure WriteDiscarded(
      const ADiscarded: TTHttpLogDiscarded); virtual;
  end;

implementation

{ TTHttpLogAbstractWriter }

procedure TTHttpLogAbstractWriter.WriteDiscarded(
  const ADiscarded: TTHttpLogDiscarded);
begin
  WriteAction(TTHttpLogAction.Create(
    String.Empty,
    Format(TTLanguage.Instance.Translate(SLogQueueDiscarded), [
      ADiscarded.Count, ADiscarded.Host])));
end;

end.
