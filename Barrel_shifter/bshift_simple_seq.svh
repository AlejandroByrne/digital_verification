class bshift_simple_seq extends uvm_sequence #(bshift_txn);
  `uvm_object_utils(bshift_simple_seq)

  function new(string name = "bshift_simple_seq");
    super.new(name);
  endfunction: new

  task body();
    bshift_txn txn;
    txn = bshift_txn::type_id::create("txn");
    start_item(txn);
    txn.x_in  = 8'b11110101;
    txn.s_in  = 3'b011;
    txn.op_in = 3'b100; // shift left logical
    finish_item(txn);
  endtask: body

endclass: bshift_simple_seq
