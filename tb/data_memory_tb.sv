module data_memory_tb;

    // Clock and interface signals
    logic clk;
    logic [7:0] address;
    logic [7:0] data_in;
    logic write_en;
    logic [7:0] data_out;

    // Instantiate data memory
    data_memory dut (
        .clk(clk),
        .address(address),
        .data_out(data_out),
        .data_in(data_in),
        .write_en(write_en)
    );

    // 10 time-unit clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump/data_memory_dump.vcd");
        $dumpvars(0, data_memory_tb);

        $display("Starting data_memory Testbench");

        // Load initial contents into the DUT core memory
        $readmemh("tb/data_memory_tb_init.hex", dut.core);

        // Read a few initialized locations
        write_en = 0;
        address = 8'h00;
        #1; $display("READ [0x00] = 0x%02x", data_out);

        address = 8'h01;
        #10; $display("READ [0x01] = 0x%02x", data_out);

        address = 8'h02;
        #10; $display("READ [0x02] = 0x%02x", data_out);

        address = 8'h0A;
        #10; $display("READ [0x0A] = 0x%02x", data_out);

        // Write a new value and verify it updates on the next clock edge
        address = 8'h02;
        data_in = 8'hAA;
        write_en = 1;
        #10;
        write_en = 0;
        address = 8'h02;
        #1; $display("WRITE [0x02] <= 0x%02x, READ BACK = 0x%02x", data_in, data_out);

        // Verify another read location remains unchanged
        address = 8'h03;
        #10; $display("READ [0x03] = 0x%02x", data_out);

        $display("data_memory Testbench Complete");
        $finish;
    end

endmodule
