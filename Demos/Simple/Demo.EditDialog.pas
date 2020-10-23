(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Demo.EditDialog;

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
  Vcl.StdCtrls,
  Trysil.Context,
  Trysil.Generics.Collections,

  Demo.Model;

type

{ TEditDialog }

  TEditDialog = class(TForm)
    IDTextbox: TEdit;
    FirstnameTextbox: TEdit;
    LastnameTextbox: TEdit;
    CompanyTextbox: TEdit;
    EmailTextbox: TEdit;
    PhoneTextbox: TEdit;
    SaveButton: TButton;
    CancelButton: TButton;
  strict private
    FContext: TTContext;
    FList: TTList<TTMasterData>;
    FEntity: TTMasterData;

    procedure BindEntityToControls;
    procedure BindControlsToEntity(const AEntity: TTMasterData);
  public
    constructor Create(
      const AContext: TTContext;
      const AList: TTList<TTMasterData>;
      const AEntity: TTMasterData); reintroduce;

    procedure AfterConstruction; override;

    class function Insert(
      const AContext: TTContext;
      const AList: TTList<TTMasterData>): Boolean;

    class function Edit(
      const AContext: TTContext;
      const AList: TTList<TTMasterData>;
      const AEntity: TTMasterData): Boolean;
  end;

implementation

{$R *.dfm}

{ TEditDialog }

constructor TEditDialog.Create(
  const AContext: TTContext;
  const AList: TTList<TTMasterData>;
  const AEntity: TTMasterData);
begin
  inherited Create(nil);
  FContext := AContext;
  FList := AList;
  FEntity := AEntity;
end;

procedure TEditDialog.AfterConstruction;
begin
  inherited AfterConstruction;
  if Assigned(FEntity) then
    BindEntityToControls;
end;

procedure TEditDialog.BindEntityToControls;
begin
  IDTextbox.Text := FEntity.ID.ToString();
  FirstnameTextbox.Text := FEntity.Firstname;
  LastnameTextbox.Text := FEntity.Lastname;
  CompanyTextbox.Text := FEntity.Company;
  EmailTextbox.Text := FEntity.Email;
  PhoneTextbox.Text := FEntity.Phone;
end;

procedure TEditDialog.BindControlsToEntity(const AEntity: TTMasterData);
begin
  AEntity.Firstname := FirstnameTextbox.Text;
  AEntity.Lastname := LastnameTextbox.Text;
  AEntity.Company := CompanyTextbox.Text;
  AEntity.Email := EmailTextbox.Text;
  AEntity.Phone := PhoneTextbox.Text;
end;

class function TEditDialog.Insert(
  const AContext: TTContext; const AList: TTList<TTMasterData>): Boolean;
var
  LDialog: TEditDialog;
  LEntity: TTMasterData;
begin
  LDialog := TEditDialog.Create(AContext, AList, nil);
  try
    result := (LDialog.ShowModal = mrOk);
    if result then
    begin
      LEntity := AContext.CreateEntity<TTMasterData>();
      LDialog.BindControlsToEntity(LEntity);
      AContext.Insert<TTMasterData>(LEntity);
      AList.Add(LEntity);
    end;
  finally
    LDialog.Free;
  end;
end;

class function TEditDialog.Edit(
  const AContext: TTContext;
  const AList: TTList<TTMasterData>;
  const AEntity: TTMasterData): Boolean;
var
  LDialog: TEditDialog;
begin
  LDialog := TEditDialog.Create(AContext, AList, AEntity);
  try
    result := (LDialog.ShowModal = mrOk);
    if result then
    begin
      LDialog.BindControlsToEntity(AEntity);
      AContext.Update<TTMasterData>(AEntity);
    end;
  finally
    LDialog.Free;
  end;
end;

end.
