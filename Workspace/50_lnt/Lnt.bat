REM Attention
REM Please update the related specific .lnt compiler (example : ..\lint\PICTUS.lnt )

rd /S/Q results
md results

cd ../20_src/
FOR /R %%i IN (*.cpp) DO ..\50_lnt\Lint\Lint-nt.exe -v -u -os(..\50_lnt\results\%%~ni-misra.cpperr) -i../10_inc -i../../STM32CubeF1/Drivers/STM32F1xx_HAL_Driver/Inc -i../../STM32CubeF1/Drivers/CMSIS/Include -i../../STM32CubeF1/Drivers/CMSIS/Device/ST/STM32F1xx/include ..\50_lnt\Lint\lnt\au-misra-9x-CPP.lnt ..\50_lnt\Lint\lnt\general-cpp.lnt ..\50_lnt\Lint\lnt\AUTOSAR.lnt ..\50_lnt\Lint\lnt\AURIX.lnt ..\50_lnt\Project.lnt %%i
FOR /R %%i IN (*.c) DO ..\50_lnt\Lint\Lint-nt.exe -v -u -os(..\50_lnt\results\%%~ni-misra.cerr) -i../10_inc -i../../STM32CubeF1/Drivers/STM32F1xx_HAL_Driver/Inc -i../../STM32CubeF1/Drivers/CMSIS/Include -i../../STM32CubeF1/Drivers/CMSIS/Device/ST/STM32F1xx/include ..\50_lnt\Lint\lnt\au-misra2-9x-C.lnt ..\50_lnt\Lint\lnt\general.lnt ..\50_lnt\Lint\lnt\AUTOSAR.lnt ..\50_lnt\Lint\lnt\AURIX.lnt ..\50_lnt\Project.lnt %%i
cd ..
