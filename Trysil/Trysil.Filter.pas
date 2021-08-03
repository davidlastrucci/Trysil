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
  System.Classes;

type

{ TTFilterTop }

  TTFilterTop = record
  strict private
    FMaxRecord: Integer;
    FOrderBy: String;

    function GetIsEmpty: Boolean;
  public
    constructor Create(const AMaxRecord: Integer; const AOrderBy: String);

    property MaxRecord: Integer read FMaxRecord write FMaxRecord;
    property OrderBy: String read FOrderBy write FOrderBy;
    property IsEmpty: Boolean read GetIsEmpty;

    class function Empty: TTFilterTop; static;
  end;

{ TTFilter }

  TTFilter = record
  strict private
    FWhere: String;
    FTop: TTFilterTop;

    function GetIsEmpty: Boolean;
  public
    constructor Create(const AWhere: String); overload;
    constructor Create(
      const AWhere: String;
      const AMaxRecord: Integer;
      const AOrderBy: String); overload;

    property Where: String read FWhere write FWhere;
    property Top: TTFilterTop read FTop write FTop;
    property IsEmpty: Boolean read GetIsEmpty;

    class function Empty: TTFilter; static;
  end;

implementation

{ TTFilterTop }

constructor TTFilterTop.Create(
  const AMaxRecord: Integer; const AOrderBy: String);
begin
  FMaxRecord := AMaxRecord;
  FOrderBy := AOrderBy;
end;

class function TTFilterTop.Empty: TTFilterTop;
begin
  result := TTFilterTop.Create(0, String.Empty);
end;

function TTFilterTop.GetIsEmpty: Boolean;
begin
  result := (FMaxRecord = 0) and (FOrderBy.IsEmpty);
end;

{ TTFilter }

constructor TTFilter.Create(const AWhere: String);
begin
  FWhere := AWhere;
  FTop := TTFilterTop.Empty();
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AMaxRecord: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  FTop := TTFilterTop.Create(AMaxRecord, AOrderBy);
end;

class function TTFilter.Empty: TTFilter;
begin
  result := TTFilter.Create(String.Empty);
end;

function TTFilter.GetIsEmpty: Boolean;
begin
  result := FWhere.IsEmpty and FTop.IsEmpty;
end;

end.
