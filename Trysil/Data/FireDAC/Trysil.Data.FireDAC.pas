(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

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
  Trysil.Data.FireDAC.ConnectionPool;

type

{ TTFDParam }

  TTFDParam = class(TTParam)
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

{ TTFireDACConnection }

  TTFireDACConnection = class abstract(TTGenericConnection)
  strict private
    FConnectionName: String;

    FWaitCursor: TFDGUIxWaitCursor;
    FConnection: TFDConnection;

    procedure SetParameters(
      const ADataSet: TFDQuery;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject);
  strict protected
    function InternalCreateDataSet(const ASQL: String): TDataSet; override;
    function GetInTransaction: Boolean; override;
  public
    constructor Create(const AConnectionName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;

    function Execute(
      const ASQL: String;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; override;
  end;

implementation

{ TTFDParam }

constructor TTFDParam.Create(const AParam: TFDParam);
begin
  inherited Create;
  FParam := AParam;
  FSize := AParam.Size;
end;

procedure TTFDParam.Clear;
begin
  FParam.Clear;
end;

function TTFDParam.GetAsString: String;
begin
  result := FParam.AsString;
end;

procedure TTFDParam.SetAsString(const AValue: String);
begin
  FParam.AsString := AValue;
end;

function TTFDParam.GetAsInteger: Integer;
begin
  result := FParam.AsInteger;
end;

procedure TTFDParam.SetAsInteger(const AValue: Integer);
begin
  FParam.AsInteger := AValue;
end;

function TTFDParam.GetAsLargeInt: Int64;
begin
  result := FParam.AsLargeInt;
end;

procedure TTFDParam.SetAsLargeInt(const AValue: Int64);
begin
  FParam.AsLargeInt := AValue;
end;

function TTFDParam.GetAsDouble: Double;
begin
  result := FParam.AsFloat;
end;

procedure TTFDParam.SetAsDouble(const AValue: Double);
begin
  FParam.AsFloat := AValue;
end;

function TTFDParam.GetAsBoolean: Boolean;
begin
  result := FParam.AsBoolean;
end;

procedure TTFDParam.SetAsBoolean(const AValue: Boolean);
begin
  FParam.AsBoolean := AValue;
end;

function TTFDParam.GetAsDateTime: TDateTime;
begin
  result := FParam.AsDateTime;
end;

procedure TTFDParam.SetAsDateTime(const AValue: TDateTime);
begin
  FParam.AsDateTime := AValue;
end;

function TTFDParam.GetAsGuid: TGUID;
begin
  result := FParam.AsGUID;
end;

procedure TTFDParam.SetAsGuid(const AValue: TGUID);
begin
  FParam.AsGUID := AValue;
end;

{ TTFireDACConnection }

constructor TTFireDACConnection.Create(const AConnectionName: String);
begin
  inherited Create;
  FConnectionName := AConnectionName;

  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FConnection := TFDConnection.Create(nil);
end;

destructor TTFireDACConnection.Destroy;
begin
  FConnection.Free;
  FWaitCursor.Free;
  inherited Destroy;
end;

procedure TTFireDACConnection.AfterConstruction;
begin
  inherited AfterConstruction;
  FWaitCursor.Provider := 'Console';
  FWaitCursor.ScreenCursor := TFDGUIxScreenCursor.gcrNone;

  FConnection.ConnectionDefName := FConnectionName;
  FConnection.LoginPrompt := False;
  FConnection.Open;
end;

function TTFireDACConnection.Execute(
  const ASQL: String;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject): Integer;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(nil);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;

    if Assigned(ATableMap) and
      Assigned(ATableMetadata) and
      Assigned(AEntity) then
      SetParameters(
        LDataSet, ATableMap, ATableMetadata, AEntity);

    LDataSet.ExecSQL;
    result := LDataSet.RowsAffected;
  finally
    LDataSet.Free;
  end;
end;

procedure TTFireDACConnection.StartTransaction;
begin
  inherited StartTransaction;
  FConnection.StartTransaction;
end;

procedure TTFireDACConnection.CommitTransaction;
begin
  inherited CommitTransaction;
  FConnection.Commit;
end;

procedure TTFireDACConnection.RollbackTransaction;
begin
  inherited RollbackTransaction;
  FConnection.Rollback;
end;

function TTFireDACConnection.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

procedure TTFireDACConnection.SetParameters(
  const ADataSet: TFDQuery;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject);
var
  LColumn: TTColumnMetadata;
  LParam: TTParam;
  LParameter: TTParameter;
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

      LParam := TTFDParam.Create(LFireDACParam);
      try
        LParameter := TTParameterFactory.Instance.CreateParameter(
          LColumn.DataType,
          LParam,
          GetColumnMap(ATableMap, LColumn.ColumnName));
        try
          LParameter.SetValue(AEntity);
        finally
          LParameter.Free;
        end;
      finally
        LParam.Free;
      end;
    end;
  end;
end;

function TTFireDACConnection.InternalCreateDataSet(
  const ASQL: String): TDataSet;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(nil);
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
