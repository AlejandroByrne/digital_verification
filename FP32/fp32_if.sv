// ============================================================
//  IEEE 754 Float32 Multiplier — Interface
//
//  Clean valid_in / valid_out handshake.
//  Driver drives: a_in, b_in, rnd_mode, valid_in, rst_n
//  DUT drives:    result_out, flags_out, valid_out
// ============================================================

interface fp32_if (input logic clk);

    // Control
    logic        rst_n;
    logic        valid_in;
    logic        valid_out;

    // Stimulus (driven by driver)
    logic [31:0] a_in;
    logic [31:0] b_in;
    logic [1:0]  rnd_mode;

    // Response (driven by DUT)
    logic [31:0] result_out;
    logic [4:0]  flags_out;     // {NV, DZ, OF, UF, NX}

endinterface : fp32_if
