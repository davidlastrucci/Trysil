(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Images;

interface

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.Controls,
  Vcl.ExtCtrls;

type

{ TTImagesDataModule }

  TTImagesDataModule = class(TDataModule)
    ImageList: TImageList;
    ButtonsImageList: TImageList;
  strict private
    class var FInstance: TTImagesDataModule;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FLogo: TBitmap;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    property Logo: TBitmap read FLogo;
    property Images: TImageList read ImageList;
    property ButtonsImages: TImageList read ButtonsImageList;

    class property Instance: TTImagesDataModule read FInstance;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TTImagesDataModule }

class constructor TTImagesDataModule.ClassCreate;
begin
  FInstance := TTImagesDataModule.Create;
end;

class destructor TTImagesDataModule.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTImagesDataModule.Create;
begin
  inherited Create(nil);
  FLogo := TBitmap.Create;
end;

destructor TTImagesDataModule.Destroy;
begin
  FLogo.Free;
  inherited Destroy;
end;

procedure TTImagesDataModule.AfterConstruction;
begin
  inherited AfterConstruction;
  FLogo.LoadFromResourceName(HInstance, 'TRYSIL_48');
end;

end.
