class my_predictor extends uvm_component;
    `uvm_component_utils(my_predictor)

    // Input from monitor
    uvm_analysis_imp #(my_txn, my_predictor) in_imp;
    // my_txn exp_q[$];
    // uvm_tlm_analysis_fifo #(my_txn) exp_fifo;   // blocking FIFO

    // OUTPUT to scoreboard (EXPECTED path): sends predicted txn
    uvm_analysis_port #(my_txn) ap;
    int exp_drop_count = 0;      // 🔥 bug control

    function new(string name, uvm_component parent);
        super.new(name, parent);
        in_imp = new("in_imp", this);
        ap = new("ap", this);
        // exp_fifo = new("exp_fifo", this);
    endfunction //new()

    // 🔥 Prediction happens HERE
    function void write(my_txn t);
        my_txn exp;

        // // 🔥 ---<BUG-2: Drop exactly ONE expected transaction>----
        // if (exp_drop_count == 0) begin
        //     exp_drop_count++;
        //     `uvm_warning("PRED",
        //         "INTENTIONAL DROP of EXP txn")
        //     return;
        // end

        exp = my_txn::type_id::create("exp");
        exp.copy(t);        // Deep copy

        // Expected model
        // exp.data = t.data;  // pass-through DUT model

        `uvm_info("PRED",
            $sformatf("Expected written to FIFO: %0d", exp.data),
            UVM_LOW)

        ap.write(exp); 
        
        `uvm_info("PRED_ALIGN",
            $sformatf("EXP issued @ %0t data=%0d", $time, exp.data),
            UVM_LOW)       
    endfunction

endclass //my_predictor extends uvm_component