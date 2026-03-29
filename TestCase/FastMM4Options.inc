{

  FastMM4Options.inc — TestCase project configuration
  Enables memory leak detection for DUnitX tests via DUnitX.MemoryLeakMonitor.FastMM4

}

{---------------------------Performance options-------------------------------}

{Enable faster fixed-size move routines when upsizing small blocks.}
{$define UseCustomFixedSizeMoveRoutines}

{Enable optimized procedure for moving a memory block of arbitrary size.}
{$define UseCustomVariableSizeMoveRoutines}

{----------------------------Leak detection-----------------------------------}

{Enable memory leak reporting. FastMM will list all leaked blocks on shutdown
 and per-test via DUnitX.MemoryLeakMonitor.FastMM4.}
{$define EnableMemoryLeakReporting}

{When defined, FastMM4 will check for leaked object instances and report them
 with their class name to help identify which test caused the leak.}
{$define CheckUnclearedObjectInstance}

