rm obj_dir/test_pairs
python3 ../assembly/assembler.py ../assembly/pairs.asm -b -o pairs
mv pairs.bin ../rtl/programs/pairs.bin
verilator --binary -j 0 -o test_pairs -Wno-WIDTHTRUNC --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/pairs_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
rm obj_dir/*.gch
./obj_dir/test_pairs