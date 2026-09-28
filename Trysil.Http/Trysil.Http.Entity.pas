(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Entity;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  Trysil.Consts,
  Trysil.Types,
  Trysil.Filter,
  Trysil.Generics.Collections,
  Trysil.JSon.Types,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Context,
  Trysil.Http.Filter;

type

{ TTHttpEntityFilterEvent }

  TTHttpEntityFilterEvent = reference to procedure(var AFilter: TTFilter);

{ TTHttpEntityEvent<T> }

  TTHttpEntityEvent<T: class> = reference to procedure(const AEntity: T);

{ TTHttpEntityReader<T> }

  TTHttpEntityReader<T: class> = class
  strict private
    FContext: TTHttpContext;
    FFilterParameters: TTHttpFilterParameters;

    FOnAddEntityFilter: TTHttpEntityFilterEvent;
    FOnBeforeSerializeEntity: TTHttpEntityEvent<T>;

    function CreateFilter(const AJSonFilter: TJSonValue): TTFilter;
    function CreateData(
      const AFilter: TTFilter;
      const AConfig: TTJSonSerializerConfig): TJSonArray;
    procedure BeforeSerializeEntity(const AEntity: T);
  public
    constructor Create(const AContext: TTHttpContext); overload;
    constructor Create(
      const AContext: TTHttpContext;
      const AFilterParameters: TTHttpFilterParameters); overload;

    function Get(const AID: TTPrimaryKey): String; overload;
    function Get(
      const AID: TTPrimaryKey;
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    function Find(const AID: TTPrimaryKey): String; overload;
    function Find(
      const AID: TTPrimaryKey;
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    function SelectAll: String; overload;
    function SelectAll(
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    function Select(const AJSonFilter: TJSonValue): String; overload;
    function Select(
      const AJSonFilter: TJSonValue;
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    function Metadata: String;

    property OnAddEntityFilter: TTHttpEntityFilterEvent
      read FOnAddEntityFilter write FOnAddEntityFilter;
    property OnBeforeSerializeEntity: TTHttpEntityEvent<T>
      read FOnBeforeSerializeEntity write FOnBeforeSerializeEntity;
  end;

{ TTHttpEntityWriter<T> }

  TTHttpEntityWriter<T: class> = class
  strict private
    FContext: TTHttpContext;

    FOnApplyDetails: TTHttpEntityEvent<T>;
    FOnBeforeInsert: TTHttpEntityEvent<T>;
    FOnAfterInsert: TTHttpEntityEvent<T>;
    FOnBeforeUpdate: TTHttpEntityEvent<T>;
    FOnAfterUpdate: TTHttpEntityEvent<T>;
    FOnBeforeDelete: TTHttpEntityEvent<T>;
    FOnAfterDelete: TTHttpEntityEvent<T>;

    procedure DoEvent(
      const AEvent: TTHttpEntityEvent<T>; const AEntity: T);

    procedure InternalInsert(const AEntity: T);
    procedure InternalUpdate(const AEntity: T);
    procedure InternalDelete(const AEntity: T);
  public
    constructor Create(const AContext: TTHttpContext);

    function Insert(const AJSonEntity: TJSonValue): String; overload;
    function Insert(
      const AJSonEntity: TJSonValue;
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    function Update(const AJSonEntity: TJSonValue): String; overload;
    function Update(
      const AJSonEntity: TJSonValue;
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);

    function CreateNew: String; overload;
    function CreateNew(
      const ASerializerConfig: TTJSonSerializerConfig): String; overload;

    property OnApplyDetails: TTHttpEntityEvent<T>
      read FOnApplyDetails write FOnApplyDetails;
    property OnBeforeInsert: TTHttpEntityEvent<T>
      read FOnBeforeInsert write FOnBeforeInsert;
    property OnAfterInsert: TTHttpEntityEvent<T>
      read FOnAfterInsert write FOnAfterInsert;
    property OnBeforeUpdate: TTHttpEntityEvent<T>
      read FOnBeforeUpdate write FOnBeforeUpdate;
    property OnAfterUpdate: TTHttpEntityEvent<T>
      read FOnAfterUpdate write FOnAfterUpdate;
    property OnBeforeDelete: TTHttpEntityEvent<T>
      read FOnBeforeDelete write FOnBeforeDelete;
    property OnAfterDelete: TTHttpEntityEvent<T>
      read FOnAfterDelete write FOnAfterDelete;
  end;

implementation

{ TTHttpEntityReader<T> }

constructor TTHttpEntityReader<T>.Create(const AContext: TTHttpContext);
begin
  Create(AContext, TTHttpFilterParameters.Defaults);
end;

constructor TTHttpEntityReader<T>.Create(
  const AContext: TTHttpContext;
  const AFilterParameters: TTHttpFilterParameters);
begin
  inherited Create;
  FContext := AContext;
  FFilterParameters := AFilterParameters;
end;

procedure TTHttpEntityReader<T>.BeforeSerializeEntity(const AEntity: T);
begin
  if Assigned(FOnBeforeSerializeEntity) then
    FOnBeforeSerializeEntity(AEntity);
end;

function TTHttpEntityReader<T>.CreateFilter(
  const AJSonFilter: TJSonValue): TTFilter;
var
  LHttpFilter: TTHttpFilter<T>;
begin
  LHttpFilter := TTHttpFilter<T>.Create(
    FContext, AJSonFilter, FFilterParameters);
  result := LHttpFilter.Filter;
  if Assigned(FOnAddEntityFilter) then
    FOnAddEntityFilter(result);
end;

function TTHttpEntityReader<T>.CreateData(
  const AFilter: TTFilter;
  const AConfig: TTJSonSerializerConfig): TJSonArray;
var
  LList: TTList<T>;
  LEntity: T;
begin
  LList := FContext.CreateEntityList<T>();
  try
    FContext.Select<T>(LList, AFilter);
    for LEntity in LList do
      BeforeSerializeEntity(LEntity);
    result := FContext.ListToJSonArray<T>(LList, AConfig);
  finally
    LList.Free;
  end;
end;

function TTHttpEntityReader<T>.Get(const AID: TTPrimaryKey): String;
begin
  result := Get(AID, TTJSonSerializerConfig.WithDetails);
end;

function TTHttpEntityReader<T>.Get(
  const AID: TTPrimaryKey;
  const ASerializerConfig: TTJSonSerializerConfig): String;
var
  LEntity: T;
begin
  if not FContext.TryGet<T>(AID, LEntity) then
    raise ETHttpNotFound.CreateFmt(
      TTLanguage.Instance.Translate(SEntityNotFound), [AID]);
  try
    BeforeSerializeEntity(LEntity);
    result := FContext.EntityToJSon<T>(LEntity, ASerializerConfig);
  finally
    FContext.FreeEntity<T>(LEntity);
  end;
end;

function TTHttpEntityReader<T>.Find(const AID: TTPrimaryKey): String;
begin
  result := Find(AID, TTJSonSerializerConfig.EntityOnly);
end;

function TTHttpEntityReader<T>.Find(
  const AID: TTPrimaryKey;
  const ASerializerConfig: TTJSonSerializerConfig): String;
begin
  result := Get(AID, ASerializerConfig);
end;

function TTHttpEntityReader<T>.SelectAll: String;
begin
  result := SelectAll(TTJSonSerializerConfig.WithRelations);
end;

function TTHttpEntityReader<T>.SelectAll(
  const ASerializerConfig: TTJSonSerializerConfig): String;
begin
  result := Select(nil, ASerializerConfig);
end;

function TTHttpEntityReader<T>.Select(
  const AJSonFilter: TJSonValue): String;
begin
  result := Select(AJSonFilter, TTJSonSerializerConfig.WithRelations);
end;

function TTHttpEntityReader<T>.Select(
  const AJSonFilter: TJSonValue;
  const ASerializerConfig: TTJSonSerializerConfig): String;
var
  LFilter: TTFilter;
  LJSon: TJSonObject;
  LData: TJSonArray;
begin
  LFilter := CreateFilter(AJSonFilter);
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair(
      'count', TJSonNumber.Create(FContext.SelectCount<T>(LFilter)));
    LData := CreateData(LFilter, ASerializerConfig);
    try
      LJSon.AddPair('data', LData);
    except
      LData.Free;
      raise;
    end;
    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

function TTHttpEntityReader<T>.Metadata: String;
begin
  result := FContext.MetadataToJSon<T>();
end;

{ TTHttpEntityWriter<T> }

constructor TTHttpEntityWriter<T>.Create(const AContext: TTHttpContext);
begin
  inherited Create;
  FContext := AContext;
end;

procedure TTHttpEntityWriter<T>.DoEvent(
  const AEvent: TTHttpEntityEvent<T>; const AEntity: T);
begin
  if Assigned(AEvent) then
    AEvent(AEntity);
end;

procedure TTHttpEntityWriter<T>.InternalInsert(const AEntity: T);
begin
  DoEvent(FOnBeforeInsert, AEntity);
  if FContext.GetID<T>(AEntity) <= 0 then
    FContext.SetSequenceID<T>(AEntity);
  FContext.Insert<T>(AEntity);
  DoEvent(FOnApplyDetails, AEntity);
  DoEvent(FOnAfterInsert, AEntity);
end;

procedure TTHttpEntityWriter<T>.InternalUpdate(const AEntity: T);
begin
  DoEvent(FOnBeforeUpdate, AEntity);
  FContext.Update<T>(AEntity);
  DoEvent(FOnApplyDetails, AEntity);
  DoEvent(FOnAfterUpdate, AEntity);
end;

procedure TTHttpEntityWriter<T>.InternalDelete(const AEntity: T);
begin
  DoEvent(FOnBeforeDelete, AEntity);
  FContext.Delete<T>(AEntity);
  DoEvent(FOnAfterDelete, AEntity);
end;

function TTHttpEntityWriter<T>.Insert(const AJSonEntity: TJSonValue): String;
begin
  result := Insert(AJSonEntity, TTJSonSerializerConfig.WithDetails);
end;

function TTHttpEntityWriter<T>.Insert(
  const AJSonEntity: TJSonValue;
  const ASerializerConfig: TTJSonSerializerConfig): String;
var
  LEntity: T;
begin
  LEntity := FContext.EntityFromJSonObject<T>(AJSonEntity);
  try
    FContext.RunInTransaction(
      procedure()
      begin
        InternalInsert(LEntity);
      end);
    result := FContext.EntityToJSon<T>(LEntity, ASerializerConfig);
  finally
    FContext.FreeEntity<T>(LEntity);
  end;
end;

function TTHttpEntityWriter<T>.Update(const AJSonEntity: TJSonValue): String;
begin
  result := Update(AJSonEntity, TTJSonSerializerConfig.WithDetails);
end;

function TTHttpEntityWriter<T>.Update(
  const AJSonEntity: TJSonValue;
  const ASerializerConfig: TTJSonSerializerConfig): String;
var
  LEntity: T;
begin
  LEntity := FContext.EntityFromJSonObject<T>(AJSonEntity);
  try
    FContext.RunInTransaction(
      procedure()
      begin
        InternalUpdate(LEntity);
      end);
    FContext.Refresh<T>(LEntity);
    result := FContext.EntityToJSon<T>(LEntity, ASerializerConfig);
  finally
    FContext.FreeEntity<T>(LEntity);
  end;
end;

procedure TTHttpEntityWriter<T>.Delete(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
var
  LEntity: T;
begin
  if not FContext.TryGet<T>(AID, LEntity) then
    raise ETHttpNotFound.CreateFmt(
      TTLanguage.Instance.Translate(SEntityNotFound), [AID]);
  try
    FContext.SetVersionID<T>(LEntity, AVersionID);
    FContext.RunInTransaction(
      procedure()
      begin
        InternalDelete(LEntity);
      end);
  finally
    FContext.FreeEntity<T>(LEntity);
  end;
end;

function TTHttpEntityWriter<T>.CreateNew: String;
begin
  result := CreateNew(TTJSonSerializerConfig.EntityOnly);
end;

function TTHttpEntityWriter<T>.CreateNew(
  const ASerializerConfig: TTJSonSerializerConfig): String;
var
  LEntity: T;
begin
  LEntity := FContext.CreateEntity<T>();
  try
    result := FContext.EntityToJSon<T>(LEntity, ASerializerConfig);
  finally
    FContext.FreeEntity<T>(LEntity);
  end;
end;

end.
