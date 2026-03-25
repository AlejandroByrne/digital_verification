interface fp_mult_if(input logic clk);
    import fp_pkg::*;

    logic rst_in_N;
    logic [P+E-1:0] x_in;     // input X; x_in[15] is the sign bit
    logic [P+E-1:0] y_in;     // input Y: y_in[15] is the sign bit
    logic [1:0] round_in;  // rounding mode specifier
    logic start_in;
    logic [P+E-1:0] p_out;  // output P: p_out[15] is the sign bit
    logic [3:0] oor_out; // out-of-range indicator vector
    logic done_out;       // signal that outputs are ready
endinterface: fp_mult_if
