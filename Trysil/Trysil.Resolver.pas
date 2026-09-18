(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Resolver;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,
  System.Generics.Collections,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Data,
  Trysil.Transaction,
  Trysil.Validation,
  Trysil.Events.Abstract,
  Trysil.Events.Factory;

type

{ TTResolverValidator }

  TTResolverValidator = class
  strict private
    FContext: TObject;
    FTableMap: TTTableMap;
    FEntity: TObject;
    FErrors: TTValidationErrors;

    function TryInvoke(
      const AValidatorMap: TTValidatorMap): Boolean;
    procedure Invoke(
      const AValidatorMap: TTValidatorMap;
      const AArgs: TArray<TTValue>);

    procedure ValidateColumns;
    procedure ValidateMethods;
  public
    constructor Create(
      const AContext: TObject;
      const ATableMap: TTTableMap;
      const AEntity: TObject;
      const AErrors: TTValidationErrors);

    procedure Execute;
  end;

{ TTEntityUndoEntry }

  TTEntityUndoEntry = record
  strict private
    FEntity: TObject;
    FMember: TTRttiMember;
    FValue: TTValue;
  public
    constructor Create(
      const AEntity: TObject;
      const AMember: TTRttiMember;
      const AValue: TTValue);

    procedure Undo;

    property Entity: TObject read FEntity;
  end;

{ TTEntityUndoLog }

  TTEntityUndoLog = class(TTTransactionObserver)
  strict private
    FEntries: TList<TTEntityUndoEntry>;
    FInTransaction: Boolean;

    procedure Clear;
  strict protected
    procedure TransactionStarted; override;
    procedure TransactionCommitted; override;
    procedure TransactionRolledback; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Save(const AEntity: TObject; const AMember: TTRttiMember);
    procedure DisposedEntity(const AEntity: TObject);
  end;

{ TTResolver }

  TTResolver = class
  strict private
    FConnection: TTConnection;
    FContext: TObject;
    FMetadata: TTMetadata;
    FUndoLog: TTEntityUndoLog;
    FOnGetCurrentUser: TFunc<String>;

    function CreateOperationTransaction: TTTransaction;
    procedure CheckReadWrite(const ATableMap: TTTableMap);

    procedure CheckPrimaryKey(
      const AEntity: TObject; const ATableMap: TTTableMap);
    procedure ExecuteValidators(
      const AEntity: TObject; const ATableMap: TTTableMap);
    procedure ApplyChangeTrackingAt(
      const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
    procedure ApplyChangeTrackingBy(
      const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
    procedure ApplyChangeTracking(
      const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
    procedure ClearChangeTrackingAt(
      const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
    procedure ClearChangeTrackingBy(
      const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
    procedure ClearChangeTracking(
      const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
    procedure IncrementVersion(
      const AEntity: TObject; const ATableMap: TTTableMap);
    procedure InternalUpdate<T: class>(
      const AEntity: T;
      const ATableMap: TTTableMap;
      const ACommand: TTAbstractCommand);
    procedure InternalInsert<T: class>(const AEntity: T);
    procedure InternalUpdateEntity<T: class>(const AEntity: T);
    procedure InternalDelete<T: class>(const AEntity: T);
    procedure InternalUndelete<T: class>(const AEntity: T);
  strict protected
    function GetValidationErrorMessage(
      const AErrors: TTValidationErrors): String; virtual;
  public
    constructor Create(
      const AConnection: TTConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata);
    destructor Destroy; override;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure DisposedEntity(const AEntity: TObject);

    procedure Validate<T: class>(const AEntity: T);

    procedure Insert<T: class>(const AEntity: T);
    procedure Update<T: class>(const AEntity: T);
    procedure Delete<T: class>(const AEntity: T);
    procedure Undelete<T: class>(const AEntity: T);

    property OnGetCurrentUser: TFunc<String>
      read FOnGetCurrentUser write FOnGetCurrentUser;
  end;

implementation

{ TTResolverValidator }

constructor TTResolverValidator.Create(
  const AContext: TObject;
  const ATableMap: TTTableMap;
  const AEntity: TObject;
  const AErrors: TTValidationErrors);
begin
  inherited Create;
  FContext := AContext;
  FTableMap := ATableMap;
  FEntity := AEntity;
  FErrors := AErrors;
end;

procedure TTResolverValidator.Execute;
begin
  ValidateColumns;
  ValidateMethods;
end;

function TTResolverValidator.TryInvoke(
  const AValidatorMap: TTValidatorMap): Boolean;
var
  LLength: Integer;
begin
  LLength := Length(AValidatorMap.Parameters);
  result := (LLength = 0);
  if result then
    Invoke(AValidatorMap, [])
  else if LLength = 1 then
  begin
    result := TTRtti.InheritsFrom(
      FErrors, AValidatorMap.Parameters[0].ParamType);
    if result then
      Invoke(AValidatorMap, [FErrors]);
  end
  else if LLength = 2 then
  begin
    result :=
      TTRtti.InheritsFrom(FContext, AValidatorMap.Parameters[0].ParamType) and
      TTRtti.InheritsFrom(FErrors, AValidatorMap.Parameters[1].ParamType);
    if result then
      Invoke(AValidatorMap, [FContext, FErrors])
  end;
end;

procedure TTResolverValidator.Invoke(
  const AValidatorMap: TTValidatorMap; const AArgs: TArray<TTValue>);
begin
  AValidatorMap.Method.Invoke(FEntity, AArgs);
end;

procedure TTResolverValidator.ValidateColumns;
var
  LColumnMap: TTColumnMap;
begin
  for LColumnMap in FTableMap.Columns do
    LColumnMap.Validate(FEntity, FErrors);
end;

procedure TTResolverValidator.ValidateMethods;
var
  LValidatorMap: TTValidatorMap;
begin
  for LValidatorMap in FTableMap.Validators do
    if not TryInvoke(LValidatorMap) then
      FErrors.Add(String.Empty, Format(SNotValidValidator, [
        LValidatorMap.Method.Name, FEntity.ClassName]));
end;

{ TTEntityUndoEntry }

constructor TTEntityUndoEntry.Create(
  const AEntity: TObject;
  const AMember: TTRttiMember;
  const AValue: TTValue);
begin
  FEntity := AEntity;
  FMember := AMember;
  FValue := AValue;
end;

procedure TTEntityUndoEntry.Undo;
begin
  FMember.SetValue(FEntity, FValue);
end;

{ TTEntityUndoLog }

constructor TTEntityUndoLog.Create;
begin
  inherited Create;
  FEntries := TList<TTEntityUndoEntry>.Create;
  FInTransaction := False;
end;

destructor TTEntityUndoLog.Destroy;
begin
  FEntries.Free;
  inherited Destroy;
end;

procedure TTEntityUndoLog.Clear;
begin
  FEntries.Clear;
end;

procedure TTEntityUndoLog.TransactionStarted;
begin
  Clear;
  FInTransaction := True;
end;

procedure TTEntityUndoLog.TransactionCommitted;
begin
  FInTransaction := False;
  Clear;
end;

procedure TTEntityUndoLog.TransactionRolledback;
var
  LIndex: Integer;
  LEntry: TTEntityUndoEntry;
begin
  FInTransaction := False;
  for LIndex := FEntries.Count - 1 downto 0 do
  begin
    LEntry := FEntries[LIndex];
    LEntry.Undo;
  end;
  Clear;
end;

procedure TTEntityUndoLog.Save(
  const AEntity: TObject; const AMember: TTRttiMember);
begin
  if FInTransaction then
    FEntries.Add(
      TTEntityUndoEntry.Create(AEntity, AMember, AMember.GetValue(AEntity)));
end;

procedure TTEntityUndoLog.DisposedEntity(const AEntity: TObject);
var
  LIndex: Integer;
begin
  for LIndex := FEntries.Count - 1 downto 0 do
    if FEntries[LIndex].Entity = AEntity then
      FEntries.Delete(LIndex);
end;

{ TTResolver }

constructor TTResolver.Create(
  const AConnection: TTConnection;
  const AContext: TObject;
  const AMetadata: TTMetadata);
begin
  inherited Create;
  FConnection := AConnection;
  FContext := AContext;
  FMetadata := AMetadata;
  FUndoLog := TTEntityUndoLog.Create;
  FOnGetCurrentUser := nil;
end;

destructor TTResolver.Destroy;
begin
  FUndoLog.Free;
  inherited Destroy;
end;

procedure TTResolver.AfterConstruction;
begin
  inherited AfterConstruction;
  FConnection.AddTransactionObserver(FUndoLog);
end;

procedure TTResolver.BeforeDestruction;
begin
  if Assigned(FConnection) then
    FConnection.RemoveTransactionObserver(FUndoLog);
  inherited BeforeDestruction;
end;

procedure TTResolver.DisposedEntity(const AEntity: TObject);
begin
  FUndoLog.DisposedEntity(AEntity);
end;

function TTResolver.CreateOperationTransaction: TTTransaction;
begin
  result := nil;
  if not FConnection.InTransaction then
    result := TTTransaction.Create(
      FConnection, TTTransactionMode.RollbackOnDestroy);
end;

procedure TTResolver.CheckReadWrite(const ATableMap: TTTableMap);
begin
  if ATableMap.HasJoins then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SJoinEntityReadOnly));

  case FConnection.UpdateMode of
    TTUpdateMode.KeyAndVersionColumn:
      if (not Assigned(ATableMap.PrimaryKey)) or
        (not Assigned(ATableMap.VersionColumn)) then
        raise ETException.Create(TTLanguage.Instance.Translate(SReadOnly));

    TTUpdateMode.KeyOnly:
      if not Assigned(ATableMap.PrimaryKey) then
        raise ETException.Create(
          TTLanguage.Instance.Translate(SReadOnlyPrimaryKey));
  end;
end;

function TTResolver.GetValidationErrorMessage(
  const AErrors: TTValidationErrors): String;
begin
  result := AErrors.ToString();
end;

procedure TTResolver.CheckPrimaryKey(
  const AEntity: TObject; const ATableMap: TTTableMap);
var
  LValue: TTValue;
begin
  if Assigned(ATableMap.PrimaryKey) then
  begin
    LValue := ATableMap.PrimaryKey.Member.GetValue(AEntity);
    if LValue.IsType<TTPrimaryKey>() and
      (LValue.AsType<TTPrimaryKey>() = 0) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SNotAssignedPrimaryKey), [
          ATableMap.PrimaryKey.Name]);
  end;
end;

procedure TTResolver.ExecuteValidators(
  const AEntity: TObject; const ATableMap: TTTableMap);
var
  LErrors: TTValidationErrors;
  LValidator: TTResolverValidator;
begin
  LErrors := TTValidationErrors.Create;
  try
    LValidator := TTResolverValidator.Create(
      FContext, ATableMap, AEntity, LErrors);
    try
      LValidator.Execute;
    finally
      LValidator.Free;
    end;
    if not LErrors.IsEmpty then
      raise ETValidationException.Create(GetValidationErrorMessage(LErrors));
  finally
    LErrors.Free;
  end;
end;

procedure TTResolver.ApplyChangeTrackingAt(
  const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
var
  LDateTime: TTNullable<TDateTime>;
  LValue: TTValue;
begin
  LDateTime := TTNullable<TDateTime>.Create(Now);
  TTValue.Make(
    @LDateTime, AChangeTracking.ChangedAt.Member.RttiType.Handle, LValue);
  FUndoLog.Save(AEntity, AChangeTracking.ChangedAt.Member);
  AChangeTracking.ChangedAt.Member.SetValue(AEntity, LValue);
end;

procedure TTResolver.ApplyChangeTrackingBy(
  const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
var
  LCurrentUser: String;
begin
  LCurrentUser := String.Empty;
  if Assigned(FOnGetCurrentUser) then
    LCurrentUser := FOnGetCurrentUser();

  FUndoLog.Save(AEntity, AChangeTracking.ChangedBy.Member);
  AChangeTracking.ChangedBy.Member.SetValue(
      AEntity, TTValue.From<String>(LCurrentUser));
end;

procedure TTResolver.ApplyChangeTracking(
  const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
begin
  if Assigned(AChangeTracking.ChangedAt) then
    ApplyChangeTrackingAt(AEntity, AChangeTracking);
  if Assigned(AChangeTracking.ChangedBy) then
    ApplyChangeTrackingBy(AEntity, AChangeTracking);
end;

procedure TTResolver.ClearChangeTrackingAt(
  const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
var
  LDateTime: TTNullable<TDateTime>;
  LValue: TTValue;
begin
  LDateTime := Default(TTNullable<TDateTime>);
  TTValue.Make(
    @LDateTime, AChangeTracking.ChangedAt.Member.RttiType.Handle, LValue);
  FUndoLog.Save(AEntity, AChangeTracking.ChangedAt.Member);
  AChangeTracking.ChangedAt.Member.SetValue(AEntity, LValue);
end;

procedure TTResolver.ClearChangeTrackingBy(
  const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
begin
  FUndoLog.Save(AEntity, AChangeTracking.ChangedBy.Member);
  AChangeTracking.ChangedBy.Member.SetValue(
      AEntity, TTValue.From<String>(String.Empty));
end;

procedure TTResolver.ClearChangeTracking(
  const AEntity: TObject; const AChangeTracking: TTChangeTrackingMap);
begin
  if Assigned(AChangeTracking.ChangedAt) then
    ClearChangeTrackingAt(AEntity, AChangeTracking);
  if Assigned(AChangeTracking.ChangedBy) then
    ClearChangeTrackingBy(AEntity, AChangeTracking);
end;

procedure TTResolver.IncrementVersion(
  const AEntity: TObject; const ATableMap: TTTableMap);
begin
  if Assigned(ATableMap.VersionColumn) then
  begin
    FUndoLog.Save(AEntity, ATableMap.VersionColumn.Member);
    ATableMap.VersionColumn.Member.SetValue(
      AEntity,
      ATableMap.VersionColumn.Member.GetValue(AEntity).AsType<TTVersion>() + 1);
  end;
end;

procedure TTResolver.Validate<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  ExecuteValidators(AEntity, LTableMap);
end;

procedure TTResolver.InternalInsert<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
  LEvent: TTEvent;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  ApplyChangeTracking(AEntity, LTableMap.Columns.CreatedChangeTracking);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateInsertCommand(LTableMap, LTableMetadata);
  try
    LEvent := TTEventFactory.Instance.CreateEvent<T>(
      LTableMap.Events.InsertEventClass, FContext, AEntity);
    try
      LCommand.Execute(AEntity, LEvent);
    finally
      if Assigned(LEvent) then
        LEvent.Free;
    end;
    if Assigned(LTableMap.VersionColumn) then
    begin
      FUndoLog.Save(AEntity, LTableMap.VersionColumn.Member);
      LTableMap.VersionColumn.Member.SetValue(AEntity, 0);
    end;
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Insert<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTransaction: TTTransaction;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  CheckReadWrite(LTableMap);
  CheckPrimaryKey(AEntity, LTableMap);
  ExecuteValidators(AEntity, LTableMap);

  LTransaction := CreateOperationTransaction;
  try
    InternalInsert<T>(AEntity);
    if Assigned(LTransaction) then
      LTransaction.Commit;
  finally
    if Assigned(LTransaction) then
      LTransaction.Free;
  end;
end;

procedure TTResolver.InternalUpdate<T>(
  const AEntity: T;
  const ATableMap: TTTableMap;
  const ACommand: TTAbstractCommand);
var
  LEvent: TTEvent;
begin
  LEvent := TTEventFactory.Instance.CreateEvent<T>(
    ATableMap.Events.UpdateEventClass, FContext, AEntity);
  try
    ACommand.Execute(AEntity, LEvent);
  finally
    if Assigned(LEvent) then
      LEvent.Free;
  end;
  IncrementVersion(AEntity, ATableMap);
end;

procedure TTResolver.InternalUpdateEntity<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  ApplyChangeTracking(AEntity, LTableMap.Columns.UpdatedChangeTracking);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateUpdateCommand(LTableMap, LTableMetadata);
  try
    InternalUpdate<T>(AEntity, LTableMap, LCommand);
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Update<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTransaction: TTTransaction;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  CheckReadWrite(LTableMap);
  ExecuteValidators(AEntity, LTableMap);

  LTransaction := CreateOperationTransaction;
  try
    InternalUpdateEntity<T>(AEntity);
    if Assigned(LTransaction) then
      LTransaction.Commit;
  finally
    if Assigned(LTransaction) then
      LTransaction.Free;
  end;
end;

procedure TTResolver.InternalDelete<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
  LEvent: TTEvent;
  LSoftDelete: Boolean;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  LTableMetadata := FMetadata.Load<T>();

  LSoftDelete := Assigned(LTableMap.Columns.DeletedChangeTracking.ChangedAt);
  if LSoftDelete then
  begin
    ApplyChangeTracking(AEntity, LTableMap.Columns.DeletedChangeTracking);
    LCommand := FConnection.CreateSoftDeleteCommand(LTableMap, LTableMetadata);
  end
  else
  begin
    FConnection.CheckRelations(LTableMap, AEntity);
    LCommand := FConnection.CreateDeleteCommand(LTableMap, LTableMetadata);
  end;

  try
    LEvent := TTEventFactory.Instance.CreateEvent<T>(
      LTableMap.Events.DeleteEventClass, FContext, AEntity);
    try
      LCommand.Execute(AEntity, LEvent);
    finally
      if Assigned(LEvent) then
        LEvent.Free;
    end;
    if LSoftDelete then
      IncrementVersion(AEntity, LTableMap);
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Delete<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTransaction: TTTransaction;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  CheckReadWrite(LTableMap);

  LTransaction := CreateOperationTransaction;
  try
    InternalDelete<T>(AEntity);
    if Assigned(LTransaction) then
      LTransaction.Commit;
  finally
    if Assigned(LTransaction) then
      LTransaction.Free;
  end;
end;

procedure TTResolver.InternalUndelete<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  ClearChangeTracking(AEntity, LTableMap.Columns.DeletedChangeTracking);
  ApplyChangeTracking(AEntity, LTableMap.Columns.UpdatedChangeTracking);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateUndeleteCommand(LTableMap, LTableMetadata);
  try
    InternalUpdate<T>(AEntity, LTableMap, LCommand);
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Undelete<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTransaction: TTTransaction;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  if not Assigned(LTableMap.Columns.DeletedChangeTracking.ChangedAt) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SUndeleteNotSupported));

  CheckReadWrite(LTableMap);
  ExecuteValidators(AEntity, LTableMap);

  LTransaction := CreateOperationTransaction;
  try
    InternalUndelete<T>(AEntity);
    if Assigned(LTransaction) then
      LTransaction.Commit;
  finally
    if Assigned(LTransaction) then
      LTransaction.Free;
  end;
end;

end.
