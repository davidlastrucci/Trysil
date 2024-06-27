(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
program Blob;

uses
  Vcl.Forms,
  Trysil.Attributes in '..\..\Trysil\Trysil.Attributes.pas',
  Trysil.Cache in '..\..\Trysil\Trysil.Cache.pas',
  Trysil.Classes in '..\..\Trysil\Trysil.Classes.pas',
  Trysil.Consts in '..\..\Trysil\Trysil.Consts.pas',
  Trysil.Context in '..\..\Trysil\Trysil.Context.pas',
  Trysil.Events.Abstract in '..\..\Trysil\Trysil.Events.Abstract.pas',
  Trysil.Events.Attributes in '..\..\Trysil\Trysil.Events.Attributes.pas',
  Trysil.Events.Factory in '..\..\Trysil\Trysil.Events.Factory.pas',
  Trysil.Events in '..\..\Trysil\Trysil.Events.pas',
  Trysil.Exceptions in '..\..\Trysil\Trysil.Exceptions.pas',
  Trysil.Factory in '..\..\Trysil\Trysil.Factory.pas',
  Trysil.Filter in '..\..\Trysil\Trysil.Filter.pas',
  Trysil.Generics.Collections in '..\..\Trysil\Trysil.Generics.Collections.pas',
  Trysil.IdentityMap in '..\..\Trysil\Trysil.IdentityMap.pas',
  Trysil.Lazy in '..\..\Trysil\Trysil.Lazy.pas',
  Trysil.LoadBalancing in '..\..\Trysil\Trysil.LoadBalancing.pas',
  Trysil.Logger in '..\..\Trysil\Trysil.Logger.pas',
  Trysil.Mapping in '..\..\Trysil\Trysil.Mapping.pas',
  Trysil.Metadata in '..\..\Trysil\Trysil.Metadata.pas',
  Trysil.Provider in '..\..\Trysil\Trysil.Provider.pas',
  Trysil.Resolver in '..\..\Trysil\Trysil.Resolver.pas',
  Trysil.Rtti in '..\..\Trysil\Trysil.Rtti.pas',
  Trysil.Session in '..\..\Trysil\Trysil.Session.pas',
  Trysil.Sync in '..\..\Trysil\Trysil.Sync.pas',
  Trysil.Transaction in '..\..\Trysil\Trysil.Transaction.pas',
  Trysil.Types in '..\..\Trysil\Trysil.Types.pas',
  Trysil.Validation.Attributes in '..\..\Trysil\Trysil.Validation.Attributes.pas',
  Trysil.Validation in '..\..\Trysil\Trysil.Validation.pas',
  Trysil.Data.Columns in '..\..\Trysil\Data\Trysil.Data.Columns.pas',
  Trysil.Data.Connection in '..\..\Trysil\Data\Trysil.Data.Connection.pas',
  Trysil.Data.Parameters in '..\..\Trysil\Data\Trysil.Data.Parameters.pas',
  Trysil.Data in '..\..\Trysil\Data\Trysil.Data.pas',
  Trysil.Data.SqlSyntax.FirebirdSQL in '..\..\Trysil\Data\SqlSyntax\Trysil.Data.SqlSyntax.FirebirdSQL.pas',
  Trysil.Data.SqlSyntax in '..\..\Trysil\Data\SqlSyntax\Trysil.Data.SqlSyntax.pas',
  Trysil.Data.SqlSyntax.PostgreSQL in '..\..\Trysil\Data\SqlSyntax\Trysil.Data.SqlSyntax.PostgreSQL.pas',
  Trysil.Data.SqlSyntax.SQLite in '..\..\Trysil\Data\SqlSyntax\Trysil.Data.SqlSyntax.SQLite.pas',
  Trysil.Data.SqlSyntax.SqlServer in '..\..\Trysil\Data\SqlSyntax\Trysil.Data.SqlSyntax.SqlServer.pas',
  Trysil.Data.FireDAC.Common in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.Common.pas',
  Trysil.Data.FireDAC.ConnectionPool in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.ConnectionPool.pas',
  Trysil.Data.FireDAC.FirebirdSQL in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.FirebirdSQL.pas',
  Trysil.Data.FireDAC in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.pas',
  Trysil.Data.FireDAC.PostgreSQL in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.PostgreSQL.pas',
  Trysil.Data.FireDAC.SQLite in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.SQLite.pas',
  Trysil.Data.FireDAC.SqlServer in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.SqlServer.pas',
  Blob.PictureHelper in 'Blob.PictureHelper.pas',
  Blob.Model in 'Blob.Model.pas',
  Blob.MainForm in 'Blob.MainForm.pas' {MainForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
