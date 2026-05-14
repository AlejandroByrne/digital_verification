class my_predictor extends uvm_component;
    `uvm_component_utils(my_predictor)
    `uvm_analysis_imp_decl(_exp)
    `uvm_analysis_imp_decl(_act)

    uvm_analysis_imp #(my_txn, my_predictor) in_ap;
    uvm_analysis_port #(my_txn) exp_ap;
    my_txn exp_q[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        in_ap   = new("in_ap", this);
        // exp_ap  = new("exp_ap", this);
    endfunction //new()

    function void write(my_txn t);
        my_txn exp = new();
        
        exp.copy(t);
        // Expected behavior model
        exp.data = t.data;   // example: pass-through DUT
        exp_ap.write(exp);
        `uvm_info("PRED",
            $sformatf("Predicted Data = %0d", exp.data),
            UVM_LOW);
        exp_q.push_back(exp);
    endfunction
endclass //my_predictor extends uvm_component