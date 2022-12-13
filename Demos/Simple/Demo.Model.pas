(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Demo.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type

{ TTMasterData }

  [TTable('MasterData')]
  [TSequence('MasterDataID')]
  TTMasterData = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(30)]
    [TColumn('Firstname')]
    FFirstname: String;

    [TRequired]
    [TMaxLength(30)]
    [TColumn('Lastname')]
    FLastname: String;

    [TMaxLength(50)]
    [TColumn('Company')]
    FCompany: String;

    [TMaxLength(255)]
    [TEmail]
    [TColumn('Email')]
    FEmail: String;

    [TMaxLength(20)]
    [TColumn('Phone')]
    FPhone: String;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  public
    function ToString(): String; override;

    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property Company: String read FCompany write FCompany;
    property Email: String read FEmail write FEmail;
    property Phone: String read FPhone write FPhone;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TTMasterData }

function TTMasterData.ToString: String;
begin
  result := Format('%s %s', [FFirstname, FLastname]);
end;

end.
