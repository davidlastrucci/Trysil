(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Filter;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,

  Trysil.Rtti;

type

{ TTFilterPaging }

  TTFilterPaging = record
  strict private
    FStart: Integer;
    FLimit: Integer;
    FOrderBy: String;

    function GetIsEmpty: Boolean;
    function GetHasPagination: Boolean;
  public
    constructor Create(
      const AStart: Integer; const ALimit: Integer; const AOrderBy: String);

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
    class operator Initialize(out AFilterPaging: TTFilterPaging);
{$ENDIF}

    property Start: Integer read FStart write FStart;
    property Limit: Integer read FLimit write FLimit;
    property OrderBy: String read FOrderBy write FOrderBy;
    property IsEmpty: Boolean read GetIsEmpty;
    property HasPagination: Boolean read GetHasPagination;

    class function Empty: TTFilterPaging; static;
  end;

{ TTFilterParameter }

  TTFilterParameter = record
  strict private
    FName: String;
    FDataType: TFieldType;
    FSize: Integer;
    FValue: TTValue;
  public
    constructor Create(
      const AName: String;
      const ADataType: TFieldType;
      const ASize: Integer;
      const AValue: TTValue);

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
    class operator Initialize(out AFilterParameter: TTFilterParameter);
{$ENDIF}

    property Name: String read FName;
    property DataType: TFieldType read FDataType;
    property Size: Integer read FSize;
    property Value: TTValue read FValue;
  end;

{ TTFilter }

  TTFilter = record
  strict private
    FWhere: String;
    FParameters: TArray<TTFilterParameter>;
    FPaging: TTFilterPaging;

    function GetIsEmpty: Boolean;
  public
    constructor Create(const AWhere: String); overload;

    constructor Create(
      const AWhere: String;
      const AMaxRecord: Integer;
      const AOrderBy: String); overload;

    constructor Create(
      const AWhere: String;
      const AStart: Integer;
      const ALimit: Integer;
      const AOrderBy: String); overload;

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
    class operator Initialize(out AFilter: TTFilter);
{$ENDIF}

    procedure AddParameter(
      const AName: String;
      const ADataType: TFieldType;
      const AValue: TTValue); overload;

    procedure AddParameter(
      const AName: String;
      const ADataType: TFieldType;
      const ASize: Integer;
      const AValue: TTValue); overload;

    property Where: String read FWhere write FWhere;
    property Parameters: TArray<TTFilterParameter> read FParameters;
    property Paging: TTFilterPaging read FPaging;
    property IsEmpty: Boolean read GetIsEmpty;

    class function Empty: TTFilter; static;
  end;

implementation

{ TTFilterPaging }

constructor TTFilterPaging.Create(
  const AStart: Integer;
  const ALimit: Integer;
  const AOrderBy: String);
begin
  FStart := AStart;
  FLimit := ALimit;
  FOrderBy := AOrderBy;
end;

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
class operator TTFilterPaging.Initialize(out AFilterPaging: TTFilterPaging);
begin
  AFilterPaging.FStart := -1;
  AFilterPaging.FLimit := -1;
  AFilterPaging.FOrderBy := String.Empty;
end;
{$ENDIF}

function TTFilterPaging.GetIsEmpty: Boolean;
begin
  result := (FStart < 0) or (FLimit <= 0);
end;

function TTFilterPaging.GetHasPagination: Boolean;
begin
  result := (FStart >= 0) and (FLimit > 0);
end;

class function TTFilterPaging.Empty: TTFilterPaging;
begin
  result := TTFilterPaging.Create(-1, -1, String.Empty);
end;

{ TTFilterParameter }

constructor TTFilterParameter.Create(
  const AName: String;
  const ADataType: TFieldType;
  const ASize: Integer;
  const AValue: TTValue);
begin
  FName := AName;
  FDataType := ADataType;
  FSize := ASize;
  FValue := AValue;
end;

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
class operator TTFilterParameter.Initialize(
  out AFilterParameter: TTFilterParameter);
begin
  AFilterParameter.FName := String.Empty;
  AFilterParameter.FDataType := TFieldType.ftUnknown;
  AFilterParameter.FSize := 0;
  AFilterParameter.FValue := TTValue.Empty;
end;
{$ENDIF}

{ TTFilter }

constructor TTFilter.Create(const AWhere: String);
begin
  FWhere := AWhere;
  SetLength(FParameters, 0);
  FPaging := TTFilterPaging.Empty();
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AMaxRecord: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  SetLength(FParameters, 0);
  FPaging := TTFilterPaging.Create(0, AMaxRecord, AOrderBy);
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AStart: Integer;
  const ALimit: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  SetLength(FParameters, 0);
  FPaging := TTFilterPaging.Create(AStart, ALimit, AOrderBy);
end;

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
class operator TTFilter.Initialize(out AFilter: TTFilter);
begin
  AFilter.FWhere := String.Empty;
  SetLength(AFilter.FParameters, 0);
  AFilter.FPaging := TTFilterPaging.Empty();
end;
{$ENDIF}

procedure TTFilter.AddParameter(
  const AName: String;
  const ADataType: TFieldType;
  const AValue: TTValue);
begin
  AddParameter(AName, ADataType, 0, AValue);
end;

procedure TTFilter.AddParameter(
  const AName: String;
  const ADataType: TFieldType;
  const ASize: Integer;
  const AValue: TTValue);
var
  LLength: Integer;
begin
  LLength := Length(FParameters);
  SetLength(FParameters, LLength + 1);
  FParameters[LLength] := TTFilterParameter.Create(
    AName, ADataType, ASize, AValue);
end;

class function TTFilter.Empty: TTFilter;
begin
  result := TTFilter.Create(String.Empty);
end;

function TTFilter.GetIsEmpty: Boolean;
begin
  result := FWhere.IsEmpty and FPaging.IsEmpty;
end;

end.
