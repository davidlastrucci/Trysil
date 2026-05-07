program Trysil.Tests.Runner;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  FireDAC.ConsoleUI.Wait,
  Trysil.Tests.Config in 'Trysil.Tests.Config.pas',
  Trysil.Tests.Types in 'Trysil.Tests.Types.pas',
  Trysil.Tests.IdentityMap in 'Trysil.Tests.IdentityMap.pas',
  Trysil.Tests.Mapping in 'Trysil.Tests.Mapping.pas',
  Trysil.Tests.Filter in 'Trysil.Tests.Filter.pas',
  Trysil.Tests.Model in 'Trysil.Tests.Model.pas',
  Trysil.Tests.Abstract.Base in 'Abstract\Trysil.Tests.Abstract.Base.pas',
  Trysil.Tests.Abstract.Crud in 'Abstract\Trysil.Tests.Abstract.Crud.pas',
  Trysil.Tests.Abstract.ChangeTracking in 'Abstract\Trysil.Tests.Abstract.ChangeTracking.pas',
  Trysil.Tests.Abstract.IdentityMap in 'Abstract\Trysil.Tests.Abstract.IdentityMap.pas',
  Trysil.Tests.Abstract.Validation in 'Abstract\Trysil.Tests.Abstract.Validation.pas',
  Trysil.Tests.Abstract.Join in 'Abstract\Trysil.Tests.Abstract.Join.pas',
  Trysil.Tests.Abstract.Session in 'Abstract\Trysil.Tests.Abstract.Session.pas',
  Trysil.Tests.Abstract.Transaction in 'Abstract\Trysil.Tests.Abstract.Transaction.pas',
  Trysil.Tests.Abstract.Lazy in 'Abstract\Trysil.Tests.Abstract.Lazy.pas',
  Trysil.Tests.Abstract.Events in 'Abstract\Trysil.Tests.Abstract.Events.pas',
  Trysil.Tests.Abstract.Relation in 'Abstract\Trysil.Tests.Abstract.Relation.pas',
  Trysil.Tests.Abstract.ContextApi in 'Abstract\Trysil.Tests.Abstract.ContextApi.pas',
  Trysil.Tests.Abstract.UpdateMode in 'Abstract\Trysil.Tests.Abstract.UpdateMode.pas',
  Trysil.Tests.Http.Exceptions in 'Trysil.Tests.Http.Exceptions.pas',
  Trysil.Tests.Http.JWT in 'Trysil.Tests.Http.JWT.pas',
  Trysil.Tests.Http.Uri in 'Trysil.Tests.Http.Uri.pas',
  Trysil.Tests.Http.Log in 'Trysil.Tests.Http.Log.pas',
  Trysil.Tests.Logger in 'Trysil.Tests.Logger.pas',
  Trysil.Tests.Abstract.JSon in 'Abstract\Trysil.Tests.Abstract.JSon.pas',
  Trysil.Tests.Abstract.AllTypes in 'Abstract\Trysil.Tests.Abstract.AllTypes.pas',
  Trysil.Tests.Abstract.AllTypesJSon in 'Abstract\Trysil.Tests.Abstract.AllTypesJSon.pas',
  Trysil.Tests.Abstract.NullablePrimitives in 'Abstract\Trysil.Tests.Abstract.NullablePrimitives.pas',
  Trysil.Tests.Abstract.NullablePrimitivesJSon in 'Abstract\Trysil.Tests.Abstract.NullablePrimitivesJSon.pas',
  Trysil.Tests.SQLite.Connection in 'SQLite\Trysil.Tests.SQLite.Connection.pas',
  Trysil.Tests.SQLite.Crud in 'SQLite\Trysil.Tests.SQLite.Crud.pas',
  Trysil.Tests.SQLite.ChangeTracking in 'SQLite\Trysil.Tests.SQLite.ChangeTracking.pas',
  Trysil.Tests.SQLite.IdentityMap in 'SQLite\Trysil.Tests.SQLite.IdentityMap.pas',
  Trysil.Tests.SQLite.Validation in 'SQLite\Trysil.Tests.SQLite.Validation.pas',
  Trysil.Tests.SQLite.Join in 'SQLite\Trysil.Tests.SQLite.Join.pas',
  Trysil.Tests.SQLite.Session in 'SQLite\Trysil.Tests.SQLite.Session.pas',
  Trysil.Tests.SQLite.Transaction in 'SQLite\Trysil.Tests.SQLite.Transaction.pas',
  Trysil.Tests.SQLite.Lazy in 'SQLite\Trysil.Tests.SQLite.Lazy.pas',
  Trysil.Tests.SQLite.Events in 'SQLite\Trysil.Tests.SQLite.Events.pas',
  Trysil.Tests.SQLite.Relation in 'SQLite\Trysil.Tests.SQLite.Relation.pas',
  Trysil.Tests.SQLite.ContextApi in 'SQLite\Trysil.Tests.SQLite.ContextApi.pas',
  Trysil.Tests.SQLite.UpdateMode in 'SQLite\Trysil.Tests.SQLite.UpdateMode.pas',
  Trysil.Tests.SQLite.JSon in 'SQLite\Trysil.Tests.SQLite.JSon.pas',
  Trysil.Tests.SQLite.AllTypes in 'SQLite\Trysil.Tests.SQLite.AllTypes.pas',
  Trysil.Tests.SQLite.AllTypesJSon in 'SQLite\Trysil.Tests.SQLite.AllTypesJSon.pas',
  Trysil.Tests.SQLite.NullablePrimitives in 'SQLite\Trysil.Tests.SQLite.NullablePrimitives.pas',
  Trysil.Tests.SQLite.NullablePrimitivesJSon in 'SQLite\Trysil.Tests.SQLite.NullablePrimitivesJSon.pas',
  Trysil.Tests.SQLite.Register in 'SQLite\Trysil.Tests.SQLite.Register.pas',
  Trysil.Tests.SqlServer.Connection in 'SqlServer\Trysil.Tests.SqlServer.Connection.pas',
  Trysil.Tests.SqlServer.Crud in 'SqlServer\Trysil.Tests.SqlServer.Crud.pas',
  Trysil.Tests.SqlServer.ChangeTracking in 'SqlServer\Trysil.Tests.SqlServer.ChangeTracking.pas',
  Trysil.Tests.SqlServer.IdentityMap in 'SqlServer\Trysil.Tests.SqlServer.IdentityMap.pas',
  Trysil.Tests.SqlServer.Validation in 'SqlServer\Trysil.Tests.SqlServer.Validation.pas',
  Trysil.Tests.SqlServer.Join in 'SqlServer\Trysil.Tests.SqlServer.Join.pas',
  Trysil.Tests.SqlServer.Session in 'SqlServer\Trysil.Tests.SqlServer.Session.pas',
  Trysil.Tests.SqlServer.Transaction in 'SqlServer\Trysil.Tests.SqlServer.Transaction.pas',
  Trysil.Tests.SqlServer.Lazy in 'SqlServer\Trysil.Tests.SqlServer.Lazy.pas',
  Trysil.Tests.SqlServer.Events in 'SqlServer\Trysil.Tests.SqlServer.Events.pas',
  Trysil.Tests.SqlServer.Relation in 'SqlServer\Trysil.Tests.SqlServer.Relation.pas',
  Trysil.Tests.SqlServer.ContextApi in 'SqlServer\Trysil.Tests.SqlServer.ContextApi.pas',
  Trysil.Tests.SqlServer.UpdateMode in 'SqlServer\Trysil.Tests.SqlServer.UpdateMode.pas',
  Trysil.Tests.SqlServer.JSon in 'SqlServer\Trysil.Tests.SqlServer.JSon.pas',
  Trysil.Tests.SqlServer.AllTypes in 'SqlServer\Trysil.Tests.SqlServer.AllTypes.pas',
  Trysil.Tests.SqlServer.AllTypesJSon in 'SqlServer\Trysil.Tests.SqlServer.AllTypesJSon.pas',
  Trysil.Tests.SqlServer.NullablePrimitives in 'SqlServer\Trysil.Tests.SqlServer.NullablePrimitives.pas',
  Trysil.Tests.SqlServer.NullablePrimitivesJSon in 'SqlServer\Trysil.Tests.SqlServer.NullablePrimitivesJSon.pas',
  Trysil.Tests.SqlServer.Register in 'SqlServer\Trysil.Tests.SqlServer.Register.pas',
  Trysil.Tests.PostgreSQL.Connection in 'PostgreSQL\Trysil.Tests.PostgreSQL.Connection.pas',
  Trysil.Tests.PostgreSQL.Crud in 'PostgreSQL\Trysil.Tests.PostgreSQL.Crud.pas',
  Trysil.Tests.PostgreSQL.ChangeTracking in 'PostgreSQL\Trysil.Tests.PostgreSQL.ChangeTracking.pas',
  Trysil.Tests.PostgreSQL.IdentityMap in 'PostgreSQL\Trysil.Tests.PostgreSQL.IdentityMap.pas',
  Trysil.Tests.PostgreSQL.Validation in 'PostgreSQL\Trysil.Tests.PostgreSQL.Validation.pas',
  Trysil.Tests.PostgreSQL.Join in 'PostgreSQL\Trysil.Tests.PostgreSQL.Join.pas',
  Trysil.Tests.PostgreSQL.Session in 'PostgreSQL\Trysil.Tests.PostgreSQL.Session.pas',
  Trysil.Tests.PostgreSQL.Transaction in 'PostgreSQL\Trysil.Tests.PostgreSQL.Transaction.pas',
  Trysil.Tests.PostgreSQL.Lazy in 'PostgreSQL\Trysil.Tests.PostgreSQL.Lazy.pas',
  Trysil.Tests.PostgreSQL.Events in 'PostgreSQL\Trysil.Tests.PostgreSQL.Events.pas',
  Trysil.Tests.PostgreSQL.Relation in 'PostgreSQL\Trysil.Tests.PostgreSQL.Relation.pas',
  Trysil.Tests.PostgreSQL.ContextApi in 'PostgreSQL\Trysil.Tests.PostgreSQL.ContextApi.pas',
  Trysil.Tests.PostgreSQL.UpdateMode in 'PostgreSQL\Trysil.Tests.PostgreSQL.UpdateMode.pas',
  Trysil.Tests.PostgreSQL.JSon in 'PostgreSQL\Trysil.Tests.PostgreSQL.JSon.pas',
  Trysil.Tests.PostgreSQL.AllTypes in 'PostgreSQL\Trysil.Tests.PostgreSQL.AllTypes.pas',
  Trysil.Tests.PostgreSQL.AllTypesJSon in 'PostgreSQL\Trysil.Tests.PostgreSQL.AllTypesJSon.pas',
  Trysil.Tests.PostgreSQL.NullablePrimitives in 'PostgreSQL\Trysil.Tests.PostgreSQL.NullablePrimitives.pas',
  Trysil.Tests.PostgreSQL.NullablePrimitivesJSon in 'PostgreSQL\Trysil.Tests.PostgreSQL.NullablePrimitivesJSon.pas',
  Trysil.Tests.PostgreSQL.Register in 'PostgreSQL\Trysil.Tests.PostgreSQL.Register.pas',
  Trysil.Tests.FirebirdSQL.Connection in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Connection.pas',
  Trysil.Tests.FirebirdSQL.Crud in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Crud.pas',
  Trysil.Tests.FirebirdSQL.ChangeTracking in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.ChangeTracking.pas',
  Trysil.Tests.FirebirdSQL.IdentityMap in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.IdentityMap.pas',
  Trysil.Tests.FirebirdSQL.Validation in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Validation.pas',
  Trysil.Tests.FirebirdSQL.Join in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Join.pas',
  Trysil.Tests.FirebirdSQL.Session in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Session.pas',
  Trysil.Tests.FirebirdSQL.Transaction in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Transaction.pas',
  Trysil.Tests.FirebirdSQL.Lazy in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Lazy.pas',
  Trysil.Tests.FirebirdSQL.Events in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Events.pas',
  Trysil.Tests.FirebirdSQL.Relation in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Relation.pas',
  Trysil.Tests.FirebirdSQL.ContextApi in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.ContextApi.pas',
  Trysil.Tests.FirebirdSQL.UpdateMode in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.UpdateMode.pas',
  Trysil.Tests.FirebirdSQL.JSon in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.JSon.pas',
  Trysil.Tests.FirebirdSQL.AllTypes in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.AllTypes.pas',
  Trysil.Tests.FirebirdSQL.AllTypesJSon in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.AllTypesJSon.pas',
  Trysil.Tests.FirebirdSQL.NullablePrimitives in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.NullablePrimitives.pas',
  Trysil.Tests.FirebirdSQL.NullablePrimitivesJSon in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.NullablePrimitivesJSon.pas',
  Trysil.Tests.FirebirdSQL.Register in 'FirebirdSQL\Trysil.Tests.FirebirdSQL.Register.pas';

var
  LRunner: ITestRunner;
  LResults: IRunResults;
  LConsoleLogger: ITestLogger;
  LNUnitLogger: ITestLogger;
begin
  ReportMemoryLeaksOnShutdown := True;
  TTTestConfig.PrintConfig;
  try
    TDUnitX.CheckCommandLine;
    LRunner := TDUnitX.CreateRunner;
    LRunner.UseRTTI := False;
    LRunner.FailsOnNoAsserts := False;

    LConsoleLogger := TDUnitXConsoleLogger.Create(True);
    LRunner.AddLogger(LConsoleLogger);

    LNUnitLogger := TDUnitXXMLNUnitFileLogger.Create(
      TDUnitX.Options.XMLOutputFile);
    LRunner.AddLogger(LNUnitLogger);

    LResults := LRunner.Execute;
    if not LResults.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    Write('Done.. press <Enter> key to quit.');
    ReadLn;
    {$ENDIF}
  except
    on E: Exception do
      Writeln(Format('%s: %s', [E.ClassName, E.Message]));
  end;
end.
