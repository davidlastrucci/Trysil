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
  Trysil.Metadata;

type

{ TTAbstractContext }

  TTAbstractContext = class abstract
  strict protected
    FConnection: TTDataConnection;
    FMapper: TTMapper;
    FMetadata: TTMetadata;
  public
    constructor Create(const AConnection: TTDataConnection); virtual;
    destructor Destroy; override;

    property Mapper: TTMapper read FMapper;
  end;

implementation

{ TTAbstractContext }

constructor TTAbstractContext.Create(const AConnection: TTDataConnection);
begin
  inherited Create;
  FConnection := AConnection;

  FMapper := TTMapper.Create;
  FMetadata := TTMetadata.Create(FMapper, FConnection);
end;

destructor TTAbstractContext.Destroy;
begin
  FMetadata.Free;
  FMapper.Free;
  inherited Destroy;
end;

end.
