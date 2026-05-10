rm obj_dir/test_alu
verilator --binary -j 0 -o test_alu --trace ../rtl/alu.sv ../tb/alu_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_alu