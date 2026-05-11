rm obj_dir/test_next_pc
verilator --binary -j 0 -o test_next_pc --trace ../rtl/next_pc.sv ../tb/next_pc_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_next_pc