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
  Trysil.JSon.Context,

  API.Config;

type

{ TAPIContext }

  TAPIContext = class
  strict private
    FConnection: TTConnection;
    FContext: TTJSonContext;
  public
    constructor Create;
    destructor Destroy; override;

    property Context: TTJSonContext read FContext;
  end;

implementation

{ TAPIContext }

constructor TAPIContext.Create;
begin
  inherited Create;
  FConnection := TTSqlServerConnection.Create(
    TAPIConfig.Instance.Database.ConnectionName);
  FContext := TTJSonContext.Create(FConnection);
end;

destructor TAPIContext.Destroy;
begin
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;

end.

