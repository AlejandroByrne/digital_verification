class fa_txn extends uvm_sequence_item;
  `uvm_object_utils(fa_txn)

  // Stimulus (randomizable)
  rand logic a_in;
  rand logic b_in;
  rand logic carry_in;

  // Response (filled by the monitor later)
  logic result_out;
  logic carry_out;

  function new(string name = "fa_txn");
    super.new(name);
  endfunction : new
endclass : fa_txn
