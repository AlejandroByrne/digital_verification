class sa_txn extends uvm_sequence_item;
  `uvm_object_utils(sa_txn)

  // Stimulus (randomizable)
  rand logic [SA_WIDTH-1:0] a_in;
  rand logic [SA_WIDTH-1:0] b_in;

  // Response (filled by the monitor)
  logic [SA_WIDTH-1:0] result_out;
  logic [1:0]          flags; // [0] = overflow, [1] = underflow

  function new(string name = "sa_txn");
    super.new(name);
  endfunction : new
endclass : sa_txn
