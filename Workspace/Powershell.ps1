$StopWatch = [system.diagnostics.stopwatch]::startNew()
$param1=$args[0]
.\Batch.bat $param1
$StopWatch.Elapsed