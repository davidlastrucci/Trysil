(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.ManagedFrame;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  Trysil.Context;

type

{ TManagedFrame }

  TManagedFrame = class(TFrame)
  strict private
    FContext: TTContext;
    FParent: TWinControl;
  public
    constructor Create(
      const AContext: TTContext;
      const AParent: TWinControl); reintroduce; virtual;

    procedure AfterConstruction; override;

    property Context: TTContext read FContext;
  end;

implementation

{$R *.dfm}

{ TManagedFrame }

constructor TManagedFrame.Create(
  const AContext: TTContext; const AParent: TWinControl);
begin
  inherited Create(nil);
  FParent := AParent;
  FContext := AContext;
end;

procedure TManagedFrame.AfterConstruction;
begin
  inherited AfterConstruction;
  Parent := FParent;
end;

end.
