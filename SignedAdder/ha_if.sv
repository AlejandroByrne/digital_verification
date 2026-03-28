// ============================================================
//  Half Adder — Interface
//
//  Combinational DUT, but we use a clock for UVM sequencing.
//  Driver drives: a_in, b_in
//  DUT drives:    result_out, carry_out
// ============================================================

interface ha_if (input logic clk);

    // Stimulus (driven by driver)
    logic a_in;
    logic b_in;

    // Response (driven by DUT)
    logic result_out;
    logic carry_out;

endinterface : ha_if
