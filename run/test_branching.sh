rm obj_dir/test_branching
python ../assembly/assembler.py ../assembly/branching.asm -b -o branching
mv branching.bin ../rtl/programs/branching.bin
verilator --binary -j 0 -o test_branching --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/branching_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_branching