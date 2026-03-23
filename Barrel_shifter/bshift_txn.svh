class bshift_txn extends uvm_sequence_item;
  `uvm_object_utils(bshift_txn)

  rand logic [7:0] x_in;
  rand logic [2:0] s_in;
  rand logic [2:0] op_in;

  function new(string name = "bshift_txn");
    super.new(name);
  endfunction: new

endclass: bshift_txn
