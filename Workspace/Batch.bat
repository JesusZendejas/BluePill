cls
@echo off
set make="..\windows-build-tools-xpack\GNU MCU Eclipse\Build Tools\2.11-20180428-1604\bin\make.exe"
set gdb="..\arm-none-eabi-gcc-xpack\xPack\ARM Embedded GCC\7.3.1-1.2\bin\arm-none-eabi-gdb.exe"

:: Evaluate if NO parameter was passed
if [%1] EQU [] (
  GOTO PARAMETERLESS
)

::Check if user want us to connect to target board
if /I %1% == connect (
  echo Connecting to board...
  %make% connect_board
  GOTO END
)

::Check if user want us to program the target
if /I %1% == program (
  echo Programming File...
  %make% -j program
  GOTO END
)

::Start Debugging session
if /I %1% == debug (
  echo Start Debugging session
  %gdb% --batch --command=GDBScript_CNC.txt
  GOTO END
)

::Check if user want us to clean the target
if /I %1% == clean (
  echo Cleaning target...
  %make% -j clean
  GOTO END
)

::Check if user want us to clean the target
if /I %1% == test (
  echo Test if folder exist...
  %make% test
  GOTO END
)

  
:PARAMETERLESS
::If no parameter was provided, let's compile the code
%make% test
%make% -j
::%make%

:END
