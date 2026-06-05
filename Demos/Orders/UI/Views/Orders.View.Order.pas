(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.View.Order;

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
  Orders.Model.Order,
  Orders.Dialog.Order,
  Orders.View.Base;

type

{ TOrderListItem }

  TOrderListItem = class(TListItem)
  strict private
    FOrder: TOrder;

    procedure SetOrder(const AValue: TOrder);
  public
    property Order: TOrder read FOrder write SetOrder;
  end;

{ TOrderView }

  TOrderView = class(TViewBase)
  strict private
    FList: TTList<TOrder>;

    function GetSelectedOrder: TOrder;
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

{ TOrderListItem }

procedure TOrderListItem.SetOrder(const AValue: TOrder);
begin
  FOrder := AValue;
  if Assigned(FOrder) then
  begin
    Caption := FOrder.ID.ToString;
    SubItems.Clear;
    SubItems.Add(FormatDateTime('dd/mm/yyyy', FOrder.OrderDate));
    SubItems.Add(FOrder.Customer.CompanyName);
    SubItems.Add(BoolToStr(FOrder.Cashed, True));
  end;
end;

{ TOrderView }

constructor TOrderView.Create(
  const AContext: TTContext; const AParent: TWinControl);
begin
  inherited Create(AContext, AParent);
  FList := Context.CreateEntityList<TOrder>();
end;

destructor TOrderView.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TOrderView.GetListItemClass: TListItemClass;
begin
  result := TOrderListItem;
end;

function TOrderView.GetSelectedOrder: TOrder;
begin
  if Assigned(ListView.Selected) then
    result := TOrderListItem(ListView.Selected).Order
  else
    result := nil;
end;

procedure TOrderView.LoadList;
var
  LOrder: TOrder;
  LItem: TListItem;
  LOrderListItem: TOrderListItem absolute LItem;
begin
  Context.Select<TOrder>(FList, TTFilter.Create('', 0, 'OrderDate DESC'));

  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for LOrder in FList do
    begin
      LItem := ListView.Items.Add;
      LOrderListItem.Order := LOrder;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TOrderView.NewItem;
var
  LOrder: TOrder;
begin
  LOrder := Context.CreateEntity<TOrder>();
  try
    if TOrderDialog.Insert(Context, LOrder) then
      LoadList;
  finally
    Context.FreeEntity<TOrder>(LOrder);
  end;
end;

procedure TOrderView.EditItem;
var
  LOrder: TOrder;
begin
  LOrder := GetSelectedOrder;
  if Assigned(LOrder) then
  begin
    Context.Refresh<TOrder>(LOrder);
    if TOrderDialog.Edit(Context, LOrder) then
      LoadList;
  end;
end;

procedure TOrderView.DeleteItem;
var
  LOrder: TOrder;
  LMsg: String;
begin
  LOrder := GetSelectedOrder;
  if Assigned(LOrder) then
  begin
    LMsg := Format('Delete order #%d?', [LOrder.ID]);
    if MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Context.Delete<TOrder>(LOrder);
      LoadList;
    end;
  end;
end;

initialization
  TFrameContainer.Instance.RegisterFrame<TOrderView>('Orders');

end.
