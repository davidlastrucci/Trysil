(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.ConnectionPool;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.UI.Intf,
  FireDAC.Comp.Client,

  Trysil.Data.FireDAC.Common;

type

{ TTFireDACConnectionPool }

  TTFireDACConnectionPool = class
  strict private
    class var FInstance: TTFireDACConnectionPool;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TTFireDACConnectionPool; static;
  strict private
    FManager: TFDManager;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RegisterConnection(
      const AName: String; const ADriver: String; const AParameters: TStrings);

    class property Instance: TTFireDACConnectionPool read GetInstance;
  end;

implementation

{ TTFireDACConnectionPool }

class constructor TTFireDACConnectionPool.ClassCreate;
begin
  FInstance := nil;
end;

class destructor TTFireDACConnectionPool.ClassDestroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TTFireDACConnectionPool.GetInstance:
  TTFireDACConnectionPool;
begin
  if not Assigned(FInstance) then
    FInstance := TTFireDACConnectionPool.Create;
  result := FInstance;
end;

constructor TTFireDACConnectionPool.Create;
begin
  inherited Create;
  FManager := TFDManager.Create(nil);
end;

destructor TTFireDACConnectionPool.Destroy;
begin
  FManager.Free;
  inherited Destroy;
end;

procedure TTFireDACConnectionPool.AfterConstruction;
begin
  inherited AfterConstruction;
  FManager.WaitCursor := TFDGUIxScreenCursor.gcrNone;
  FManager.Open;
end;

procedure TTFireDACConnectionPool.RegisterConnection(
  const AName: String;
  const ADriver: String;
  const AParameters: TStrings);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add('Pooled=True');
    LParameters.Add(Format('DriverID=%s', [ADriver]));

    LParameters.AddStrings(AParameters);

    FManager.AddConnectionDef(AName, ADriver, LParameters);
  finally
    LParameters.Free;
  end;
end;

end.
