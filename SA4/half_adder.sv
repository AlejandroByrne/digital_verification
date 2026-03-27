module half_adder(
  input logic         a_in,
  input logic         b_in,
  output logic        result_out,
  output logic        carry_out
);

  always_comb begin : block
    result_out = a_in ^ b_in;
    carry_out = a_in & b_in;
  end

endmodule: half_adder
