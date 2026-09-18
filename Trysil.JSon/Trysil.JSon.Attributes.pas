(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Attributes;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Rtti;

type

{ TJSonIgnoreAttribute }

  TJSonIgnoreAttribute = class(TCustomAttribute);

{ TJSonIgnoreSerializeAttribute }

  TJSonIgnoreSerializeAttribute = class(TCustomAttribute);

{ TJSonIgnoreDeserializeAttribute }

  TJSonIgnoreDeserializeAttribute = class(TCustomAttribute);

{ TTJSonDirection }

  TTJSonDirection = record
  public
    class function CanSerialize(
      const AMember: TTRttiMember): Boolean; overload; static;
    class function CanSerialize(
      const AColumnMetadata: TTColumnMetadata): Boolean; overload; static;
    class function CanDeserialize(
      const AMember: TTRttiMember): Boolean; static;
    class function CanDeserializeColumn(
      const ATableMap: TTTableMap;
      const AColumnMap: TTColumnMap): Boolean; static;
  end;

implementation

{ TTJSonDirection }

class function TTJSonDirection.CanSerialize(
  const AMember: TTRttiMember): Boolean;
begin
  result := Assigned(AMember) and
    (not Assigned(AMember.GetAttribute<TJSonIgnoreAttribute>())) and
    (not Assigned(AMember.GetAttribute<TJSonIgnoreSerializeAttribute>()));
end;

class function TTJSonDirection.CanSerialize(
  const AColumnMetadata: TTColumnMetadata): Boolean;
begin
  result :=
    (not AColumnMetadata.HasAttribute(TJSonIgnoreAttribute)) and
    (not AColumnMetadata.HasAttribute(TJSonIgnoreSerializeAttribute));
end;

class function TTJSonDirection.CanDeserialize(
  const AMember: TTRttiMember): Boolean;
begin
  result := Assigned(AMember) and
    (not Assigned(AMember.GetAttribute<TJSonIgnoreAttribute>())) and
    (not Assigned(AMember.GetAttribute<TJSonIgnoreDeserializeAttribute>()));
end;

class function TTJSonDirection.CanDeserializeColumn(
  const ATableMap: TTTableMap;
  const AColumnMap: TTColumnMap): Boolean;
begin
  result :=
    (not ATableMap.Columns.IsChangeTracking(AColumnMap)) and
    CanDeserialize(AColumnMap.Member);
end;

end.
