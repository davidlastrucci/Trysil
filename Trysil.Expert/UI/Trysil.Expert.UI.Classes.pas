(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Classes;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.ComCtrls,

  Trysil.Expert.Model;

type

{ TTTreeNode<T> }

  TTTreeNode<T> = class(TTreeNode)
  strict private
    FValue: T;
  strict protected
    procedure SetValue(const AValue: T); virtual;
  public
    property Value: T read FValue write SetValue;
  end;

{ TTEntityTreeNode }

  TTEntityTreeNode = class(TTTreeNode<TTEntity>)
  strict protected
    procedure SetValue(const AValue: TTEntity); override;
  end;

{ TTListItem<T> }

  TTListItem<T> = class(TListItem)
  strict private
    FValue: T;
  strict protected
    procedure SetValue(const AValue: T); virtual;
  public
    property Value: T read FValue write SetValue;
  end;

{ TTEntityListItem }

  TTEntityListItem = class(TTListItem<TTEntity>)
  strict protected
    procedure SetValue(const AValue: TTEntity); override;
  end;

{ TTColumnListItem }

  TTColumnListItem = class(TTListItem<TTAbstractColumn>)
  strict protected
    procedure SetValue(const AValue: TTAbstractColumn); override;
  end;

implementation

{ TTTreeNode<T> }

procedure TTTreeNode<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

{ TTEntityTreeNode }

procedure TTEntityTreeNode.SetValue(const AValue: TTEntity);
begin
  inherited SetValue(AValue);
  ImageIndex := 0;
end;

{ TTListItem<T> }

procedure TTListItem<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

{ TTEntityListItem }

procedure TTEntityListItem.SetValue(const AValue: TTEntity);
begin
  inherited SetValue(AValue);
  Caption := AValue.Name;
  ImageIndex := 0;
end;

{ TTColumnListItem }

procedure TTColumnListItem.SetValue(const AValue: TTAbstractColumn);
begin
  inherited SetValue(AValue);
  Caption := AValue.Name;
  ImageIndex := 1;
  SubItems.Add(AValue.ColumnName);

  if AValue is TTLazyListColumn then
    SubItems.Add(
      Format('{%s}[]', [TTLazyListColumn(AValue).ObjectName]))
  else if AValue is TTLazyColumn then
  begin
    SubItems.Add(Format('{%s}', [TTLazyColumn(AValue).ObjectName]));
  end
  else if AValue is TTColumn then
  begin
    SubItems.Add(TTColumn(AValue).DataTypeToString);
    if TTColumn(AValue).Size <> 0 then
      SubItems.Add(TTColumn(AValue).Size.ToString);
  end;
end;

end.
