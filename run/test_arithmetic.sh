rm obj_dir/test_arithmetic
python ../assembly/assembler.py ../assembly/arithmetic.asm -b -o arithmetic
mv arithmetic.bin ../rtl/programs/arithmetic.bin
verilator --binary -j 0 -o test_arithmetic --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/arithmetic_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
rm obj_dir/*.gch
./obj_dir/test_arithmetic