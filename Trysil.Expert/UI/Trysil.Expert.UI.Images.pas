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
  strict private
    class var FInstance: TTImagesDataModule;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  public
    property Images: TImageList read ImageList;

    class property Instance: TTImagesDataModule read FInstance;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TTImagesDataModule }

class constructor TTImagesDataModule.ClassCreate;
begin
  FInstance := TTImagesDataModule.Create(nil);
end;

class destructor TTImagesDataModule.ClassDestroy;
begin
  FInstance.Free;
end;

end.
