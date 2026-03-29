unit TestServices;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Web.ReqMulti,
  Web.WebReq,
  Web.WebBroker,
  IdHTTPWebBrokerBridge,

  {$IFDEF MSWINDOWS}
    VCL.Forms,
    DUnitX.Loggers.GUI.VCL,
  {$ENDIF}
  {$IFDEF TESTINSIGHT}
    TestInsight.DUnitX,
  {$ELSE}
    DUnitX.Loggers.Console,
    DUnitX.Loggers.Xml.NUnit,
  {$ENDIF}

  DUnitX.TestFramework;

  procedure CommandLine;
  procedure RegisterTestFixture;

var
  runner: ITestRunner;
  results: IRunResults;
  nunitLogger: ITestLogger;
  Logger: TDUnitXConsoleLogger;

implementation

uses
  Cases;

procedure CommandLine;
begin
   try
    // Check command line options, will exit if invalid
    // TDUnitX.CheckCommandLine;
    // Create the test runner
    runner := TDUnitX.CreateRunner;
    // Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := true;

    // When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    // tell the runner how we will log things
    // Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      Logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(Logger);
    end;
    // Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    // Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
      // We don't want this happening when running under CI.
      if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
      begin
        System.Write('Done.. press <Enter> key to quit.');
        System.Readln;
      end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end;

procedure RegisterTestFixture;
begin

  TDUnitX.RegisterTestFixture(TTestNullable);
  TDUnitX.RegisterTestFixture(TTestFilterPaging);
  TDUnitX.RegisterTestFixture(TTestFilter);
  TDUnitX.RegisterTestFixture(TTestValidationErrors);
  TDUnitX.RegisterTestFixture(TTestHashList);
  TDUnitX.RegisterTestFixture(TTestObjectList);
  TDUnitX.RegisterTestFixture(TTestExceptions);
  TDUnitX.RegisterTestFixture(TTestMapper);
  TDUnitX.RegisterTestFixture(TTestValidationRequired);
  TDUnitX.RegisterTestFixture(TTestValidationLength);
  TDUnitX.RegisterTestFixture(TTestValidationValue);
  TDUnitX.RegisterTestFixture(TTestValidationRegex);

  {$IFDEF TESTINSIGHT}
    TestInsight.DUnitX.RunRegisteredTests;
  {$ELSE}
    {$IFDEF MSWINDOWS}
      // modalita' visuale dei test per debug, in jenkins verra' eseguito tutto in Commandline
      {$IFNDEF CI}
        Application.Initialize;
        Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
        Application.Run;
      {$ELSE}
        CommandLine;
      {$ENDIF}

    {$ELSE}
      // puo essere Linux / iOS
      CommandLine;
    {$ENDIF}
  {$ENDIF}
end;

end.
