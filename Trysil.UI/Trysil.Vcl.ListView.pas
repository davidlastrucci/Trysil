(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Vcl.ListView;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  Vcl.Controls,
  Vcl.ComCtrls,

  Trysil.Types,
  Trysil.Rtti,
  Trysil.Factory,
  Trysil.Generics.Collections;

type

{ TTListViewHelper }

  TTListViewHelper = class
  strict private
    FListView: TCustomListView;
    FSortType: Integer;
    FSortColumn: Integer;
    FDefaultColumnOrder: Integer;

    procedure AddHeaderSortImage;
    procedure RemoveHeaderSortImage;
  public
    constructor Create(const AListView: TCustomListView);

    procedure SortListView; overload;
    procedure SortListView(const AColumnIndex: Integer); overload;

    property SortColumn: Integer read FSortColumn;
    property SortType: Integer read FSortType;
    property DefaultColumnOrder: Integer
      read FDefaultColumnOrder write FDefaultColumnOrder;
  end;

{ TTListItem<T> }

  TTListItem<T: class> = class(TListItem)
  strict private
    FEntity: T;

    procedure SetEntity(const AValue: T);
  public
    property Entity: T read FEntity write SetEntity;
  end;

{ TTListViewColumn }

  TTListViewColumn = class
  strict private
    FCaption: String;
    FAlignment: TAlignment;
    FWidth: Integer;
    FPropertyName: String;
    FFormat: String;
  public
    constructor Create(
      const ACaption: String;
      const AAlignment: TAlignment;
      const AWidth: Integer;
      const APropertyName: String;
      const AFormat: String);

    property Caption: String read FCaption;
    property Alignment: TAlignment read FAlignment;
    property Width: Integer read FWidth;
    property PropertyName: String read FPropertyName;
    property Format: String read FFormat;
  end;

{ TTListViewColumns }

  TTListViewColumns = class
  strict private
    FColumns: TObjectList<TTListViewColumn>;

    function GetColumns: TEnumerable<TTListViewColumn>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(
      const ACaption: String;
      const AAlignment: TAlignment;
      const AWidth: Integer;
      const APropertyName: String;
      const AFormat: String);

    property Columns: TEnumerable<TTListViewColumn> read GetColumns;
  end;

{ TTRttiListViewProperties }

  TTRttiListViewProperties = class
  strict private
    FContext: TRttiContext;
    FProperties: TList<TRttiProperty>;

    function InternalGetValue(
      const AValue: TValue; const AFormat: String): String;
    function InternalFormatValue(
      const AValue: TValue; const AFormat: String): String;
  public
    constructor Create(const AContext: TRttiContext);
    destructor Destroy; override;

    function GetValue(
      const AObject: TObject; const AFormat: String): String; overload;
    function GetValue(
      const AType: TRttiType;
      const AObject: TObject;
      const APropertyName: String;
      const AFormat: String): String; overload;
  end;

{ TTRttiListView<T> }

  TTRttiListView<T> = class
  strict private
    FContext: TRttiContext;
    FType: TRttiType;
    FProperties: TObjectDictionary<String, TTRttiListViewProperties>;
  public
    constructor Create;
    destructor Destroy; override;

    function GetValue(
      const AItem: TObject;
      const APropertyName: String;
      const AFormat: String): String;
  end;

{ TTListViewOnItemChanged<T> }

  TTListViewOnItemChanged<T: class> = procedure(
    const ASelected: T) of object;

{ TTListViewOnCompare<T>}

  TTListViewOnCompare<T: class> = procedure(
    const AColumnIndex: Integer;
    const ALeft: T;
    const ARight: T;
    var AResult: Integer) of object;

{ TTListView<T> }

  TTListView<T: class> = class(TCustomListView)
  strict private
    FParent: TWinControl;
    FDefaultColumnOrder: Integer;
    FHelper: TTListViewHelper;
    FListViewColumns: TTListViewColumns;
    FRttiListView: TTRttiListView<T>;
    FImageIndex: Integer;
    FColumnsChanged: Boolean;
    FOnItemChanged: TTListViewOnItemChanged<T>;
    FOnItemCompare: TTListViewOnCompare<T>;

    procedure ListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewSelectedItem(
      Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ListViewCompare(
      Sender: TObject;
      Item1, Item2: TListItem;
      Data: Integer;
      var Compare: Integer);

    function GetSelectedEntity: T;

    procedure AddItems(
      const AItems: TTList<T>;
      const APredicate: TTPredicate<T>;
      const ASelectedEntity: T);
  private // internal
    procedure BindItem(const AItem: TTListItem<T>);
  public
    constructor Create(
      const AOwner: TComponent;
      const AParent: TWinControl); reintroduce; virtual;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure AddColumn(
      const ACaption: String;
      const AAlignment: TAlignment;
      const AWidth: Integer;
      const APropertyName: String); overload;

    procedure AddColumn(
      const ACaption: String;
      const AAlignment: TAlignment;
      const AWidth: Integer;
      const APropertyName: String;
      const AFormat: String); overload;

    procedure PrepareColumns;

    procedure BindData(const AItems: TTList<T>); overload;
    procedure BindData(
      const AItems: TTList<T>; const APredicate: TTPredicate<T>); overload;

    procedure UpdateSelected;

    property DefaultColumnOrder: Integer
      read FDefaultColumnOrder write FDefaultColumnOrder;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property SelectedEntity: T read GetSelectedEntity;
    property OnItemChanged: TTListViewOnItemChanged<T>
      read FOnItemChanged write FOnItemChanged;
    property OnItemCompare: TTListViewOnCompare<T>
      read FOnItemCompare write FOnItemCompare;
  end;

implementation

{ TTListViewHelper }

constructor TTListViewHelper.Create(const AListView: TCustomListView);
begin
  inherited Create;
  FListView := AListView;
  FSortType := -1;
  FSortColumn := -1;
  FDefaultColumnOrder := -1;
end;

procedure TTListViewHelper.AddHeaderSortImage;
var
  LHeader: HWND;
  LItem: THDItem;
begin
  if FSortColumn >= 0 then
  begin
    LHeader := ListView_GetHeader(FListView.Handle);
    ZeroMemory(@LItem, SizeOf(LItem));
    LItem.Mask := HDI_FORMAT;
    Header_GetItem(LHeader, FSortColumn, LItem);
    LItem.fmt := LItem.fmt and not (HDF_SORTUP or HDF_SORTDOWN);
    if FSortType < 0 then
      LItem.fmt := LItem.fmt or HDF_SORTDOWN
    else
      LItem.fmt := LItem.fmt or HDF_SORTUP;
    Header_SetItem(LHeader, FSortColumn, LItem);
  end;
end;

procedure TTListViewHelper.RemoveHeaderSortImage;
var
  LHeader: HWND;
  LItem: THDItem;
begin
  if FSortColumn >= 0 then
  begin
    LHeader := ListView_GetHeader(FListView.Handle);
    ZeroMemory(@LItem, SizeOf(LItem));
    LItem.Mask := HDI_FORMAT;
    Header_GetItem(LHeader, FSortColumn, LItem);
    LItem.fmt := LItem.fmt and not (HDF_SORTUP or HDF_SORTDOWN);
    Header_SetItem(LHeader, FSortColumn, LItem);
  end;
end;

procedure TTListViewHelper.SortListView;
begin
  RemoveHeaderSortImage;
  if FSortColumn < 0 then
  begin
    FSortType := -1;
    SortListView(FDefaultColumnOrder);
  end
  else
  begin
    FSortType := -FSortType;
    SortListView(FSortColumn);
  end;
end;

procedure TTListViewHelper.SortListView(const AColumnIndex: Integer);
begin
  if FSortColumn >= 0 then
    RemoveHeaderSortImage;

  if FSortColumn = AColumnIndex then
    FSortType := -FSortType
  else
  begin
    FSortType := 1;
    FSortColumn := AColumnIndex;
  end;

  AddHeaderSortImage;

  FListView.Items.BeginUpdate;
  try
    FListView.AlphaSort;
    if Assigned(FListView.Selected) then
      FListView.Selected.MakeVisible(True);
  finally
    FListView.Items.EndUpdate;
  end;
end;

{ TTListItem<T> }

procedure TTListItem<T>.SetEntity(const AValue: T);
var
  LListView: TCustomListView;
  LListViewT: TTListView<T> absolute LListView;
begin
  FEntity := AValue;
  LLIstView := ListView;
  if ListView is TTListView<T> then
    LListViewT.BindItem(Self);
end;

{ TTListViewColumn }

constructor TTListViewColumn.Create(
  const ACaption: String;
  const AAlignment: TAlignment;
  const AWidth: Integer;
  const APropertyName: String;
  const AFormat: String);
begin
  inherited Create;
  FCaption := ACaption;
  FAlignment := AAlignment;
  FWidth := AWidth;
  FPropertyName := APropertyName;
  FFormat := AFormat;
end;

{ TTListViewColumns }

constructor TTListViewColumns.Create;
begin
  inherited Create;
  FColumns := TObjectList<TTListViewColumn>.Create(True);
end;

destructor TTListViewColumns.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

procedure TTListViewColumns.Add(
  const ACaption: String;
  const AAlignment: TAlignment;
  const AWidth: Integer;
  const APropertyName: String;
  const AFormat: String);
begin
  FColumns.Add(
    TTListViewColumn.Create(
      ACaption, AAlignment, AWidth, APropertyName, AFormat));
end;

function TTListViewColumns.GetColumns: TEnumerable<TTListViewColumn>;
begin
  result := FColumns;
end;

{ TTRttiListViewProperties }

constructor TTRttiListViewProperties.Create(const AContext: TRttiContext);
begin
  inherited Create;
  FContext := AContext;
  FProperties := TList<TRttiProperty>.Create;
end;

destructor TTRttiListViewProperties.Destroy;
begin
  FProperties.Free;
  inherited Destroy;
end;

function TTRttiListViewProperties.GetValue(
  const AObject: TObject; const AFormat: String): String;
var
  LObject: TObject;
  LProperty: TRttiProperty;
  LValue: TValue;
begin
  LObject := AObject;

  for LProperty in FProperties do
  begin
    LValue := nil;
    if Assigned(LObject) then
      LValue := LProperty.GetValue(LObject);
    if LValue.IsObject then
      LObject := LValue.AsObject;
  end;

  result := InternalGetValue(LValue, AFormat);
end;

function TTRttiListViewProperties.GetValue(
  const AType: TRttiType;
  const AObject: TObject;
  const APropertyName: String;
  const AFormat: String): String;
var
  LObject: TObject;
  LType: TRttiType;
  LPropertyNames: TArray<String>;
  LPropertyName: String;
  LProperty: TRttiProperty;
  LValue: TValue;
begin
  LType := AType;
  LObject := AObject;

  LPropertyNames := APropertyName.Split(['.']);
  for LPropertyName in LPropertyNames do
  begin
    LProperty := LType.GetProperty(LPropertyName);
    FProperties.Add(LProperty);

    LValue := nil;
    if Assigned(LObject) then
      LValue := LProperty.GetValue(LObject);

    if LValue.IsObject then
    begin
      LObject := LValue.AsObject;
      LType := FContext.GetType(LProperty.PropertyType.Handle);
    end;
  end;

  result := InternalGetValue(LValue, AFormat);
end;

function TTRttiListViewProperties.InternalGetValue(
  const AValue: TValue; const AFormat: String): String;
begin
  if AValue.IsEmpty then
    result := ''
  else if AValue.IsObject then
    result := AValue.AsObject.ToString()
  else if AValue.IsNullable then
    result := AValue.NullableValueToString()
  else if not AFormat.IsEmpty then
    result := InternalFormatValue(AValue, AFormat)
  else
    result := AValue.ToString();
end;

function TTRttiListViewProperties.InternalFormatValue(
  const AValue: TValue; const AFormat: String): String;
begin
  if AValue.IsType<Integer>() then
    result := FormatFloat(AFormat, AValue.AsInteger)
  else if AValue.IsType<Extended>() then
  begin
    if AFormat.Contains('0') then
      result := FormatFloat(AFormat, AValue.AsExtended)
    else
      result := FormatDateTime(AFormat, AValue.AsType<TDateTime>())
  end
  else
    result := AFormat;
end;

{ TTRttiListView<T> }

constructor TTRttiListView<T>.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
  FType := FContext.GetType(TTFactory.Instance.GetType<T>());
  FProperties := TObjectDictionary<
    String, TTRttiListViewProperties>.Create([doOwnsValues]);
end;

destructor TTRttiListView<T>.Destroy;
begin
  FProperties.Free;
  inherited Destroy;
end;

function TTRttiListView<T>.GetValue(
  const AItem: TObject;
  const APropertyName: String;
  const AFormat: String): String;
var
  LProperties: TTRttiListViewProperties;
begin
  if FProperties.TryGetValue(APropertyName, LProperties) then
    result := LProperties.GetValue(AItem, AFormat)
  else
  begin
    LProperties := TTRttiListViewProperties.Create(FContext);
    try
      result := LProperties.GetValue(FType, AItem, APropertyName, AFormat);
      FProperties.Add(APropertyName, LProperties);
    except
      LProperties.Free;
      raise;
    end;
  end;
end;

{ TTListView<T> }

constructor TTListView<T>.Create(
  const AOwner: TComponent; const AParent: TWinControl);
begin
  inherited Create(AOwner);
  FParent := AParent;
  FHelper := TTListViewHelper.Create(Self);
  FListViewColumns := TTListViewColumns.Create;
  FRttiListView := TTRttiListView<T>.Create;
end;

destructor TTListView<T>.Destroy;
begin
  FRttiListView.Free;
  FListViewColumns.Free;
  FHelper.Free;
  inherited Destroy;
end;

procedure TTListView<T>.AfterConstruction;
begin
  inherited AfterConstruction;
  FDefaultColumnOrder := 0;
  FImageIndex := -1;
  FColumnsChanged := False;

  Self.ReadOnly := True;
  Self.RowSelect := True;
  Self.ViewStyle := TViewStyle.vsReport;

  Self.Parent := FParent;
  Self.Align := TAlign.alClient;
  Self.Visible := True;

  Self.OnCreateItemClass := ListViewCreateItemClass;
  Self.OnColumnClick := ListViewColumnClick;
  Self.OnCompare := ListViewCompare;
  Self.OnSelectItem := ListViewSelectedItem;

  if ClassName.Length > 63 then
    raise Exception.CreateFmt('Classe name "%s" too long.', [ClassName]);
end;

procedure TTListView<T>.ListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TTListItem<T>;
end;

procedure TTListView<T>.AddColumn(
  const ACaption: String;
  const AAlignment: TAlignment;
  const AWidth: Integer;
  const APropertyName: String);
begin
  AddColumn(ACaption, AAlignment, AWidth, APropertyName, String.Empty);
end;

procedure TTListView<T>.AddColumn(
  const ACaption: String;
  const AAlignment: TAlignment;
  const AWidth: Integer;
  const APropertyName: String;
  const AFormat: String);
begin
  FListViewColumns.Add(ACaption, AAlignment, AWidth, APropertyName, AFormat);
  FColumnsChanged := True;
end;

procedure TTListView<T>.ListViewColumnClick(
  Sender: TObject; Column: TListColumn);
begin
  FHelper.SortListView(Column.Index);
end;

procedure TTListView<T>.ListViewSelectedItem(
  Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Assigned(FOnItemChanged) then
    FOnItemChanged(SelectedEntity);
end;

procedure TTListView<T>.ListViewCompare(
  Sender: TObject;
  Item1, Item2: TListItem;
  Data: Integer;
  var Compare: Integer);
begin
  Compare := 0;
  if Assigned(FOnItemCompare) then
  begin
    FOnItemCompare(
      FHelper.SortColumn,
      TTListItem<T>(Item1).Entity,
      TTListItem<T>(Item2).Entity,
      Compare);
    Compare := Compare * FHelper.SortType;
  end;
end;

procedure TTListView<T>.PrepareColumns;
var
  LListViewColumn: TTListViewColumn;
  LListColumn: TListColumn;
begin
  Columns.Clear;
  for LListViewColumn in FListViewColumns.Columns do
  begin
    LLIstColumn := Columns.Add;
    LListColumn.Caption := LListViewColumn.Caption;
    LListColumn.Alignment := LListViewColumn.Alignment;
    LListColumn.Width := LListViewColumn.Width;
  end;
  FColumnsChanged := False;
end;

function TTListView<T>.GetSelectedEntity: T;
begin
  result := nil;
  if Assigned(Selected) then
    result := TTListItem<T>(Selected).Entity;
end;

procedure TTListView<T>.AddItems(
  const AItems: TTList<T>;
  const APredicate: TTPredicate<T>;
  const ASelectedEntity: T);
var
  LEntityItem: T;
  LListItem: TListItem;
begin
  Items.Clear;
  for LEntityItem in AItems.Where(APredicate) do
  begin
    LListItem := Items.Add;
    TTListItem<T>(LListItem).Entity := LEntityItem;
    if Assigned(ASelectedEntity) and (ASelectedEntity = LEntityItem) then
      LListItem.Selected := True;
  end;
end;

procedure TTListView<T>.BindData(const AItems: TTList<T>);
begin
  BindData(AItems, nil);
end;

procedure TTListView<T>.BindData(
  const AItems: TTList<T>;
  const APredicate: TTPredicate<T>);
var
  LSelectedEntity, LEntityItem: T;
  LListItem: TListItem;
begin
  LSelectedEntity := SelectedEntity;

  if FHelper.DefaultColumnOrder < 0 then
    FHelper.DefaultColumnOrder := FDefaultColumnOrder;

  Items.BeginUpdate;
  try
    if FColumnsChanged then
      PrepareColumns;
    AddItems(AItems, APredicate, LSelectedEntity);
    FHelper.SortListView;

    if (not Assigned(SelectedEntity)) and (Items.Count > 0) then
      Selected := Items[0];
    if Assigned(Selected) then
      Selected.MakeVisible(True);
  finally
    Items.EndUpdate;
  end;
end;

procedure TTListView<T>.BindItem(const AItem: TTListItem<T>);
var
  LFirst: Boolean;
  LColumn: TTListViewColumn;
  LValue: String;
begin
  LFirst := True;
  AItem.ImageIndex := FImageIndex;
  AItem.SubItems.Clear;
  for LColumn in FListViewColumns.Columns do
  begin
    LValue := FRttiListView.GetValue(
      AItem.Entity, LColumn.PropertyName, LColumn.Format);
    if LFirst then
      AItem.Caption := LValue
    else
      AItem.SubItems.Add(LValue);
    LFirst := False;
  end;
end;

procedure TTListView<T>.UpdateSelected;
var
  LItem: TTListItem<T>;
begin
  if Assigned(Selected) then
  begin
    LItem := TTListItem<T>(Selected);
    BindItem(LItem);
  end;
end;

end.

