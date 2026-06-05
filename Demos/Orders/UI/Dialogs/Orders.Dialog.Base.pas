(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Dialog.Base;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Trysil.Context;

type

{ TDialogBase }

  TDialogBase = class(TForm)
    ContentPanel: TPanel;
    ButtonPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    procedure OkButtonClick(Sender: TObject);
  strict private
    FContext: TTContext;
  strict protected
    procedure LoadFromEntity; virtual; abstract;
    procedure SaveToEntity; virtual; abstract;
    procedure ApplyEntity; virtual; abstract;

    function Execute: Boolean;
  public
    constructor Create(const AContext: TTContext); reintroduce; virtual;

    property Context: TTContext read FContext;
  end;

implementation

{$R *.dfm}

{ TDialogBase }

constructor TDialogBase.Create(const AContext: TTContext);
begin
  inherited Create(nil);
  FContext := AContext;
end;

function TDialogBase.Execute: Boolean;
begin
  LoadFromEntity;
  result := (ShowModal = mrOk);
end;

procedure TDialogBase.OkButtonClick(Sender: TObject);
begin
  SaveToEntity;
  ApplyEntity;
  ModalResult := mrOk;
end;

end.
