(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Demo.Model;

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes;

type

{ TTMasterData }

  [TTable('MasterData')]
  [TSequence('MasterData')]
  TTMasterData = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Firstname')]
    FFirstname: String;

    [TColumn('Lastname')]
    FLastname: String;

    [TColumn('Company')]
    FCompany: String;

    [TColumn('Email')]
    FEmail: String;

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
