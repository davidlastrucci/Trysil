(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Demo.MainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.WinXCtrls,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,
  Trysil.Filter,
  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SqlServer,
  Trysil.Context,
  Trysil.Generics.Collections,
  Trysil.Vcl.ListView,

  Demo.Config,
  Demo.Model,
  Demo.ListView,
  Demo.EditDialog;

type

{ TMainForm }

  TMainForm = class(TForm)
    Toolbar: TPanel;
    OpenButton: TButton;
    Bevel: TBevel;
    InsertButton: TButton;
    EditButton: TButton;
    DeleteButton: TButton;
    SearchTextbox: TSearchBox;
    ImageList: TImageList;
    ListViewContainer: TPanel;
    StatusBar: TPanel;
    SelectedPanel: TPanel;
    CounterPanel: TPanel;
    ApplicationEvents: TApplicationEvents;
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure OpenButtonClick(Sender: TObject);
    procedure InsertButtonClick(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure SearchTextboxInvokeSearch(Sender: TObject);
  strict private
    FConfig: TConfig;
    FConnection: TTConnection;
    FContext: TTContext;
    FMasterData: TTList<TTMasterData>;
    FMasterDataListView: TTMasterDataListView;

    procedure MasterDataListViewItemChanged(const ASelected: TTMasterData);
    procedure MasterDataListViewOnDblClick(Sender: TObject);

    procedure RefreshListView;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
var
  LConnection: TConnectionConfig;
begin
  inherited Create(AOwner);
  TTFireDACConnectionPool.Instance.Config.Enabled := True;

  FConfig := TConfig.Create;
  for LConnection in FConfig.Connections do
    TTSqlServerConnection.RegisterConnection(
      LConnection.Name,
      LConnection.Server,
      LConnection.Username,
      LConnection.Password,
      LConnection.DatabaseName);

  FConnection := TTSqlServerConnection.Create('Test');
  FContext := TTContext.Create(FConnection);

  FMasterData := TTList<TTMasterData>.Create;
  FMasterDataListView := TTMasterDataListView.Create(nil, ListViewContainer);
end;

destructor TMainForm.Destroy;
begin
  FMasterDataListView.Free;
  FMasterData.Free;
  FContext.Free;
  FConnection.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FMasterDataListView.SmallImages := ImageList;
  FMasterDataListView.OnItemChanged := MasterDataListViewItemChanged;
  FMasterDataListView.OnDblClick := MasterDataListViewOnDblClick;
end;

procedure TMainForm.ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
var
  LEntity: TTMasterData;
begin
  if Assigned(FMasterDataListView) then
  begin
    LEntity := FMasterDataListView.SelectedEntity;
    EditButton.Enabled := Assigned(LEntity);
    DeleteButton.Enabled := Assigned(LEntity);
  end;
  Done := True;
end;

procedure TMainForm.MasterDataListViewItemChanged(const ASelected: TTMasterData);
begin
  SelectedPanel.Caption := '';
  if Assigned(ASelected) then
    SelectedPanel.Caption := ASelected.ToString();
end;

procedure TMainForm.MasterDataListViewOnDblClick(Sender: TObject);
begin
  EditButton.Click;
end;

procedure TMainForm.RefreshListView;
begin
  FMasterDataListView.BindData(FMasterData, SearchTextbox.Text);
  CounterPanel.Caption := Format('%d di %d', [
    FMasterDataListView.Items.Count, FMasterData.Count]);
end;

procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  FContext.SelectAll<TTMasterData>(FMasterData);
  RefreshListView;
end;

procedure TMainForm.SearchTextboxInvokeSearch(Sender: TObject);
begin
  RefreshListView;
end;

procedure TMainForm.InsertButtonClick(Sender: TObject);
begin
  if TEditDialog.Insert(FContext, FMasterData) then
    RefreshListView;
end;

procedure TMainForm.EditButtonClick(Sender: TObject);
var
  LEntity: TTMasterData;
begin
  LEntity := FMasterDataListView.SelectedEntity;
  if Assigned(LEntity) then
    if TEditDialog.Edit(FContext, FMasterData, LEntity) then
      RefreshListView;
end;

procedure TMainForm.DeleteButtonClick(Sender: TObject);
var
  LEntity: TTMasterData;
begin
  LEntity := FMasterDataListView.SelectedEntity;
  if Assigned(LEntity) then
    if Application.MessageBox(
      PChar(Format('Eliminare "%s"?', [LEntity.ToString()])),
      'Conferma',
      MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) = IDYES then
    begin
      FContext.Delete<TTMasterData>(LEntity);
      FMasterData.Remove(LEntity);
      RefreshListView;
    end;
end;

end.
