(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Progress;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math;

type

{ TTVersionState }

  TTVersionState = (Waiting, Installing, Done, Failed);

{ TTSetupStartEvent }

  TTSetupStartEvent = procedure(const AVersions: TArray<String>) of object;

{ TTSetupPercentEvent }

  TTSetupPercentEvent = procedure(const APercent: Integer) of object;

{ TTSetupStateEvent }

  TTSetupStateEvent = procedure(
    const AIndex: Integer; const AState: TTVersionState) of object;

{ TTSetupProgress }

  TTSetupProgress = class
  strict private
    FTotal: Integer;
    FDone: Integer;
    FOnStart: TTSetupStartEvent;
    FOnPercent: TTSetupPercentEvent;
    FOnState: TTSetupStateEvent;

    function Percent: Integer;
    procedure NotifyPercent;
  public
    constructor Create;

    procedure Start(const ATotal: Integer; const AVersions: TArray<String>);
    procedure Step;
    procedure Reach(const ADone: Integer);
    procedure SetState(const AIndex: Integer; const AState: TTVersionState);

    property Done: Integer read FDone;
    property OnStart: TTSetupStartEvent read FOnStart write FOnStart;
    property OnPercent: TTSetupPercentEvent read FOnPercent write FOnPercent;
    property OnState: TTSetupStateEvent read FOnState write FOnState;
  end;

implementation

{ TTSetupProgress }

constructor TTSetupProgress.Create;
begin
  inherited Create;
  FTotal := 0;
  FDone := 0;
end;

function TTSetupProgress.Percent: Integer;
begin
  if FTotal > 0 then
    result := (FDone * 100) div FTotal
  else
    result := 0;
end;

procedure TTSetupProgress.NotifyPercent;
begin
  if Assigned(FOnPercent) then
    FOnPercent(Percent);
end;

procedure TTSetupProgress.Start(
  const ATotal: Integer; const AVersions: TArray<String>);
begin
  FTotal := ATotal;
  FDone := 0;
  if Assigned(FOnStart) then
    FOnStart(AVersions);
  NotifyPercent;
end;

procedure TTSetupProgress.Step;
begin
  Reach(FDone + 1);
end;

procedure TTSetupProgress.Reach(const ADone: Integer);
begin
  FDone := Min(Max(FDone, ADone), FTotal);
  NotifyPercent;
end;

procedure TTSetupProgress.SetState(
  const AIndex: Integer; const AState: TTVersionState);
begin
  if Assigned(FOnState) then
    FOnState(AIndex, AState);
end;

end.
