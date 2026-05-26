rm obj_dir/test_stack
python3 ../assembly/assembler.py ../assembly/stack.asm -b -o stack
mv stack.bin ../rtl/programs/stack.bin
verilator --binary -j 0 -o test_stack --trace ../rtl/packages/types.sv ../rtl/*.sv ../tb/stack_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
rm obj_dir/*.gch
./obj_dir/test_stack