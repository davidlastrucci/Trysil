﻿(*

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

  TTCache<K; V: class> = class abstract
  strict protected
    FCriticalSection: TTCriticalSection;
    FCache: TObjectDictionary<K, V>;
  strict protected
    function CreateObject(const AKey: K): V; virtual; abstract;
    function GetValueOrCreate(const AKey: K): V;
  public
    constructor Create;
    destructor Destroy; override;
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

function TTCache<K, V>.GetValueOrCreate(const AKey: K): V;
begin
  if not FCache.TryGetValue(AKey, result) then
  begin
    FCriticalSection.Acquire;
    try
      if not FCache.TryGetValue(AKey, result) then
      begin
        result := CreateObject(AKey);
        try
          FCache.Add(AKey, result);
        except
          result.Free;
          raise;
        end;
      end;
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

end.
