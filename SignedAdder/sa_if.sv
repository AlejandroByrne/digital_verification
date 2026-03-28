interface sa_if #(parameter int WIDTH = 4) (input logic clk);
  logic [WIDTH-1:0] a_in;
  logic [WIDTH-1:0] b_in;

  logic [WIDTH-1:0] result_out;
  logic [1:0]       flags; // [0] = overflow, [1] = underflow
endinterface : sa_if
