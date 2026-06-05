(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Dialog.Order;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.ImageList,
  System.Actions,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.ImageCollection,
  Vcl.VirtualImageList,
  Vcl.ActnList,
  Trysil.Context,
  Trysil.Filter,
  Trysil.Session,
  Trysil.Transaction,
  Trysil.Generics.Collections,

  Orders.Model.Customer,
  Orders.Model.Order,
  Orders.Model.OrderDetail,
  Orders.Dialog.Base,
  Orders.Dialog.OrderDetail, Vcl.Buttons, Vcl.BaseImageCollection;

type

{ TOrderDetailListItem }

  TOrderDetailListItem = class(TListItem)
  strict private
    FDetail: TOrderDetail;

    procedure SetDetail(const AValue: TOrderDetail);
  public
    property Detail: TOrderDetail read FDetail write SetDetail;
  end;

{ TOrderDialog }

  TOrderDialog = class(TDialogBase)
    OrderDateLabel: TLabel;
    OrderDatePicker: TDateTimePicker;
    CustomerLabel: TLabel;
    CustomerCombo: TComboBox;
    CashedCheck: TCheckBox;
    DetailsLabel: TLabel;
    DetailListView: TListView;
    IconCollection: TImageCollection;
    ImageList: TVirtualImageList;
    ActionList: TActionList;
    NewAction: TAction;
    EditAction: TAction;
    DeleteAction: TAction;
    ToolbarPanel: TPanel;
    NewButton: TSpeedButton;
    EditButton: TSpeedButton;
    DeleteButton: TSpeedButton;
    procedure DetailListViewDblClick(Sender: TObject);
    procedure DetailListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure NewActionExecute(Sender: TObject);
    procedure EditActionExecute(Sender: TObject);
    procedure DeleteActionExecute(Sender: TObject);
  strict private
    FOrder: TOrder;
    FCustomers: TTList<TCustomer>;
    FSession: TTSession<TOrderDetail>;

    procedure FillCustomerCombo;
    function FindCustomerIndex(const ACustomer: TCustomer): Integer;

    procedure LoadDetailList;
    function GetSelectedDetail: TOrderDetail;

    class function ShowDialog(
      const AContext: TTContext;
      const AOrder: TOrder;
      const ACaption: String): Boolean; static;
  strict protected
    procedure LoadFromEntity; override;
    procedure SaveToEntity; override;
    procedure ApplyEntity; override;
  public
    constructor Create(
      const AContext: TTContext; const AOrder: TOrder); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function Insert(
      const AContext: TTContext; const AOrder: TOrder): Boolean;
    class function Edit(
      const AContext: TTContext; const AOrder: TOrder): Boolean;
  end;

implementation

{$R *.dfm}

{ TOrderDetailListItem }

procedure TOrderDetailListItem.SetDetail(const AValue: TOrderDetail);
begin
  FDetail := AValue;
  if Assigned(FDetail) then
  begin
    Caption := FDetail.ID.ToString;
    SubItems.Clear;
    SubItems.Add(FDetail.Product.Description);
    SubItems.Add(Format('%g', [FDetail.Quantity]));
    SubItems.Add(Format('%.2f', [FDetail.Price]));
    SubItems.Add(Format('%.2f', [FDetail.Amount]));
  end;
end;

{ TOrderDialog }

constructor TOrderDialog.Create(
  const AContext: TTContext; const AOrder: TOrder);
begin
  inherited Create(AContext);
  FOrder := AOrder;
  FCustomers := Context.CreateEntityList<TCustomer>();
  FSession := Context.CreateSession<TOrderDetail>(FOrder.Detail);
end;

destructor TOrderDialog.Destroy;
begin
  FSession.Free;
  FCustomers.Free;
  inherited Destroy;
end;

procedure TOrderDialog.AfterConstruction;
begin
  inherited AfterConstruction;
  FillCustomerCombo;
end;

procedure TOrderDialog.FillCustomerCombo;
var
  LCustomer: TCustomer;
begin
  Context.Select<TCustomer>(FCustomers, TTFilter.Create('', 0, 'CompanyName'));

  CustomerCombo.Items.BeginUpdate;
  try
    CustomerCombo.Items.Clear;
    for LCustomer in FCustomers do
      CustomerCombo.Items.AddObject(LCustomer.CompanyName, LCustomer);
  finally
    CustomerCombo.Items.EndUpdate;
  end;
end;

function TOrderDialog.FindCustomerIndex(const ACustomer: TCustomer): Integer;
var
  LIndex: Integer;
begin
  result := -1;
  if Assigned(ACustomer) then
    for LIndex := 0 to CustomerCombo.Items.Count - 1 do
      if CustomerCombo.Items.Objects[LIndex] = ACustomer then
      begin
        result := LIndex;
        Break;
      end;
end;

class function TOrderDialog.ShowDialog(
  const AContext: TTContext;
  const AOrder: TOrder;
  const ACaption: String): Boolean;
var
  LDialog: TOrderDialog;
begin
  LDialog := TOrderDialog.Create(AContext, AOrder);
  try
    LDialog.Caption := ACaption;
    result := LDialog.Execute;
  finally
    LDialog.Free;
  end;
end;

class function TOrderDialog.Insert(
  const AContext: TTContext; const AOrder: TOrder): Boolean;
begin
  result := ShowDialog(AContext, AOrder, 'New order');
end;

class function TOrderDialog.Edit(
  const AContext: TTContext; const AOrder: TOrder): Boolean;
begin
  result := ShowDialog(AContext, AOrder, 'Edit order');
end;

procedure TOrderDialog.LoadFromEntity;
begin
  OrderDatePicker.Date := FOrder.OrderDate;
  CustomerCombo.ItemIndex := FindCustomerIndex(FOrder.Customer);
  CashedCheck.Checked := FOrder.Cashed;
  LoadDetailList;
end;

procedure TOrderDialog.SaveToEntity;
begin
  FOrder.OrderDate := OrderDatePicker.Date;
  if CustomerCombo.ItemIndex >= 0 then
    FOrder.Customer := TCustomer(CustomerCombo.Items.Objects[CustomerCombo.ItemIndex])
  else
    FOrder.Customer := nil;
  FOrder.Cashed := CashedCheck.Checked;
end;

procedure TOrderDialog.ApplyEntity;
var
  LTransaction: TTTransaction;
begin
  LTransaction := Context.CreateTransaction;
  try
    try
      Context.Save<TOrder>(FOrder);
      FSession.ApplyChanges;
    except
      LTransaction.Rollback;
      raise;
    end;
  finally
    LTransaction.Free;
  end;
end;

procedure TOrderDialog.LoadDetailList;
var
  LDetail: TOrderDetail;
  LItem: TListItem;
  LDetailListItem: TOrderDetailListItem absolute LItem;
begin
  DetailListView.Items.BeginUpdate;
  try
    DetailListView.Items.Clear;
    for LDetail in FSession.Entities do
    begin
      LItem := DetailListView.Items.Add;
      LDetailListItem.Detail := LDetail;
    end;
  finally
    DetailListView.Items.EndUpdate;
  end;
end;

function TOrderDialog.GetSelectedDetail: TOrderDetail;
begin
  if Assigned(DetailListView.Selected) then
    result := TOrderDetailListItem(DetailListView.Selected).Detail
  else
    result := nil;
end;

procedure TOrderDialog.DetailListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TOrderDetailListItem;
end;

procedure TOrderDialog.NewActionExecute(Sender: TObject);
var
  LDetail: TOrderDetail;
begin
  LDetail := Context.CreateEntity<TOrderDetail>();
  try
    LDetail.OrderID := FOrder.ID;
    if TOrderDetailDialog.Insert(Context, LDetail, FSession) then
      LoadDetailList
    else
      Context.FreeEntity<TOrderDetail>(LDetail);
  except
    Context.FreeEntity<TOrderDetail>(LDetail);
    raise;
  end;
end;

procedure TOrderDialog.EditActionExecute(Sender: TObject);
var
  LDetail: TOrderDetail;
begin
  LDetail := GetSelectedDetail;
  if Assigned(LDetail) then
    if TOrderDetailDialog.Edit(Context, LDetail, FSession) then
      LoadDetailList;
end;

procedure TOrderDialog.DeleteActionExecute(Sender: TObject);
var
  LDetail: TOrderDetail;
  LMsg: String;
begin
  LDetail := GetSelectedDetail;
  if Assigned(LDetail) then
  begin
    LMsg := Format('Delete detail "%s"?', [LDetail.Product.Description]);
    if MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FSession.Delete(LDetail);
      LoadDetailList;
    end;
  end;
end;

procedure TOrderDialog.DetailListViewDblClick(Sender: TObject);
begin
  if EditAction.Enabled then
    EditAction.Execute;
end;

end.
