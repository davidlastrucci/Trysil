program Expressions;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.IOUtils,
  FireDAC.ConsoleUI.Wait,
  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Context,
  Trysil.Data.FireDAC.SQLite,
  Expressions.Model in 'Expressions.Model.pas',
  Expressions.Database in 'Expressions.Database.pas',
  Expressions.Scenarios in 'Expressions.Scenarios.pas';

const
  DatabaseName = 'Expressions.db';

var
  LConnection: TTConnection;
  LContext: TTContext;
  LScenarios: TDemoScenarios;
begin
  ReportMemoryLeaksOnShutdown := True;
  try
    TTFireDACConnectionPool.Instance.Config.Enabled := False;

    if TFile.Exists(DatabaseName) then
      TFile.Delete(DatabaseName);

    TTSQLiteConnection.RegisterConnection('Expressions', DatabaseName);
    LConnection := TTSQLiteConnection.Create('Expressions');
    try
      LContext := TTContext.Create(LConnection);
      try
        TDemoDatabase.Build(LConnection);

        LScenarios := TDemoScenarios.Create(LContext);
        try
          LScenarios.Run;
        finally
          LScenarios.Free;
        end;
      finally
        LContext.Free;
      end;
    finally
      LConnection.Free;
    end;
  except
    on E: Exception do
      Writeln(Format('%s: %s', [E.ClassName, E.Message]));
  end;

  Writeln;
  Write('Press ENTER to exit...');
  Readln;
end.
