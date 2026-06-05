(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.View.Customer;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ImgList,
  Trysil.Context,
  Trysil.Filter,
  Trysil.Generics.Collections,

  Orders.FrameManager,
  Orders.Model.Customer,
  Orders.Dialog.Customer,
  Orders.View.Base, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type

{ TCustomerListItem }

  TCustomerListItem = class(TListItem)
  strict private
    FCustomer: TCustomer;

    procedure SetCustomer(const AValue: TCustomer);
  public
    property Customer: TCustomer read FCustomer write SetCustomer;
  end;

{ TCustomerView }

  TCustomerView = class(TViewBase)
    FilterPanel: TPanel;
    CityLabel: TLabel;
    CityEdit: TEdit;
    ApplyFilterButton: TSpeedButton;
    ShowDeletedCheck: TCheckBox;
    RestoreButton: TSpeedButton;
    ApplyFilterAction: TAction;
    RestoreAction: TAction;
    procedure ShowDeletedCheckClick(Sender: TObject);
    procedure ApplyFilterActionExecute(Sender: TObject);
    procedure RestoreActionExecute(Sender: TObject);
  strict private
    FList: TTList<TCustomer>;

    function GetSelectedCustomer: TCustomer;

    procedure RestoreItem;
  strict protected
    function GetListItemClass: TListItemClass; override;

    procedure LoadList; override;
    procedure NewItem; override;
    procedure EditItem; override;
    procedure DeleteItem; override;
  public
    constructor Create(
      const AContext: TTContext; const AParent: TWinControl); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TCustomerListItem }

procedure TCustomerListItem.SetCustomer(const AValue: TCustomer);
begin
  FCustomer := AValue;
  if Assigned(FCustomer) then
  begin
    Caption := FCustomer.ID.ToString;
    SubItems.Clear;
    SubItems.Add(FCustomer.CompanyName);
    SubItems.Add(FCustomer.City);
    SubItems.Add(FCustomer.Country);
    SubItems.Add(FCustomer.Email);
  end;
end;

{ TCustomerView }

constructor TCustomerView.Create(
  const AContext: TTContext; const AParent: TWinControl);
begin
  inherited Create(AContext, AParent);
  FList := Context.CreateEntityList<TCustomer>();
end;

destructor TCustomerView.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TCustomerView.GetListItemClass: TListItemClass;
begin
  result := TCustomerListItem;
end;

function TCustomerView.GetSelectedCustomer: TCustomer;
begin
  if Assigned(ListView.Selected) then
    result := TCustomerListItem(ListView.Selected).Customer
  else
    result := nil;
end;

procedure TCustomerView.LoadList;
var
  LBuilder: TTFilterBuilder<TCustomer>;
  LFilter: TTFilter;
  LCity: String;
  LCustomer: TCustomer;
  LItem: TListItem;
  LCustomerListItem: TCustomerListItem absolute LItem;
begin
  LBuilder := Context.CreateFilterBuilder<TCustomer>();
  try
    LCity := Trim(CityEdit.Text);
    if LCity <> '' then
      LBuilder.Where('City').Like(Format('%%%s%%', [LCity]));
    if ShowDeletedCheck.Checked then
      LBuilder.IncludeDeleted;
    LFilter := LBuilder.Build;
  finally
    LBuilder.Free;
  end;

  Context.Select<TCustomer>(FList, LFilter);

  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for LCustomer in FList do
    begin
      LItem := ListView.Items.Add;
      LCustomerListItem.Customer := LCustomer;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TCustomerView.ApplyFilterActionExecute(Sender: TObject);
begin
  LoadList;
end;

procedure TCustomerView.ShowDeletedCheckClick(Sender: TObject);
begin
  RestoreAction.Enabled := ShowDeletedCheck.Checked;
  LoadList;
end;

procedure TCustomerView.RestoreActionExecute(Sender: TObject);
begin
  RestoreItem;
end;

procedure TCustomerView.RestoreItem;
var
  LCustomer: TCustomer;
  LMessage: String;
begin
  LCustomer := GetSelectedCustomer;
  if Assigned(LCustomer) then
  begin
    if LCustomer.DeletedAt.IsNull then
    begin
      LMessage := Format(
        'Customer "%s" is not deleted.', [LCustomer.CompanyName]);
      MessageDlg(LMessage, mtInformation, [mbOK], 0)
    end
    else
    begin
      LMessage := Format('Restore customer "%s"?', [LCustomer.CompanyName]);
      if MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        Context.Undelete<TCustomer>(LCustomer);
        LoadList;
      end;
    end;
  end;
end;

procedure TCustomerView.NewItem;
var
  LCustomer: TCustomer;
begin
  LCustomer := Context.CreateEntity<TCustomer>();
  try
    if TCustomerDialog.Insert(Context, LCustomer) then
      LoadList;
  finally
    Context.FreeEntity<TCustomer>(LCustomer);
  end;
end;

procedure TCustomerView.EditItem;
var
  LCustomer: TCustomer;
begin
  LCustomer := GetSelectedCustomer;
  if Assigned(LCustomer) then
  begin
    Context.Refresh<TCustomer>(LCustomer);
    if TCustomerDialog.Edit(Context, LCustomer) then
      LoadList;
  end;
end;

procedure TCustomerView.DeleteItem;
var
  LCustomer: TCustomer;
  LMsg: String;
begin
  LCustomer := GetSelectedCustomer;
  if Assigned(LCustomer) then
  begin
    LMsg := Format('Delete customer "%s"?', [LCustomer.CompanyName]);
    if MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Context.Delete<TCustomer>(LCustomer);
      LoadList;
    end;
  end;
end;

initialization
  TFrameContainer.Instance.RegisterFrame<TCustomerView>('Customers');

end.
