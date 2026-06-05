(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Dialog.Brand;

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
  Vcl.ExtDlgs,
  Vcl.Mask,

  Trysil.Context,

  Orders.Model.Brand,
  Orders.Dialog.Base;

type

{ TBrandDialog }

  TBrandDialog = class(TDialogBase)
    DescriptionEdit: TLabeledEdit;
  strict private
    FBrand: TBrand;

    class function ShowDialog(
      const AContext: TTContext;
      const ABrand: TBrand;
      const ACaption: String): Boolean; static;
  strict protected
    procedure LoadFromEntity; override;
    procedure SaveToEntity; override;
    procedure ApplyEntity; override;
  public
    class function Insert(
      const AContext: TTContext; const ABrand: TBrand): Boolean;
    class function Edit(
      const AContext: TTContext; const ABrand: TBrand): Boolean;
  end;

implementation

{$R *.dfm}

{ TBrandDialog }

class function TBrandDialog.ShowDialog(
  const AContext: TTContext;
  const ABrand: TBrand;
  const ACaption: String): Boolean;
var
  LDialog: TBrandDialog;
begin
  LDialog := TBrandDialog.Create(AContext);
  try
    LDialog.Caption := ACaption;
    LDialog.FBrand := ABrand;
    result := LDialog.Execute;
  finally
    LDialog.Free;
  end;
end;

class function TBrandDialog.Insert(
  const AContext: TTContext; const ABrand: TBrand): Boolean;
begin
  result := ShowDialog(AContext, ABrand, 'New brand');
end;

class function TBrandDialog.Edit(
  const AContext: TTContext; const ABrand: TBrand): Boolean;
begin
  result := ShowDialog(AContext, ABrand, 'Edit brand');
end;

procedure TBrandDialog.LoadFromEntity;
begin
  DescriptionEdit.Text := FBrand.Description;
end;

procedure TBrandDialog.SaveToEntity;
begin
  FBrand.Description := DescriptionEdit.Text;
end;

procedure TBrandDialog.ApplyEntity;
begin
  Context.Save<TBrand>(FBrand);
end;

end.
