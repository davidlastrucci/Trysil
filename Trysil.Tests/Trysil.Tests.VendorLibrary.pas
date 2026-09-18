(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.VendorLibrary;

interface

uses
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,

  Trysil.Data.FireDAC,

  Trysil.Tests.Config;

type

{ TTTestVendorLibrary }

  TTTestVendorLibrary = class
  strict private
    class procedure PrependToPath(const AFolder: String);
  public
    class procedure Apply(
      const ADatabaseName: String; const ADriver: TTFireDACDriver);
  end;

implementation

{ TTTestVendorLibrary }

class procedure TTTestVendorLibrary.PrependToPath(const AFolder: String);
var
  LFolder: String;
  LPath: String;
begin
  LFolder := ExcludeTrailingPathDelimiter(AFolder);
  LPath := GetEnvironmentVariable('PATH');
  if not LPath.Contains(LFolder) then
    Winapi.Windows.SetEnvironmentVariable(
      'PATH', PChar(Format('%s;%s', [LFolder, LPath])));
end;

class procedure TTTestVendorLibrary.Apply(
  const ADatabaseName: String; const ADriver: TTFireDACDriver);
var
  LVendorHome: String;
  LVendorLib: String;
begin
  LVendorHome := TTTestConfig.GetDatabaseParam(ADatabaseName, 'vendorHome');
  if not LVendorHome.IsEmpty then
  begin
    ADriver.VendorHome := LVendorHome;
    PrependToPath(LVendorHome);
  end;

  LVendorLib := TTTestConfig.GetDatabaseParam(ADatabaseName, 'vendorLib');
  if not LVendorLib.IsEmpty then
  begin
    ADriver.VendorLib := LVendorLib;
    PrependToPath(TPath.GetDirectoryName(LVendorLib));
  end;
end;

end.
