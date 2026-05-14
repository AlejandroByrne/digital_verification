class my_predictor extends uvm_component;
  `uvm_component_utils(my_predictor)

  // input from driver
  uvm_analysis_imp #(my_txn, my_predictor) in;

  // output to scoreboard
  uvm_analysis_port #(my_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in = new("in", this);
    ap = new("ap", this);
  endfunction

  function void write(my_txn t);
    my_txn exp;

    exp = my_txn::type_id::create("exp");
    exp.copy(t);  
    // exp.set_id_info(t);

    // your current model = pass-through
    // (later you’ll modify this)
    `uvm_info("PRED",
      $sformatf("Expected written to FIFO: %0d", exp.data),
      UVM_LOW)

    ap.write(exp);
  endfunction
endclass
