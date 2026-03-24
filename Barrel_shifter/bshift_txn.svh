class bshift_txn extends uvm_sequence_item;
  `uvm_object_utils(bshift_txn)

  // Inputs — all values are legal for this DUT; no constraints needed here.
  // Distribution weighting and directed values are the sequences' responsibility.
  rand logic [7:0] x_in;
  rand logic [2:0] s_in;
  rand logic [2:0] op_in;

  // Outputs — NOT rand. Filled in by the monitor after observing the DUT.
  // The scoreboard reads these and compares against predict().
  logic [7:0] y_out;
  logic       zf_out;
  logic       vf_out;

  function new(string name = "bshift_txn");
    super.new(name);
  endfunction: new

endclass: bshift_txn
