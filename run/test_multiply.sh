rm obj_dir/test_multiply
python3 ../assembly/assembler.py ../assembly/multiply.asm -b -o multiply
mv multiply.bin ../rtl/programs/multiply.bin
verilator --binary -j 0 -o test_multiply -Wno-WIDTHTRUNC --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/multiply_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
rm obj_dir/*.gch
./obj_dir/test_multiply