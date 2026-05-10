rm obj_dir/test_top
python ../assembly/assembler.py ../assembly/branching.asm -b -o branching
mv branching.bin ../rtl/programs/branching.bin
verilator --binary -j 0 -o test_top --trace ../rtl/top.sv ../rtl/alu.sv ../rtl/data_memory.sv ../rtl/decoder.sv ../rtl/instruction_memory.sv ../rtl/next_pc.sv ../rtl/register_file.sv ../rtl/register_write_mux.sv ../tb/branching_tb.sv
rm obj_dir/*.h
rm obj_dir/*.cpp
rm obj_dir/*.a
rm obj_dir/*.d
rm obj_dir/*.o
rm obj_dir/*.dat
rm obj_dir/*.mk
./obj_dir/test_top