# BluePill
Everything needed for BluePill compilation

External dependencies:
  1. Makefile utility:
    https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/download/v2.11-20180428/gnu-mcu-eclipse-build-tools-2.11-20180428-1604-win64.zip
    https://github.com/gnu-mcu-eclipse/windows-build-tools/releases
    FileName: gnu-mcu-eclipse-build-tools-2.11-20180428-1604-win64.zip
    Version: v2.11-20180428

  2. GNU MCU Eclipse ARM Embedded GCC:
    https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v7.3.1-1.2/xpack-arm-none-eabi-gcc-7.3.1-1.2-win32-x64.zip
    https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/
    FileName: gnu-mcu-eclipse-arm-none-eabi-gcc-7.3.1-1.1-20180724-0637-win64.zip
    Version: v7.3.1-1.2
    Remark: It follows the official GNU Arm Embedded Toolchain (https://developer.arm.com/tools-and-software/open-source-software/gnu-toolchain/gnu-rm). Eclipse tools are preferred since it has x64 tools versions.

  3. J-Link:
    Official page
    https://www.segger.com/downloads/jlink/

SW_Collateral:
  4. STM32CubeF1 Firmware
    https://github.com/STMicroelectronics/STM32CubeF1/archive/refs/tags/v1.8.4.zip
    https://github.com/STMicroelectronics/STM32CubeF1/tags
    FileName: en.stm32cubel4.zip
    Version: v1.8.4

File Structure:
.\
  arm-none-eabi-gcc-xpack\ (This is the folder from number 2 above)
  STM32CubeF1\ (This is the folder from number 4 above)
  windows-build-tools-xpack\ (This is the folder from number 1 above)
  Workspace\
  .gitignore
  LICENSE
  README.md
  
Steps for a successful compilation:
Inside Workspace folder, there is a Powershell script
1. Clean any previous binaries/compilation files
BluePill> .\Powershell.ps1 clean
2. Compile
BluePill> .\Powershell.ps1
3. In a new Windows Powershell, run GDB server from J-Link
PS C:\Program Files\SEGGER\JLink> .\JLinkGDBServerCL.exe -if SWD -device STM32F103T8
4. In a new Windows Powershell, connect gdb:
BluePill\arm-none-eabi-gcc-xpack\xPack\ARM Embedded GCC\7.3.1-1.2\bin\arm-none-eabi-gdb.exe
5. In GDB, put the following commands:
target remote localhost:2331
monitor halt
monitor reset 0
file helloworld.elf
load
