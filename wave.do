view wave 
wave clipboard store
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/mpu/ce_n 
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/mpu/we_n 
wave create -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps sim:/mpu/oe_n 
wave create -driver freeze -pattern constant -value 0000000000000000 -range 15 0 -starttime 0ps -endtime 1000ps sim:/mpu/address 
WaveExpandAll -1
wave create -driver freeze -pattern constant -value 1000000000000111 -range 15 0 -starttime 0ps -endtime 1000ps sim:/mpu/data 
WaveExpandAll -1
wave create -driver freeze -pattern clock -initialvalue 0 -period 100ps -dutycycle 50 -starttime 0ps -endtime 1000ps sim:/mpu/clk 
wave modify -driver freeze -pattern clock -initialvalue 0 -period 50ps -dutycycle 50 -starttime 0ps -endtime 1000ps Edit:/mpu/clk 
wave modify -driver freeze -pattern constant -value 1 -starttime 275ps -endtime 300ps Edit:/mpu/ce_n 
wave modify -driver freeze -pattern constant -value 1000100000000111 -range 15 0 -starttime 0ps -endtime 1000ps Edit:/mpu/data 
wave modify -driver freeze -pattern constant -value 1000000000000111 -range 15 0 -starttime 0ps -endtime 300ps Edit:/mpu/data 
wave modify -driver freeze -pattern constant -value 1 -starttime 575ps -endtime 600ps Edit:/mpu/ce_n 
wave modify -driver freeze -pattern constant -value 0000000000000000 -range 15 0 -starttime 600ps -endtime 1000ps Edit:/mpu/data 
wave modify -driver freeze -pattern constant -value 1 -starttime 875ps -endtime 900ps Edit:/mpu/ce_n 
wave modify -driver freeze -pattern clock -initialvalue 0 -period 50ps -dutycycle 50 -starttime 0ps -endtime 5000ps Edit:/mpu/clk 
wave modify -driver freeze -pattern constant -value 0000000000000000 -range 15 0 -starttime 900ps -endtime 2000ps Edit:/mpu/address 
wave modify -driver freeze -pattern constant -value 0010000000000000 -range 15 0 -starttime 900ps -endtime 2000ps Edit:/mpu/data 
wave modify -driver freeze -pattern constant -value 0 -starttime 1000ps -endtime 5000ps Edit:/mpu/ce_n 
wave modify -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 5000ps Edit:/mpu/we_n 
wave modify -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 5000ps Edit:/mpu/oe_n 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 5000ps Edit:/mpu/oe_n 
wave modify -driver freeze -pattern constant -value 0100000000000000 -range 15 0 -starttime 1200ps -endtime 2000ps Edit:/mpu/data 
wave modify -driver freeze -pattern constant -value 1 -starttime 1475ps -endtime 1500ps Edit:/mpu/ce_n 
wave modify -driver freeze -pattern constant -value 1010100000000000 -range 15 0 -starttime 1500ps -endtime 2000ps Edit:/mpu/data 
WaveCollapseAll -1
wave clipboard restore
