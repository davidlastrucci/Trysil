(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Cache;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TypInfo,

  Trysil.Sync;

type

{ TTCache<K, V> }

  TTCache<K; V: class> = class
  strict protected
    FCriticalSection: TTCriticalSection;
    FCache: TObjectDictionary<K, V>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AKey: K; const AValue: V);
    function TryGetValue(const AKey: K; var AValue: V): Boolean;
    procedure Remove(const AKey: K);
  end;

{ TTCacheEx<K, V> }

  TTCacheEx<K; V: class> = class abstract(TTCache<K, V>)
  strict protected
    function CreateObject(const AKey: K): V; virtual; abstract;
    function GetValueOrCreate(const AKey: K): V;
  end;

implementation

{ TTCache<K, V> }

constructor TTCache<K, V>.Create;
begin
  inherited Create;
  FCriticalSection := TTCriticalSection.Create;
  FCache := TObjectDictionary<K, V>.Create([doOwnsValues]);
end;

destructor TTCache<K, V>.Destroy;
begin
  FCache.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

procedure TTCache<K, V>.Add(const AKey: K; const AValue: V);
begin
  if not FCache.ContainsKey(AKey) then
  begin
    FCriticalSection.Acquire;
    try
      if not FCache.ContainsKey(AKey) then
        FCache.Add(AKey, AValue);
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

function TTCache<K, V>.TryGetValue(const AKey: K; var AValue: V): Boolean;
begin
  result := FCache.TryGetValue(AKey, AValue);
end;

procedure TTCache<K, V>.Remove(const AKey: K);
begin
  if FCache.ContainsKey(AKey) then
  begin
    FCriticalSection.Acquire;
    try
      if FCache.ContainsKey(AKey) then
        FCache.Remove(AKey);
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

{ TTCacheEx<K, V> }

function TTCacheEx<K, V>.GetValueOrCreate(const AKey: K): V;
begin
  if not FCache.TryGetValue(AKey, result) then
  begin
    FCriticalSection.Acquire;
    try
      if not FCache.TryGetValue(AKey, result) then
      begin
        result := CreateObject(AKey);
        FCache.Add(AKey, result);
      end;
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

end.
