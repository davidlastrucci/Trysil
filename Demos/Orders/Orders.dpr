(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
program Orders;

uses
  Vcl.Forms,
  Orders.Config in 'Classes\Orders.Config.pas',
  Orders.FrameManager in 'Classes\Orders.FrameManager.pas',
  Orders.Model.Brand in 'Model\Orders.Model.Brand.pas',
  Orders.Model.Customer in 'Model\Orders.Model.Customer.pas',
  Orders.Model.Order in 'Model\Orders.Model.Order.pas',
  Orders.Model.OrderDetail in 'Model\Orders.Model.OrderDetail.pas',
  Orders.Model.Product in 'Model\Orders.Model.Product.pas',
  Orders.Model.ProductsTodo in 'Model\Orders.Model.ProductsTodo.pas',
  Orders.View.Base in 'UI\Views\Orders.View.Base.pas' {ViewBase: TFrame},
  Orders.View.Brand in 'UI\Views\Orders.View.Brand.pas' {BrandView: TFrame},
  Orders.View.Customer in 'UI\Views\Orders.View.Customer.pas' {CustomerView: TFrame},
  Orders.View.Order in 'UI\Views\Orders.View.Order.pas' {OrderView: TFrame},
  Orders.View.Product in 'UI\Views\Orders.View.Product.pas' {ProductView: TFrame},
  Orders.Dialog.Base in 'UI\Dialogs\Orders.Dialog.Base.pas' {DialogBase},
  Orders.Dialog.Brand in 'UI\Dialogs\Orders.Dialog.Brand.pas' {BrandDialog},
  Orders.Dialog.Customer in 'UI\Dialogs\Orders.Dialog.Customer.pas' {CustomerDialog},
  Orders.Dialog.Order in 'UI\Dialogs\Orders.Dialog.Order.pas' {OrderDialog},
  Orders.Dialog.OrderDetail in 'UI\Dialogs\Orders.Dialog.OrderDetail.pas' {OrderDetailDialog},
  Orders.Dialog.Product in 'UI\Dialogs\Orders.Dialog.Product.pas' {ProductDialog},
  Orders.MainForm in 'UI\Orders.MainForm.pas' {MainForm},
  Orders.ManagedFrame in 'Classes\Orders.ManagedFrame.pas' {ManagedFrame: TFrame};

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
