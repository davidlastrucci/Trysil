(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.FrameManager;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,

  Trysil.Context,
  Orders.ManagedFrame;

type

{ EFrameManagerException }

  EFrameManagerException = class(Exception);

{ TManagedFrameClass }

  TManagedFrameClass = class of TManagedFrame;

{ TFrameItem }

  TFrameItem = class
  strict private
    FName: String;
    FFrame: TManagedFrame;
  public
    constructor Create(
      const AName: String;
      const AFrameClass: TManagedFrameClass;
      const AParent: TWinControl;
      const AContext: TTContext);
    destructor Destroy; override;

    property Name: String read FName;
    property Frame: TManagedFrame read FFrame;
  end;

{ TFrameContainer }

  TFrameContainer = class
  strict private
    class var FInstance: TFrameContainer;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FFrameClasses: TDictionary<String, TManagedFrameClass>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterFrame<T: TManagedFrame>(const AName: String);
    function TryResolve(
      const AName: String; var AResult: TManagedFrameClass): Boolean;

    class property Instance: TFrameContainer read FInstance;
  end;

{ TFrameManager }

  TFrameManager = class
  strict private
    FFrameParent: TWinControl;
    FContext: TTContext;
    FActiveFrameItem: TFrameItem;
    FFrameItems: TObjectList<TFrameItem>;

    function TryActivateFrame(const AName: String): Boolean;
    procedure ActivateFrameItem(const AFrameItem: TFrameItem);
  public
    constructor Create(
      const AFrameParent: TWinControl; const AContext: TTContext);
    destructor Destroy; override;

    procedure OpenFrame(const AName: String);
    procedure Clear;
  end;

resourcestring
  SFrameNotFound = 'Frame "%s" not found.';

implementation

{ TFrameItem }

constructor TFrameItem.Create(
  const AName: String;
  const AFrameClass: TManagedFrameClass;
  const AParent: TWinControl;
  const AContext: TTContext);
begin
  inherited Create;
  FName := AName;
  FFrame := AFrameClass.Create(AContext, AParent);
end;

destructor TFrameItem.Destroy;
begin
  FFrame.Free;
  inherited Destroy;
end;

{ TFrameContainer }

class constructor TFrameContainer.ClassCreate;
begin
  FInstance := TFrameContainer.Create;
end;

class destructor TFrameContainer.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TFrameContainer.Create;
begin
  inherited Create;
  FFrameClasses := TDictionary<String, TManagedFrameClass>.Create;
end;

destructor TFrameContainer.Destroy;
begin
  FFrameClasses.Free;
  inherited Destroy;
end;

procedure TFrameContainer.RegisterFrame<T>(const AName: String);
begin
  FFrameClasses.Add(AName.ToLower(), T);
end;

function TFrameContainer.TryResolve(
  const AName: String; var AResult: TManagedFrameClass): Boolean;
begin
  result := FFrameClasses.TryGetValue(AName.ToLower(), AResult);
end;

{ TFrameManager }

constructor TFrameManager.Create(
  const AFrameParent: TWinControl; const AContext: TTContext);
begin
  inherited Create;
  FFrameParent := AFrameParent;
  FContext := AContext;
  FActiveFrameItem := nil;
  FFrameItems := TObjectList<TFrameItem>.Create(True);
end;

destructor TFrameManager.Destroy;
begin
  FFrameItems.Free;
  inherited Destroy;
end;

procedure TFrameManager.ActivateFrameItem(const AFrameItem: TFrameItem);
begin
  if FActiveFrameItem <> AFrameItem then
  begin
    if Assigned(FActiveFrameItem) then
      FActiveFrameItem.Frame.Visible := False;

    FActiveFrameItem := AFrameItem;
    FActiveFrameItem.Frame.Visible := True;
  end;
end;

function TFrameManager.TryActivateFrame(const AName: String): Boolean;
var
  LFrameItem: TFrameItem;
begin
  result := False;
  for LFrameItem in FFrameItems do
  begin
    result := LFrameItem.Name.Equals(AName);
    if result then
    begin
      ActivateFrameItem(LFrameItem);
      Break;
    end;
  end;
end;

procedure TFrameManager.OpenFrame(const AName: String);
var
  LName: String;
  LFrameClass: TManagedFrameClass;
  LFrameItem: TFrameItem;
begin
  LName := AName.ToLower();
  if not TryActivateFrame(LName) then
  begin
    if not TFrameContainer.Instance.TryResolve(LName, LFrameClass) then
      raise EFrameManagerException.CreateFmt(SFrameNotFound, [AName]);

    LFrameItem := TFrameItem.Create(LName, LFrameClass, FFrameParent, FContext);
    try
      LFrameItem.Frame.Align := alClient;
      FFrameItems.Add(LFrameItem);
      ActivateFrameItem(LFrameItem);
    except
      if FActiveFrameItem = LFrameItem then
        FActiveFrameItem := nil;
      if FFrameItems.Contains(LFrameItem) then
        FFrameItems.Remove(LFrameItem)
      else
        LFrameItem.Free;
      raise;
    end;
  end;
end;

procedure TFrameManager.Clear;
begin
  FActiveFrameItem := nil;
  FFrameItems.Clear;
end;

end.
