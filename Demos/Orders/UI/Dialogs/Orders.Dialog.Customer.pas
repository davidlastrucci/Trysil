(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Dialog.Customer;

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
  Vcl.Mask,

  Trysil.Context,

  Orders.Model.Customer,
  Orders.Dialog.Base;

type

{ TCustomerDialog }

  TCustomerDialog = class(TDialogBase)
    CompanyNameEdit: TLabeledEdit;
    AddressEdit: TLabeledEdit;
    CityEdit: TLabeledEdit;
    RegionEdit: TLabeledEdit;
    PostalCodeEdit: TLabeledEdit;
    CountryEdit: TLabeledEdit;
    EmailEdit: TLabeledEdit;
  strict private
    FCustomer: TCustomer;

    class function ShowDialog(
      const AContext: TTContext;
      const ACustomer: TCustomer;
      const ACaption: String): Boolean; static;
  strict protected
    procedure LoadFromEntity; override;
    procedure SaveToEntity; override;
    procedure ApplyEntity; override;
  public
    class function Insert(
      const AContext: TTContext; const ACustomer: TCustomer): Boolean;
    class function Edit(
      const AContext: TTContext; const ACustomer: TCustomer): Boolean;
  end;

implementation

{$R *.dfm}

{ TCustomerDialog }

class function TCustomerDialog.ShowDialog(
  const AContext: TTContext;
  const ACustomer: TCustomer;
  const ACaption: String): Boolean;
var
  LDialog: TCustomerDialog;
begin
  LDialog := TCustomerDialog.Create(AContext);
  try
    LDialog.Caption := ACaption;
    LDialog.FCustomer := ACustomer;
    result := LDialog.Execute;
  finally
    LDialog.Free;
  end;
end;

class function TCustomerDialog.Insert(
  const AContext: TTContext; const ACustomer: TCustomer): Boolean;
begin
  result := ShowDialog(AContext, ACustomer, 'New customer');
end;

class function TCustomerDialog.Edit(
  const AContext: TTContext; const ACustomer: TCustomer): Boolean;
begin
  result := ShowDialog(AContext, ACustomer, 'Edit customer');
end;

procedure TCustomerDialog.LoadFromEntity;
begin
  CompanyNameEdit.Text := FCustomer.CompanyName;
  AddressEdit.Text := FCustomer.Address;
  CityEdit.Text := FCustomer.City;
  RegionEdit.Text := FCustomer.Region;
  PostalCodeEdit.Text := FCustomer.PostalCode;
  CountryEdit.Text := FCustomer.Country;
  EmailEdit.Text := FCustomer.Email;
end;

procedure TCustomerDialog.SaveToEntity;
begin
  FCustomer.CompanyName := CompanyNameEdit.Text;
  FCustomer.Address := AddressEdit.Text;
  FCustomer.City := CityEdit.Text;
  FCustomer.Region := RegionEdit.Text;
  FCustomer.PostalCode := PostalCodeEdit.Text;
  FCustomer.Country := CountryEdit.Text;
  FCustomer.Email := EmailEdit.Text;
end;

procedure TCustomerDialog.ApplyEntity;
begin
  Context.Save<TCustomer>(FCustomer);
end;

end.
