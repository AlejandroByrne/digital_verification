class fp_mult_txn extends uvm_sequence_item;
  `uvm_object_utils(fp_mult_txn)

  // Inputs
  rand logic [P+E-1:0]    x_in;     // input X; x_in[15] is the sign bit
  rand logic [P+E-1:0]    y_in;     // input Y: y_in[15] is the sign bit
  rand logic [1:0]        round_in;  // rounding mode specifier


  logic [P+E-1:0]         p_out;  // output P: p_out[15] is the sign bit
  logic [3:0]             oor_out; // out-of-range indicator vector

  function new(string name="fp_mult_txn");
    super.new(name);
  endfunction: new
endclass: fp_mult_txn
