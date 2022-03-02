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

{ TTFilter }

  TTFilter = record
  strict private
    FWhere: String;
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

    property Where: String read FWhere write FWhere;
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

{ TTFilter }

constructor TTFilter.Create(const AWhere: String);
begin
  FWhere := AWhere;
  FPaging := TTFilterPaging.Empty();
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AMaxRecord: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  FPaging := TTFilterPaging.Create(0, AMaxRecord, AOrderBy);
end;

constructor TTFilter.Create(
  const AWhere: String;
  const AStart: Integer;
  const ALimit: Integer;
  const AOrderBy: String);
begin
  FWhere := AWhere;
  FPaging := TTFilterPaging.Create(AStart, ALimit, AOrderBy);
end;

{$IF CompilerVersion >= 34} // Delphi 10.4 Sydney
class operator TTFilter.Initialize(out AFilter: TTFilter);
begin
  AFilter.FWhere := String.Empty;
  AFilter.FPaging := TTFilterPaging.Empty();
end;
{$ENDIF}

class function TTFilter.Empty: TTFilter;
begin
  result := TTFilter.Create(String.Empty);
end;

function TTFilter.GetIsEmpty: Boolean;
begin
  result := FWhere.IsEmpty and FPaging.IsEmpty;
end;

end.
