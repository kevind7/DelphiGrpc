program TestService;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  SysUtils,
  DUnitTestRunner,
  TextTestRunner,
  TestUTestService.client in 'TestUTestService.client.pas';

{$R *.RES}

begin
  // You'll be needing to run TestTestService\gRPCService.NET\bin\Debug\net5.0\gRPCService.NET.exe
  // It's a server compatible with the requests being made by this test.
  TextTestRunner.RunRegisteredTests(rxbContinue);
  ReadLn;
end.
