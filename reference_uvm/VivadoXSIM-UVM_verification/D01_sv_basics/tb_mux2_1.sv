// Basic testbench to verify environment setup
module tb_mux2;

    // Testbench signals
    logic a;
    logic b;
    logic sel;
    logic y;

    // Instantiate DUT
    mux2 dut (
        .a   (a),
        .b   (b),
        .sel (sel),
        .y   (y)
    );

    // Initial block: apply stimulus
    initial begin
        // Create waveform dump
        $dumpfile("mux2.vcd");
        $dumpvars(0, tb_mux2);

        // Apply test vectors
        a = 0; b = 0; sel = 0; #10;
        a = 0; b = 1; sel = 0; #10;
        a = 1; b = 0; sel = 1; #10;
        a = 1; b = 1; sel = 1; #10;

        // End simulation
        $display("Environment check PASSED");
        $finish;
    end

endmodule
