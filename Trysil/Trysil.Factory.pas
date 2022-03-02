(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Factory;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Generics.Collections;

type

{ TTFactory }

  TTFactory = class
  strict private
    class var FInstance: TTFactory;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FTypes: TDictionary<PTypeInfo, PTypeInfo>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterType<T; K: T>();

    function GetType<T>(): PTypeInfo; overload;
    function GetType(const ATypeInfo: PTypeInfo): PTypeInfo; overload;

    class property Instance: TTFactory read FInstance;
  end;

implementation

{ TTFactory }

class constructor TTFactory.ClassCreate;
begin
  FInstance := TTFactory.Create;
end;

class destructor TTFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTFactory.Create;
begin
  inherited Create;
  FTypes := TDictionary<PTypeInfo, PTypeInfo>.Create;
end;

destructor TTFactory.Destroy;
begin
  FTypes.Free;
  inherited Destroy;
end;

procedure TTFactory.RegisterType<T, K>();
begin
  FTypes.Add(TypeInfo(T), TypeInfo(K));
end;

function TTFactory.GetType<T>(): PTypeInfo;
begin
  result := GetType(TypeInfo(T));
end;

function TTFactory.GetType(const ATypeInfo: PTypeInfo): PTypeInfo;
begin
  if not FTypes.TryGetValue(ATypeInfo, result) then
    result := ATypeInfo;
end;

end.
