(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Context;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Data,
  Trysil.Data.FireDAC.SqlServer,
  Trysil.Http.Context,

  API.Config;

type

{ TAPIContext }

  TAPIContext = class
  strict private
    FConnection: TTConnection;
    FContext: TTHttpContext;
  public
    constructor Create;
    destructor Destroy; override;

    property Context: TTHttpContext read FContext;
  end;

implementation

{ TAPIContext }

constructor TAPIContext.Create;
begin
  inherited Create;
  FConnection := TTSqlServerConnection.Create(
    TAPIConfig.Instance.Database.ConnectionName);
  FContext := TTHttpContext.Create(FConnection);
end;

destructor TAPIContext.Destroy;
begin
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;

end.

