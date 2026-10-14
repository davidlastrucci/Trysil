(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.OpenAPISamples;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Types,
  Trysil.Attributes;

type

{ TTestOpenApiProduct }

  [TTable('OtherProducts')]
  [TSequence('OtherProductsID')]
  TTestOpenApiProduct = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Code')]
    FCode: String;
  public
    property ID: TTPrimaryKey read FID;
    property Code: String read FCode;
  end;

implementation

end.
