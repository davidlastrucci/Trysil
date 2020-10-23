(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Context.Abstract;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Data,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.IdentityMap;

type

{ TTAbstractContext }

  TTAbstractContext = class abstract
  strict private
    FConnection: TTDataConnection;
    FMapper: TTMapper;
    FMetadata: TTMetadata;
    FIdentityMap: TTIdentityMap;
    FOwnership: TObjectList<TObject>;
  public
    constructor Create(const AConnection: TTDataConnection); virtual;
    destructor Destroy; override;

    procedure AddToOwnership<T: class>(const AObject: T);

    property Connection: TTDataConnection read FConnection;
    property Mapper: TTMapper read FMapper;
    property Metadata: TTMetadata read FMetadata;
    property IdentityMap: TTIdentityMap read FIdentityMap;
  end;

implementation

{ TTAbstractContext }

constructor TTAbstractContext.Create(const AConnection: TTDataConnection);
begin
  inherited Create;
  FConnection := AConnection;

  FMapper := TTMapper.Create;
  FMetadata := TTMetadata.Create(FMapper, FConnection);
  FIdentityMap := TTIdentityMap.Create;
  FOwnership := TObjectList<TObject>.Create(True);
end;

destructor TTAbstractContext.Destroy;
begin
  FOwnership.Free;
  FIdentityMap.Free;
  FMetadata.Free;
  FMapper.Free;
  inherited Destroy;
end;

procedure TTAbstractContext.AddToOwnership<T>(const AObject: T);
begin
  FOwnership.Add(AObject);
end;

end.
