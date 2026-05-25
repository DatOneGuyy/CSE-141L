rm obj_dir/test_recursion
python ../assembly/assembler.py ../assembly/recursion.asm -b -o recursion
mv recursion.bin ../rtl/programs/recursion.bin
verilator --binary -j 0 -o test_recursion --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/recursion_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_recursion