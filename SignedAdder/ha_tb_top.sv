// ============================================================
//  Half Adder — Testbench Top
//
//  Instantiates clock, interface, DUT, and kicks off UVM.
// ============================================================

`include "ha_pkg.sv"
`include "ha_if.sv"

module top;
    import uvm_pkg::*;
    import ha_pkg::*;

    // ── Clock generation ──
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz (10 ns period)

    // ── Interface ──
    ha_if dut_if (.clk(clk));

    // ── DUT instantiation ──
    half_adder dut (
        .a_in       (dut_if.a_in),
        .b_in       (dut_if.b_in),
        .result_out (dut_if.result_out),
        .carry_out  (dut_if.carry_out)
    );

    // ── UVM entry point ──
    initial begin
        uvm_config_db #(virtual ha_if)::set(null, "*", "ha_vi", dut_if);
        run_test("");          // test name from +UVM_TESTNAME=
    end

    // ── Waveform dump ──
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule : top
