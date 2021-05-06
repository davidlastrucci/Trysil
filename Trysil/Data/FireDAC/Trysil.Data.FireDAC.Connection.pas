(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Data,
  Trysil.Data.SqlSyntax,
  Trysil.Data.Connection,
  Trysil.Data.Parameters,
  Trysil.Events.Abstract,
  Trysil.Data.FireDAC.Common,
  Trysil.Data.FireDAC;

type

{ TTFDDatasetParam }

  TTFDDatasetParam = class(TTDatasetParam)
  strict private
    FParam: TFDParam;
  strict protected
    function GetAsString: String; override;
    procedure SetAsString(const AValue: String); override;
    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const AValue: Integer); override;
    function GetAsLargeInt: Int64; override;
    procedure SetAsLargeInt(const AValue: Int64); override;
    function GetAsDouble: Double; override;
    procedure SetAsDouble(const AValue: Double); override;
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const AValue: Boolean); override;
    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const AValue: TDateTime); override;
    function GetAsGuid: TGUID; override;
    procedure SetAsGuid(const AValue: TGUID); override;
  public
    constructor Create(const AParam: TFDParam);

    procedure Clear; override;
  end;

{ TTDataFireDACConnection }

  TTDataFireDACConnection = class abstract(TTDataGenericConnection)
  strict private
    FConnectionName: String;

    FWaitCursor: TFDGUIxWaitCursor;
    FConnection: TFDConnection;

    function CreateDatasetParam(const AParam: TFDParam): TTDatasetParam;

    function GetColumnMap(
      const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;

    procedure SetDatasetParameters(
      const ADataSet: TFDQuery;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject);
  strict protected
    function GetInTransaction: Boolean; override;
  public
    constructor Create(const AConnectionName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;

    function CreateDataSet(const ASQL: String): TDataSet; override;
    function Execute(
      const ASQL: String;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; override;
  end;

implementation

{ TTFDDatasetParam }

constructor TTFDDatasetParam.Create(const AParam: TFDParam);
begin
  inherited Create;
  FParam := AParam;
end;

procedure TTFDDatasetParam.Clear;
begin
  FParam.Clear;
end;

function TTFDDatasetParam.GetAsString: String;
begin
  result := FParam.AsString;
end;

procedure TTFDDatasetParam.SetAsString(const AValue: String);
begin
  FParam.AsString := AValue;
end;

function TTFDDatasetParam.GetAsInteger: Integer;
begin
  result := FParam.AsInteger;
end;

procedure TTFDDatasetParam.SetAsInteger(const AValue: Integer);
begin
  FParam.AsInteger := AValue;
end;

function TTFDDatasetParam.GetAsLargeInt: Int64;
begin
  result := FParam.AsLargeInt;
end;

procedure TTFDDatasetParam.SetAsLargeInt(const AValue: Int64);
begin
  FParam.AsLargeInt := AValue;
end;

function TTFDDatasetParam.GetAsDouble: Double;
begin
  result := FParam.AsFloat;
end;

procedure TTFDDatasetParam.SetAsDouble(const AValue: Double);
begin
  FParam.AsFloat := AValue;
end;

function TTFDDatasetParam.GetAsBoolean: Boolean;
begin
  result := FParam.AsBoolean;
end;

procedure TTFDDatasetParam.SetAsBoolean(const AValue: Boolean);
begin
  FParam.AsBoolean := AValue;
end;

function TTFDDatasetParam.GetAsDateTime: TDateTime;
begin
  result := FParam.AsDateTime;
end;

procedure TTFDDatasetParam.SetAsDateTime(const AValue: TDateTime);
begin
  FParam.AsDateTime := AValue;
end;

function TTFDDatasetParam.GetAsGuid: TGUID;
begin
  result := FParam.AsGUID;
end;

procedure TTFDDatasetParam.SetAsGuid(const AValue: TGUID);
begin
  FParam.AsGUID := AValue;
end;

{ TTDataFireDACConnection }

constructor TTDataFireDACConnection.Create(const AConnectionName: String);
begin
    inherited Create;
    FConnectionName := AConnectionName;

    FWaitCursor := TFDGUIxWaitCursor.Create(nil);
    FConnection := TFDConnection.Create(nil);
end;

destructor TTDataFireDACConnection.Destroy;
begin
    FConnection.Free;
    FWaitCursor.Free;
    inherited Destroy;
end;

function TTDataFireDACConnection.Execute(
  const ASQL: String;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject): Integer;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(FConnection);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;

    if Assigned(AMapper) and Assigned(ATableMap) and
      Assigned(ATableMetadata) and Assigned(AEntity) then
      SetDatasetParameters(
        LDataSet, AMapper, ATableMap, ATableMetadata, AEntity);

    LDataSet.ExecSQL;
    result := LDataSet.RowsAffected;
  except
    LDataSet.Free;
    raise;
  end;
end;

procedure TTDataFireDACConnection.AfterConstruction;
begin
  inherited AfterConstruction;
  FWaitCursor.Provider := 'Console';
  FWaitCursor.ScreenCursor := TFDGUIxScreenCursor.gcrNone;

  FConnection.ConnectionDefName := FConnectionName;
  FConnection.Open;
end;

procedure TTDataFireDACConnection.StartTransaction;
begin
  if FConnection.InTransaction then
    raise ETException.CreateFmt(SInTransaction, ['StartTransaction']);
  FConnection.StartTransaction;
end;

procedure TTDataFireDACConnection.CommitTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['CommitTransaction']);
  FConnection.Commit;
end;

procedure TTDataFireDACConnection.RollbackTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['RollbackTransaction']);
  FConnection.Rollback;
end;

function TTDataFireDACConnection.CreateDatasetParam(
  const AParam: TFDParam): TTDatasetParam;
begin
  result := TTFDDatasetParam.Create(AParam);
end;

function TTDataFireDACConnection.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

function TTDataFireDACConnection.GetColumnMap(
  const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;
var
  LColumn: TTColumnMap;
begin
  result := nil;
  for LColumn in ATableMap.Columns do
    if LColumn.Name.Equals(AColumnName) then
    begin
      result := LColumn;
      Break;
    end;

  if not Assigned(result) then
    raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);
end;

procedure TTDataFireDACConnection.SetDatasetParameters(
  const ADataSet: TFDQuery;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject);
var
  LColumn: TTColumnMetadata;
  LDatasetParam: TTDatasetParam;
  LParameter: TTDataParameter;
  LFireDACParam: TFDParam;
begin
  for LColumn in ATableMetadata.Columns do
  begin
    LFireDACParam := ADataset.Params.FindParam(
      GetParameterName(LColumn.ColumnName));
    if Assigned(LFireDACParam) then
    begin
      LFireDACParam.ParamType := TParamType.ptInput;
      LFireDACParam.DataType := LColumn.DataType;
      LFireDACParam.Size := LColumn.DataSize;

      LDatasetParam := CreateDatasetParam(LFireDACParam);
      try
        LParameter := TTDataParameterFactory.Instance.CreateParameter(
          LColumn.DataType,
          LDatasetParam,
          AMapper,
          GetColumnMap(ATableMap, LColumn.ColumnName));
        try
          LParameter.SetValue(AEntity);
        finally
          LParameter.Free;
        end;
      finally
        LDatasetParam.Free;
      end;
    end;
  end;
end;

function TTDataFireDACConnection.CreateDataSet(const ASQL: String): TDataSet;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(FConnection);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;
  except
    LDataSet.Free;
    raise;
  end;
  result := LDataSet;
end;

end.
