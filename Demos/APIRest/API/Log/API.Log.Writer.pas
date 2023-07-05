(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Log.Writer;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Writer,

  API.Context,
  API.Log.Model;

type

{ TAPILogWriter }

  TAPILogWriter = class(TTHttpLogAbstractWriter)
  strict private
    FContext: TAPIContext;
  public
    constructor Create;
    destructor Destroy; override;

    procedure WriteAction(const AAction: TTHttpLogAction); override;
    procedure WriteRequest(const ARequest: TTHttpLogRequest); override;
    procedure WriteResponse(const AResponse: TTHttpLogResponse); override;
  end;

implementation

{ TAPILogWriter }

constructor TAPILogWriter.Create;
begin
  inherited Create;
  FContext := TAPIContext.Create;
end;

destructor TAPILogWriter.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

procedure TAPILogWriter.WriteAction(const AAction: TTHttpLogAction);
var
  LLogAction: TLogAction;
begin
  LLogAction := FContext.Context.CreateEntity<TLogAction>();
  try
    LLogAction.SetValues(AAction);
    FContext.Context.Insert<TLogAction>(LLogAction);
  finally
    LLogAction.Free;
  end;
end;

procedure TAPILogWriter.WriteRequest(const ARequest: TTHttpLogRequest);
var
  LLogRequest: TLogRequest;
begin
  LLogRequest := FContext.Context.CreateEntity<TLogRequest>();
  try
    LLogRequest.SetValues(ARequest);
    FContext.Context.Insert<TLogRequest>(LLogRequest);
  finally
    LLogRequest.Free;
  end;
end;

procedure TAPILogWriter.WriteResponse(const AResponse: TTHttpLogResponse);
var
  LLogResponse: TLogResponse;
begin
  LLogResponse := FContext.Context.CreateEntity<TLogResponse>();
  try
    LLogResponse.SetValues(AResponse);
    FContext.Context.Insert<TLogResponse>(LLogResponse);
  finally
    LLogResponse.Free;
  end;
end;

end.
