(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRest.Parameters;

interface

uses
  System.SysUtils,
  System.Classes;

{$SCOPEDENUMS ON}

type

{ TTApiRestFeature }

  TTApiRestFeature = (MultiTenant, Auth, Log, RS256);

{ TTApiRestFeatures }

  TTApiRestFeatures = set of TTApiRestFeature;

{ TTApiRestDatabase }

  TTApiRestDatabase = class
  strict private
    const Drivers: array[0..6] of String = (
      'FB', 'IB', 'MariaDB', 'Ora', 'PG', 'MSSQL', 'SQLite');
  strict private
    FDriverIndex: Integer;
    FHost: String;
    FPort: Integer;
    FUsername: String;
    FPassword: String;
    FDatabaseName: String;

    function GetDriver: String;
  public
    property DriverIndex: Integer read FDriverIndex write FDriverIndex;
    property Driver: String read GetDriver;
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property Username: String read FUsername write FUsername;
    property Password: String read FPassword write FPassword;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
  end;

{ TTApiRestParameters }

  TTApiRestParameters = class
  strict private
    FDirectory: String;
    FProjectName: String;
    FServiceName: String;
    FDescription: String;
    FFeatures: TTApiRestFeatures;
    FBaseUri: String;
    FPort: Integer;
    FDatabase: TTApiRestDatabase;
    FLogDatabase: TTApiRestDatabase;
    FJWTSecret: String;
    FPasswordSecret: String;

    class function NewSecret: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Has(const AFeature: TTApiRestFeature): Boolean;

    property Directory: String read FDirectory write FDirectory;
    property ProjectName: String read FProjectName write FProjectName;
    property ServiceName: String read FServiceName write FServiceName;
    property Description: String read FDescription write FDescription;
    property Features: TTApiRestFeatures read FFeatures write FFeatures;
    property BaseUri: String read FBaseUri write FBaseUri;
    property Port: Integer read FPort write FPort;
    property Database: TTApiRestDatabase read FDatabase;
    property LogDatabase: TTApiRestDatabase read FLogDatabase;
    property JWTSecret: String read FJWTSecret;
    property PasswordSecret: String read FPasswordSecret;
  end;

implementation

{ TTApiRestDatabase }

function TTApiRestDatabase.GetDriver: String;
begin
  if (FDriverIndex >= Low(Drivers)) and (FDriverIndex <= High(Drivers)) then
    result := Drivers[FDriverIndex]
  else
    result := String.Empty;
end;

{ TTApiRestParameters }

constructor TTApiRestParameters.Create;
begin
  inherited Create;
  FDatabase := TTApiRestDatabase.Create;
  FLogDatabase := TTApiRestDatabase.Create;
end;

destructor TTApiRestParameters.Destroy;
begin
  FLogDatabase.Free;
  FDatabase.Free;
  inherited Destroy;
end;

procedure TTApiRestParameters.AfterConstruction;
begin
  inherited AfterConstruction;
  FJWTSecret := NewSecret;
  FPasswordSecret := NewSecret;
end;

class function TTApiRestParameters.NewSecret: String;
var
  LIndex: Integer;
begin
  result := String.Empty;
  for LIndex := 1 to 2 do
    result := Format('%s%s', [
      result,
      TGUID.NewGuid.ToString
        .Replace('{', '', [rfReplaceAll])
        .Replace('}', '', [rfReplaceAll])
        .Replace('-', '', [rfReplaceAll])
        .ToLower]);
end;

function TTApiRestParameters.Has(const AFeature: TTApiRestFeature): Boolean;
begin
  result := AFeature in FFeatures;
end;

end.
