class my_predictor extends uvm_component;
    `uvm_component_utils(my_predictor)

    uvm_analysis_imp #(my_txn, my_predictor) in_ap;
    // my_txn exp_q[$];
    uvm_tlm_analysis_fifo #(my_txn) exp_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        in_ap = new("in_ap", this);
        exp_fifo = new("exp_fifo", this);
    endfunction //new()

    function void write(my_txn t);
        my_txn exp;

        exp = my_txn::type_id::create("exp");
        exp.copy(t);        // Deep copy

        // Expected model
        exp.data = t.data;  // pass-through DUT model
        exp_fifo.write(exp);

        `uvm_info("PRED",
        $sformatf("Expected written to FIFO: %0d", exp.data),
        UVM_LOW)

    endfunction
endclass //my_predictor extends uvm_component