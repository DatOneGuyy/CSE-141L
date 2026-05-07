verilator --binary -j 0 -o test_alu --trace --Mdir ../CSE-141L rtl/alu.sv tb/alu_tb.sv
rm *.h
rm *.cpp
rm *.a
rm *.d
rm *.o
rm *.dat
rm *.mk
./test_alu