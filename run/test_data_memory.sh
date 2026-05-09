rm obj_dir/test_data_memory
verilator --binary -j 0 -o test_data_memory --trace ../rtl/data_memory.sv ../tb/data_memory_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_data_memory
