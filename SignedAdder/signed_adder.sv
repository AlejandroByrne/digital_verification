module signed_adder #(parameter int WIDTH = 4) (
  input logic [WIDTH-1:0]       a_in,
  input logic [WIDTH-1:0]       b_in,
  output logic [WIDTH-1:0]      result_out,
  output logic [1:0]            flags // first bit is overflow, second is underflow
);

  logic [WIDTH-1:0] carries; // For linking the carries over to the next full adder
  // First adder is half adder due to no carry in
  half_adder ha (
    .a_in(a_in[0]),
    .b_in(b_in[0]),
    .result_out(result_out[0]),
    .carry_out(carries[0])
  );

  genvar i; // compile time variable, when the loop unroll happens. int is runtime variable
  generate
    // The cascade of full adders
    for (i = 1; i < WIDTH; i++) begin : fa_chain
      full_adder fa (
        .a_in(a_in[i]),
        .b_in(b_in[i]),
        .carry_in(carries[i-1]),
        .result_out(result_out[i]),
        .carry_out(carries[i])
      );
    end
  endgenerate

  // Overflow / underflow logic
  assign flags[0] = !a_in[WIDTH-1] & !b_in[WIDTH-1] & result_out[WIDTH-1]; // overflow flag
  assign flags[1] = a_in[WIDTH-1] & b_in[WIDTH-1] & !result_out[WIDTH-1]; // underflow flag

endmodule : signed_adder
