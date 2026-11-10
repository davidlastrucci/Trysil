(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Model.Protected;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,

  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation,
  Trysil.Validation.Attributes,
  Trysil.Events.Attributes;

{$RTTI EXPLICIT
  FIELDS([vcPrivate, vcProtected, vcPublic, vcPublished])
  METHODS([vcProtected, vcPublic, vcPublished])
  PROPERTIES([vcPublic, vcPublished])}

type

{ TTestProtectedEventCustomer }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestProtectedEventCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    FEventLog: String;
    FValidated: Boolean;
  protected
    [TBeforeInsertEvent]
    procedure OnBeforeInsert;

    [TAfterInsertEvent]
    procedure OnAfterInsert;

    [TValidator]
    procedure Validate(const AErrors: TTValidationErrors);
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
    property EventLog: String read FEventLog;
    property Validated: Boolean read FValidated;
  end;

implementation

{ TTestProtectedEventCustomer }

procedure TTestProtectedEventCustomer.OnBeforeInsert;
begin
  FEventLog := Format('%sBI;', [FEventLog]);
end;

procedure TTestProtectedEventCustomer.OnAfterInsert;
begin
  FEventLog := Format('%sAI;', [FEventLog]);
end;

procedure TTestProtectedEventCustomer.Validate(
  const AErrors: TTValidationErrors);
begin
  FValidated := True;
end;

end.
