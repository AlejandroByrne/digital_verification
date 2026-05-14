class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard);

    uvm_analysis_imp #(my_txn, my_scoreboard) imp;

    function new(string name="my_scoreboard",uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction //new()

    function void write(my_txn ts);
        `uvm_info("SCB", 
            $sformatf("Checking data = %0d", ts.data),
            UVM_MEDIUM)
        
        // Simple pass-through check
        // (Future: compare with expected queue)
        if (ts.data inside {[0:255]}) begin
            `uvm_info("SCB", "Pass", UVM_LOW)
        end else begin
            `uvm_error("SCB", "Fail: Data out of range")
        end

    endfunction
endclass //my_scoreboard extends uvm_component