// ============================================================
//  IEEE 754 Float32 Multiplier — Testbench Top
// ============================================================

`include "fp32_pkg.sv"
`include "fp32_if.sv"
`include "fp32_internal_if.sv"

module top;
    import uvm_pkg::*;
    import fp32_pkg::*;

    // ── Clock generation ──
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz (10 ns period)

    // ── Interface ──
    fp32_if dut_if (.clk(clk));
    
    // ── Internal Interface (Peeking) ──
    fp32_internal_if int_if();
    
    // Manual mapping (xsim doesn't always support bind well for deep logic)
    always_comb begin
        int_if.lsb    = dut.core.lsb;
        int_if.guard  = dut.core.guard;
        int_if.round  = dut.core.round_bit;
        int_if.sticky = dut.core.sticky;
    end

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
        uvm_config_db #(virtual fp32_internal_if)::set(null, "*", "fp32_int_vi", int_if);
        run_test(); 
    end

    // ── Waveform dump (opt-in via +DUMP plusarg to avoid huge VCDs) ──
    initial begin
        if ($test$plusargs("DUMP")) begin
            $dumpfile("dump.vcd");
            $dumpvars;
        end
    end

endmodule : top
