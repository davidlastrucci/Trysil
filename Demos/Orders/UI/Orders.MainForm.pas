(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.MainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.ImgList,
  Vcl.Buttons,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,
  Trysil.Data,
  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SQLite,
  Trysil.Data.FireDAC.SqlServer,
  Trysil.Context,

  Orders.Config,
  Orders.FrameManager;

type

{ TMainForm }

  TMainForm = class(TForm)
    ImageList: TImageList;
    ActionList: TActionList;
    BrandsAction: TAction;
    ProductsAction: TAction;
    CustomersAction: TAction;
    OrdersAction: TAction;
    MainMenu: TPanel;
    MainMenuLabel: TLabel;
    BrandsButton: TSpeedButton;
    ProductsButton: TSpeedButton;
    CustomersButton: TSpeedButton;
    OrdersButton: TSpeedButton;
    MainPanel: TPanel;
    StatusBar: TPanel;
    StatusBarLabel: TLabel;
    procedure BrandsActionExecute(Sender: TObject);
    procedure ProductsActionExecute(Sender: TObject);
    procedure CustomersActionExecute(Sender: TObject);
    procedure OrdersActionExecute(Sender: TObject);
  strict private
    const ConnectionName: String = 'Orders';
  strict private
    FConfig: TConfig;
    FConnection: TTConnection;
    FContext: TTContext;
    FFrameManager: TFrameManager;

    function GetDatabaseVersion: String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

constructor TMainForm.Create(AOwner: TComponent);
var
  LFactory: TTFireDACConnectionFactory;
begin
  inherited Create(AOwner);
  TTFireDACConnectionPool.Instance.Config.Enabled := False;

  FConfig := TConfig.Create;

  LFactory := TTFireDACConnectionFactory.Instance;
  LFactory.RegisterConnection(ConnectionName, FConfig.Parameters);
  FConnection := LFactory.CreateConnection(ConnectionName);

  FContext := TTContext.Create(FConnection);
  FFrameManager := TFrameManager.Create(MainPanel, FContext);
end;

destructor TMainForm.Destroy;
begin
  FFrameManager.Free;
  FContext.Free;
  FConnection.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FContext.OnGetCurrentUser :=
    function: String
    begin
      result := 'Demo';
    end;

  StatusBarLabel.Caption := Format('Connected at: %s - %s', [
    FConfig.Parameters.Driver, GetDatabaseVersion]);
end;

function TMainForm.GetDatabaseVersion: String;
var
  LIndex: Integer;
begin
  result := FConnection.DatabaseVersion;
  LIndex := result.IndexOf(#10);
  if LIndex >= 0 then
    result := result.SubString(0, LIndex).Trim();
end;

procedure TMainForm.BrandsActionExecute(Sender: TObject);
begin
  FFrameManager.OpenFrame('Brands');
end;

procedure TMainForm.ProductsActionExecute(Sender: TObject);
begin
  FFrameManager.OpenFrame('Products');
end;

procedure TMainForm.CustomersActionExecute(Sender: TObject);
begin
  FFrameManager.OpenFrame('Customers');
end;

procedure TMainForm.OrdersActionExecute(Sender: TObject);
begin
  FFrameManager.OpenFrame('Orders');
end;

end.
