rm obj_dir/test_hamming
python3 ../assembly/assembler.py ../assembly/hamming.asm -b -o hamming
mv hamming.bin ../rtl/programs/hamming.bin
verilator --binary -j 0 -o test_hamming --trace -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND ../rtl/packages/types.sv ../rtl/*.sv ../tb/hamming_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_hamming