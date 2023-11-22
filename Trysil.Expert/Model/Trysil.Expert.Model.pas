(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.Model;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSon,
  System.TypInfo,
  System.Generics.Collections,

  Trysil.Expert.Consts,
  Trysil.Expert.Classes;

type

{ ITEntities }

  ITEntities = interface
    ['{2026E425-5956-4637-B48C-BF9E8D754EEC}']
    function GetObjectName(const AID: String): String;
  end;

{ ITEntity }

  ITEntity = interface
    ['{B03335F9-7CF2-49C7-A02D-B74ED0380301}']
    procedure MarkAsModified;
    procedure MarkAsDeleted;
  end;

{ TTAbstractColumn }

  TTAbstractColumn = class abstract
  strict private
    FEntity: ITEntity;

    FName: String;
    FColumnName: String;
    FRequired: Boolean;

    procedure SetName(const AValue: String);
    procedure SetColumnName(const AValue: String);
    procedure SetRequired(const AValue: Boolean);
  strict protected
    FEntities: ITEntities;

    procedure NotifyChanged;
    function GetColumnType: String; virtual; abstract;
  public
    constructor Create(const AEntities: ITEntities; const AEntity: ITEntity);

    procedure FromJSon(const AJSon: TJSonValue); virtual;
    procedure ToJSon(const AJSon: TJSonObject); virtual;

    property Name: String read FName write SetName;
    property ColumnName: String read FColumnName write SetColumnName;
    property Required: Boolean read FRequired write SetRequired;
    property ColumnType: String read GetColumnType;
  end;

{ TTDataType }

  TTDataType = (
    dtPrimaryKey,
    dtString,
    dtMemo,
    dtSmallint,
    dtInteger,
    dtLargeInteger,
    dtDouble,
    dtBoolean,
    dtDateTime,
    dtGuid,
    dtBlob,
    dtVersion);

{ TTColumn }

  TTColumn = class(TTAbstractColumn)
  strict private
    FDataType: TTDataType;
    FSize: Integer;

    procedure SetDataType(const AValue: TTDataType);
    procedure SetSize(const AValue: Integer);
  strict protected
    function GetColumnType: String; override;
  public
    function DataTypeToString: String;

    procedure FromJSon(const AJSon: TJSonValue); override;
    procedure ToJSon(const AJSon: TJSonObject); override;

    property DataType: TTDataType read FDataType write SetDataType;
    property Size: Integer read FSize write SetSize;
  end;

{ TTObjectColumn }

  TTObjectColumn = class(TTAbstractColumn)
  strict private
    FDataType: String;

    procedure SetDataType(const AValue: String);
    function GetObjectName: String;
  strict protected
    function GetColumnType: String; override;
  public
    procedure FromJSon(const AJSon: TJSonValue); override;
    procedure ToJSon(const AJSon: TJSonObject); override;

    property DataType: String read FDataType write SetDatatype;
    property ObjectName: String read GetObjectName;
  end;

{ TTLazyColumn }

  TTLazyColumn = class(TTObjectColumn);

{ TTLazyListColumn }

  TTLazyListColumn = class(TTObjectColumn);

{ TTColumns }

  TTColumns = class
  strict private
    FEntities: ITEntities;
    FEntity: ITEntity;

    FColumns: TObjectList<TTAbstractColumn>;

    procedure NotifyChanged;
    function GetColumns: TList<TTAbstractColumn>;
  public
    constructor Create(const AEntities: ITEntities; const AEntity: ITEntity);
    destructor Destroy; override;

    procedure AddColumn(const AColumn: TTAbstractColumn);
    procedure DeleteColumn(const AColumn: TTAbstractColumn);

    procedure FromJSon(const AJSon: TJSonArray);
    procedure ToJSon(const AJSon: TJSonArray);

    property Columns: TList<TTAbstractColumn> read GetColumns;
  end;

{ TTEntityStatus }

  TTEntityStatus = (
    esUnmodified,
    esModified,
    esDeleted);

{ TNoRefCountObject }

{$IF CompilerVersion < 35}

  TNoRefCountObject = class(TObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

{$ENDIF}

{ TTEntity }

  TTEntity = class(TNoRefCountObject, ITEntity)
  strict private
    FEntityStatus: TTEntityStatus;

    FID: String;
    FName: String;
    FTableName: String;
    FSequenceName: String;
    FColumns: TTColumns;

    procedure FromJSon(const AJSon: TJSonValue);
    procedure ToJSon(const AJSon: TJSonObject);

    function GetNewID: String;
    procedure SetName(const AValue: String);
    procedure SetTableName(const AValue: String);
    procedure SetSequenceName(const AValue: String);

    // ITEntity
    procedure MarkAsModified;
    procedure MarkAsDeleted;
  public
    constructor Create(const AEntities: ITEntities);
    destructor Destroy; override;

    procedure Delete;

    procedure LoadFromFile(const AFileName: String);
    procedure SaveToFile(const AFileName: String);

    property EntityStatus: TTEntityStatus read FEntityStatus;

    property ID: String read FID;
    property Name: String read FName write SetName;
    property TableName: String read FTableName write SetTableName;
    property SequenceName: String read FSequenceName write SetSequenceName;
    property Columns: TTColumns read FColumns;
  end;

{ TTRelation }

  TTRelation = record
  strict private
    FTableName: String;
    FColumnName: String;
    FCascade: Boolean;
  public
    constructor Create(
      const ATableName: String;
      const AColumnName: String;
      const ACascade: Boolean);

    property TableName: String read FTableName;
    property ColumnName: String read FColumnName;
    property Cascade: Boolean read FCascade;
  end;

{ TTEntities }

  TTEntities = class(TNoRefCountObject, ITEntities)
  strict private
    FEntities: TObjectList<TTEntity>;
    FEntityUses: TObjectDictionary<TTEntity, TList<TTEntity>>;
    FEntityRelations: TObjectDictionary<TTEntity, TList<TTRelation>>;

    procedure AddEntityUses(const AEntity: TTEntity);
    procedure AddEntityRelations(const AEntity: TTEntity);

    function GetEntities: TList<TTEntity>;
    function GetEntityUses(const AEntity: TTEntity): TList<TTEntity>;
    function GetEntityRelations(
      const AEntity: TTEntity): TList<TTRelation>;
    function SearchEntityByName(const AName: String): TTEntity;

    // ITEntities
    function GetObjectName(const AID: String): String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddEntity(const AEntity: TTEntity);
    procedure DeleteEntity(const AEntity: TTEntity);

    procedure CalculateUsesAndRelations;

    procedure LoadFromDirectory(const APath: String);
    procedure SaveToDirectory(const APath: String);

    property Entities: TList<TTEntity> read GetEntities;
    property EntityUses[const AEntity: TTEntity]: TList<TTEntity>
      read GetEntityUses;
    property EntityRelations[const AEntity: TTEntity]: TList<TTRelation>
      read GetEntityRelations;
  end;

implementation

{ TTAbstractColumn }

constructor TTAbstractColumn.Create(
  const AEntities: ITEntities; const AEntity: ITEntity);
begin
  inherited Create;
  FEntities := AEntities;
  FEntity := AEntity;
end;

procedure TTAbstractColumn.NotifyChanged;
begin
  FEntity.MarkAsModified;
end;

procedure TTAbstractColumn.SetName(const AValue: String);
begin
  if not FName.Equals(AValue) then
  begin
    FName := AValue;
    NotifyChanged;
  end;
end;

procedure TTAbstractColumn.SetColumnName(const AValue: String);
begin
  if not FColumnName.Equals(AValue) then
  begin
    FColumnName := AValue;
    NotifyChanged;
  end;
end;

procedure TTAbstractColumn.SetRequired(const AValue: Boolean);
begin
  if FRequired <> AValue then
  begin
    FRequired := AValue;
    NotifyChanged;
  end;
end;

procedure TTAbstractColumn.FromJSon(const AJSon: TJSonValue);
begin
  FName := AJSon.GetValue<String>('name', String.Empty);
  FColumnName := AJSon.GetValue<String>('columnName', String.Empty);
  FRequired := AJSon.GetValue<Boolean>('required', false);
end;

procedure TTAbstractColumn.ToJSon(const AJSon: TJSonObject);
begin
  AJSon.AddPair('name', FName);
  AJSon.AddPair('columnName', FColumnName);
  if FRequired then
    AJSon.AddPair('required', TJSonBool.Create(FRequired));
end;

{ TTColumn }

function TTColumn.DataTypeToString: String;
begin
  result := GetEnumName(TypeInfo(TTDataType), Ord(FDataType)).Substring(2);
end;

procedure TTColumn.SetDataType(const AValue: TTDataType);
begin
  if FDataType <> AValue then
  begin
    FDataType := AValue;
    NotifyChanged;
  end;
end;

procedure TTColumn.SetSize(const AValue: Integer);
begin
  if FSize <> AValue then
  begin
    FSize := AValue;
    NotifyChanged;
  end;
end;

function TTColumn.GetColumnType: String;
begin
  case FDataType of
    TTDataType.dtPrimaryKey:
      result := 'TTPrimaryKey';

    TTDataType.dtString,
    TTDataType.dtMemo:
      result := 'String';

    TTDataType.dtSmallint,
    TTDataType.dtInteger:
      result := 'Integer';

    TTDataType.dtLargeInteger:
      result := 'Int64';

    TTDataType.dtDouble:
      result := 'Double';

    TTDataType.dtBoolean:
      result := 'Boolean';

    TTDataType.dtDateTime:
      result := 'TDateTime';

    TTDataType.dtGuid:
      result := 'TGuid';

    TTDataType.dtBlob:
      result := 'TBytes';

    TTDataType.dtVersion:
      result := 'TTVersion';

    else
      raise ETExpertException.Create(SInvalidColumnType);
  end;

  if (not Required) and
    (not (FDataType in [TTDataType.dtPrimaryKey, TTDataType.dtVersion])) then
    result := Format('TTNullable<%s>', [result]);
end;

procedure TTColumn.FromJSon(const AJSon: TJSonValue);
begin
  inherited FromJSon(AJSon);
  FDataType := TTDataType(
    GetEnumValue(
      TypeInfo(TTDataType),
      Format('dt%s', [AJSon.GetValue<String>('type', String.Empty)])));
  FSize := AJSon.GetValue<Integer>('size', 0);
end;

procedure TTColumn.ToJSon(const AJSon: TJSonObject);
begin
  inherited ToJSon(AJSon);
  AJSon.AddPair('type',DataTypeToString);
  if FSize <> 0 then
    AJSon.AddPair('size', TJSonNumber.Create(FSize));
end;

{ TTObjectColumn }

function TTObjectColumn.GetColumnType: String;
begin
  result := FDataType;
end;

function TTObjectColumn.GetObjectName: String;
var
  LIndex: Integer;
  LResult: String;
begin
  result := String.Empty;
  LIndex := FDataType.IndexOf('{');
  if LIndex >= 0  then
  begin
    LResult := FDataType.Substring(LIndex + 1);
    LIndex := LResult.IndexOf('}');
    if LIndex >= 0 then
    begin
      LResult := LResult.Substring(0, LIndex);
      result := FEntities.GetObjectName(LResult);
    end;
  end;
end;

procedure TTObjectColumn.SetDataType(const AValue: String);
begin
  if not FDataType.Equals(AValue) then
  begin
    FDataType := AValue;
    NotifyChanged;
  end;
end;

procedure TTObjectColumn.FromJSon(const AJSon: TJSonValue);
begin
  inherited FromJSon(AJSon);
  FDataType := AJSon.GetValue<String>('type', String.Empty);
end;

procedure TTObjectColumn.ToJSon(const AJSon: TJSonObject);
begin
  inherited ToJSon(AJSon);
  AJSon.AddPair('type', FDataType);
end;

{ TTColumns }

constructor TTColumns.Create(
  const AEntities: ITEntities; const AEntity: ITEntity);
begin
  inherited Create;
  FEntities := AEntities;
  FEntity := AEntity;
  FColumns := TObjectList<TTAbstractColumn>.Create(True);
end;

destructor TTColumns.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

function TTColumns.GetColumns: TList<TTAbstractColumn>;
begin
  result := FColumns;
end;

procedure TTColumns.NotifyChanged;
begin
  FEntity.MarkAsModified;
end;

procedure TTColumns.AddColumn(const AColumn: TTAbstractColumn);
var
  LIndex: Integer;
begin
  LIndex := FColumns.Count - 1;
  if LIndex < 0 then
    FColumns.Add(AColumn)
  else
    FColumns.Insert(LIndex, AColumn);
  NotifyChanged;
end;

procedure TTColumns.DeleteColumn(const AColumn: TTAbstractColumn);
begin
  FColumns.Remove(AColumn);
  NotifyChanged;
end;

procedure TTColumns.FromJSon(const AJSon: TJSonArray);
var
  LValue: TJSonValue;
  LType: String;
  LColumn: TTAbstractColumn;
begin
  for LValue in AJSon do
  begin
    LType := LValue.GetValue<String>('type', String.Empty);
    LColumn := nil;
    try
      if LType.StartsWith('{') and LType.EndsWith('}[]') then
        LColumn := TTLazyListColumn.Create(FEntities, FEntity)
      else if LType.StartsWith('{') and LType.EndsWith('}') then
        LColumn := TTLazyColumn.Create(FEntities, FEntity)
      else
        LColumn := TTColumn.Create(FEntities, FEntity);
      LColumn.FromJSon(LValue);
      FColumns.Add(LColumn);
    except
      if Assigned(LColumn) then
        LColumn.Free;
      raise;
    end;
  end;
end;

procedure TTColumns.ToJSon(const AJSon: TJSonArray);
var
  LColumn: TTAbstractColumn;
  LObject: TJSonObject;
begin
  for LColumn in FColumns do
  begin
    LObject := TJSonObject.Create;
    try
      LColumn.ToJSon(LObject);
      AJSon.AddElement(LObject);
    except
      LObject.Free;
      raise;
    end;
  end;
end;

{$IF CompilerVersion < 35}

{ TNoRefCountObject  }

function TNoRefCountObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNoRefCountObject._AddRef: Integer;
begin
  Result := -1;
end;

function TNoRefCountObject._Release: Integer;
begin
  Result := -1;
end;

{$ENDIF}

{ TTEntity }

constructor TTEntity.Create(const AEntities: ITEntities);
begin
  inherited Create;
  FID := GetNewID;
  FEntityStatus := TTEntityStatus.esUnmodified;
  FColumns := TTColumns.Create(AEntities, Self);
end;

destructor TTEntity.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

function TTEntity.GetNewID: String;
var
  LID: String;
begin
  LID := TGUID.NewGuid().ToString().ToLower();
  result := LID.Substring(1, LID.Length - 2);
end;

procedure TTEntity.SetName(const AValue: String);
begin
  if not FName.Equals(AValue) then
  begin
    FName := AValue;
    MarkAsModified;
  end;
end;

procedure TTEntity.SetTableName(const AValue: String);
begin
  if not FTableName.Equals(AValue) then
  begin
    FTableName := AValue;
    MarkAsModified;
  end;
end;

procedure TTEntity.SetSequenceName(const AValue: String);
begin
  if not FSequenceName.Equals(AValue) then
  begin
    FSequenceName := AValue;
    MarkAsModified;
  end;
end;

procedure TTEntity.Delete;
begin
  MarkAsDeleted;
end;

procedure TTEntity.MarkAsModified;
begin
  FEntityStatus := TTEntityStatus.esModified;
end;

procedure TTEntity.MarkAsDeleted;
begin
  FEntityStatus := TTEntityStatus.esDeleted;
end;

procedure TTEntity.LoadFromFile(const AFileName: String);
var
  LJSon: TJSonValue;
begin
  LJSon := TJSonObject.ParseJSonValue(
    TFile.ReadAllText(AFileName), False, True);
  try
    FromJSon(LJSon);
  finally
    LJSon.Free;
  end;
end;

procedure TTEntity.SaveToFile(const AFileName: String);
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    ToJSon(LJSon);
    TFile.WriteAllText(AFileName, LJSon.Format(2));
  finally
    LJSon.Free;
  end;
end;

procedure TTEntity.FromJSon(const AJSon: TJSonValue);
begin
  FID := AJSon.GetValue<String>('id', String.Empty);
  FName := AJSon.GetValue<String>('name', String.Empty);
  FTableName := AJSon.GetValue<String>('tableName', String.Empty);
  FSequenceName := AJSon.GetValue<String>('sequenceName', String.Empty);
  FColumns.FromJSon(AJSon.GetValue<TJSonArray>('columns', nil));
end;

procedure TTEntity.ToJSon(const AJSon: TJSonObject);
var
  LArray: TJSonArray;
begin
  AJSon.AddPair('id', FID);
  AJSon.AddPair('name', FName);
  AJSon.AddPair('tableName', FTableName);
  AJSon.AddPair('sequenceName', FSequenceName);
  LArray := TJSonArray.Create;
  try
    FColumns.ToJSon(LArray);
    AJSon.AddPair('columns', LArray);
  except
    LArray.Free;
    raise;
  end;
end;

{ TTRelation }

constructor TTRelation.Create(
  const ATableName: String;
  const AColumnName: String;
  const ACascade: Boolean);
begin
  FTableName := ATableName;
  FColumnName := AColumnName;
  FCascade := ACascade;
end;

{ TTEntities }

constructor TTEntities.Create;
begin
  inherited Create;
  FEntities := TObjectList<TTEntity>.Create(True);
  FEntityUses := TObjectDictionary<
    TTEntity, TList<TTEntity>>.Create([doOwnsValues]);
  FEntityRelations := TObjectDictionary<
    TTEntity, TList<TTRelation>>.Create([doOwnsValues]);
end;

destructor TTEntities.Destroy;
begin
  FEntityRelations.Free;
  FEntityUses.Free;
  FEntities.Free;
  inherited Destroy;
end;

function TTEntities.GetEntities: TList<TTEntity>;
begin
  result := FEntities;
end;

procedure TTEntities.AddEntity(const AEntity: TTEntity);
var
  LPrimaryKey, LVersion: TTColumn;
begin
  LPrimaryKey := TTColumn.Create(Self, AEntity);
  try
    LPrimaryKey.Name := 'ID';
    LPrimaryKey.ColumnName := 'ID';
    LPrimaryKey.DataType := TTDataType.dtPrimaryKey;

    LVersion := TTColumn.Create(Self, AEntity);
    try
      LVersion.Name := 'VersionID';
      LVersion.ColumnName := 'VersionID';
      LVersion.DataType := TTDataType.dtVersion;

      AEntity.Columns.AddColumn(LVersion);
      AEntity.Columns.AddColumn(LPrimaryKey);
    except
      LVersion.Free;
      raise;
    end;
  except
    LPrimaryKey.Free;
    raise;
  end;

  FEntities.Add(AEntity);
end;

procedure TTEntities.DeleteEntity(const AEntity: TTEntity);
begin
  AEntity.Delete;
end;

function TTEntities.GetEntityUses(
  const AEntity: TTEntity): TList<TTEntity>;
var
  LResult: TList<TTEntity>;
begin
  result := nil;
  if FEntityUses.TryGetValue(AEntity, LResult) then
    result := LResult;
end;

function TTEntities.GetEntityRelations(
  const AEntity: TTEntity): TList<TTRelation>;
var
  LResult: TList<TTRelation>;
begin
  result := nil;
  if FEntityRelations.TryGetValue(AEntity, LResult) then
    result := LResult;
end;

procedure TTEntities.AddEntityUses(const AEntity: TTEntity);
var
  LList: TList<TTEntity>;
begin
  LList := TList<TTEntity>.Create;
  try
    FEntityUses.Add(AEntity, LList);
  except
    LList.Free;
    raise;
  end;
end;

procedure TTEntities.AddEntityRelations(const AEntity: TTEntity);
var
  LList: TList<TTRelation>;
begin
  LList := TList<TTRelation>.Create;
  try
    FEntityRelations.Add(AEntity, LList);
  except
    LList.Free;
    raise;
  end;
end;

procedure TTEntities.CalculateUsesAndRelations;
var
  LEntity, LUsedEntity: TTEntity;
  LColumn: TTAbstractColumn;
  LUses: TList<TTEntity>;
  LRelations: TList<TTRelation>;
begin
  FEntityUses.Clear;
  FEntityRelations.Clear;
  for LEntity in FEntities do
  begin
    AddEntityUses(LEntity);
    AddEntityRelations(LEntity);
  end;

  for LEntity in FEntities do
    if FEntityUses.TryGetValue(LEntity, LUses) then
      for LColumn in LEntity.Columns.Columns do
        if LColumn is TTObjectColumn then
        begin
          LUsedEntity := SearchEntityByName(TTObjectColumn(LColumn).ObjectName);
          if LUsedEntity <> LEntity then
            LUses.Add(LUsedEntity);

          if FEntityRelations.TryGetValue(LUsedEntity, LRelations) then
            LRelations.Add(
              TTRelation.Create(
                LEntity.TableName,
                LColumn.ColumnName,
                (LColumn is TTLazyListColumn)));
        end;
end;

function TTEntities.SearchEntityByName(const AName: String): TTEntity;
var
  LEntity: TTEntity;
begin
  result := nil;
  for LEntity in FEntities do
    if String.Compare(LEntity.Name, AName, True) = 0 then
    begin
      result := LEntity;
      Break;
    end;

  if not Assigned(result) then
    raise ETExpertException.CreateFmt(SEntityNotFound, [AName]);
end;

function TTEntities.GetObjectName(const AID: String): String;
var
  LEntity: TTEntity;
begin
  result := String.Empty;
  for LEntity in FEntities do
    if String.Compare(LEntity.ID, AID) = 0 then
    begin
      result := LEntity.Name;
      Break;
    end;
end;

procedure TTEntities.LoadFromDirectory(const APath: String);
var
  LFile: String;
  LEntity: TTEntity;
begin
  for LFile in TDirectory.GetFiles(APath, '*.json') do
  begin
    LEntity := TTEntity.Create(Self);
    try
      LEntity.LoadFromFile(LFile);
      FEntities.Add(LEntity);
    except
      LEntity.Free;
      raise;
    end;
  end;
end;

procedure TTEntities.SaveToDirectory(const APath: String);
var
  LEntity: TTEntity;
  LFile: String;
begin
  for LEntity in FEntities do
  begin
    LFile := TPath.Combine(APath, Format('%s.json', [LEntity.Name.ToLower()]));
    case LEntity.EntityStatus of
      esModified:
        LEntity.SaveToFile(LFile);

      esDeleted:
        TFile.Delete(LFile);
    end;
  end;
end;

end.
