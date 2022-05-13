(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Controller;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSon,
  Trysil.Types,
  Trysil.Filter,
  Trysil.Generics.Collections,
  Trysil.JSon.Types,
  Trysil.Http.Consts,
  Trysil.Http.Attributes,
  Trysil.Http.Exceptions,
  Trysil.Http.Context,
  Trysil.Http.Filter,
  Trysil.Http.Controller,

  API.Context;

type

{ TAPIController }

  TAPIController = class(TTHttpController<TAPIContext>)
  strict private
    function GetContext: TTHttpContext;
  strict protected
    property Context: TTHttpContext read GetContext;
  end;

{ TAPIReadOnlyController<T> }

  TAPIReadOnlyController<T: class> = class(TAPIController)
  strict private
    FConfigGet: TTJSonSerializerConfig;
    FConfigSelect: TTJSonSerializerConfig;
    FConfigFind: TTJSonSerializerConfig;

    procedure InternalGet(
      const AID: TTPrimaryKey; const AConfig: TTJSonSerializerConfig);

    procedure InternalSelect(const AFilter: TTFilter);
  strict protected
    property ConfigGet: TTJSonSerializerConfig read FConfigGet;
    property ConfigSelect: TTJSonSerializerConfig read FConfigSelect;
    property ConfigFind: TTJSonSerializerConfig read FConfigFind;
  public
    procedure AfterConstruction; override;

    [TGet('/?')]
    procedure Get(const AID: TTPrimaryKey);

    [TGet]
    procedure SelectAll;

    [TPost('/select')]
    procedure Select;

    [TGet('/find/?')]
    procedure Find(const AID: TTPrimaryKey);
  end;

{ TAPIReadWriteController<T> }

  TAPIReadWriteController<T: class> = class(TAPIReadOnlyController<T>)
  public
    [TPost]
    procedure Insert;

    [TPut]
    procedure Update;

    [TDelete('/?/?')]
    procedure Delete(const AID: TTPrimaryKey; const AVersionID: TTVersion);

    [TGet('/createnew')]
    procedure CreateNew;
  end;

implementation

{ TAPIController }

function TAPIController.GetContext: TTHttpContext;
begin
  result := FContext.Context;
end;

{ TAPIReadOnlyController<T> }

procedure TAPIReadOnlyController<T>.AfterConstruction;
begin
  inherited AfterConstruction;
  FConfigGet := TTJSonSerializerConfig.Create(1, True);
  FConfigSelect := TTJSonSerializerConfig.Create(1, False);
  FConfigFind := TTJSonSerializerConfig.Create(0, False);
end;

procedure TAPIReadOnlyController<T>.InternalGet(
  const AID: TTPrimaryKey; const AConfig: TTJSonSerializerConfig);
var
  LEntity: T;
begin
  LEntity := Context.Get<T>(AID);
  if not Assigned(LEntity) then
    raise ETHttpNotFound.CreateFmt(SNotFound, [FRequest.ControllerID.Uri]);
  try
    FResponse.Content := Context.EntityToJSon<T>(LEntity, AConfig);
  finally
    LEntity.Free;
  end;
end;

procedure TAPIReadOnlyController<T>.InternalSelect(const AFilter: TTFilter);
var
  LJSon: TJSonObject;
  LList: TTObjectList<T>;
  LJSonData: TJSonArray;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('count', TJSonNumber.Create(Context.SelectCount<T>(AFilter)));
    LList := TTObjectList<T>.Create(True);
    try
      Context.Select<T>(LList, AFilter);
      LJSonData := Context.ListToJSonArray<T>(LList, ConfigSelect);
      try
        LJSon.AddPair('data', LJSonData);
      except
        LJSonData.Free;
        raise;
      end;

      FResponse.Content := LJSon.ToJSon();
    finally
      LList.Free;
    end;
  finally
    LJSon.Free;
  end;
end;

procedure TAPIReadOnlyController<T>.Get(const AID: TTPrimaryKey);
begin
  InternalGet(AID, ConfigGet);
end;

procedure TAPIReadOnlyController<T>.SelectAll;
begin
  InternalSelect(TTFilter.Empty());
end;

procedure TAPIReadOnlyController<T>.Select;
var
  LHttpFilter: TTHttpFilter<T>;
begin
  LHttpFilter := TTHttpFilter<T>.Create(Context, FRequest.JSonContent);
  InternalSelect(LHttpFilter.Filter);
end;

procedure TAPIReadOnlyController<T>.Find;
begin
  InternalGet(AID, ConfigFind);
end;

{ TAPIReadWriteController<T> }

procedure TAPIReadWriteController<T>.Insert;
var
  LEntity: T;
begin
  LEntity := Context.EntityFromJSonObject<T>(FRequest.JSonContent);
  try
    if Context.GetID<T>(LEntity) <= 0 then
      Context.SetSequenceID<T>(LEntity);
    Context.Insert<T>(LEntity);
    FResponse.Content := Context.EntityToJSon<T>(LEntity, ConfigGet);
  finally
    LEntity.Free;
  end;
end;

procedure TAPIReadWriteController<T>.Update;
var
  LEntity: T;
begin
  LEntity := Context.EntityFromJSonObject<T>(FRequest.JSonContent);
  try
    Context.Update<T>(LEntity);
    FResponse.Content := Context.EntityToJSon<T>(LEntity, ConfigGet);
  finally
    LEntity.Free;
  end;
end;

procedure TAPIReadWriteController<T>.Delete(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
begin
  Context.Delete<T>(AID, AVersionID);
end;

procedure TAPIReadWriteController<T>.CreateNew;
var
  LEntity: T;
begin
  LEntity := Context.CreateEntity<T>();
  try
    FResponse.Content := Context.EntityToJSon<T>(LEntity, ConfigFind);
  finally
    LEntity.Free;
  end;
end;

end.
