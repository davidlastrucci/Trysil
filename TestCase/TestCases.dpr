program TestCases;

{$IFDEF CI}
{$UNDEF TESTINSIGHT}
{$ENDIF}
{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
{$IFDEF MSWINDOWS}
   {$DEFINE ADDFASTMM4}
   {$INCLUDE FastMM4Options.inc}
{$ENDIF}

uses
  {$IFDEF MSWINDOWS}
  FastMM4,
  {$ENDIF }
  DUnitX.MemoryLeakMonitor.FastMM4,
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  {$IFNDEF TESTINSIGHT}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  Cases in 'Cases.pas',
  TestServices in 'TestServices.pas';

begin
  { Register Test Fixture
   *** all future tests must be register here
  }
  RegisterTestFixture;

end.
