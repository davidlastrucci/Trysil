(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.FirebirdSQL;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.Connection,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.FirebirdSQL;

type

{ TTDataFirebirdSQLConnection }

  TTDataFirebirdSQLConnection = class(TTDataFireDACConnection)
  strict private
    class var VendorLib: String;
  strict private
    FDriverLink: TFDPhysFBDriverLink;
  strict protected
    function CreateSyntaxClasses: TTDataSyntaxClasses; override;
  public
    constructor Create(const AConnectionName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;
  public
    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String;
      const AVendorLib: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AParameters: TStrings); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AVendorLib: String;
      const AParameters: TStrings); overload;
  end;

implementation

{ TTDataFirebirdSQLConnection }

constructor TTDataFirebirdSQLConnection.Create(const AConnectionName: String);
begin
  inherited Create(AConnectionName);
  FDriverLink := TFDPhysFBDriverLink.Create(nil);
end;

destructor TTDataFirebirdSQLConnection.Destroy;
begin
  FDriverLink.Free;
  inherited Destroy;
end;

procedure TTDataFirebirdSQLConnection.AfterConstruction;
begin
  FDriverLink.VendorLib := VendorLib;
  inherited AfterConstruction;
end;

function TTDataFirebirdSQLConnection.CreateSyntaxClasses: TTDataSyntaxClasses;
begin
  result := TTDataFirebirdSQLSyntaxClasses.Create;
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  RegisterConnection(AName, AServer, AUsername, APassword, ADatabaseName, '');
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String;
  const AVendorLib: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Server=%s', [AServer]));
    LParameters.Add(Format('Database=%s', [ADatabaseName]));
    if AUsername.IsEmpty then
        LParameters.Add('OSAuthent=Yes')
    else
    begin
        LParameters.Add(Format('User_Name=%s', [AUserName]));
        LParameters.Add(Format('Password=%s', [APassword]));
    end;
    RegisterConnection(AName, VendorLib, LParameters);
  finally
    LParameters.Free;
  end;
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String; const AParameters: TStrings);
begin
  RegisterConnection(AName, VendorLib, AParameters);
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String; const AVendorLib: String; const AParameters: TStrings);
begin
  VendorLib := AVendorLib;
  TTDataFireDACConnectionPool.Instance.RegisterConnection(
    AName, 'FB', AParameters);
end;

end.
