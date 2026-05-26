rm obj_dir/test_combined
python3 ../assembly/assembler.py ../assembly/combined.asm -b -o combined
mv combined.bin ../rtl/programs/combined.bin
verilator --binary -j 0 -o test_combined -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -fno-localize --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/combined_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
rm obj_dir/*.gch
./obj_dir/test_combined