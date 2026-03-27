module full_adder (
  input logic a_in,
  input logic b_in,
  input logic carry_in,
  output logic result_out,
  output logic carry_out
);
  logic result_1;
  logic carry_1;
  logic carry_2;

  half_adder ha1 (
    .a_in(a_in),
    .b_in(b_in),
    .result_out(result_1),
    .carry_out(carry_1)
  );

  half_adder ha2 (
    .a_in(result_1),
    .b_in(carry_in),
    .result_out(result_out),
    .carry_out(carry_2)
  );

  assign carry_out = carry_1 | carry_2;

endmodule : full_adder
