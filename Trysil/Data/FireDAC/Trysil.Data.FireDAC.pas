(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.UI.Intf,
  FireDAC.Comp.Client,

  Trysil.Data.FireDAC.Common;

type

{ TTDataFireDACConnectionPool }

  TTDataFireDACConnectionPool = class
  strict private
    class var FInstance: TTDataFireDACConnectionPool;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FManager: TFDManager;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RegisterConnection(
      const AName: String;
      const ADriver: String;
      const AParameters: TStrings);

    class property Instance: TTDataFireDACConnectionPool read FInstance;
  end;

implementation

{ TTDataFireDACConnectionPool }

class constructor TTDataFireDACConnectionPool.ClassCreate;
begin
  FInstance := TTDataFireDACConnectionPool.Create;
end;

class destructor TTDataFireDACConnectionPool.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTDataFireDACConnectionPool.Create;
begin
  inherited Create;
  FManager := TFDManager.Create(nil);
end;

destructor TTDataFireDACConnectionPool.Destroy;
begin
  FManager.Free;
  inherited Destroy;
end;

procedure TTDataFireDACConnectionPool.AfterConstruction;
begin
  inherited AfterConstruction;
  FManager.WaitCursor := TFDGUIxScreenCursor.gcrNone;
  FManager.Open;
end;

procedure TTDataFireDACConnectionPool.RegisterConnection(
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
