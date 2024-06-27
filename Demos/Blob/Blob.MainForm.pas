(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Blob.MainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SqlServer,
  Trysil.Context,
  Trysil.Generics.Collections,
  Blob.PictureHelper,
  Blob.Model, Vcl.StdCtrls, Vcl.ExtCtrls;

type

{ TMainForm }

  TMainForm = class(TForm)
    WriteImagesButton: TButton;
    ReadImagesButton: TButton;
    IDTextbox: TEdit;
    NameTextbox: TEdit;
    ImageImage: TImage;
    PriorButton: TButton;
    NextButton: TButton;
    procedure WriteImagesButtonClick(Sender: TObject);
    procedure ReadImagesButtonClick(Sender: TObject);
    procedure PriorButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
  strict private
    FConnection: TTConnection;
    FContext: TTContext;
    FImages: TTList<TTImage>;
    FImageIndex: Integer;

    procedure ShowImageData(const AImage: TTImage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TTSqlServerConnection.RegisterConnection(
    'Test', '(local)\Test', 'sa', 'Sviluppo.2022', 'Test');

  FConnection := TTSqlServerConnection.Create('Test');
  FContext := TTContext.Create(FConnection);
  FImages := TTList<TTImage>.Create;
end;

destructor TMainForm.Destroy;
begin
  FImages.Free;
  FContext.Free;
  FConnection.Free;
  inherited Destroy;
end;

procedure TMainForm.WriteImagesButtonClick(Sender: TObject);
var
  LFile: String;
  LImage: TTImage;
begin
  for LFile in TDirectory.GetFiles('..\..\Images', '*.png') do
  begin
    LImage := FContext.CreateEntity<TTImage>();
    LImage.Name := TPath.GetFileNameWithoutExtension(LFile);
    LImage.Image := TFile.ReadAllBytes(LFile);
    FContext.Insert<TTImage>(LImage);
  end;
end;

procedure TMainForm.ShowImageData(const AImage: TTImage);
begin
  IDTextbox.Text := AImage.Id.ToString;
  NameTextbox.Text := AImage.Name;
  ImageImage.Picture.LoadFromBytes(AImage.Image);
end;

procedure TMainForm.ReadImagesButtonClick(Sender: TObject);
begin
  FContext.SelectAll<TTImage>(FImages);
  FImageIndex := 0;
  ShowImageData(FImages[FImageIndex]);
end;

procedure TMainForm.PriorButtonClick(Sender: TObject);
begin
  if FImageIndex > 0 then
  begin
    Dec(FImageIndex);
    ShowImageData(FImages[FImageIndex]);
  end;
end;

procedure TMainForm.NextButtonClick(Sender: TObject);
begin
  if FImageIndex < FImages.Count - 1 then
  begin
    Inc(FImageIndex);
    ShowImageData(FImages[FImageIndex]);
  end;
end;

end.
