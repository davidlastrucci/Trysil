(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Demo.ListView;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Generics.Collections,
  Trysil.Vcl.ListView,

  Demo.Model;

type

{ TTMasterDataListView }

  TTMasterDataListView = class(TTListView<TTMasterData>)
  strict private
    procedure AddColumns;
    function GetPredicate(const ASearchText: String): TTPredicate<TTMasterData>;
    procedure ItemCompare(
      const AColumnIndex: Integer;
      const ALeft: TTMasterData;
      const ARight: TTMasterData;
      var AResult: Integer);
  public
    procedure AfterConstruction; override;

    procedure BindData(
      const AData: TTList<TTMasterData>; const ASearchText: String);

    property SmallImages;
    property OnDblClick;
  end;

resourcestring
  SID = 'ID';
  SFirstName = 'First name';
  SLastName = 'Last name';
  SCompany = 'Company';
  SEmail = 'E-Mail';
  SPhone = 'Phone';

implementation

{ TTMasterDataListView }

procedure TTMasterDataListView.AfterConstruction;
begin
  inherited AfterConstruction;
  Self.OnItemCompare := ItemCompare;
  AddColumns;
end;

procedure TTMasterDataListView.AddColumns;
begin
  AddColumn(SID, taLeftJustify, 50, 'ID');
  AddColumn(SFirstName, taLeftJustify, 150, 'FirstName');
  AddColumn(SLastName, taLeftJustify, 150, 'LastName');
  AddColumn(SCompany, taLeftJustify, 200, 'Company');
  AddColumn(SEmail, taLeftJustify, 200, 'Email');
  AddColumn(SPhone, taRightJustify, 120, 'Phone');

  PrepareColumns;
end;

procedure TTMasterDataListView.BindData(
  const AData: TTList<TTMasterData>; const ASearchText: String);
begin
  inherited BindData(AData, GetPredicate(ASearchText));
end;

function TTMasterDataListView.GetPredicate(
  const ASearchText: String): TTPredicate<TTMasterData>;
var
  LSearchText: String;
begin
  result := nil;
  if not ASearchText.IsEmpty then
  begin
    LSearchText := ASearchText.ToLower();
    result := function(const AItem: TTMasterData): Boolean
    begin
      result :=
        AItem.Firstname.ToLower().Contains(LSearchText) or
        AItem.Lastname.ToLower().Contains(LSearchText) or
        AItem.Company.ToLower().Contains(LSearchText) or
        AItem.Email.ToLower().Contains(LSearchText) or
        AItem.Phone.ToLower().Contains(LSearchText);
    end;
  end;
end;

procedure TTMasterDataListView.ItemCompare(
  const AColumnIndex: Integer;
  const ALeft: TTMasterData;
  const ARight: TTMasterData;
  var AResult: Integer);
begin
  case AColumnIndex of
    0: AResult := ALeft.ID - ARight.ID;
    1: AResult := String.Compare(ALeft.Firstname, ARight.Firstname);
    2: AResult := String.Compare(ALeft.Lastname, ARight.Lastname);
    3: AResult := String.Compare(ALeft.Company, ARight.Company);
    4: AResult := String.Compare(ALeft.Email, ARight.Email);
    5: AResult := String.Compare(ALeft.Phone, ARight.Phone);
  end;
end;

end.
