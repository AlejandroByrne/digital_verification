// ============================================================
//  IEEE 754 Float32 Multiplier — Testbench Top
//
//  Instantiates clock, interface, DUT, and kicks off UVM.
// ============================================================

`include "fp32_pkg.sv"
`include "fp32_if.sv"

module top;
    import uvm_pkg::*;
    import fp32_pkg::*;

    // ── Clock generation ──
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz (10 ns period)

    // ── Interface ──
    fp32_if dut_if (.clk(clk));

    // ── DUT instantiation ──
    fp32_mult dut (
        .clk          (clk),
        .rst_n        (dut_if.rst_n),
        .a_in         (dut_if.a_in),
        .b_in         (dut_if.b_in),
        .rnd_mode_in  (dut_if.rnd_mode),
        .valid_in     (dut_if.valid_in),
        .result_out   (dut_if.result_out),
        .flags_out    (dut_if.flags_out),
        .valid_out    (dut_if.valid_out)
    );

    // ── Reset sequence ──
    initial begin
        dut_if.rst_n = 1'b0;
        #25;                   // hold reset for 2.5 clock cycles
        dut_if.rst_n = 1'b1;
    end

    // ── UVM entry point ──
    initial begin
        uvm_config_db #(virtual fp32_if)::set(null, "*", "fp32_vi", dut_if);
        run_test("");          // test name from +UVM_TESTNAME=
    end

    // ── Waveform dump ──
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule : top
