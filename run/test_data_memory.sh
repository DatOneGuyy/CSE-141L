verilator --binary -j 0 -o test_data_memory --trace --Mdir ../CSE-141L rtl/data_memory.sv tb/data_memory_tb.sv
rm *.h
rm *.cpp
rm *.a
rm *.d
rm *.o
rm *.dat
rm *.mk
./test_data_memory
